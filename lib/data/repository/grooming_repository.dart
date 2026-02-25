import '../source/grooming_dao.dart';
import '../entity/cat.dart';
import '../entity/session.dart';
import '../entity/session_photo.dart';
import '../entity/booking.dart';
import '../entity/grooming_service.dart';
import '../entity/hotel_entities.dart';
import '../entity/expense.dart';
import '../entity/chip_option.dart';
import '../entity/deposit_entities.dart';
import '../entity/cat_last_session.dart';
import '../model/cloud_sync_data.dart';
import '../../util/settings_preferences.dart';
import '../../util/image_compressor.dart';
import '../../util/offline_backup_manager.dart';
import 'firebase_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import '../source/database_helper.dart';

class GroomingRepository {
  final GroomingDao _dao;
  final FirebaseRepository _firebaseRepo;
  final SettingsPreferences _settingsPrefs;

  // Stream controllers for reactive updates
  final _hotelBookingChangeController = StreamController<void>.broadcast();
  Stream<void> get onHotelBookingChanged => _hotelBookingChangeController.stream;

  final _sessionChangeController = StreamController<void>.broadcast();
  Stream<void> get onSessionChanged => _sessionChangeController.stream;

  final _dataRestoredController = StreamController<void>.broadcast();
  Stream<void> get onDataRestored => _dataRestoredController.stream;

  final _expenseChangeController = StreamController<void>.broadcast();
  Stream<void> get onExpenseChanged => _expenseChangeController.stream;

  GroomingRepository(this._dao, this._firebaseRepo, this._settingsPrefs);

  void _syncIfEnabled(Future<void> Function(String shopId) action) {
    if (_settingsPrefs.isCloudSyncEnabled &&
        _settingsPrefs.storeId.isNotEmpty) {
      action(_settingsPrefs.storeId).catchError((e) {
        print('Sync error: $e');
      });
    }
  }

  // ─── Cats ──────────────────────────────────────────────────────────────

  Stream<List<Cat>> getAllCats() => _dao.getAllCats();

  Stream<List<Cat>> searchCats(String query) => _dao.searchCats(query);

  Future<Cat?> getCatById(int id) => _dao.getCatById(id);

  Future<void> insertCat(Cat cat) async {
    await _dao.insertCat(cat);
    _syncIfEnabled((shopId) => _firebaseRepo.syncCat(shopId, cat));
  }

  Future<void> updateCat(Cat cat) async {
    await _dao.updateCat(cat);
    _syncIfEnabled((shopId) => _firebaseRepo.syncCat(shopId, cat));
  }

  Future<void> deleteCat(Cat cat) async {
    await _dao.deleteCat(cat);
    _syncIfEnabled((shopId) =>
        _firebaseRepo.deleteFromSync(shopId, 'cats', cat.catId.toString()));
  }

  // ─── Sessions ──────────────────────────────────────────────────────────

  Stream<List<Session>> getSessionsForCat(int catId) =>
      _dao.getSessionsForCat(catId);

  Stream<List<Session>> getActiveSessions() => _dao.getActiveSessions();

  Stream<List<Session>> getRecentSessions() => _dao.getRecentSessions();

  Stream<List<Session>> getAllSessions() => _dao.getAllSessions();

  Future<Session?> getSessionById(int id) => _dao.getSessionById(id);

  Future<void> updateSession(Session session) async {
    await _dao.updateSession(session);
    _syncIfEnabled(
        (shopId) => _firebaseRepo.syncSession(shopId, session));
    _sessionChangeController.add(null);
  }

  Future<void> deleteSession(Session session) async {
    await _dao.deleteSession(session);
    _sessionChangeController.add(null);
  }

  Stream<List<SessionPhoto>> getAllPhotos() => _dao.getAllPhotos();

  Stream<int> getSessionsCountByDateRange(int start, int end) =>
      _dao.getSessionsCountByDateRange(start, end);

  Stream<double?> getTotalIncomeByDateRange(int start, int end) =>
      _dao.getTotalIncomeByDateRange(start, end);

  Stream<List<Session>> getSessionsByDateRange(int start, int end) =>
      _dao.getSessionsByDateRange(start, end);

  Stream<List<CatLastSession>> getLastSessionDateForEachCat() =>
      _dao.getLastSessionDateForEachCat();

  // ─── Chips ──────────────────────────────────────────────────────────────

  Stream<List<ChipOption>> getOptionsByCategory(String category) =>
      _dao.getOptionsByCategory(category);

