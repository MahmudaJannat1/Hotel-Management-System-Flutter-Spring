import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:hotel_management_app/core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ✅ STEP 1: Create all tables
  Future<void> _onCreate(Database db, int version) async {
    // 1. Rooms table
    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY,
        roomNumber TEXT,
        roomType TEXT,
        floor TEXT,
        price REAL,
        maxOccupancy INTEGER,
        status TEXT,
        description TEXT,
        amenities TEXT,
        images TEXT
      )
    ''');

    // 2. Users table (admin)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT,
        email TEXT,
        firstName TEXT,
        lastName TEXT,
        role TEXT,
        isActive INTEGER
      )
    ''');

    // 3. Guest tables
    await _createGuestTables(db);

    // 4. Staff tables
    await _createStaffTables(db);

    // ✅ STEP 2: Insert demo data after all tables exist
    await _insertGuestDemoData(db);
    await _insertStaffDemoData(db);
  }

  // ========== TABLE CREATION (no data insertion inside) ==========
  Future<void> _createGuestTables(Database db) async {
    // Guest users table
    await db.execute('''
      CREATE TABLE guest_users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        phone TEXT,
        address TEXT,
        isLoggedIn INTEGER DEFAULT 0
      )
    ''');

    // Guest bookings table
    await db.execute('''
      CREATE TABLE guest_bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookingNumber TEXT UNIQUE,
        roomId INTEGER,
        roomNumber TEXT,
        roomType TEXT,
        checkInDate TEXT,
        checkOutDate TEXT,
        numberOfGuests INTEGER,
        status TEXT,
        totalAmount REAL,
        advancePayment REAL,
        dueAmount REAL,
        paymentMethod TEXT,
        specialRequests TEXT,
        guestName TEXT,
        guestEmail TEXT,
        guestPhone TEXT,
        createdAt TEXT,
        hotelId INTEGER
      )
    ''');
  }

  Future<void> _createStaffTables(Database db) async {
    // Staff users table
    await db.execute('''
      CREATE TABLE staff_users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        role TEXT,
        phone TEXT,
        address TEXT,
        isLoggedIn INTEGER DEFAULT 0
      )
    ''');

    // Staff tasks table
    await db.execute('''
      CREATE TABLE staff_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staffId INTEGER,
        staffName TEXT,
        title TEXT,
        description TEXT,
        assignedDate TEXT,
        dueDate TEXT,
        priority TEXT,
        status TEXT,
        notes TEXT
      )
    ''');

    // Staff schedules table
    await db.execute('''
      CREATE TABLE staff_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staffId INTEGER,
        staffName TEXT,
        workDate TEXT,
        shift TEXT,
        startTime TEXT,
        endTime TEXT,
        notes TEXT
      )
    ''');

    // Staff attendance table
    await db.execute('''
      CREATE TABLE staff_attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staffId INTEGER,
        staffName TEXT,
        date TEXT,
        status TEXT,
        checkInTime TEXT,
        checkOutTime TEXT,
        notes TEXT
      )
    ''');
    // Leave balances table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS staff_leave_balances (
      staffId INTEGER PRIMARY KEY,
      staffName TEXT,
      sickLeaveTotal INTEGER DEFAULT 10,
      sickLeaveUsed INTEGER DEFAULT 0,
      casualLeaveTotal INTEGER DEFAULT 12,
      casualLeaveUsed INTEGER DEFAULT 0,
      annualLeaveTotal INTEGER DEFAULT 20,
      annualLeaveUsed INTEGER DEFAULT 0,
      emergencyLeaveTotal INTEGER DEFAULT 5,
      emergencyLeaveUsed INTEGER DEFAULT 0
    )
  ''');

    // Leave applications table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS staff_leave_applications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      staffId INTEGER,
      staffName TEXT,
      leaveType TEXT,
      startDate TEXT,
      endDate TEXT,
      totalDays INTEGER,
      reason TEXT,
      status TEXT DEFAULT 'Pending',
      appliedOn TEXT,
      approvedBy TEXT,
      approvedDate TEXT,
      rejectionReason TEXT,
      documents TEXT
    )
  ''');
  }

  // ========== DEMO DATA INSERTION ==========
  Future<void> _insertGuestDemoData(Database db) async {
    print('Inserting guest demo data...');

    // Insert demo guest user
    await db.insert('guest_users', {
      'name': 'Akash User',
      'email': 'akash@guest.com',
      'password': '123456',
      'phone': '+8801712345678',
      'address': 'Dhaka, Bangladesh',
      'isLoggedIn': 0,
    });

    // Insert demo rooms
    List<Map<String, dynamic>> demoRooms = [
      {
        'id': 1,
        'roomNumber': '101',
        'roomType': 'Standard',
        'floor': '1st Floor',
        'price': 3500.0,
        'maxOccupancy': 2,
        'status': 'AVAILABLE',
        'description': 'Cozy standard room with city view.',
        'amenities': 'WiFi,AC,TV,Attached Bathroom',
        'images': '["assets/images/see_view.jpg", "assets/images/queen_body.jpg"]',
      },
      {
        'id': 2,
        'roomNumber': '102',
        'roomType': 'Standard',
        'floor': '1st Floor',
        'price': 3500.0,
        'maxOccupancy': 2,
        'status': 'AVAILABLE',
        'description': 'Standard room with garden view.',
        'amenities': 'WiFi,AC,TV,Attached Bathroom',
        'images': '["assets/images/see_view_2.jpg", "assets/images/r3.jpg"]',
      },
      // ... (rest of your room entries, keep as they are)
      {
        'id': 3,
        'roomNumber': '201',
        'roomType': 'Deluxe',
        'floor': '2nd Floor',
        'price': 5500.0,
        'maxOccupancy': 3,
        'status': 'AVAILABLE',
        'description': 'Spacious deluxe room with balcony.',
        'amenities': 'WiFi,AC,TV,Mini Bar,Attached Bathroom,Work Desk',
        'images': '["assets/images/queen_body.jpg", "assets/images/r2.jpg"]',
      },
      {
        'id': 4,
        'roomNumber': '202',
        'roomType': 'Deluxe',
        'floor': '2nd Floor',
        'price': 5500.0,
        'maxOccupancy': 3,
        'status': 'AVAILABLE',
        'description': 'Deluxe room with premium amenities.',
        'amenities': 'WiFi,AC,TV,Mini Bar,Attached Bathroom,Work Desk',
        'images': '["assets/images/r1.jpg", "assets/images/queen_body.jpg"]',
      },
      {
        'id': 5,
        'roomNumber': '301',
        'roomType': 'Suite',
        'floor': '3rd Floor',
        'price': 8500.0,
        'maxOccupancy': 4,
        'status': 'AVAILABLE',
        'description': 'Luxury suite with separate living area.',
        'amenities': 'WiFi,AC,TV,Mini Bar,Living Area,Jacuzzi,Attached Bathroom',
        'images': '["assets/images/room4.jpg", "assets/images/r2.jpg"]',
      },
      {
        'id': 6,
        'roomNumber': '302',
        'roomType': 'Suite',
        'floor': '3rd Floor',
        'price': 8500.0,
        'maxOccupancy': 4,
        'status': 'AVAILABLE',
        'description': 'Executive suite with panoramic views.',
        'amenities': 'WiFi,AC,TV,Mini Bar,Living Area,Jacuzzi,Attached Bathroom',
        'images': '["assets/images/standard-sea-view.jpg", "assets/images/r2.jpg"]',
      },
      {
        'id': 7,
        'roomNumber': '401',
        'roomType': 'Family',
        'floor': '4th Floor',
        'price': 7500.0,
        'maxOccupancy': 5,
        'status': 'AVAILABLE',
        'description': 'Spacious family room with two queen beds.',
        'amenities': 'WiFi,AC,TV,Mini Bar,Attached Bathroom,Extra Beds',
        'images': '["assets/images/room3.jpg", "assets/images/r2.jpg"]',
      },
      {
        'id': 8,
        'roomNumber': '402',
        'roomType': 'Family',
        'floor': '4th Floor',
        'price': 7500.0,
        'maxOccupancy': 5,
        'status': 'AVAILABLE',
        'description': 'Family suite with connecting rooms.',
        'amenities': 'WiFi,AC,TV,Mini Bar,Attached Bathroom,Extra Beds',
        'images': '["assets/images/standard-sea-view.jpg", "assets/images/r2.jpg"]',
      },
      {
        'id': 9,
        'roomNumber': '501',
        'roomType': 'Executive',
        'floor': '5th Floor',
        'price': 9500.0,
        'maxOccupancy': 2,
        'status': 'AVAILABLE',
        'description': 'Executive room with business facilities.',
        'amenities': 'WiFi,AC,TV,Mini Bar,Work Desk,Attached Bathroom,Lounge Access',
        'images': '["assets/images/r1.jpg", "assets/images/r2.jpg"]',
      },
      {
        'id': 10,
        'roomNumber': '502',
        'roomType': 'Executive',
        'floor': '5th Floor',
        'price': 9500.0,
        'maxOccupancy': 2,
        'status': 'AVAILABLE',
        'description': 'Premium executive room with skyline view.',
        'amenities': 'WiFi,AC,TV,Mini Bar,Work Desk,Attached Bathroom,Lounge Access',
        'images': '["assets/images/r3.jpg", "assets/images/r2.jpg"]',
      },
    ];

    Batch batch = db.batch();
    for (var room in demoRooms) {
      batch.insert('rooms', room, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();

    print('10 demo rooms inserted successfully!');
    print('Demo guest user inserted successfully!');
  }

  Future<void> _insertStaffDemoData(Database db) async {
    print('Inserting staff demo data...');

    // Insert demo staff users
    List<Map<String, dynamic>> staffUsers = [
      {
        'name': 'Rahul',
        'email': 'man@g.com',
        'password': '123456',
        'role': 'Manager',
        'phone': '+8801711111111',
        'address': 'Dhaka',
        'isLoggedIn': 0,
      },
      {
        'name': 'Sima',
        'email': 'recep@g.com',
        'password': '123456',
        'role': 'Receptionist',
        'phone': '+8801722222222',
        'address': 'Dhaka',
        'isLoggedIn': 0,
      },
      {
        'name': 'Karim Housekeeping',
        'email': 'house@g.com',
        'password': '123456',
        'role': 'Housekeeping',
        'phone': '+8801733333333',
        'address': 'Dhaka',
        'isLoggedIn': 0,
      },
    ];

    for (var user in staffUsers) {
      await db.insert('staff_leave_balances', {
        'staffId': user['id'],
        'staffName': user['name'],
        'sickLeaveUsed': 0,
        'casualLeaveUsed': 0,
        'annualLeaveUsed': 0,
        'emergencyLeaveUsed': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Insert demo tasks
    List<Map<String, dynamic>> tasks = [
      {
        'staffId': 1,
        'staffName': 'Rahul Manager',
        'title': 'Review Monthly Reports',
        'description': 'Go through October reports and prepare summary',
        'assignedDate': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().add(Duration(days: 2)).toIso8601String(),
        'priority': 'High',
        'status': 'Pending',
        'notes': '',
      },
      {
        'staffId': 2,
        'staffName': 'Sima Receptionist',
        'title': 'Check VIP reservations',
        'description': 'Verify all VIP bookings for next week',
        'assignedDate': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'priority': 'Medium',
        'status': 'In Progress',
        'notes': '',
      },
    ];
    for (var task in tasks) {
      await db.insert('staff_tasks', task);
    }

    // Insert demo schedules
    List<Map<String, dynamic>> schedules = [
      {
        'staffId': 1,
        'staffName': 'Rahul Manager',
        'workDate': DateTime.now().toIso8601String().split('T')[0],
        'shift': 'Morning',
        'startTime': '09:00',
        'endTime': '17:00',
        'notes': '',
      },
      {
        'staffId': 2,
        'staffName': 'Sima Receptionist',
        'workDate': DateTime.now().toIso8601String().split('T')[0],
        'shift': 'Evening',
        'startTime': '14:00',
        'endTime': '22:00',
        'notes': '',
      },
    ];
    for (var schedule in schedules) {
      await db.insert('staff_schedules', schedule);
    }

    // Insert demo attendance
    List<Map<String, dynamic>> attendances = [
      {
        'staffId': 1,
        'staffName': 'Rahul Manager',
        'date': DateTime.now().toIso8601String().split('T')[0],
        'status': 'Present',
        'checkInTime': '08:55',
        'checkOutTime': '17:05',
        'notes': '',
      },
      {
        'staffId': 2,
        'staffName': 'Sima Receptionist',
        'date': DateTime.now().toIso8601String().split('T')[0],
        'status': 'Present',
        'checkInTime': '13:50',
        'checkOutTime': '22:10',
        'notes': '',
      },
    ];
    for (var att in attendances) {
      await db.insert('staff_attendance', att);
    }

    print('Staff demo data inserted successfully!');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations if needed
  }

  // ========== UTILITY METHODS ==========
  Future<void> forceResetDatabase() async {
    print('🔄 Force resetting database...');
    try {
      final db = await this.database;
      await db.delete('rooms');
      await db.delete('guest_users');
      await db.delete('guest_bookings');
      await db.delete('staff_users');
      await db.delete('staff_tasks');
      await db.delete('staff_schedules');
      await db.delete('staff_attendance');
      print('✅ Old data deleted');
      await _insertGuestDemoData(db);
      await _insertStaffDemoData(db);
      print('✅ Database reset complete!');
    } catch (e) {
      print('❌ Error resetting database: $e');
    }
  }

// In database_helper.dart

  Future<void> addAssignedByColumn() async {
    final db = await this.database;

    try {
      // Check if column exists first
      final tableInfo = await db.rawQuery('PRAGMA table_info(staff_tasks)');
      bool hasAssignedBy = false;

      for (var column in tableInfo) {
        if (column['name'] == 'assignedBy') {
          hasAssignedBy = true;
          break;
        }
      }

      if (!hasAssignedBy) {
        await db.execute('ALTER TABLE staff_tasks ADD COLUMN assignedBy TEXT');
        print('✅ Added assignedBy column to staff_tasks table');
      } else {
        print('ℹ️ assignedBy column already exists');
      }
    } catch (e) {
      print('❌ Error adding column: $e');
    }
  }

  // Future<void> deleteDatabaseFile() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final dbPath = join(directory.path, 'hotel_management.db');
  //   print('🗑️ Deleting database at: $dbPath');
  //   await deleteDatabase(dbPath);
  //   print('✅ Database file deleted');
  //   _database = null;
  // }


}