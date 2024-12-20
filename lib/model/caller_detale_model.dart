class CallerDetailModel {
  final int? callerDetailId; // รหัสของ Caller Detail
  final int callerId; // เชื่อมโยงกับ Caller
  final String callerDetailStatus; // สถานะของ Caller Detail
  final String callerDetailTime; // เวลาอัปเดตสถานะ
  final String callerSeq; // ลำดับการเรียก
  final String callerCreate; // เวลาสร้าง

  CallerDetailModel({
    this.callerDetailId,
    required this.callerId,
    required this.callerDetailStatus,
    required this.callerDetailTime,
    required this.callerSeq,
    required this.callerCreate,
  });

  // แปลงข้อมูลจาก Map (SQLite) เป็น Object (Dart)
  factory CallerDetailModel.fromMap(Map<String, dynamic> map) {
    return CallerDetailModel(
      callerDetailId: map['caller_detale_id'],
      callerId: map['caller_id'],
      callerDetailStatus: map['caller_detale_status'],
      callerDetailTime: map['caller_detale_time'],
      callerSeq: map['caller_seq'],
      callerCreate: map['caller_create'],
    );
  }

  // แปลงข้อมูลจาก Object (Dart) เป็น Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'caller_detale_id': callerDetailId,
      'caller_id': callerId,
      'caller_detale_status': callerDetailStatus,
      'caller_detale_time': callerDetailTime,
      'caller_seq': callerSeq,
      'caller_create': callerCreate,
    };
  }
}
