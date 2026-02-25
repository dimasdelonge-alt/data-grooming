import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class SecurityPreferences {
  static const String _keyAppLockEnabled = 'app_lock_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyPinHash = 'pin_hash';

  final SharedPreferences _prefs;

  SecurityPreferences(this._prefs);

  // ─── App Lock ──────────────────────────────────────────────────────

  bool get isAppLockEnabled => _prefs.getBool(_keyAppLockEnabled) ?? false;
  set isAppLockEnabled(bool value) =>
      _prefs.setBool(_keyAppLockEnabled, value);

  // ─── Biometric ─────────────────────────────────────────────────────

  bool get isBiometricEnabled =>
      _prefs.getBool(_keyBiometricEnabled) ?? false;
  set isBiometricEnabled(bool value) =>
      _prefs.setBool(_keyBiometricEnabled, value);

  // ─── PIN ───────────────────────────────────────────────────────────

  void savePin(String pin) {
    final hash = sha256.convert(utf8.encode(pin)).toString();
    _prefs.setString(_keyPinHash, hash);
  }

  bool validatePin(String pin) {
    final storedHash = _prefs.getString(_keyPinHash);
    if (storedHash == null) return false;
    final inputHash = sha256.convert(utf8.encode(pin)).toString();
    return storedHash == inputHash;
  }

  bool hasPin() {
    return _prefs.getString(_keyPinHash) != null;
  }
}
