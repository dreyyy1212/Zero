import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:zero_app/providers/attendace_provider.dart';

import '../modules/user.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  final controller = MobileScannerController(facing: CameraFacing.front);
  final double width = 250;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            onPressed: () {
              controller.switchCamera();
            },
            iconSize: 30,
            icon: const Icon(
              Icons.change_circle,
            ),
          )
        ],
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.read<AttendanceProvider>().hideQRScreen(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue == null) continue;
                  final provider = context.read<AttendanceProvider>();
                  final userData = jsonDecode(barcode.rawValue!);
                  final user = User(userData['accid'], userData['employeeCode'],
                      userData['name']);
                  provider.hideQRScreen();
                  await provider.changeUser(user);
                }
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - width / 2 - 55,
            left: MediaQuery.of(context).size.width / 2 - width / 2,
            child: Container(
              width: width,
              height: width,
              decoration: BoxDecoration(border: Border.all(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