  Future<void> insertOption(ChipOption option) async {
    await _dao.insertOption(option);
    _syncIfEnabled((shopId) => _firebaseRepo.syncChipOption(shopId, option));
  }

  Future<void> deleteOption(ChipOption option) async {
    await _dao.deleteOption(option);
    _syncIfEnabled((shopId) => _firebaseRepo.deleteFromSync(shopId, 'chip_options', option.id.toString()));
  }

  Future<void> insertSessionWithPhotos(
      Session session, List<SessionPhoto> photos) async {
    final newId = await _dao.insertSessionWithPhotos(session, photos);
    final sessionWithId = session.copyWith(sessionId: newId);
    _syncIfEnabled(
        (shopId) => _firebaseRepo.syncSession(shopId, sessionWithId));
    _sessionChangeController.add(null);
  }

  Future<void> insertPhoto(SessionPhoto photo) => _dao.insertPhoto(photo);

  // ─── Bookings ──────────────────────────────────────────────────────────

  Stream<List<Booking>> get allBookings => _dao.getAllBookings();

  Future<void> insertBooking(Booking booking) async {
    await _dao.insertBooking(booking);
    _syncIfEnabled((shopId) => _firebaseRepo.syncGroomingBooking(shopId, booking));
  }

  Future<void> updateBooking(Booking booking) async {
    await _dao.updateBooking(booking);
    _syncIfEnabled((shopId) => _firebaseRepo.syncGroomingBooking(shopId, booking));
  }

  Future<void> deleteBooking(Booking booking) async {
    await _dao.deleteBooking(booking);
    _syncIfEnabled((shopId) => _firebaseRepo.deleteFromSync(shopId, 'bookings', booking.bookingId.toString()));
  }

  // ─── Services ──────────────────────────────────────────────────────────

  Stream<List<GroomingService>> getAllServices() => _dao.getAllServices();

  Future<void> insertService(GroomingService service) async {
    await _dao.insertService(service);
    _syncIfEnabled((shopId) => _firebaseRepo.syncService(shopId, service));
  }

  Future<void> updateService(GroomingService service) async {
    await _dao.updateService(service);
    _syncIfEnabled((shopId) => _firebaseRepo.syncService(shopId, service));
  }

  Future<void> deleteService(GroomingService service) async {
    await _dao.deleteService(service);
    _syncIfEnabled((shopId) => _firebaseRepo.deleteFromSync(shopId, 'services', service.id.toString()));
  }

  // ─── Hotel Financials ──────────────────────────────────────────────────

  Stream<double?> getHotelIncomeByDateRange(int start, int end) =>
      _dao.getHotelIncomeByDateRange(start, end);

  Stream<List<HotelBooking>> getCompletedHotelBookings(int start, int end) =>
      _dao.getCompletedHotelBookings(start, end);

  Stream<List<HotelBooking>> getAllCompletedHotelBookings() =>
      _dao.getAllCompletedHotelBookings();

  Stream<double?> getCombinedIncomeByDateRange(int start, int end) =>
      _dao.getCombinedIncomeByDateRange(start, end);

  Future<HotelBooking?> getBookingById(int id) =>
      _dao.getHotelBookingById(id);

  Stream<List<HotelAddOn>> getAddOnsForBooking(int bookingId) =>
      _dao.getAddOnsForBooking(bookingId);

  Stream<List<HotelRoom>> getAllRooms() => _dao.getAllRooms();
  Future<HotelRoom?> getRoomById(int id) => _dao.getRoomById(id);
  Future<void> insertRoom(HotelRoom room) async {
    await _dao.insertRoom(room);
    _syncIfEnabled((shopId) => _firebaseRepo.syncHotelRoom(shopId, room));
  }

  Future<void> updateRoom(HotelRoom room) async {
    await _dao.updateRoom(room);
    _syncIfEnabled((shopId) => _firebaseRepo.syncHotelRoom(shopId, room));
  }

  Future<void> deleteRoom(HotelRoom room) async {
    await _dao.deleteRoom(room);
    _syncIfEnabled((shopId) => _firebaseRepo.deleteFromSync(shopId, 'hotel_rooms', room.id.toString()));
  }

