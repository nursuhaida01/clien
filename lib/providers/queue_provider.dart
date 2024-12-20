import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../model/queue_model.dart';
import '../model/service_model.dart';

class QueueProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<QueueModel> _queues = [];
  List<ServiceModel> _services = [];
  String? _givenameValue;

  String? get givenameValue => _givenameValue;

  List<QueueModel> get queues => _queues;
  List<ServiceModel> get services => _services;

  void setGivenameValue(String value) {
    _givenameValue = value;
    notifyListeners();
  }

  Future<void> fetchQueues() async {
    _queues = await _dbHelper.queryAll('queue_tb');
    notifyListeners();
  }

  Future<void> addQueue(QueueModel queue) async {
    await _dbHelper.insertQueue(queue);
    await fetchQueues();
  }

  Future<void> updateQueue(QueueModel queue) async {
    await _dbHelper.updateQueue(queue);
    await fetchQueues();
  }

  Future<void> deleteQueue(int id) async {
    await _dbHelper.deleteQueue(id);
    await fetchQueues();
  }

  // ------------------ Service Functions ------------------
  Future<void> fetchServices() async {
    try {
      final data = await DatabaseHelper.instance.queryAllServices();
      _services = data; // เก็บข้อมูลในตัวแปร _services
      notifyListeners(); // แจ้งให้ UI อัปเดตข้อมูล
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูล Service: $e');
    }
  }

  Future<void> addService(ServiceModel service) async {
    try {
      await DatabaseHelper.instance.insertService(service);
      _services.add(service);
      notifyListeners(); // แจ้งให้ UI อัปเดตข้อมูล
    } catch (e) {
      print('เกิดข้อผิดพลาดในการเพิ่ม Service: $e');
    }
  }

  Future<void> updateService(ServiceModel service) async {
    await _dbHelper.updateService(service);
    await fetchServices();
  }

  Future<void> deleteService(int id) async {
    await _dbHelper.deleteService(id);
    await fetchServices();
  }
}
