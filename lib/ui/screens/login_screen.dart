import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repository/firebase_repository.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../util/settings_preferences.dart';

class LoginScreen extends StatefulWidget {
  final SettingsPreferences settingsPrefs;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.settingsPrefs,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _shopIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firebaseRepo = FirebaseRepository();

  bool _isRegisterMode = false;
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _handleLogin() async {
    final shopId = _shopIdController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (shopId.isEmpty || password.isEmpty) {
      setState(() => _error = 'Shop ID dan Password harus diisi');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final storedKey = await _firebaseRepo.getSecretKey(shopId);
      if (storedKey == null) {
        setState(() { _error = 'Shop ID tidak ditemukan'; _isLoading = false; });
        return;
      }

      final hashedInput = _hashPassword(password);
      if (storedKey == hashedInput) {
        // Cek Limit Device
        final subStatus = await _firebaseRepo.checkSubscriptionStatus(shopId);
        if (widget.settingsPrefs.deviceId.isEmpty) {
          widget.settingsPrefs.deviceId = "DEV-${DateTime.now().millisecondsSinceEpoch}";
        }
        
        final deviceName = kIsWeb ? 'Web Browser' : (Platform.isAndroid ? 'Android Device' : 'iOS/Other Device');
        final isAllowed = await _firebaseRepo.registerDevice(
          shopId, 
          widget.settingsPrefs.deviceId, 
          deviceName, 
          subStatus.maxDevices
        );

        if (!isAllowed) {
          setState(() { 
            _error = 'Login ditolak: Limit perangkat tercapai (${subStatus.maxDevices} device).\nSilakan upgrade ke PRO untuk akses lebih banyak.'; 
            _isLoading = false; 
          });
          return;
        }

        // Login berhasil
        widget.settingsPrefs.storeId = shopId;
        widget.settingsPrefs.syncSecretKey = hashedInput;
        widget.settingsPrefs.isCloudSyncEnabled = true;
        widget.settingsPrefs.userPlan = subStatus.plan;
        widget.settingsPrefs.maxDevices = subStatus.maxDevices;
        widget.settingsPrefs.validUntil = subStatus.validUntil;
        widget.onLoginSuccess();
      } else {
        setState(() { _error = 'Password salah'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Gagal terhubung ke server'; _isLoading = false; });
    }
  }

  Future<void> _handleRegister() async {
    final shopId = _shopIdController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (shopId.isEmpty || password.isEmpty) {
      setState(() => _error = 'Semua field harus diisi');
      return;
    }
    if (shopId.contains(' ') || shopId.contains('/')) {
      setState(() => _error = 'Shop ID tidak boleh mengandung spasi atau /');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Password tidak cocok');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      // Check if shop ID already exists
      final existing = await _firebaseRepo.getSecretKey(shopId);
      if (existing != null) {
        setState(() { _error = 'Shop ID "$shopId" sudah dipakai, coba yang lain'; _isLoading = false; });
        return;
      }

      // Create account
      final hashedPassword = _hashPassword(password);
      await _firebaseRepo.setSecretKey(shopId, hashedPassword);

      // Manage Subscriptions & Devices for new accounts (Starter limit 1)
      if (widget.settingsPrefs.deviceId.isEmpty) {
        widget.settingsPrefs.deviceId = "DEV-${DateTime.now().millisecondsSinceEpoch}";
      }
      final deviceName = kIsWeb ? 'Web Browser' : (Platform.isAndroid ? 'Android Device' : 'iOS/Other Device');
      await _firebaseRepo.registerDevice(
        shopId, 
        widget.settingsPrefs.deviceId, 
        deviceName, 
        1 // Default starter limit
      );

      // Save locally
      widget.settingsPrefs.storeId = shopId;
      widget.settingsPrefs.syncSecretKey = hashedPassword;
      widget.settingsPrefs.isCloudSyncEnabled = true;
      widget.settingsPrefs.userPlan = 'starter';
      widget.settingsPrefs.maxDevices = 1;
      widget.onLoginSuccess();
    } catch (e) {
      setState(() { _error = 'Gagal membuat akun: $e'; _isLoading = false; });
    }
  }

  void _openWhatsApp() async {
    final shopId = _shopIdController.text.trim();
    final message = shopId.isNotEmpty
        ? 'Halo, saya lupa password SmartGroomer. Shop ID saya: $shopId'
        : 'Halo, saya lupa password SmartGroomer.';
    final url = Uri.parse('https://wa.me/6282137895794?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _shopIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(Icons.pets_rounded, size: 64, color: primaryColor),
                const SizedBox(height: 12),
                Text(
                  'Data Groomer App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isRegisterMode ? 'Buat Akun Baru' : 'Masuk ke Akun',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Shop ID
                        TextField(
                          controller: _shopIdController,
                          decoration: InputDecoration(
                            labelText: 'Shop ID',
                            hintText: 'cth: jeni_cathouse',
                            prefixIcon: const Icon(Icons.store_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          textInputAction: _isRegisterMode ? TextInputAction.next : TextInputAction.done,
                          onSubmitted: _isRegisterMode ? null : (_) => _handleLogin(),
                        ),

                        // Confirm Password (register mode only)
                        if (_isRegisterMode) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: 'Ulangi Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleRegister(),
                          ),
                        ],

                        // Error message
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _isLoading ? null : (_isRegisterMode ? _handleRegister : _handleLogin),
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(
                                    _isRegisterMode ? 'Daftar' : 'Masuk',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Toggle login/register
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegisterMode = !_isRegisterMode;
                      _error = null;
                      _confirmPasswordController.clear();
                    });
                  },
                  child: Text(
                    _isRegisterMode ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Buat Baru',
                    style: TextStyle(color: primaryColor),
                  ),
                ),

                // Forgot password
                if (!_isRegisterMode) ...[
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: const Text('Lupa Password? Hubungi Admin'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