  Stream<List<HotelBooking>> getActiveHotelBookings() => _dao.getActiveHotelBookings();
  Stream<List<HotelBooking>> getAllHotelBookings() => _dao.getAllHotelBookings();
  Stream<List<HotelBooking>> getHotelBookingsForCat(int catId) => _dao.getHotelBookingsForCat(catId);
  Future<HotelBooking?> getHotelBookingById(int id) => _dao.getHotelBookingById(id);
  Future<void> insertHotelBooking(HotelBooking booking) async {
    await _dao.insertHotelBooking(booking);
    _syncIfEnabled((shopId) => _firebaseRepo.syncHotelBooking(shopId, booking));
    _hotelBookingChangeController.add(null);
  }

  Future<void> updateHotelBooking(HotelBooking booking) async {
    await _dao.updateHotelBooking(booking);
    _syncIfEnabled((shopId) => _firebaseRepo.syncHotelBooking(shopId, booking));
    _hotelBookingChangeController.add(null);
  }

  Future<void> deleteHotelBookingById(int id) async {
    await _dao.deleteHotelBookingById(id);
    _syncIfEnabled((shopId) => _firebaseRepo.deleteFromSync(shopId, 'hotel_bookings', id.toString()));
    _hotelBookingChangeController.add(null);
  }
  Future<List<HotelBooking>> checkRoomAvailability(int roomId, int start, int end) => _dao.checkRoomAvailability(roomId, start, end);
  Future<List<HotelBooking>> checkRoomAvailabilityExcluding(int roomId, int start, int end, int excludeId) => _dao.checkRoomAvailabilityExcludingBooking(roomId, start, end, excludeId);


  Future<List<HotelAddOn>> getAllAddOns() => _dao.getAllAddOns().first;
  Future<void> insertAddOn(HotelAddOn addOn) async {
    await _dao.insertAddOn(addOn);
    _syncIfEnabled((shopId) => _firebaseRepo.syncHotelAddOn(shopId, addOn));
  }

  Future<void> deleteAddOn(HotelAddOn addOn) async {
    await _dao.deleteAddOn(addOn);
    _syncIfEnabled((shopId) => _firebaseRepo.deleteFromSync(shopId, 'hotel_adds', addOn.id.toString()));
  }

  // ─── Expense Tracking ──────────────────────────────────────────────────

  Stream<List<Expense>> getExpensesByMonth(int start, int end) =>
      _dao.getExpensesByMonth(start, end);

  Stream<double?> getTotalExpenseByDateRange(int start, int end) =>
      _dao.getTotalExpenseByDateRange(start, end);

  Future<void> insertExpense(Expense expense) async {
    await _dao.insertExpense(expense);
    _syncIfEnabled((shopId) => _firebaseRepo.syncExpense(shopId, expense));
    _expenseChangeController.add(null);
  }

  Future<void> deleteExpense(Expense expense) async {
    await _dao.deleteExpense(expense);
    _syncIfEnabled((shopId) => _firebaseRepo.deleteFromSync(shopId, 'expenses', expense.id.toString()));
    _expenseChangeController.add(null);
  }

  // ─── Deposits ──────────────────────────────────────────────────────────

  Stream<List<OwnerDeposit>> getAllDeposits() => _dao.getAllDeposits();
  Future<OwnerDeposit?> getDeposit(String phone) => _dao.getDeposit(phone);
  Future<void> insertDeposit(OwnerDeposit deposit) => _dao.insertDeposit(deposit);
  Future<void> updateDeposit(OwnerDeposit deposit) => _dao.updateDeposit(deposit);
  Stream<List<DepositTransaction>> getDepositTransactions(String phone) => _dao.getDepositTransactions(phone);
  Future<void> insertDepositTransaction(DepositTransaction txn) => _dao.insertDepositTransaction(txn);
  Future<List<DepositTransaction>> getDepositTransactionsForRef(int refId) => _dao.getTransactionsByReferenceId(refId);
  Future<void> deleteDeposit(OwnerDeposit deposit) => _dao.deleteDeposit(deposit);
  Future<void> deleteDepositTransactions(String phone) => _dao.deleteDepositTransactions(phone);

  // ─── Cloud Restore ─────────────────────────────────────────────────────

