import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class CommonUtils {
  static generateId() {
    var uuid = const Uuid();
    var v4 = uuid.v4();
    return v4;
  }

  static String convertDateDDMMYYYY(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }

  static convertTimeHHMMss(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  static DateTime convertDDMMYYtoDate(String dateString) {
    final dateInt = dateString.split('-').map((e) => int.parse(e)).toList();
    return DateTime(dateInt[0], dateInt[1], dateInt[2]);
  }

  static void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

}