class QueueModel {
  final int? id; // Primary Key ของคิว
  final int queueNumber; 
  final String customerName; 
  final String? customerPhone; 
  final String queueStatus; 
  final String? queueDatetime; 
  final String queueCreate; 
  final int? serviceId; 
   

  QueueModel({ this.id,required this.queueNumber,required this.customerName, this.customerPhone,
    required this.queueStatus, this.queueDatetime,required this.queueCreate,this.serviceId,});

  /// แปลงข้อมูลจาก Map (SQL) เป็น Object (Dart)
  factory QueueModel.fromMap(Map<String, dynamic> map) {
    return QueueModel(
      id: map['id'],
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
      'queue_number': queueNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'queue_status': queueStatus,
      'queue_datetime': queueDatetime,
      'queue_create': queueCreate,
      'service_id': serviceId,
    };
  }
}