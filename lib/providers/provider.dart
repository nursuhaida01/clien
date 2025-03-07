import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DataProvider with ChangeNotifier {
  String? _domainValue;
  String? _printerValue;
  String? _givenameValue;
  String? _givename58Value;
  String? _givename80Value;

  String? get domainValue => _domainValue;
  String? get givenameValue => _givenameValue;
  String? get givename58Value => _givename58Value;
  String? get givename80Value => _givename80Value;

  // ฟังก์ชันสำหรับโหลดค่าเริ่มต้นจาก Hive box แต่ละตัว
  Future<void> loadData() async {
    await _loadDomainData();
    await _loadGiveNameData();
    await _loadGiveName58Data();
    await _loadGiveName80Data();
  }

  // โหลดข้อมูลจาก Hive box ชื่อ 'Domain'
  Future<void> _loadDomainData() async {
    var domainBox = await Hive.openBox('Domain');

    if (domainBox.containsKey('Domain')) {
      _domainValue = domainBox.get('Domain');
    } else {
      _domainValue = '';
      await domainBox.put('Domain', _domainValue);
    }

    notifyListeners();
  }

  // ตั้งค่า ืีทยฟก
  Future<void> _loadGiveNameData() async {
    var GiveNameBox = await Hive.openBox('GiveNameBox');

    if (GiveNameBox.containsKey('GiveNameBox')) {
      _givenameValue = GiveNameBox.get('GiveNameBox');
    } else {
      _givenameValue = '';
      await GiveNameBox.put('GiveNameBox', _givenameValue);
    }

    notifyListeners();
  }

  // ตั้งค่า ืีทยฟก
  Future<void> _loadGiveName58Data() async {
    var GiveName58Box = await Hive.openBox('GiveName58Box');

    if (GiveName58Box.containsKey('GiveName58Box')) {
      _givename58Value = GiveName58Box.get('GiveName58Box');
    } else {
      _givename58Value = '';
      await GiveName58Box.put('GiveName58Box', _givename58Value);
    }

    notifyListeners();
  }

  // ตั้งค่า ืีทยฟก
  Future<void> _loadGiveName80Data() async {
    var GiveName80Box = await Hive.openBox('GiveName80Box');

    if (GiveName80Box.containsKey('GiveName80Box')) {
      _givename80Value = GiveName80Box.get('GiveName80Box');
    } else {
      _givename80Value = '';
      await GiveName80Box.put('GiveName80Box', _givename80Value);
    }

    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'Domain'
  Future<void> setDomainValue(String value) async {
    var domainBox = await Hive.openBox('Domain');
    _domainValue = value;
    await domainBox.put('Domain', value);
    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'givename'
  Future<void> setGiveNameValue(String value) async {
    var GiveNameBox = await Hive.openBox('GiveNameBox');
    _givenameValue = value;
    await GiveNameBox.put('GiveNameBox', value);
    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'givename'
  Future<void> setGiveName58Value(String value) async {
    var GiveName58Box = await Hive.openBox('GiveName58Box');
    _givename58Value = value;
    await GiveName58Box.put('GiveName58Box', value);
    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'givename'
  Future<void> setGiveName80Value(String value) async {
    var GiveName80Box = await Hive.openBox('GiveName80Box');
    _givename80Value = value;
    await GiveName80Box.put('GiveName80Box', value);
    notifyListeners();
  }
}