  Future<void> fullRestoreFromCloud() async {
    final shopId = _settingsPrefs.storeId;
    if (shopId.isEmpty) return;

    final cloudData = await _firebaseRepo.fetchAllSyncData(shopId);
    if (cloudData == null) return;

    // 1. Restore Cats (Dependencies for Bookings/Sessions)
    for (final cat in cloudData.cats.values) {
      await _dao.insertCat(cat);
    }

    // 2. Restore Rooms (Dependency for Hotel Bookings)
    for (final room in cloudData.hotelRooms.values) {
      await _dao.insertRoom(room);
    }

    // 3. Restore Sessions
    for (final session in cloudData.sessions.values) {
      try {
        await _dao.insertSession(session);
      } catch (e) {
        // e.g. FOREIGN KEY constraint failed if cat is missing
        print('Skipping session ${session.sessionId} (restore error): $e');
      }
    }

    // 4. Restore Hotel Bookings (Now safe as Rooms & Cats exist)
    for (final booking in cloudData.hotelBookings.values) {
      try {
        await _dao.insertHotelBooking(booking);
      } catch (e) {
        print('Skipping booking ${booking.id} (restore error): $e');
      }
    }

    // 5. Restore Services
    for (final service in cloudData.services.values) {
      await _dao.insertService(service);
    }

    // 6. Restore Expenses
    for (final expense in cloudData.expenses.values) {
      await _dao.insertExpense(expense);
    }

    // 6.5 Restore Chip Options (Findings & Treatments)
    if (cloudData.chipOptions.isNotEmpty) {
      for (final option in cloudData.chipOptions.values) {
        await _dao.insertOption(option);
      }
    }

    // 6.6 Restore Grooming Bookings
    if (cloudData.bookings.isNotEmpty) {
      for (final booking in cloudData.bookings.values) {
        try {
          await _dao.insertBooking(booking);
        } catch (e) {
          print('Skipping grooming booking ${booking.bookingId} (restore error): $e');
        }
      }
    }

    // 6.7 Restore Hotel Add-ons
    if (cloudData.hotelAdds.isNotEmpty) {
      for (final addOn in cloudData.hotelAdds.values) {
        try {
          await _dao.insertAddOn(addOn);
        } catch (e) {
          print('Skipping hotel add-on ${addOn.id} (restore error): $e');
        }
      }
    }

    // 6.8 Restore Deposits
    if (cloudData.ownerDeposits.isNotEmpty) {
      for (final deposit in cloudData.ownerDeposits.values) {
        await _dao.insertDeposit(deposit);
      }
    }
    if (cloudData.depositTransactions.isNotEmpty) {
      for (final transaction in cloudData.depositTransactions.values) {
        await _dao.insertDepositTransaction(transaction);
      }
    }

    // 7. Restore Shop Identity (Name, Phone, Address)
    final identity = await _firebaseRepo.getShopIdentity(shopId);
    if (identity != null) {
      final name = identity['shopName'];
      final phone = identity['shopPhone'];
      final address = identity['shopAddress'];
      if (name != null && name.isNotEmpty) {
        _settingsPrefs.businessName = name;
      }
      if (phone != null && phone.isNotEmpty) {
        _settingsPrefs.businessInfo = phone;
      }
      if (address != null && address.isNotEmpty) {
        _settingsPrefs.businessAddress = address;
      }
    }

    // 8. Restore Cat Photos (Download Base64 -> Save File -> Update Cat)
    for (final entry in cloudData.catPhotos.entries) {
      final catId = int.tryParse(entry.key);
      final base64Image = entry.value;
      if (catId != null && base64Image.isNotEmpty) {
        final savedPath = await ImageCompressor.saveImageFromBase64(base64Image, 'cat_$catId.jpg');
        if (savedPath != null) {
          final cat = await _dao.getCatById(catId);
          if (cat != null) {
            await _dao.updateCat(cat.copyWith(imagePath: savedPath));
          }
        }
      }
    }

    _dataRestoredController.add(null);
  }

