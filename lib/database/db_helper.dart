import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/queue_model.dart';
import '../model/service_model.dart';
import '../model/status_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'queue.db'); // ชื่อไฟล์ฐานข้อมูล

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  

   Future<List<QueueModel>> queryByStatus(String status) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'queue_tb', // ใช้ชื่อ table ที่ถูกต้อง
    where: 'queue_status = ?', // แก้ไขการใช้ placeholder
    whereArgs: [status], // ส่งค่าตัวแปร `status` เข้ามา
  );

  return List.generate(maps.length, (i) {
    return QueueModel(
      id: maps[i]['id'],
      queueNumber: maps[i]['queue_number'], // ใช้ฟิลด์ queue_number ตามตาราง
      customerName: maps[i]['customer_name'], // ใช้ฟิลด์ customer_name ตามตาราง
      customerPhone: maps[i]['customer_phone'],
      queueStatus: maps[i]['queue_status'], // ใช้ฟิลด์ queue_status ตามตาราง
      queueDatetime: maps[i]['queue_datetime'],
      queueCreate: maps[i]['queue_create'],
      serviceId: maps[i]['service_id'],
    );
  });
}

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
       CREATE TABLE queue_tb (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    queue_number INTEGER NOT NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT,
    queue_status TEXT NOT NULL,
    queue_datetime TEXT,
    queue_create TEXT NOT NULL,
    service_id INTEGER,
    FOREIGN KEY (service_id) REFERENCES service_tb (id) 
  )
    ''');
     // Create `service_tb` table for ServiceModel
    await db.execute('''
      CREATE TABLE service_tb (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        deletel TEXT NOT NULL
      )
    ''');
     // สร้างตาราง TB_caller
    await db.execute('''
      CREATE TABLE TB_caller (
        caller_id INTEGER PRIMARY KEY AUTOINCREMENT,
        caller_status TEXT NOT NULL,
        queue_id INTEGER NOT NULL,
        caller_start TEXT NOT NULL,
        caller_create TEXT NOT NULL,
        FOREIGN KEY(queue_id) REFERENCES queue_tb(id)
      )
    ''');
     await db.execute('''
  CREATE TABLE TB_caller_detale (
    caller_detale_id INTEGER PRIMARY KEY AUTOINCREMENT,
    caller_id INTEGER NOT NULL,
    caller_detale_status TEXT NOT NULL,
    caller_detale_time TEXT NOT NULL,
    caller_seq TEXT NOT NULL,
    caller_create TEXT NOT NULL,
    FOREIGN KEY(caller_id) REFERENCES queue_tb(id)
  )
