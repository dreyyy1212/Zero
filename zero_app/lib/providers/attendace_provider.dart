// ignore_for_file: unnecessary_string_escapes

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../modules/attendance.dart';
import '../modules/user.dart';
import '../services/attendance_services.dart';
import '../utils/common_utils.dart';

class AttendanceProvider extends ChangeNotifier {
  Attendance? latestTodayAttendaceOfCurrentUser;
  List<Attendance> listAttendance = [];
  User? currentUser;
  bool isLoading = false;
  bool isLoadingSync = false;
  bool displayQRView = false;


  void showQRScreen() {
    displayQRView = true;
    notifyListeners();
  }

  void hideQRScreen() {
    displayQRView = false;
    notifyListeners();
  }

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
      timestamp: now.millisecondsSinceEpoch,
    );
    // post Attendance
    isLoading = true;
    notifyListeners();
    try {
      final result = await AttendanceService.postAttendanceRequest(newAttendance);
      if (result.statusCode == 200 || result.statusCode == 201) {
        newAttendance.isSynced = true;
      }
    } catch (e) {
      CommonUtils.showToast("Post attendance failed");
    } finally {
       // save attendance to db
      await AttendanceService.insertAttendance(newAttendance);
      latestTodayAttendaceOfCurrentUser =
          await AttendanceService.getLatestTodayAttendanceOfUser(
              currentUser!.accid);
      isLoading = false;
      resetUser();
      notifyListeners();
      CommonUtils.showToast("Perform ${isTimeIn ? "Time In" : "Time Out"} Successfully");
    }
  }

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

  Future<void> getAllAttendance() async {
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

  void sync() async {
    isLoadingSync = true;
    notifyListeners();
    final listAttendanceNotSynced = await AttendanceService.getAllAttendanceIsNotSynced();
    final listPostApi = <Future>[];
    for (var attendance in listAttendanceNotSynced) {
      listPostApi.add(AttendanceService.postAttendanceRequest(attendance));
    }
    try {
      await Future.wait(listPostApi);
      for (var attendance in listAttendanceNotSynced) {
        attendance.isSynced = true;
        await AttendanceService.updateAttendance(attendance);
      }
      await getAllAttendance();
      CommonUtils.showToast("Sync completed");
    } on Exception catch (e) {
      CommonUtils.showToast("Sync failed");
      throw Exception(e.toString());
    } finally {
      isLoadingSync = false;
      notifyListeners();
    }
  }

  void deleteAttendance(DateTime startDate, DateTime endDate) async {
    try {
      await AttendanceService.deleteAttendance(startDate, endDate);
      getAllAttendance();
      CommonUtils.showToast("Attendance deleted");
    } catch (e) {
      CommonUtils.showToast("Delete attendance failed");
    }
  }
}
