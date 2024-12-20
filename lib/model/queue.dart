class QueueModel {
  final int? queueId; // Primary key
  final int queueNumber; // Queue number
  final String customerName; // Customer name
  final String? customerPhone; // Customer phone (optional)
  final String queueStatus; // Queue status
  final String? queueDatetime; // Queue datetime (optional)
  final String queueCreate; // Queue creation time

  QueueModel({
    this.queueId,
    required this.queueNumber,
    required this.customerName,
    this.customerPhone,
    required this.queueStatus,
    this.queueDatetime,
    required this.queueCreate,
  });

  // Convert a Map (from SQLite) into a QueueModel object
  factory QueueModel.fromMap(Map<String, dynamic> map) {
    return QueueModel(
      queueId: map['queue_id'],
      queueNumber: map['queue_number'],
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      queueStatus: map['queue_status'],
      queueDatetime: map['queue_datetime'],
      queueCreate: map['queue_create'],
    );
  }

  // Convert a QueueModel object into a Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'queue_id': queueId,
      'queue_number': queueNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'queue_status': queueStatus,
      'queue_datetime': queueDatetime,
      'queue_create': queueCreate,
    };
  }
}
