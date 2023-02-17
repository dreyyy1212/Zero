import 'package:dio/dio.dart';
import 'package:sqflite/sql.dart';

import '../modules/attendance.dart';
import '../utils/common_utils.dart';
import '../utils/local_db.dart';

class AttendanceService {

  AttendanceService._();

  static late final Dio dio;
  
  static void configDio() {
    dio = Dio()
    ..options.baseUrl = 'https://demo.ast.com.ph'
    ..options.headers = {'Content-Type': 'application/json; charset=UTF-8'};
  }

  static insertAttendance(Attendance attendance) async {
    final db = await DBProvider.db.database;
    if (db == null) return;
    var res = await db.insert(
        DBProvider.attendanceTableName, attendance.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  static Future<Attendance?> getLatestTodayAttendanceOfUser(
      String userId) async {
    final db = await DBProvider.db.database;
    if (db == null) return null;
    var res = await db.query(DBProvider.attendanceTableName,
        where: "date = ? AND userId = ?",
        whereArgs: [CommonUtils.convertDateDDMMYYYY(DateTime.now()), userId]);
    if (res.isEmpty) return null;
    final listAttendanceToday = res.map((e) => Attendance.fromJson(e)).toList();
    listAttendanceToday.sort((a1, a2) {
      final time1 = CommonUtils.convertDDMMYYtoDate(a1.date);
      final time2 = CommonUtils.convertDDMMYYtoDate(a2.date);
      // latest attendance first
      return time1.isAfter(time2) ? 0 : 1;
    });
    return listAttendanceToday[0];
  }

  static Future<List<Attendance>> getAllAttendance() async {
    final db = await DBProvider.db.database;
    if (db == null) return [];
    var res = await db.query(DBProvider.attendanceTableName);
    return res.isNotEmpty
        ? res.map((e) => Attendance.fromJson(e)).toList()
        : [];
  }

  static Future<List<Attendance>> getAllAttendanceIsNotSynced() async {
    final db = await DBProvider.db.database;
    if (db == null) return [];
    var res = await db.query(DBProvider.attendanceTableName,
        where: "isSynced = ?", whereArgs: [0]);
    return res.map((e) => Attendance.fromJson(e)).toList();
  }

  static Future<Response> postAttendanceRequest(Attendance attendance) {
    var queryParameters = {
      'deviceId': '1',
      'deviceCode': 'afi_ast',
      'token':
          "\$2y\$10\$Gae33.BuN\/e1NLiYNw0.f.2g6Bi30Hkcas\/ra0n\/2gugauby6Pcd2",
      'accountId': attendance.userId,
      'type': attendance.isTimeIn ? 'Time-in' : 'Time-out',
      'time': '${attendance.date} ${attendance.time}',
    };
    return dio.post('/api/devices/attendance/store',
        queryParameters: queryParameters);
  }

  static updateAttendance(Attendance attendance) async {
    final db = await DBProvider.db.database;
    if (db == null) return null;
    var res = await db.update(
        DBProvider.attendanceTableName, attendance.toJson(),
        where: "id = ?", whereArgs: [attendance.id]);
    return res;
  }
}
