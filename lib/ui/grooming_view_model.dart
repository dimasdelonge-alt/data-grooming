import 'package:flutter/material.dart';
import 'dart:async';
import '../data/repository/grooming_repository.dart';
import '../data/repository/firebase_repository.dart';
import '../data/entity/cat.dart';
import '../data/entity/session.dart';
import '../data/entity/session_photo.dart';
import '../data/entity/grooming_service.dart';
import '../data/entity/chip_option.dart';
import '../data/entity/booking.dart';
import '../data/entity/cat_last_session.dart';
import '../data/model/cloud_sync_data.dart';
import '../data/model/backup_data.dart';
import '../util/date_utils.dart' as app_date;
import '../util/settings_preferences.dart';
import '../util/offline_backup_manager.dart';
import '../util/notification_service.dart';
import '../data/repository/weather_repository.dart';
import '../data/entity/hotel_entities.dart';

class GroomingViewModel extends ChangeNotifier {
  final GroomingRepository _repository;
  final FirebaseRepository _firebaseRepo;
  final SettingsPreferences _settingsPrefs;

  GroomingViewModel(this._repository, this._firebaseRepo, this._settingsPrefs) {
    _init();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<Cat> _allCats = [];
  List<Cat> _filteredCats = [];
  List<Session> _recentSessions = [];
  List<Session> _allSessions = [];
  List<Session> _activeSessions = [];
  List<GroomingService> _services = [];
  List<ChipOption> _findingOptions = [];
  List<ChipOption> _treatmentOptions = [];
  List<ReminderItem> _marketingReminders = [];
  List<CatLastSession> _lastSessionDates = [];
  List<Booking> _bookings = [];

  String _searchQuery = '';
  double _currentMonthIncome = 0.0;
  double _currentMonthExpense = 0.0;
  int _currentMonthSessionCount = 0;
  bool _showArchivedCats = false;
  bool _isProcessingImage = false;
  bool _isLoading = false;
  String? _processedImagePath;
  String? _weatherIconUrl;
  
  // Stream Subscriptions
  StreamSubscription? _sessionSub;
  StreamSubscription? _bookingSub;
  StreamSubscription? _expenseSub;
  StreamSubscription? _restoreSub;

  // ═══════════════════════════════════════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  bool get showArchivedCats => _showArchivedCats;

  void toggleShowArchivedCats() {
    _showArchivedCats = !_showArchivedCats;
    _applySearchFilter();
    notifyListeners();
  }

  String get businessName => _settingsPrefs.businessName;
  String get businessPhone => _settingsPrefs.businessInfo; // businessInfo stores phone
  bool get isProcessingImage => _isProcessingImage;
  bool get isLoading => _isLoading;
  String? get weatherIconUrl => _weatherIconUrl;

  ThemeMode get themeMode {
    switch (_settingsPrefs.theme) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setTheme(int mode) {
    _settingsPrefs.theme = mode;
    notifyListeners();
  }

  List<Cat> get cats => _filteredCats;
  List<Cat> get allCats => _allCats;
  List<Session> get recentSessions => _recentSessions;
  List<Session> get allSessions => _allSessions;
  List<Session> get activeSessions => _activeSessions;
  List<GroomingService> get services => _services;
  List<ChipOption> get findingOptions => _findingOptions;
  List<ChipOption> get treatmentOptions => _treatmentOptions;
  List<ReminderItem> get marketingReminders => _marketingReminders;
  List<Booking> get bookings => _bookings;
  List<Booking> get upcomingBookings => _bookings
      .where((b) => b.status != 'CANCELLED' && b.status != 'COMPLETED')
      .toList()
    ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));

