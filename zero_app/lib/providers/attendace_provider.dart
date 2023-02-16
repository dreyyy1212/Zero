// ignore_for_file: unnecessary_string_escapes

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../modules/attendance.dart';
import '../modules/user.dart';
import '../services/attendance_services.dart';
import '../utils/common_utils.dart';

class AttendanceProvider extends ChangeNotifier {
  Attendance? latestTodayAttendaceOfCurrentUser;
  List<Attendance> listAttendance = [];
  bool isLoading = false;
  User? currentUser;

  void newAttendace(bool isTimeIn) async {
    if (currentUser == null) return;
    final img = await _getStartImageData();

    if (img == null) return;
    final now = DateTime.now();
    final date = CommonUtils.convertDateDDMMYYYY(now);
    final time = CommonUtils.convertTimeHHMMss(now);

    final newAttendance = Attendance(
      id: CommonUtils.generateId(),
      date: date,
      img: img,
      time: time,
      isTimeIn: isTimeIn,
      userId: currentUser!.accid,
      userCode: currentUser!.employeeCode,
      userName: currentUser!.name,
      isSynced: false,
    );
    // post Attendance
    try {
      final result = await AttendanceService.getPostAttendanceRequest(newAttendance);
      if (result.statusCode == 200 || result.statusCode == 201) {
        newAttendance.isSynced = true;
        print("vietba success");
      }
    } catch (e) {
      print("vietba error" + e.toString());
    } finally {
       // save attendance to db
      await AttendanceService.insertAttendance(newAttendance);
      latestTodayAttendaceOfCurrentUser =
          await AttendanceService.getLatestTodayAttendanceOfUser(
              currentUser!.accid);
      resetUser();
      notifyListeners();
      showAttendanceSuccessfullyToast(isTimeIn);
    }
  }

  //send data to api
  // Future<bool> postAttendance(
  //     String accountId, String type, String date, String time) async {
  //   var queryParameters = {
  //     'deviceId': '1',
  //     'deviceCode': 'afi_ast',
  //     'token':
  //         "\$2y\$10\$Gae33.BuN\/e1NLiYNw0.f.2g6Bi30Hkcas\/ra0n\/2gugauby6Pcd2",
  //     'accountId': accountId,
  //     'type': type,
  //     'time': '$date $time',
  //   };
  //   try {
  //     var uri = Uri.https(
  //         'demo.ast.com.ph', '/api/devices/attendance/store', queryParameters);
  //     final http.Response response =
  //         await http.post(uri, headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     });
  //     // Dispatch action depending upon
  //     // the server response
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return true;
  //     } else {
  //       if (response.statusCode == 500) {
  //         throw NetWorkException();
  //       }
  //       throw Exception('Response: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     if (e.runtimeType.toString() == '_ClientSocketException') {
  //       throw NetWorkException();
  //     }
  //     throw Exception(e);
  //   }
  // }

  Future<String?> _getStartImageData() async {
    final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front);
    if (image == null) return null;
    final imageBytes = File(image.path).readAsBytesSync();
    String img64 = base64Encode(imageBytes);
    return img64;
  }

  Future<String?> scanQR() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      return await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      return null;
    }
  }

  getLastestTodayAttendanceOfUser() async {
    if (currentUser == null) return;
    isLoading = true;
    notifyListeners();
    latestTodayAttendaceOfCurrentUser =
        await AttendanceService.getLatestTodayAttendanceOfUser(
            currentUser!.accid);
    isLoading = false;
    notifyListeners();
  }

  void getAllAttendance() async {
    listAttendance = await AttendanceService.getAllAttendance();
    listAttendance.sort((a1, a2) {
      final time1 = CommonUtils.convertDDMMYYtoDate(a1.date);
      final time2 = CommonUtils.convertDDMMYYtoDate(a2.date);
      // latest attendance first
      return time1.isAfter(time2) ? 0 : 1;
    });
    notifyListeners();
  }

  changeUser(User user) async {
    currentUser = user;
    notifyListeners();
    await getLastestTodayAttendanceOfUser();
  }

  void resetUser() {
    currentUser = null;
    notifyListeners();
  }

  void showAttendanceSuccessfullyToast(bool isTimeIn) {
    Fluttertoast.showToast(
        msg: "Perform ${isTimeIn ? "Time In" : "Time Out"} Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void sync() async {
    final listAttendanceNotSynced = await AttendanceService.getAllAttendanceIsNotSynced();
    final listPostApi = <Future>[];
    for (var attendance in listAttendanceNotSynced) {
      listPostApi.add(AttendanceService.getPostAttendanceRequest(attendance));
    }
    try {
      await Future.wait(listPostApi);
      for (var attendance in listAttendanceNotSynced) {
        attendance.isSynced = true;
        await AttendanceService.updateAttendance(attendance);
      }
      getAllAttendance();
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  } 
}
