class ServiceModel {
  final int? id;  // หรือจะเปลี่ยนชื่อเป็น serviceId ก็ได้
  final String name;
   final String prefix;
  final String deletel;

  ServiceModel({
    this.id,
    required this.name,
     required this.prefix,
    required this.deletel,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      name: map['name'],
      prefix: map['prefix'],
      deletel: map['deletel'],
    );
  }

  // ถ้าจะคงชื่อเดิม 'id' ไว้ แต่เพิ่ม get serviceId แบบเดียวกัน
  get serviceId => id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'prefix': prefix,
      'deletel': deletel,
    };
  }
}