  String get searchQuery => _searchQuery;
  double get currentMonthIncome => _currentMonthIncome;
  double get currentMonthExpense => _currentMonthExpense;
  double get currentMonthNetProfit => _currentMonthIncome - _currentMonthExpense;
  int get currentMonthSessionCount => _currentMonthSessionCount;
  String get currentMonthName => app_date.getCurrentMonthName();
  SettingsPreferences get settingsPrefs => _settingsPrefs;
  String get currentShopId => _settingsPrefs.storeId;
  String get currentSecretKey => _settingsPrefs.syncSecretKey;
  String get userPlan => _settingsPrefs.userPlan;
  int get validUntil => _settingsPrefs.validUntil;
  int get maxDevices => _settingsPrefs.maxDevices;
  String get deviceId => _settingsPrefs.deviceId;
  String get businessAddress => _settingsPrefs.businessAddress;
  String get logoPath => _settingsPrefs.logoPath;
  bool get isBookingReminderEnabled => _settingsPrefs.isBookingReminderEnabled;
  int get reminderHour => _settingsPrefs.reminderHour;
  int get reminderMinute => _settingsPrefs.reminderMinute;
  int get lastNotificationCheck => _settingsPrefs.lastNotificationCheck;

  void markNotificationsAsRead() {
    _settingsPrefs.lastNotificationCheck = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  String? get processedImagePath => _processedImagePath;

  List<OwnerInfo> get owners {
    final map = <String, OwnerInfo>{};
    for (final cat in _allCats) {
      map.putIfAbsent(
        cat.ownerPhone,
        () => OwnerInfo(name: cat.ownerName, phone: cat.ownerPhone),
      );
    }
    final list = map.values.toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKUP & SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> refreshSubscription() async {
    if (_settingsPrefs.storeId.isEmpty) return;
    try {
      final status = await _firebaseRepo.checkSubscriptionStatus(_settingsPrefs.storeId);
      _settingsPrefs.userPlan = status.plan;
      _settingsPrefs.maxDevices = status.maxDevices;
      _settingsPrefs.validUntil = status.validUntil;
      notifyListeners();
    } catch (e) {
      debugPrint('refreshSubscription error: $e');
    }
  }

  Future<void> updateBusinessInfo(String name, String phone, {String? address, String? storeId}) async {
    _settingsPrefs.businessName = name;
    _settingsPrefs.businessInfo = phone;
    if (address != null) _settingsPrefs.businessAddress = address;
    if (storeId != null) _settingsPrefs.storeId = storeId;
    notifyListeners();
  }

  Future<void> updateLogo(String path) async {
    _settingsPrefs.logoPath = path;
    notifyListeners();
  }

  Future<bool> connectShop(String shopId, String secretKey) async {
    _isLoading = true;
    notifyListeners();
    try {
      final validKey = await _firebaseRepo.getSecretKey(shopId);
      if (validKey != null && validKey == secretKey) {
        _settingsPrefs.storeId = shopId;
        _settingsPrefs.syncSecretKey = secretKey;
        _settingsPrefs.isCloudSyncEnabled = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('connectShop error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnectShop() async {
    _settingsPrefs.storeId = '';
    _settingsPrefs.syncSecretKey = '';
    _settingsPrefs.isCloudSyncEnabled = false;
    notifyListeners();
  }

  Future<void> backupData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.uploadAllDataToCloud(_settingsPrefs.businessName, _settingsPrefs.businessInfo);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createNewShop(String shopName, {String? manualId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Use manual ID if provided, otherwise generate random
      final shopId = (manualId != null && manualId.isNotEmpty)
          ? manualId
          : 'SHOP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      
      // Generate Key
      final secretKey = _generateRandomKey(6);

      // Set to Firebase
      debugPrint('Creating shop: $shopId with key: $secretKey');
      await _firebaseRepo.setSecretKey(shopId, secretKey);
      await _firebaseRepo.syncShopIdentity(shopId, shopName, _settingsPrefs.businessInfo, _settingsPrefs.businessAddress);

      // Save Local
      _settingsPrefs.storeId = shopId;
      _settingsPrefs.syncSecretKey = secretKey;
      _settingsPrefs.isCloudSyncEnabled = true;
      _settingsPrefs.businessName = shopName;

      // Initial Upload
      await _repository.uploadAllDataToCloud(shopName, _settingsPrefs.businessInfo);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('createNewShop error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateRandomKey(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Exclude ambiguous chars
    final now = DateTime.now();
    return List.generate(length, (index) {
      return chars[(now.microsecondsSinceEpoch + index) % chars.length];
    }).join();
  }

  Future<bool> restoreData() async {
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('Starting restoreData...');
      await _repository.fullRestoreFromCloud();
      debugPrint('Restore finished. Reloading data...');
      _init(); // Reload all data
      debugPrint('Data reloaded.');
      return true;
    } catch (e) {
      debugPrint('restoreData FATAL error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> backupOffline() async {
    _isLoading = true;
    notifyListeners();
    try {
      final zipPath = await _repository.backupOffline();
      if (zipPath != null) {
        await OfflineBackupManager().shareBackup(zipPath);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreOffline() async {
    final zipPath = await OfflineBackupManager().pickBackupFile();
    if (zipPath == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.restoreOffline(zipPath);
      if (success) {
        _init(); // Reload all data
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  void _init() {
    _loadCats();
    _loadSessions();
    _loadServices();
    _loadBookings();
    _loadChipOptions();
    _loadDashboardStats();
    _loadReminders();
    _cleanupOldSessions();
    _fetchWeather();

    // Set up reactive listeners
    _sessionSub = _repository.onSessionChanged.listen((_) => _loadDashboardStats());
    _bookingSub = _repository.onHotelBookingChanged.listen((_) => _loadDashboardStats());
    _expenseSub = _repository.onExpenseChanged.listen((_) => _loadDashboardStats());
    _restoreSub = _repository.onDataRestored.listen((_) => refreshAll());
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _bookingSub?.cancel();
    _expenseSub?.cancel();
    _restoreSub?.cancel();
    super.dispose();
  }

  Future<void> refreshAll() async {
    _loadCats();
    _loadSessions();
    _loadServices();
    _loadDashboardStats();
    _loadReminders();
    _fetchWeather();
  }

  void refreshDashboardStats() {
    _loadDashboardStats();
  }

  void _fetchWeather() async {
    final repo = WeatherRepository();
    final url = await repo.getCurrentWeatherIcon();
    if (url != null) {
      _weatherIconUrl = url;
      notifyListeners();
    }
  }

  void _loadCats() {
    _repository.getAllCats().listen((cats) {
      _allCats = cats;
      _applySearchFilter();
      _computeReminders();
      notifyListeners();
    });
  }

  void _loadSessions() {
    _repository.getRecentSessions().listen((sessions) {
      _recentSessions = sessions;
      notifyListeners();
    });
    _repository.getAllSessions().listen((sessions) {
      _allSessions = sessions;
      notifyListeners();
    });
    _repository.getActiveSessions().listen((sessions) {
      _activeSessions = sessions;
      notifyListeners();
    });
  }

  void _loadServices() {
    _repository.getAllServices().listen((services) {
      _services = services;
      notifyListeners();
    });
  }

  void _loadChipOptions() {
    _repository.getOptionsByCategory('finding').listen((options) {
      _findingOptions = options;
      notifyListeners();
    });
    _repository.getOptionsByCategory('treatment').listen((options) {
      _treatmentOptions = options;
      notifyListeners();
    });
  }

  void _loadDashboardStats() {
    final startOfMonth = app_date.getStartOfCurrentMonth();
    final endOfMonth = app_date.getEndOfCurrentMonth();

    _repository.getCombinedIncomeByDateRange(startOfMonth, endOfMonth).listen((income) {
      _currentMonthIncome = income ?? 0.0;
      notifyListeners();
    });
    _repository.getTotalExpenseByDateRange(startOfMonth, endOfMonth).listen((expense) {
      _currentMonthExpense = expense ?? 0.0;
      notifyListeners();
    });
    _repository.getSessionsCountByDateRange(startOfMonth, endOfMonth).listen((count) {
      _currentMonthSessionCount = count;
      notifyListeners();
    });
  }

  void _loadReminders() {
    _repository.getLastSessionDateForEachCat().listen((dates) {
      _lastSessionDates = dates;
      _computeReminders();
      notifyListeners();
    });
  }

  void _computeReminders() {
    final now = DateTime.now().millisecondsSinceEpoch;
    const oneDayMs = 24 * 60 * 60 * 1000;

    final lastSessionMap = {
      for (final d in _lastSessionDates) d.catId: d.lastDate
    };

    _marketingReminders = _allCats
        .where((cat) => !cat.permanentAlert.startsWith('[ARCHIVED]'))
        .where((cat) => lastSessionMap.containsKey(cat.catId))
        .map((cat) {
          final lastDate = lastSessionMap[cat.catId]!;
          final daysSince = (now - lastDate) ~/ oneDayMs;
          return ReminderItem(cat: cat, daysSince: daysSince, lastDate: lastDate);
        })
        .toList()
      ..sort((a, b) => b.daysSince.compareTo(a.daysSince));
  }

  Future<void> updateReminders() async {
    final notifService = NotificationService();
    await notifService.cancelAll();

    if (!isBookingReminderEnabled) return;

    for (var booking in _bookings) {
      if (booking.status == 'CANCELLED' || booking.status == 'COMPLETED') continue;

      final bookingDate = DateTime.fromMillisecondsSinceEpoch(booking.bookingDate);
      
      // H-1 logic
      final scheduleDate = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day - 1,
        reminderHour,
        reminderMinute,
      );

      if (scheduleDate.isAfter(DateTime.now())) {
        final cat = _allCats.firstWhere(
          (c) => c.catId == booking.catId, 
          orElse: () => const Cat(catName: 'Kucing', ownerName: '', ownerPhone: '')
        );
        await notifService.scheduleReminder(
          id: booking.bookingId ?? booking.hashCode,
          title: 'Pengingat Grooming Besok!',
          body: 'Jadwal Grooming untuk ${cat.catName} besok. Jangan lupa ya!',
          scheduledTime: scheduleDate,
          payload: booking.bookingId.toString(),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════════════════

  void onSearchQueryChanged(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  void _applySearchFilter() {
    final activeCats = _allCats.where((c) {
      if (_showArchivedCats) return true;
      return !c.permanentAlert.startsWith('[ARCHIVED]');
    }).toList();
    
    if (_searchQuery.isEmpty) {
      _filteredCats = activeCats;
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredCats = activeCats
          .where((c) =>
              c.catName.toLowerCase().contains(q) ||
              c.ownerName.toLowerCase().contains(q))
          .toList();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CAT CRUD
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> addCat(Cat cat) async {
    await _repository.insertCat(cat);
    _loadCats();
  }

  Future<void> updateCat(Cat cat) async {
    await _repository.updateCat(cat);
    _loadCats();
  }

  Future<void> deleteCat(Cat cat) async {
    await _repository.deleteCat(cat);
    _loadCats();
  }

  Future<void> archiveCat(Cat cat) async {
    if (cat.permanentAlert.startsWith('[ARCHIVED]')) return;
    final updatedCat = cat.copyWith(
      permanentAlert: '[ARCHIVED] ${cat.permanentAlert}'.trim(),
    );
    await updateCat(updatedCat);
  }

  Future<void> unarchiveCat(Cat cat) async {
    if (!cat.permanentAlert.startsWith('[ARCHIVED]')) return;
    String newAlert = cat.permanentAlert.replaceFirst('[ARCHIVED]', '').trim();
    final updatedCat = cat.copyWith(
      permanentAlert: newAlert,
    );
    await updateCat(updatedCat);
  }

  Future<Cat?> getCat(int id) => _repository.getCatById(id);

  Stream<List<HotelBooking>> getHotelBookingsForCat(int catId) => 
      _repository.getHotelBookingsForCat(catId);

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION CRUD
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> addSession(Session session, List<SessionPhoto> photos) async {
    try {
      await _repository.insertSessionWithPhotos(session, photos);

      if (session.status != 'DONE') {
        final shopId = _settingsPrefs.storeId;
        final cat = await _repository.getCatById(session.catId);
        if (shopId.isNotEmpty && cat != null) {
          await _firebaseRepo.updateTrackingStatus(shopId, session, cat.catName);
        }
      }
      _loadSessions(); // Refresh UI
    } catch (e) {
      debugPrint('addSession error: $e');
    }
  }

  Future<void> updateSession(Session session) async {
    try {
      var missedHistory = <MapEntry<String, int>>[];

      if (session.status == 'DONE') {
        final oldSession = await _repository.getSessionById(session.sessionId);
        if (oldSession != null &&
            oldSession.status != 'DONE' &&
            oldSession.status != 'PICKUP_READY') {
          const orderedStates = [
            'WAITING', 'BATHING', 'DRYING', 'FINISHING', 'PICKUP_READY', 'DONE'
          ];
          final oldIndex = orderedStates.indexOf(oldSession.status);
          final newIndex = orderedStates.indexOf('DONE');

          if (oldIndex != -1 && newIndex > oldIndex + 1) {
            final skipped = orderedStates.sublist(oldIndex + 1, newIndex);
            final now = DateTime.now().millisecondsSinceEpoch;
            missedHistory = skipped.asMap().entries.map((e) {
              final stepsFromEnd = skipped.length - e.key;
              final timeOffset = stepsFromEnd * 15 * 60 * 1000;
              return MapEntry(e.value, now - timeOffset);
            }).toList();
          }
        }
      }

      await _repository.updateSession(session);

      final shopId = _settingsPrefs.storeId;
      final cat = await _repository.getCatById(session.catId);
      if (shopId.isNotEmpty && cat != null && session.trackingToken != null) {
        await _firebaseRepo.updateTrackingStatus(
          shopId, session, cat.catName,
          missedHistory: missedHistory,
        );
      }
      _loadSessions(); // Refresh UI
    } catch (e) {
      debugPrint('updateSession error: $e');
    }
  }

  Future<void> deleteSession(Session session) async {
    await _repository.deleteSession(session);
    if (session.trackingToken != null) {
      final shopId = _settingsPrefs.storeId;
      await _firebaseRepo.deleteTrackingStatus(shopId, session.trackingToken);
    }
    _loadSessions(); // Refresh UI
  }

  Future<Session?> getSession(int id) => _repository.getSessionById(id);

  Stream<List<Session>> getSessionsForCat(int catId) =>
      _repository.getSessionsForCat(catId);

  // ═══════════════════════════════════════════════════════════════════════════
  // CHIP OPTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> addChipOption(String category, String label) async {
    await _repository.insertOption(ChipOption(category: category, label: label));
    await _refreshChipOptions(category);
  }

  Future<void> deleteChipOption(ChipOption option) async {
    await _repository.deleteOption(option);
    await _refreshChipOptions(option.category);
  }

  Future<void> _refreshChipOptions(String category) async {
    final options = await _repository.getOptionsByCategory(category).first;
    if (category == 'finding') {
      _findingOptions = options;
    } else if (category == 'treatment') {
      _treatmentOptions = options;
    }
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOOKINGS
  // ═══════════════════════════════════════════════════════════════════════════

  void _loadBookings() {
    _repository.allBookings.listen((list) {
      _bookings = list;
      updateReminders();
      notifyListeners();
    });
  }

  Future<void> addBooking(Booking booking) async {
    await _repository.insertBooking(booking);
    _loadBookings();
  }

  Future<void> updateBooking(Booking booking) async {
    await _repository.updateBooking(booking);
    _loadBookings();
  }

  Future<void> deleteBooking(Booking booking) async {
    await _repository.deleteBooking(booking);
    _loadBookings();
  }

  Future<void> updateBookingStatus(Booking booking, String status) async {
    await _repository.updateBooking(booking.copyWith(status: status));
    _loadBookings();
  }

  Future<void> rescheduleBooking(Booking booking, int newDate) async {
    await _repository.updateBooking(booking.copyWith(bookingDate: newDate));
    _loadBookings();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> addService(String name, int price) async {
    await _repository.insertService(
      GroomingService(serviceName: name, defaultPrice: price),
    );
    _loadServices();
  }

  Future<void> updateService(GroomingService service) async {
    await _repository.updateService(service);
    _loadServices();
  }

  Future<void> deleteService(GroomingService service) async {
    await _repository.deleteService(service);
    _loadServices();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKUP / RESTORE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<BackupData> getBackupData() async {
    final cats = await _repository.getAllCats().first;
    final sessions = await _repository.getAllSessions().first;
    final photos = await _repository.getAllPhotos().first;
    final bookings = await _repository.allBookings.first;
    final services = await _repository.getAllServices().first;

    return BackupData(
      cats: cats,
      sessions: sessions,
      photos: photos,
      bookings: bookings,
      services: services,
    );
  }

  Future<void> restoreBackup(BackupData data) async {
    for (final cat in data.cats) {
      await _repository.insertCat(cat);
    }
    for (final session in data.sessions) {
      await _repository.insertSessionWithPhotos(session, []);
    }
    for (final photo in data.photos) {
      await _repository.insertPhoto(photo);
    }
  }

  Future<double> getDepositPaidForSession(int sessionId) async {
    final txs = await _repository.getDepositTransactionsForRef(sessionId);
    return txs.where((t) => t.amount < 0).fold<double>(0.0, (sum, t) => sum + (-t.amount));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // IMAGE PROCESSING STATE
  // ═══════════════════════════════════════════════════════════════════════════

  void clearProcessedImage() {
    _processedImagePath = null;
    notifyListeners();
  }

  void setProcessedImage(String? path) {
    _processedImagePath = path;
    notifyListeners();
  }

  void setProcessingImageState(bool isProcessing) {
    _isProcessingImage = isProcessing;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _cleanupOldSessions() async {
    try {
      final sessions = await _repository.getAllSessions().first;
      final now = DateTime.now().millisecondsSinceEpoch;
      final twelveHoursAgo = now - (12 * 60 * 60 * 1000);

      final toCleanup = sessions.where((s) =>
          s.status == 'DONE' &&
          s.updatedAt > 0 &&
          s.updatedAt < twelveHoursAgo &&
          s.trackingToken != null);

      if (toCleanup.isEmpty) return;

      final shopId = _settingsPrefs.storeId;
      if (shopId.isEmpty) return;

      for (final session in toCleanup) {
        await _firebaseRepo.deleteTrackingStatus(shopId, session.trackingToken!);
        await _repository.updateSession(
            session.copyWith(trackingToken: null));
      }
    } catch (e) {
      debugPrint('cleanupOldSessions error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADMIN PANEL
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Map<String, ShopCredentials>?> getAllShopsCredentials() async {
    return _firebaseRepo.getAllShopsCredentials();
  }

  Future<bool> updateSubscription(String shopId, SubscriptionStatus status) async {
    return _firebaseRepo.updateSubscription(shopId, status);
  }

  Future<bool> verifyAdminPin(String pin) async {
    return _firebaseRepo.verifyAdminPin(pin);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class OwnerInfo {
  final String name;
  final String phone;
  const OwnerInfo({required this.name, required this.phone});
}

class ReminderItem {
  final Cat cat;
  final int daysSince;
  final int lastDate;
  const ReminderItem({
    required this.cat,
    required this.daysSince,
    required this.lastDate,
  });
}
