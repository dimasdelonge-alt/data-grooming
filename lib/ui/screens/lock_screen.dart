import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import '../../util/security_preferences.dart';

// Conditional import for biometric auth
import 'lock_screen_native.dart' if (dart.library.js_interop) 'lock_screen_web.dart' as bio;

class LockScreen extends StatefulWidget {
  final SecurityPreferences securityPrefs;
  final VoidCallback onUnlock;

  const LockScreen({
    super.key,
    required this.securityPrefs,
    required this.onUnlock,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  bool _isError = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    if (widget.securityPrefs.isBiometricEnabled) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() => _isAuthenticating = true);
      final authenticated = await bio.authenticate();
      setState(() => _isAuthenticating = false);
      if (authenticated) {
        widget.onUnlock();
      }
    } catch (e) {
      debugPrint("Biometric error: $e");
      setState(() => _isAuthenticating = false);
    }
  }

  void _handleKeyPress(String key) {
    if (_isAuthenticating) return;

    setState(() {
      if (key == 'DEL') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
      } else if (key == 'BIO') {
        _authenticateWithBiometrics();
      } else {
        if (_pin.length < 6) {
          _pin += key;
          if (_pin.length == 6) {
            _validatePin();
          }
        }
      }
    });
  }

  void _validatePin() {
    if (widget.securityPrefs.validatePin(_pin)) {
      widget.onUnlock();
    } else {
      setState(() {
        _isError = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _pin = '';
            _isError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.lock_rounded, size: 64, color: primaryColor),
            const SizedBox(height: 24),
            Text(
              _isError ? 'PIN Salah' : 'Masukkan PIN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isError ? Colors.red : null,
              ),
            ),
            const SizedBox(height: 32),
            
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? primaryColor
                        : (isDark ? Colors.grey[800] : Colors.grey[300]),
                  ),
                );
              }),
            ),
            
            const Spacer(),
            
            // NumPad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  _buildNumRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildNumRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildNumRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  _buildNumRow(['BIO', '0', 'DEL']),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _buildKey(k)).toList(),
    );
  }

  Widget _buildKey(String key) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (key == 'BIO' && (!widget.securityPrefs.isBiometricEnabled || kIsWeb)) {
      return const SizedBox(width: 72, height: 72);
    }

    return Material(
      color: isDark ? Colors.grey[900] : Colors.grey[100],
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleKeyPress(key),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(
            child: _buildKeyContent(key),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyContent(String key) {
    if (key == 'DEL') return const Icon(Icons.backspace_rounded);
    if (key == 'BIO') return const Icon(Icons.fingerprint_rounded, size: 32);
    return Text(
      key,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