  Future<void> uploadAllDataToCloud(
      String shopName, String shopPhone) async {
    final shopId = _settingsPrefs.storeId;
    if (shopId.isEmpty) return;

    try {
      // 1. Gather all local data
      final cats = await _dao.getAllCatsSync();
      final sessions = await _dao.getAllSessionsSync();
      final hotelBookings = await _dao.getAllHotelBookingsSync();
      final rooms = await _dao.getAllRoomsSync();
      final services = await _dao.getAllServicesSync();
      final expenses = await _dao.getAllExpensesSync();
      final chips = await _dao.getAllChipOptionsSync();
      final groomingBookings = await _dao.getAllBookingsSync();
      final hotelAdds = await _dao.getAllAddOnsSync();
      final ownerDepositsList = await _dao.getAllDeposits().first;
      // We need to fetch deposit transactions. Flutter doesn't have getAllDepositTransactionsSync, so let's get them from DB directly
      final List<Map<String, dynamic>> maps = await DatabaseHelper.instance.database.then((db) => db.query('deposit_transactions'));
      final List<DepositTransaction> depositTransactionsList = maps.map((e) => DepositTransaction.fromMap(e)).toList();

      final catsMap = {for (final c in cats) c.catId.toString(): c};
      final sessionsMap = {
        for (final s in sessions) s.sessionId.toString(): s
      };
      final hotelBookingsMap = {for (final b in hotelBookings) b.id.toString(): b};
      final roomsMap = {for (final r in rooms) r.id.toString(): r};
      final servicesMap = {for (final s in services) s.id.toString(): s};
      final expensesMap = {for (final e in expenses) e.id.toString(): e};
      final chipsMap = {for (final c in chips) c.id.toString(): c};
      final groomingBookingsMap = {for (final b in groomingBookings) b.bookingId.toString(): b};
      final hotelAddsMap = {for (final a in hotelAdds) a.id.toString(): a};
      final ownerDepositsMap = {for (final d in ownerDepositsList) d.ownerPhone: d};
      final depositTransactionsMap = {for (final t in depositTransactionsList) t.id.toString(): t};

      // 2. Process Photos (Compress & Encode)
      final catPhotos = <String, String>{};
      for (final cat in cats) {
        if (cat.imagePath != null && cat.imagePath!.isNotEmpty) {
           final compressed = await ImageCompressor.compressImage(cat.imagePath!);
           if (compressed != null) {
             catPhotos[cat.catId.toString()] = compressed;
           }
        }
      }

      // 3. Wrap in Sync Package
      final packageData = CloudSyncData(
        cats: catsMap,
        catPhotos: catPhotos,
        sessions: sessionsMap,
        hotelBookings: hotelBookingsMap,
        hotelRooms: roomsMap,
        services: servicesMap,
        expenses: expensesMap,
        chipOptions: chipsMap,
        bookings: groomingBookingsMap,
        hotelAdds: hotelAddsMap,
        ownerDeposits: ownerDepositsMap,
        depositTransactions: depositTransactionsMap,
      );

      // 4. Upload to Cloud
      await _firebaseRepo.uploadAllData(shopId, packageData);

      // 5. Sync Identity
      await _firebaseRepo.syncShopIdentity(shopId, shopName, shopPhone, _settingsPrefs.businessAddress);

      // 6. Sync Secret Key
      final secretKey = _settingsPrefs.syncSecretKey;
      if (secretKey.isNotEmpty) {
        await _firebaseRepo.setSecretKey(shopId, secretKey);
      }
    } catch (e) {
      print('Upload error: $e');
    }
  }
  // ═══════════════════════════════════════════════════════════════════════════
  // OFFLINE BACKUP & RESTORE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<String?> backupOffline() async {
    try {
      // 1. Gather Image Paths
      final imagePaths = <String>[];
      final cats = await _dao.getAllCatsSync();
      for (final cat in cats) {
        if (cat.imagePath != null && cat.imagePath!.isNotEmpty) {
          imagePaths.add(cat.imagePath!);
        }
      }
      final photos = await _dao.getAllPhotosSync();
      for (final photo in photos) {
        if (photo.filePath.isNotEmpty) {
          imagePaths.add(photo.filePath);
        }
      }

      // 2. Close DB
      await DatabaseHelper.instance.close();

      // 3. Create Backup
      final dbPath = await DatabaseHelper.instance.dbPath;
      final zipPath = await OfflineBackupManager().createBackup(
        dbPath: dbPath,
        imagePaths: imagePaths,
      );

      // 4. Re-open DB
      await DatabaseHelper.instance.database;

      return zipPath;
    } catch (e) {
      print('Backup Offline Error: $e');
      // Ensure DB is open even on error
      await DatabaseHelper.instance.database;
      return null;
    }
  }

  Future<bool> restoreOffline(String zipPath) async {
    try {
      // 1. Close DB
      await DatabaseHelper.instance.close();

      // 2. Restore
      // DatabaseHelper.instance.dbPath returns full path including filename
      // OfflineBackupManager wants dbFolder
      final dbFolder = await getDatabasesPath();
      final docsDir = await getApplicationDocumentsDirectory();
      
      await OfflineBackupManager().restoreBackup(
        zipPath: zipPath,
        dbFolder: dbFolder,
        docsFolder: docsDir.path,
        dbName: 'grooming_database.db',
      );

      // 3. Re-open DB
      await DatabaseHelper.instance.database;
      
      _dataRestoredController.add(null);
      return true;
    } catch (e) {
      print('Restore Offline Error: $e');
      await DatabaseHelper.instance.database;
      return false;
    }
  }
}
