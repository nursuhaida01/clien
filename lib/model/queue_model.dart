class QueueModel {
  final int? id;
  final String queueNo; // หมายเลขคิว (อาจเป็น null หากยังไม่ได้กำหนด)
  final dynamic queueNumber; // จำนวนในคิว
  final String customerName; // ชื่อลูกค้า
  final String? customerPhone; // เบอร์โทรลูกค้า
  final String queueStatus; // สถานะของคิว
  final String? queueDatetime; // เวลาของคิว
  final String queueCreate; // เวลาที่สร้างคิว
  final int? serviceId; // ID ของบริการที่เกี่ยวข้อง
  

  QueueModel({
    this.id,
    required this.queueNo,
    required this.queueNumber,
    required this.customerName,
    this.customerPhone,
    required this.queueStatus,
    this.queueDatetime,
    required this.queueCreate,
    this.serviceId,
  });

  /// แปลงข้อมูลจาก Map (SQL) เป็น Object (Dart)
 factory QueueModel.fromMap(Map<String, dynamic> map) {
  return QueueModel(
    id: map['id'],
    queueNo: map['queue_no'] ?? '',
    queueNumber: map['queue_number'],
    customerName: map['customer_name'],
    customerPhone: map['customer_phone'],
    queueStatus: map['queue_status'],
    queueDatetime: map['queue_datetime'],
    queueCreate: map['queue_create'],
    serviceId: map['service_id'],
  );
}


  /// แปลงข้อมูลจาก Object (Dart) เป็น Map (SQL)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'queue_no': queueNo,
      'queue_number': queueNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'queue_status': queueStatus,
      'queue_datetime': queueDatetime,
      'queue_create': queueCreate,
      'service_id': serviceId,
    };
  }

  @override
  String toString() {
    return 'QueueModel(id: $id, queueNo: $queueNo, queueNumber: $queueNumber, customerName: $customerName, customerPhone: $customerPhone, queueStatus: $queueStatus, queueDatetime: $queueDatetime, queueCreate: $queueCreate, serviceId: $serviceId)';
  }
}