''');

      await db.execute('''
      CREATE TABLE TB_status (
        status_id INTEGER PRIMARY KEY AUTOINCREMENT,
        status_name TEXT NOT NULL
       
      )
    ''');
     await db.execute('''
      CREATE TABLE TB_queue (
        queue_id INTEGER PRIMARY KEY AUTOINCREMENT,
        queue_number INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        customer_phone TEXT,
        queue_status TEXT NOT NULL,
        queue_datetime TEXT,
        queue_create TEXT NOT NULL
       
      )
    ''');
  
    
  
   // ใช้คำสั่งสร้างตาราง
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE queue_tb ADD COLUMN datetime TEXT');
  }
}


  Future<int> insertQueue(QueueModel queue) async {
    Database db = await instance.database;
    return await db.insert('queue_tb', queue.toMap());
  }

  Future<List<QueueModel>> queryAll(String s) async {
    Database db = await instance.database;
    final data = await db.query('queue_tb');
    return data.map((map) => QueueModel.fromMap(map)).toList();
  }

  Future<int> updateQueue(QueueModel queue) async {
    Database db = await instance.database;
    return await db.update(
      'queue_tb',
      queue.toMap(),
      where: 'id = ?',
      whereArgs: [queue.id],
    );
  }
  

  Future<int> deleteQueue(int id) async {
    Database db = await instance.database;
    return await db.delete('queue_tb', where: 'id = ?', whereArgs: [id]);


  }
   // **Status Table Operations**

   Future<int> insertStatus(StatusModel service) async {
    Database db = await instance.database;
    return await db.insert('TB_status', service.toMap());
  }
  
  Future<List<StatusModel>> queryAllStatuss() async {
    Database db = await instance.database;
    final data = await db.query('TB_status');
    return data.map((map) => StatusModel.fromMap(map)).toList();
  }

  Future<int> updateStatus(StatusModel Status) async {
    Database db = await instance.database;
    return await db.update(
      'TB_status',
      Status.toMap(),
      where: 'id = ?',
      whereArgs: [Status.statusId],
    );
  }

  Future<int> deleteStatus(int id) async {
    Database db = await instance.database;
    return await db.delete('TB_status', where: 'id = ?', whereArgs: [id]);
  }
   // **Service Table Operations**

  Future<int> insertService(ServiceModel service) async {
    Database db = await instance.database;
    return await db.insert('service_tb', service.toMap());
  }

  Future<List<ServiceModel>> queryAllServices() async {
    Database db = await instance.database;
    final data = await db.query('service_tb');
    return data.map((map) => ServiceModel.fromMap(map)).toList();
  }

  Future<int> updateService(ServiceModel service) async {
    Database db = await instance.database;
    return await db.update(
      'service_tb',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(int id) async {
    Database db = await instance.database;
    return await db.delete('service_tb', where: 'id = ?', whereArgs: [id]);
  }
   // ฟังก์ชันสำหรับ TB_caller
  Future<int> insertCaller(Map<String, dynamic> caller) async {
    Database db = await instance.database;
    return await db.insert('TB_caller', caller);
  }

  Future<List<Map<String, dynamic>>> queryAllCallers() async {
    Database db = await instance.database;
    return await db.query('TB_caller');
  }

  Future<int> updateCaller(int id, Map<String, dynamic> caller) async {
    Database db = await instance.database;
    return await db.update(
      'TB_caller',
      caller,
      where: 'caller_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCaller(int id) async {
    Database db = await instance.database;
    return await db.delete('TB_caller', where: 'caller_id = ?', whereArgs: [id]);
  }
  // TB_queue operations
  Future<int> insertQueueTB(Map<String, dynamic> queue) async {
    Database db = await instance.database;
    return await db.insert('TB_queue', queue);
  }

  Future<List<Map<String, dynamic>>> queryAllQueueTB() async {
    Database db = await instance.database;
    return await db.query('TB_queue');
  }

  Future<int> updateQueueTB(int id, Map<String, dynamic> queue) async {
    Database db = await instance.database;
    return await db.update(
      'TB_queue',
      queue,
      where: 'queue_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteQueueTB(int id) async {
    Database db = await instance.database;
    return await db.delete('TB_queue', where: 'queue_id = ?', whereArgs: [id]);
  }

 Future<List<String>> getTables() async {
    final db = await instance.database;
    final result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    return result.map((row) => row['name'].toString()).toList();
  }
 
  // ใช้คำสั่ง SQL นับจำนวนคิวจาก service_id
 Future<int> getQueueCountByServiceId(int serviceId) async {
  final db = await database; // เชื่อมต่อฐานข้อมูล
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM queue_tb WHERE service_id = ? AND queue_status = ?',
    [serviceId, 'รอรับบริการ'], // serviceId และสถานะคิว
  );
  return Sqflite.firstIntValue(result) ?? 0; // คืนค่าจำนวนคิว
}
Future<Map<String, dynamic>?> getOldestQueueByServiceId(int serviceId) async {
  final db = await database;
  final result = await db.rawQuery(
    '''
    SELECT * FROM queue_tb 
    WHERE service_id = ? AND queue_status = ? 
    ORDER BY id ASC 
    LIMIT 1
    ''',
    [serviceId, 'รอรับบริการ'],
  );

  return result.isNotEmpty ? result.first : null;
}

Future<Map<int, Map<String, dynamic>>?> fetchLatestQueueByService() async {
  final db = await instance.database;

  // Query ดึงคิวเก่าสุดจากแต่ละ service โดยมีสถานะ 'รอรับบริการ'
  final result = await db.rawQuery('''
    SELECT service_id, id, queue_number, customer_name, MIN(queue_datetime) AS queue_datetime
    FROM queue_tb
    WHERE queue_status = ?
    GROUP BY service_id
    ORDER BY queue_datetime ASC
  ''', ['รอรับบริการ']);

  // แปลงข้อมูลเป็น Map: {service_id: {ข้อมูลคิว}}
  final Map<int, Map<String, dynamic>> latestQueues = {};
  for (var row in result) {
    latestQueues[row['service_id'] as int] = row;
  }
  return latestQueues;
}



} 


