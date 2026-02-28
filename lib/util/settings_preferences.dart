import 'package:shared_preferences/shared_preferences.dart';

class SettingsPreferences {
  static const String _keyBusinessName = 'business_name';
  static const String _keyBusinessInfo = 'business_info';
  static const String _keyTheme = 'theme';
  static const String _keyStoreId = 'store_id';
  static const String _keyCloudSync = 'cloud_sync_enabled';
  static const String _keySyncSecretKey = 'sync_secret_key';
  static const String _keyLogoPath = 'logo_path';
  static const String _keyUserPlan = 'user_plan';
  static const String _keyMaxDevices = 'max_devices';
  static const String _keyDeviceId = 'device_id';
  static const String _keyBusinessAddress = 'business_address';
  static const String _keyValidUntil = 'valid_until';
  static const String _keyReminderHour = 'reminder_hour';
  static const String _keyReminderMinute = 'reminder_minute';
  static const String _keyBookingReminderEnabled = 'booking_reminder_enabled';
  static const String _keyLastNotificationCheck = 'last_notification_check';
  static const String _keyLanguage = 'language_code';

  final SharedPreferences _prefs;

  SettingsPreferences(this._prefs);

  // ─── Business Name ─────────────────────────────────────────────────

  String get businessName => _prefs.getString(_keyBusinessName) ?? '';
  set businessName(String value) => _prefs.setString(_keyBusinessName, value);

  // ─── Business Info ─────────────────────────────────────────────────

  String get businessInfo => _prefs.getString(_keyBusinessInfo) ?? '';
  set businessInfo(String value) => _prefs.setString(_keyBusinessInfo, value);

  // ─── Theme (0 = System, 1 = Light, 2 = Dark) ──────────────────────

  int get theme => _prefs.getInt(_keyTheme) ?? 0;
  set theme(int value) => _prefs.setInt(_keyTheme, value);

  // ─── Store ID ──────────────────────────────────────────────────────

  String get storeId => _prefs.getString(_keyStoreId) ?? '';
  set storeId(String value) => _prefs.setString(_keyStoreId, value);

  // ─── Cloud Sync ────────────────────────────────────────────────────

  bool get isCloudSyncEnabled => _prefs.getBool(_keyCloudSync) ?? false;
  set isCloudSyncEnabled(bool value) => _prefs.setBool(_keyCloudSync, value);

  // ─── Sync Secret Key ──────────────────────────────────────────────

  String get syncSecretKey => _prefs.getString(_keySyncSecretKey) ?? '';
  set syncSecretKey(String value) =>
      _prefs.setString(_keySyncSecretKey, value);

  // ─── Logo Path ─────────────────────────────────────────────────────

  String get logoPath => _prefs.getString(_keyLogoPath) ?? '';
  set logoPath(String value) => _prefs.setString(_keyLogoPath, value);

  // ─── User Plan ─────────────────────────────────────────────────────

  String get userPlan => _prefs.getString(_keyUserPlan) ?? '';
  set userPlan(String value) => _prefs.setString(_keyUserPlan, value);

  // ─── Max Devices ───────────────────────────────────────────────────

  int get maxDevices => _prefs.getInt(_keyMaxDevices) ?? 1;
  set maxDevices(int value) => _prefs.setInt(_keyMaxDevices, value);

  // ─── Device ID ─────────────────────────────────────────────────────

  String get deviceId => _prefs.getString(_keyDeviceId) ?? '';
  set deviceId(String value) => _prefs.setString(_keyDeviceId, value);

  // ─── Business Address ──────────────────────────────────────────────

  String get businessAddress => _prefs.getString(_keyBusinessAddress) ?? '';
  set businessAddress(String value) => _prefs.setString(_keyBusinessAddress, value);

  // ─── Valid Until (subscription expiry millis) ──────────────────────

  int get validUntil => _prefs.getInt(_keyValidUntil) ?? 0;
  set validUntil(int value) => _prefs.setInt(_keyValidUntil, value);

  // ─── Booking Reminder ──────────────────────────────────────────────

  bool get isBookingReminderEnabled => _prefs.getBool(_keyBookingReminderEnabled) ?? false;
  set isBookingReminderEnabled(bool value) => _prefs.setBool(_keyBookingReminderEnabled, value);

  int get reminderHour => _prefs.getInt(_keyReminderHour) ?? 8;
  set reminderHour(int value) => _prefs.setInt(_keyReminderHour, value);

  int get reminderMinute => _prefs.getInt(_keyReminderMinute) ?? 0;
  set reminderMinute(int value) => _prefs.setInt(_keyReminderMinute, value);

  // ─── Last Notification Check ───────────────────────────────────────

  int get lastNotificationCheck => _prefs.getInt(_keyLastNotificationCheck) ?? 0;
  set lastNotificationCheck(int value) => _prefs.setInt(_keyLastNotificationCheck, value);

  // ─── Language ──────────────────────────────────────────────────────

  String get language => _prefs.getString(_keyLanguage) ?? 'id';
  set language(String value) => _prefs.setString(_keyLanguage, value);
}
