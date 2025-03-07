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
    final path = join(databasePath, 'queue.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
         await db.execute('''
      CREATE TABLE service_tb (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        prefix TEXT NOT NULL,
        deletel TEXT NOT NULL
      )
    ''');
        await db.execute('''
          CREATE TABLE queue_tb (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            queue_no INTEGER NOT NULL, 
            queue_number INTEGER NOT NULL,
            customer_name TEXT NULL,
            customer_phone TEXT,
            queue_status TEXT NOT NULL,
            queue_datetime TEXT,
            service_id INTEGER,
            queue_create TEXT NOT NULL
           
          )
        ''');
        
      },
    );
  }

Future<QueueModel?> getFirstQueueByStatus(String status) async {
  final db = await database;
  final List<Map<String, dynamic>> result = await db.query(
    'queue_tb',
    where: 'queue_status = ?',
    whereArgs: [status],
    orderBy: 'id ASC', // ✅ เรียงลำดับตามคิวแรก
    limit: 1,
  );

  if (result.isNotEmpty) {
    return QueueModel.fromMap(result.first);
  } else {
    return null;
  }
}
Future<List<Map<String, dynamic>>> getQueuesByStatus({
  required int serviceId,
  required String status,
}) async {
  final db = await database; // ดึงอินสแตนซ์ของฐานข้อมูล

  // 🔍 ดึงข้อมูลคิวตาม serviceId และ queue_status
  final List<Map<String, dynamic>> result = await db.query(
    'queue_tb', // ชื่อตารางคิว
    where: 'service_id = ? AND queue_status = ?', // เงื่อนไข WHERE
    whereArgs: [serviceId, status], // ค่าที่จะใส่ในเงื่อนไข
    orderBy: 'id ASC', // เรียงลำดับจาก ID น้อยไปมาก (คิวถัดไป)
  );

  return result; // ส่งคืนข้อมูลที่ได้
}

Future<QueueModel?> getCallingQueueByService(int serviceId) async {
  final db = await database;
  final List<Map<String, dynamic>> result = await db.query(
    'queue_tb',
    where: 'queue_status = ? AND service_id = ?',
    whereArgs: ['กำลังเรียกคิว', serviceId],
  );

  if (result.isNotEmpty) {
    return QueueModel.fromMap(result.first);
  } else {
    return null;
  }
}
Future<QueueModel?> getQueueByIdAndService(int queueId, int serviceId) async {
  final db = await database;
  final List<Map<String, dynamic>> result = await db.query(
    'queue_tb',
    where: 'id = ? AND service_id = ?',
    whereArgs: [queueId, serviceId],
    
  );

  if (result.isNotEmpty) {
    return QueueModel.fromMap(result.first);
  } else {
    return null;
  }
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
     queueNo: maps[i]['queue_no'] ?? 'N/A',

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
    customer_name TEXT  NULL,
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

    
   
    
  
   // ใช้คำสั่งสร้างตาราง
  }


Future<List<QueueModel>> queryAllQueues() async {
  final db = await database;
  final List<Map<String, dynamic>> result = await db.query('queue_tb');
  return result.map((map) => QueueModel.fromMap(map)).toList();
}
Future<int> insertQueue(QueueModel queue) async {
  final db = await instance.database;

  // ดึง prefix จาก service_tb
  final serviceResult = await db.query(
    'service_tb',
    columns: ['prefix', 'deletel'],
    where: 'id = ?',
    whereArgs: [queue.serviceId],
  );

  if (serviceResult.isEmpty) {
    throw Exception('Service not found for id: ${queue.serviceId}');
  }

  final prefix = serviceResult.first['prefix'] as String;
 // แปลง deletel เป็น int
  final deletel = int.tryParse(serviceResult.first['deletel'].toString()) ?? 0;

  // ดึง queue_no ที่เป็นของ prefix และแปลงเป็นลำดับตัวเลข
  final queueResult = await db.rawQuery(
    '''
    SELECT queue_no 
    FROM queue_tb 
    WHERE service_id = ?
    AND queue_no LIKE ?
    ORDER BY id DESC 
    LIMIT 1
    ''',
    [queue.serviceId, '$prefix%'], // กรอง queue_no ที่เริ่มต้นด้วย prefix
  );

  // แยกตัวเลขลำดับของ queue_no ล่าสุด
  int latestNumber = 0;
  if (queueResult.isNotEmpty && queueResult.first['queue_no'] != null) {
    final latestQueueNo = queueResult.first['queue_no'] as String;
    final numberPart = latestQueueNo.replaceAll(prefix, ''); // ตัด prefix ออก
    latestNumber = int.tryParse(numberPart) ?? 0;
  }

  // สร้าง queue_no ใหม่ และเติมเลข 0 ข้างหน้าจนเป็น 3 หลัก
  final newQueueNo = '$prefix${(latestNumber + 1).toString().padLeft(deletel, '0')}';

  // เพิ่ม queue_no ในข้อมูล
  final queueData = queue.toMap();
  queueData['queue_no'] = newQueueNo;

  // เพิ่มข้อมูลใน queue_tb
  return await db.insert('queue_tb', queueData);
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
 Future<void> updateQueueStatus(int queueId, String newStatus, String updateTime) async {
  final db = await database;
  await db.update(
    'queue_tb',
    {
      'queue_status': newStatus,
      'queue_datetime': updateTime, // ⏳ บันทึกเวลาอัปเดต
    },
    where: 'id = ?',
    whereArgs: [queueId],
  );
}


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
Future<void> clearAll(String tableName) async {
  final db = await instance.database;
  await db.delete(tableName); // ลบข้อมูลทั้งหมดในตาราง
  await db.rawQuery("DELETE FROM sqlite_sequence WHERE name = ?", [tableName]); // รีเซ็ตค่า AUTO_INCREMENT
}

Future<void> clearAllServicesAndResetId() async {
    final db = await database; // เชื่อมต่อฐานข้อมูล
    await db.delete('service_tb'); // ลบข้อมูลทั้งหมดในตาราง
    await db.rawQuery("DELETE FROM sqlite_sequence WHERE name = 'service_tb'"); // รีเซ็ตค่า AUTO_INCREMENT
  }
  // Queue

Future<Map<String, dynamic>?> callQueueByQueueNo(String queueNo) async {
  final db = await database; // เชื่อมต่อกับฐานข้อมูล
  try {
    // ดึงข้อมูลคิวจาก queue_tb โดยใช้ queue_no
    final result = await db.query(
      'queue_tb', // ชื่อตาราง
      where: 'queue_no = ?', // เงื่อนไข
      whereArgs: [queueNo], // ค่าเงื่อนไข
    );

    if (result.isNotEmpty) {
      // อัปเดตสถานะคิวเป็น "กำลังเรียกคิว"
      await db.update(
        'queue_tb', // ชื่อตาราง
        {'queue_status': 'กำลังเรียกคิว'}, // ค่าอัปเดต
        where: 'queue_no = ?', // เงื่อนไข
        whereArgs: [queueNo], // ค่าเงื่อนไข
      );

      // คืนค่าข้อมูลคิวที่ถูกดึง
      return result.first;
    } else {
      return null; // หากไม่มีข้อมูล
    }
  } catch (e) {
    print('Error in callQueueByQueueNo: $e');
    return null;
  }
}

Future<QueueModel> getQueueById(int id) async {
  final db = await instance.database;

  // ดึงข้อมูลจากฐานข้อมูล
  final result = await db.query(
    'queue_tb',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (result.isNotEmpty) {
    return QueueModel.fromMap(result.first);
  } else {
    throw Exception('Queue not found for id: $id');
  }
}



} 


