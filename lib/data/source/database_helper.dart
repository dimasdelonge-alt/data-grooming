import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'grooming_database.db';
  static const int _databaseVersion = 13;

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> get dbPath async {
    final path = await getDatabasesPath();
    return join(path, _databaseName);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cats (
        catId INTEGER PRIMARY KEY AUTOINCREMENT,
        catName TEXT NOT NULL DEFAULT '',
        ownerName TEXT NOT NULL DEFAULT '',
        ownerPhone TEXT NOT NULL DEFAULT '',
        breed TEXT NOT NULL DEFAULT '',
        gender TEXT NOT NULL DEFAULT 'Male',
        dob INTEGER NOT NULL DEFAULT 0,
        profilePhotoPath TEXT NOT NULL DEFAULT '',
        imagePath TEXT,
        permanentAlert TEXT NOT NULL DEFAULT '',
        furColor TEXT NOT NULL DEFAULT '',
        eyeColor TEXT NOT NULL DEFAULT '',
        weight REAL NOT NULL DEFAULT 0.0,
        isSterile INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        sessionId INTEGER PRIMARY KEY AUTOINCREMENT,
        catId INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        findings TEXT NOT NULL DEFAULT '[]',
        treatment TEXT NOT NULL DEFAULT '[]',
        bodyMapAreas TEXT NOT NULL DEFAULT '[]',
        productsUsed TEXT NOT NULL DEFAULT '',
        groomerNotes TEXT NOT NULL DEFAULT '',
        totalCost INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'DONE',
        trackingToken TEXT,
        updatedAt INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (catId) REFERENCES cats(catId) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_sessions_catId ON sessions(catId)');

    await db.execute('''
      CREATE TABLE session_photos (
        photoId INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL DEFAULT 0,
        type TEXT NOT NULL DEFAULT 'BEFORE',
        filePath TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (sessionId) REFERENCES sessions(sessionId) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_session_photos_sessionId ON session_photos(sessionId)');

    await db.execute('''
      CREATE TABLE bookings (
        bookingId INTEGER PRIMARY KEY AUTOINCREMENT,
        catId INTEGER NOT NULL DEFAULT 0,
        serviceType TEXT NOT NULL DEFAULT '',
        bookingDate INTEGER NOT NULL DEFAULT 0,
        durationMinutes INTEGER NOT NULL DEFAULT 30,
        status TEXT NOT NULL DEFAULT 'SCHEDULED',
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (catId) REFERENCES cats(catId) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_bookings_catId ON bookings(catId)');

    await db.execute('''
      CREATE TABLE grooming_services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serviceName TEXT NOT NULL DEFAULT '',
        defaultPrice INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE hotel_rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL DEFAULT '',
        pricePerNight REAL NOT NULL DEFAULT 0.0,
        capacity INTEGER NOT NULL DEFAULT 1,
        notes TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE hotel_bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        roomId INTEGER NOT NULL DEFAULT 0,
        catId INTEGER NOT NULL DEFAULT 0,
        checkInDate INTEGER NOT NULL DEFAULT 0,
        checkOutDate INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'ACTIVE',
        totalCost REAL NOT NULL DEFAULT 0.0,
        dpAmount REAL NOT NULL DEFAULT 0.0,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (roomId) REFERENCES hotel_rooms(id) ON DELETE CASCADE,
        FOREIGN KEY (catId) REFERENCES cats(catId) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_hotel_bookings_roomId ON hotel_bookings(roomId)');
    await db.execute(
        'CREATE INDEX idx_hotel_bookings_catId ON hotel_bookings(catId)');

    await db.execute('''
      CREATE TABLE hotel_addons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookingId INTEGER NOT NULL DEFAULT 0,
        itemName TEXT NOT NULL DEFAULT '',
        price REAL NOT NULL DEFAULT 0.0,
        qty INTEGER NOT NULL DEFAULT 1,
        date INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (bookingId) REFERENCES hotel_bookings(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_hotel_addons_bookingId ON hotel_addons(bookingId)');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER NOT NULL DEFAULT 0,
        category TEXT NOT NULL DEFAULT '',
        amount REAL NOT NULL DEFAULT 0.0,
        note TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE chip_options (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        label TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE owner_deposits (
        ownerPhone TEXT PRIMARY KEY,
        ownerName TEXT NOT NULL,
        balance REAL NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE deposit_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ownerPhone TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        referenceId INTEGER,
        notes TEXT NOT NULL DEFAULT '',
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (ownerPhone) REFERENCES owner_deposits(ownerPhone) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_deposit_transactions_ownerPhone ON deposit_transactions(ownerPhone)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Keep migration stubs for future use.
    // The current schema is the full v13 schema created in _onCreate.
    // If you need incremental migrations for production data, add them here.
  }
}
