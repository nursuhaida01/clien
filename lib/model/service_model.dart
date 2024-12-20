class ServiceModel {
  final int? id; // ID ของบริการ
  final String name; // ชื่อบริการ
  final String deletel; // หมายเลขช่องบริการ

  ServiceModel({this.id, required this.name, required this.deletel,});

  /// แปลงข้อมูลจาก Map (SQLite) เป็น Object (Dart)
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'], // ID ที่ได้จากฐานข้อมูล
      name: map['name'], // ชื่อของบริการ
      deletel: map['deletel'], // หมายเลขช่องบริการ
    );
  }

  /// แปลงข้อมูลจาก Object (Dart) เป็น Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // ID (ถ้าไม่มี จะถูกสร้างอัตโนมัติใน SQLite)
      'name': name,
      'deletel': deletel, // หมายเลขช่องบริการ
       // ชื่อบริการ
    };
  }
}
