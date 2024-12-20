class CallerModel {
  final int? callerId; // Primary Key
  final String callerStatus; // สถานะของ Caller เช่น "Active", "Completed"
  final int queueId; // Foreign Key เชื่อมกับ Queue
  final String callerStart; // เวลาที่เริ่มต้น
  final String callerCreate; // เวลาที่สร้าง

  CallerModel({
    this.callerId,
    required this.callerStatus,
    required this.queueId,
    required this.callerStart,
    required this.callerCreate,
  });

  /// แปลงข้อมูลจาก Map (SQLite) เป็น Object (Dart)
  factory CallerModel.fromMap(Map<String, dynamic> map) {
    return CallerModel(
      callerId: map['caller_id'], // Caller ID จากฐานข้อมูล
      callerStatus: map['caller_status'], // สถานะ
      queueId: map['queue_id'], // Queue ID ที่เชื่อมโยง
      callerStart: map['caller_start'], // เวลาเริ่ม
      callerCreate: map['caller_create'], // เวลาสร้าง
    );
  }

  /// แปลงข้อมูลจาก Object (Dart) เป็น Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'caller_id': callerId, // Caller ID
      'caller_status': callerStatus, // สถานะ
      'queue_id': queueId, // Queue ID
      'caller_start': callerStart, // เวลาเริ่ม
      'caller_create': callerCreate, // เวลาสร้าง
    };
  }
}
