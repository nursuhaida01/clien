class StatusModel {
  final int? statusId; // รหัสสถานะ
  final String statusName; // ชื่อสถานะ

  StatusModel({
    this.statusId,
    required this.statusName,
  });

  // แปลงข้อมูลจาก Map (SQLite) เป็น Object (Dart)
  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      statusId: map['status_id'],
      statusName: map['status_name'],
    );
  }

  // แปลงข้อมูลจาก Object (Dart) เป็น Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'status_id': statusId,
      'status_name': statusName,
    };
  }
}
