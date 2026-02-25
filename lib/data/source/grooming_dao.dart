import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
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

class GroomingDao {
  final DatabaseHelper _dbHelper;

  GroomingDao(this._dbHelper);

  Future<Database> get _db => _dbHelper.database;

  // ═══════════════════════════════════════════════════════════════════════════
  // CATS
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<Cat>> getAllCats() async* {
    final db = await _db;
    final results =
        await db.query('cats', orderBy: 'catName ASC');
    yield results.map((row) => Cat.fromMap(row)).toList();
  }

  Stream<List<Cat>> searchCats(String query) async* {
    final db = await _db;
    final results = await db.query(
      'cats',
      where: "catName LIKE ? OR ownerName LIKE ?",
      whereArgs: ['%$query%', '%$query%'],
    );
    yield results.map((row) => Cat.fromMap(row)).toList();
  }

  Future<Cat?> getCatById(int id) async {
    final db = await _db;
    final results =
        await db.query('cats', where: 'catId = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return Cat.fromMap(results.first);
  }

  Future<int> insertCat(Cat cat) async {
    final db = await _db;
    return await db.insert('cats', cat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCat(Cat cat) async {
    final db = await _db;
    await db.update('cats', cat.toMap(),
        where: 'catId = ?', whereArgs: [cat.catId]);
  }

  Future<void> deleteCat(Cat cat) async {
    final db = await _db;
    await db.delete('cats', where: 'catId = ?', whereArgs: [cat.catId]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<Session>> getSessionsForCat(int catId) async* {
    final db = await _db;
    final results = await db.query('sessions',
        where: 'catId = ?', whereArgs: [catId], orderBy: 'timestamp DESC');
    yield results.map((row) => Session.fromMap(row)).toList();
  }

  Stream<List<Session>> getRecentSessions() async* {
    final db = await _db;
    final results =
        await db.query('sessions', orderBy: 'timestamp DESC', limit: 5);
    yield results.map((row) => Session.fromMap(row)).toList();
  }

  Future<int> insertSession(Session session) async {
    final db = await _db;
    return await db.insert('sessions', session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteSession(Session session) async {
    final db = await _db;
    await db.delete('sessions',
        where: 'sessionId = ?', whereArgs: [session.sessionId]);
  }

  Future<void> updateSession(Session session) async {
    final db = await _db;
    await db.update('sessions', session.toMap(),
        where: 'sessionId = ?', whereArgs: [session.sessionId]);
  }

  Future<Session?> getSessionById(int id) async {
    final db = await _db;
    final results =
        await db.query('sessions', where: 'sessionId = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return Session.fromMap(results.first);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PHOTOS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> insertPhoto(SessionPhoto photo) async {
    final db = await _db;
    await db.insert('session_photos', photo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Stream<List<SessionPhoto>> getPhotosForSession(int sessionId) async* {
    final db = await _db;
    final results = await db.query('session_photos',
        where: 'sessionId = ?', whereArgs: [sessionId]);
    yield results.map((row) => SessionPhoto.fromMap(row)).toList();
  }

  Stream<List<Session>> getActiveSessions() async* {
    final db = await _db;
    final results = await db.query('sessions',
        where: "status != 'DONE'", orderBy: 'timestamp ASC');
    yield results.map((row) => Session.fromMap(row)).toList();
  }

  Stream<List<Session>> getAllSessions() async* {
    final db = await _db;
    final results =
        await db.query('sessions', orderBy: 'timestamp DESC');
    yield results.map((row) => Session.fromMap(row)).toList();
  }

  Stream<List<SessionPhoto>> getAllPhotos() async* {
    final db = await _db;
    final results = await db.query('session_photos');
    yield results.map((row) => SessionPhoto.fromMap(row)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FINANCIAL REPORTS
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<int> getSessionsCountByDateRange(int start, int end) async* {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM sessions WHERE timestamp BETWEEN ? AND ?',
      [start, end],
    );
    yield Sqflite.firstIntValue(result) ?? 0;
  }

  Stream<double?> getTotalIncomeByDateRange(int start, int end) async* {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT SUM(totalCost) as total FROM sessions WHERE timestamp BETWEEN ? AND ?',
      [start, end],
    );
    final value = result.first['total'];
    yield value != null ? (value as num).toDouble() : null;
  }

  Stream<List<Session>> getSessionsByDateRange(int start, int end) async* {
    final db = await _db;
    final results = await db.query('sessions',
        where: 'timestamp BETWEEN ? AND ?',
        whereArgs: [start, end],
        orderBy: 'timestamp DESC');
    yield results.map((row) => Session.fromMap(row)).toList();
  }

  Stream<List<CatLastSession>> getLastSessionDateForEachCat() async* {
    final db = await _db;
    final results = await db.rawQuery(
      'SELECT catId, MAX(timestamp) as lastDate FROM sessions GROUP BY catId',
    );
    yield results.map((row) => CatLastSession.fromMap(row)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TRANSACTIONS (Session + Photos)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<int> insertSessionWithPhotos(
      Session session, List<SessionPhoto> photos) async {
    final db = await _db;
    return await db.transaction((txn) async {
      final sessionId = await txn.insert('sessions', session.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      for (final photo in photos) {
        await txn.insert(
          'session_photos',
          photo.copyWith(sessionId: sessionId).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      return sessionId;
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOOKINGS (Grooming)
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<Booking>> getAllBookings() async* {
    final db = await _db;
    final results =
        await db.query('bookings', orderBy: 'bookingDate ASC');
    yield results.map((row) => Booking.fromMap(row)).toList();
  }

  Future<void> insertBooking(Booking booking) async {
    final db = await _db;
    await db.insert('bookings', booking.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBooking(Booking booking) async {
    final db = await _db;
    await db.update('bookings', booking.toMap(),
        where: 'bookingId = ?', whereArgs: [booking.bookingId]);
  }

  Future<void> deleteBooking(Booking booking) async {
    final db = await _db;
    await db.delete('bookings',
        where: 'bookingId = ?', whereArgs: [booking.bookingId]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICES
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<GroomingService>> getAllServices() async* {
    final db = await _db;
    final results =
        await db.query('grooming_services', orderBy: 'serviceName ASC');
    yield results.map((row) => GroomingService.fromMap(row)).toList();
  }

  Future<void> insertService(GroomingService service) async {
    final db = await _db;
    await db.insert('grooming_services', service.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateService(GroomingService service) async {
    final db = await _db;
    await db.update('grooming_services', service.toMap(),
        where: 'id = ?', whereArgs: [service.id]);
  }

  Future<void> deleteService(GroomingService service) async {
    final db = await _db;
    await db.delete('grooming_services',
        where: 'id = ?', whereArgs: [service.id]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKUP & RESTORE BATCH INSERTS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> insertCats(List<Cat> cats) async {
    final db = await _db;
    final batch = db.batch();
    for (final cat in cats) {
      batch.insert('cats', cat.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertSessions(List<Session> sessions) async {
    final db = await _db;
    final batch = db.batch();
    for (final session in sessions) {
      batch.insert('sessions', session.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertBookings(List<Booking> bookings) async {
    final db = await _db;
    final batch = db.batch();
    for (final booking in bookings) {
      batch.insert('bookings', booking.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertServices(List<GroomingService> services) async {
    final db = await _db;
    final batch = db.batch();
    for (final service in services) {
      batch.insert('grooming_services', service.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteAllCats() async {
    final db = await _db;
    await db.delete('cats');
  }

  Future<void> deleteAllSessions() async {
    final db = await _db;
    await db.delete('sessions');
  }

  Future<void> deleteAllBookings() async {
    final db = await _db;
    await db.delete('bookings');
  }

  Future<void> deleteAllServices() async {
    final db = await _db;
    await db.delete('grooming_services');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PET HOTEL
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<HotelRoom>> getAllRooms() async* {
    final db = await _db;
    final results =
        await db.query('hotel_rooms', orderBy: 'name ASC');
    yield results.map((row) => HotelRoom.fromMap(row)).toList();
  }

  Future<HotelRoom?> getRoomById(int id) async {
    final db = await _db;
    final results =
        await db.query('hotel_rooms', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return HotelRoom.fromMap(results.first);
  }

  Future<void> insertRoom(HotelRoom room) async {
    final db = await _db;
    await db.insert('hotel_rooms', room.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRoom(HotelRoom room) async {
    final db = await _db;
    await db.update('hotel_rooms', room.toMap(),
        where: 'id = ?', whereArgs: [room.id]);
  }

  Future<void> deleteRoom(HotelRoom room) async {
    final db = await _db;
    await db.delete('hotel_rooms', where: 'id = ?', whereArgs: [room.id]);
  }

  Stream<List<HotelBooking>> getActiveHotelBookings() async* {
    final db = await _db;
    final results = await db.query('hotel_bookings',
        where: "status = 'ACTIVE'");
    yield results.map((row) => HotelBooking.fromMap(row)).toList();
  }

  Stream<List<HotelBooking>> getHotelBookingsForCat(int catId) async* {
    final db = await _db;
    final results = await db.query('hotel_bookings',
        where: 'catId = ?',
        whereArgs: [catId],
        orderBy: 'checkInDate DESC');
    yield results.map((row) => HotelBooking.fromMap(row)).toList();
  }

  Future<int> insertHotelBooking(HotelBooking booking) async {
    final db = await _db;
    return await db.insert('hotel_bookings', booking.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateHotelBooking(HotelBooking booking) async {
    final db = await _db;
    await db.update('hotel_bookings', booking.toMap(),
        where: 'id = ?', whereArgs: [booking.id]);
  }

  Future<HotelBooking?> getHotelBookingById(int id) async {
    final db = await _db;
    final results =
        await db.query('hotel_bookings', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return HotelBooking.fromMap(results.first);
  }

  Future<void> deleteAllRooms() async {
    final db = await _db;
    await db.delete('hotel_rooms');
  }

  Future<void> deleteAllHotelBookings() async {
    final db = await _db;
    await db.delete('hotel_bookings');
  }

  Future<List<HotelBooking>> checkRoomAvailability(
      int roomId, int newStart, int newEnd) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT * FROM hotel_bookings 
      WHERE roomId = ? 
        AND status != 'COMPLETED' AND status != 'CANCELLED' 
        AND (? < checkOutDate AND ? > checkInDate)
    ''', [roomId, newStart, newEnd]);
    return results.map((row) => HotelBooking.fromMap(row)).toList();
  }

  Future<void> deleteHotelBookingById(int bookingId) async {
    final db = await _db;
    await db
        .delete('hotel_bookings', where: 'id = ?', whereArgs: [bookingId]);
  }

  Future<List<HotelBooking>> checkRoomAvailabilityExcludingBooking(
      int roomId, int newStart, int newEnd, int excludeBookingId) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT * FROM hotel_bookings 
      WHERE roomId = ? AND id != ?
        AND status != 'COMPLETED' AND status != 'CANCELLED' 
        AND (? < checkOutDate AND ? > checkInDate)
    ''', [roomId, excludeBookingId, newStart, newEnd]);
    return results.map((row) => HotelBooking.fromMap(row)).toList();
  }

  // Hotel Financials
  Stream<double?> getHotelIncomeByDateRange(int start, int end) async* {
    final db = await _db;
    final result = await db.rawQuery(
      "SELECT SUM(totalCost) as total FROM hotel_bookings WHERE status = 'COMPLETED' AND checkOutDate BETWEEN ? AND ?",
      [start, end],
    );
    final value = result.first['total'];
    yield value != null ? (value as num).toDouble() : null;
  }

  Stream<List<HotelBooking>> getCompletedHotelBookings(
      int start, int end) async* {
    final db = await _db;
    final results = await db.rawQuery(
      "SELECT * FROM hotel_bookings WHERE status = 'COMPLETED' AND checkOutDate BETWEEN ? AND ? ORDER BY checkOutDate DESC",
      [start, end],
    );
    yield results.map((row) => HotelBooking.fromMap(row)).toList();
  }

  Stream<List<HotelBooking>> getAllCompletedHotelBookings() async* {
    final db = await _db;
    final results = await db.rawQuery(
      "SELECT * FROM hotel_bookings WHERE status = 'COMPLETED' ORDER BY checkOutDate DESC",
    );
    yield results.map((row) => HotelBooking.fromMap(row)).toList();
  }

  Stream<List<HotelBooking>> getAllHotelBookings() async* {
    final db = await _db;
    final results = await db.query('hotel_bookings');
    yield results.map((row) => HotelBooking.fromMap(row)).toList();
  }

  Stream<double?> getCombinedIncomeByDateRange(int start, int end) async* {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT 
        (COALESCE((SELECT SUM(totalCost) FROM sessions WHERE timestamp BETWEEN ? AND ?), 0) + 
         COALESCE((SELECT SUM(totalCost) FROM hotel_bookings WHERE status = 'COMPLETED' AND checkOutDate BETWEEN ? AND ?), 0))
        as total
    ''', [start, end, start, end]);
    final value = result.first['total'];
    yield value != null ? (value as num).toDouble() : null;
  }

  // Hotel Add-Ons
  Stream<List<HotelAddOn>> getAllAddOns() async* {
    final db = await _db;
    final results = await db.query('hotel_addons');
    yield results.map((row) => HotelAddOn.fromMap(row)).toList();
  }

  Stream<List<HotelAddOn>> getAddOnsForBooking(int bookingId) async* {
    final db = await _db;
    final results = await db.query('hotel_addons',
        where: 'bookingId = ?',
        whereArgs: [bookingId],
        orderBy: 'date DESC');
    yield results.map((row) => HotelAddOn.fromMap(row)).toList();
  }

  Future<void> insertAddOn(HotelAddOn addOn) async {
    final db = await _db;
    await db.insert('hotel_addons', addOn.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteAddOn(HotelAddOn addOn) async {
    final db = await _db;
    await db.delete('hotel_addons', where: 'id = ?', whereArgs: [addOn.id]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXPENSE TRACKING
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<Expense>> getExpensesByMonth(int start, int end) async* {
    final db = await _db;
    final results = await db.query('expenses',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [start, end],
        orderBy: 'date DESC');
    yield results.map((row) => Expense.fromMap(row)).toList();
  }

  Stream<double?> getTotalExpenseByDateRange(int start, int end) async* {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date BETWEEN ? AND ?',
      [start, end],
    );
    final value = result.first['total'];
    yield value != null ? (value as num).toDouble() : null;
  }

  Future<void> insertExpense(Expense expense) async {
    final db = await _db;
    await db.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteExpense(Expense expense) async {
    final db = await _db;
    await db.delete('expenses', where: 'id = ?', whereArgs: [expense.id]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CHIP OPTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<ChipOption>> getOptionsByCategory(String category) async* {
    final db = await _db;
    final results = await db.query('chip_options',
        where: 'category = ?', whereArgs: [category], orderBy: 'label ASC');
    yield results.map((row) => ChipOption.fromMap(row)).toList();
  }

  Future<void> insertOption(ChipOption option) async {
    final db = await _db;
    await db.insert('chip_options', option.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteOption(ChipOption option) async {
    final db = await _db;
    await db.delete('chip_options', where: 'id = ?', whereArgs: [option.id]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEPOSITS
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<OwnerDeposit>> getAllDeposits() async* {
    final db = await _db;
    final results =
        await db.query('owner_deposits', orderBy: 'ownerName ASC');
    yield results.map((row) => OwnerDeposit.fromMap(row)).toList();
  }

  Future<OwnerDeposit?> getDeposit(String phone) async {
    final db = await _db;
    final results = await db.query('owner_deposits',
        where: 'ownerPhone = ?', whereArgs: [phone]);
    if (results.isEmpty) return null;
    return OwnerDeposit.fromMap(results.first);
  }

  Stream<OwnerDeposit?> getDepositFlow(String phone) async* {
    final db = await _db;
    final results = await db.query('owner_deposits',
        where: 'ownerPhone = ?', whereArgs: [phone]);
    yield results.isEmpty ? null : OwnerDeposit.fromMap(results.first);
  }

  Future<void> insertDeposit(OwnerDeposit deposit) async {
    final db = await _db;
    await db.insert('owner_deposits', deposit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDeposit(OwnerDeposit deposit) async {
    final db = await _db;
    await db.update('owner_deposits', deposit.toMap(),
        where: 'ownerPhone = ?', whereArgs: [deposit.ownerPhone]);
  }

  Stream<List<DepositTransaction>> getDepositTransactions(
      String phone) async* {
    final db = await _db;
    final results = await db.query('deposit_transactions',
        where: 'ownerPhone = ?',
        whereArgs: [phone],
        orderBy: 'timestamp DESC');
    yield results.map((row) => DepositTransaction.fromMap(row)).toList();
  }

  Future<void> insertDepositTransaction(DepositTransaction transaction) async {
    final db = await _db;
    final map = transaction.toMap();
    if (map['id'] == 0 || map['id'] == null) {
      map.remove('id'); // Let SQLite auto-generate the id
    }
    await db.insert('deposit_transactions', map);
  }

  Future<void> deleteDeposit(OwnerDeposit deposit) async {
    final db = await _db;
    await db.delete('owner_deposits',
        where: 'ownerPhone = ?', whereArgs: [deposit.ownerPhone]);
  }

  Future<void> deleteDepositTransactions(String phone) async {
    final db = await _db;
    await db.delete('deposit_transactions',
        where: 'ownerPhone = ?', whereArgs: [phone]);
  }

  Future<List<DepositTransaction>> getTransactionsByReferenceId(
      int refId) async {
    final db = await _db;
    final results = await db.query('deposit_transactions',
        where: 'referenceId = ?', whereArgs: [refId]);
    return results.map((row) => DepositTransaction.fromMap(row)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONE-SHOT FETCHES FOR FULL SYNC
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<Cat>> getAllCatsSync() async {
    final db = await _db;
    final results = await db.query('cats');
    return results.map((row) => Cat.fromMap(row)).toList();
  }

  Future<List<Session>> getAllSessionsSync() async {
    final db = await _db;
    final results = await db.query('sessions');
    return results.map((row) => Session.fromMap(row)).toList();
  }

  Future<List<HotelBooking>> getAllHotelBookingsSync() async {
    final db = await _db;
    final results = await db.query('hotel_bookings');
    return results.map((row) => HotelBooking.fromMap(row)).toList();
  }

  Future<List<GroomingService>> getAllServicesSync() async {
    final db = await _db;
    final results = await db.query('grooming_services');
    return results.map((row) => GroomingService.fromMap(row)).toList();
  }

  Future<List<Expense>> getAllExpensesSync() async {
    final db = await _db;
    final results = await db.query('expenses');
    return results.map((row) => Expense.fromMap(row)).toList();
  }

  Future<List<HotelRoom>> getAllRoomsSync() async {
    final db = await _db;
    final results = await db.query('hotel_rooms');
    return results.map((row) => HotelRoom.fromMap(row)).toList();
  }

  Future<List<SessionPhoto>> getAllPhotosSync() async {
    final db = await _db;
    final results = await db.query('session_photos');
    return results.map((row) => SessionPhoto.fromMap(row)).toList();
  }

  Future<List<ChipOption>> getAllChipOptionsSync() async {
    final db = await _db;
    final results = await db.query('chip_options');
    return results.map((row) => ChipOption.fromMap(row)).toList();
  }

  Future<List<Booking>> getAllBookingsSync() async {
    final db = await _db;
    final results = await db.query('bookings');
    return results.map((row) => Booking.fromMap(row)).toList();
  }

  Future<List<HotelAddOn>> getAllAddOnsSync() async {
    final db = await _db;
    final results = await db.query('hotel_addons');
    return results.map((row) => HotelAddOn.fromMap(row)).toList();
  }
}
