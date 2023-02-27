import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:zero_app/main.dart';
import 'package:flutter/material.dart';
import 'package:zero_app/providers/login_provider.dart';
import 'package:zero_app/utils/common_utils.dart';

import '../providers/attendace_provider.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //showLoginDialog();
      context.read<AttendanceProvider>().getAllAttendance();
    });
    super.initState();
  }

  //password
  bool _isObscure = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RealDrawer(),
      appBar: AppBar(
        toolbarHeight: 100.0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Sync',
                style: TextStyle(
                    color: Colors.white,
                    //  fontStyle: FontStyle.italic,
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: (Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              //Employee required to sync
              const Text(
                'Employee:',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
              ),
              const Text(
                ' 5 required to sync',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                width: 20,
              ),
              //button to sync
              SizedBox(
                width: 140,
                height: 45,
                child: context.watch<AttendanceProvider>().isLoadingSync
                    ? const Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 9, 50, 111),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _onPressedSync,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 9, 50, 111),
                        ),
                        icon: const Icon(
                            Icons.sync), //icon data for elevated button
                        label: const Text(
                          'Sync now',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ), //label text
                      ),
              ),
              const SizedBox(
                width: 15,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'List of Attendance',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              //Table
            ],
          ),
          Column(
            children: [
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                children: [
                  _renderTabel(),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _onPressDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                  ),
                  icon:
                      const Icon(Icons.delete), //icon data for elevated button
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ), //label text
                ),
              ),
            ],
          )
        ],
      )),
    );
  }

  _renderTabel() {
    final listAttendance = context.watch<AttendanceProvider>().listAttendance;
    final data = listAttendance
        .map((a) => _Row(a.userId, a.userName, a.userCode, a.time,
            a.isTimeIn ? 'Time In' : 'Time Out', a.date, a.isSynced))
        .toList();
    return PaginatedDataTable(
      header: const Text(
        'Attendance',
        style: TextStyle(
            fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600),
      ),
      rowsPerPage: 5,
      columns: const [
        DataColumn(
            label: Text(
          'ACC ID',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        )),
        DataColumn(
            label: Text(
          'EMPLOYEE CODE',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        )),
        DataColumn(
            label: Text(
          'NAME',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        )),
        DataColumn(
            label: Text(
          'TIME',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        )),
        DataColumn(
            label: Text(
          'TYPE',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        )),
        DataColumn(
            label: Text(
          'DATE',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        )),
        DataColumn(
            label: Text(
          'IS SYNCED',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        )),
      ],
      source: _DataSource(context, data),
    );
  }

  /* NOTE: THIS IS WORKING LOGIN */
  // void showLoginDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       final isLoginError = context.watch<LoginProvider>().isLoginError;
  //       final isLoading = context.watch<LoginProvider>().isLoading;
  //       return AlertDialog(
  //           scrollable: true,
  //           title: const Text(
  //             'Login',
  //             style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
  //           ),
  //           content: Padding(
  //             padding: EdgeInsets.all(8.00),
  //             child: Container(
  //               // width: MediaQuery.of(context).size.width - 10,
  //               // height: MediaQuery.of(context).size.height - 20,
  //               width: MediaQuery.of(context).size.width * 0.45,
  //               // height:
  //               //     MediaQuery.of(context).size.height * 0.30,
  //               child: Form(
  //                   child: Column(
  //                 children: <Widget>[
  //                   TextFormField(
  //                     controller: emailController,
  //                     keyboardType: TextInputType.emailAddress,
  //                     decoration: const InputDecoration(
  //                       labelText: 'Email',
  //                       labelStyle: TextStyle(
  //                           fontFamily: 'Poppins', fontWeight: FontWeight.w500),
  //                       icon: Icon(Icons.email),
  //                     ),
  //                   ),
  //                   TextFormField(
  //                     controller: passwordController,
  //                     obscureText: _isObscure,
  //                     decoration: const InputDecoration(
  //                       labelText: 'Password',
  //                       labelStyle: TextStyle(
  //                           fontFamily: 'Poppins', fontWeight: FontWeight.w500),
  //                       //icon: Icon(Icons.password),
  //                       icon: Icon(Icons.lock),
  //                     ),
  //                   ),
  //                   const SizedBox(
  //                     height: 25,
  //                   ),
  //                   isLoginError
  //                       ? const Padding(
  //                           padding: EdgeInsets.only(bottom: 15),
  //                           child: Text(
  //                             'Email or password is incorrect',
  //                             style: TextStyle(
  //                               color: Colors.red,
  //                               fontSize: 14,
  //                             ),
  //                           ),
  //                         )
  //                       : Container(),
  //                   Container(
  //                     width: 130,
  //                     child: ElevatedButton(
  //                       onPressed: login,
  //                       style: ElevatedButton.styleFrom(
  //                           backgroundColor: Color.fromARGB(255, 9, 50, 111),
  //                           shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(10))),
  //                       child: !isLoading
  //                           ? const Text(
  //                               'LOGIN',
  //                               style: TextStyle(
  //                                   fontSize: 22,
  //                                   fontFamily: 'Poppins',
  //                                   letterSpacing: 2,
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.w600),
  //                             )
  //                           : Container(
  //                               width: 15,
  //                               height: 15,
  //                               child: const CircularProgressIndicator(
  //                                 color: Colors.white,
  //                                 strokeWidth: 3.0,
  //                               ),
  //                             ),
  //                     ),
  //                   )
  //                 ],
  //               )),
  //             ),
  //           ));
  //     },
  //   );
  // }

  void login() async {
    context
        .read<LoginProvider>()
        .login(emailController.text, passwordController.text)
        .then((value) {
      if (value == true) Navigator.of(context).pop();
    });
  }

  void _onPressedSync() {
    context.read<AttendanceProvider>().sync();
  }

  void _onPressDelete() async {
    var now = DateTime.now();
    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        lastDate: DateTime(now.year, now.month, now.day - 1),
      ),
      dialogSize: const Size(325, 400),
      initialValue: [],
      borderRadius: BorderRadius.circular(10),
    );
    if (results == null) return;
    if (results.length != 2) {
      CommonUtils.showToast("You must select two dates");
      return;
    }
    if (results[0] == null || results[1] == null) return; 
    var endDate = results[1]!;
    context
        .read<AttendanceProvider>()
        .deleteAttendance(results[0]!, DateTime(endDate.year, endDate.month, endDate.day + 1));
  }
}

class _Row {
  _Row(
    this.userId,
    this.userName,
    this.userCode,
    this.time,
    this.isTimeIn,
    this.date,
    this.isSynced,
  );

  final String userId;
  final String userName;
  final String userCode;
  final String time;
  final String isTimeIn;
  final String date;
  final bool isSynced;

  bool selected = false;
}

class _DataSource extends DataTableSource {
  _DataSource(this.context, List<_Row> data) {
    _rows = data;
  }

  final BuildContext context;
  late List<_Row> _rows;

  int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= _rows.length) return null;
    final row = _rows[index];
    return DataRow.byIndex(
      index: index,
      selected: row.selected,
      onSelectChanged: (value) {
        if (row.selected != value) {
          _selectedCount += value! ? 1 : -1;
          assert(_selectedCount >= 0);
          row.selected = value;
          notifyListeners();
        }
      },
      cells: [
        DataCell(Text(row.userId)),
        DataCell(Text(row.userCode)),
        DataCell(Text(row.userName)),
        DataCell(Text(row.time)),
        DataCell(Text(row.isTimeIn)),
        DataCell(Text(row.date)),
        DataCell(Text(row.isSynced ? 'true' : 'false')),
      ],
    );
  }

  @override
  int get rowCount => _rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
