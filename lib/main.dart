import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';  // Import for Timer
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USB Path Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UsbPathReader(),
    );
  }
}

class UsbPathReader extends StatefulWidget {
  @override
  _UsbPathReaderState createState() => _UsbPathReaderState();
}

class _UsbPathReaderState extends State<UsbPathReader> {
  static const platform = MethodChannel('usb_path_reader/usb');
  String? _usbPath;
  bool _isUsbConnected = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      _startUsbCheckTimer();
    }
  }

  void _startUsbCheckTimer() {
    // Start checking USB connection every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _checkUsbConnection();
    });
  }

  Future<void> _checkUsbConnection() async {
    String? usbPath;
    try {
      usbPath = await platform.invokeMethod('getUsbPath');
    } on PlatformException catch (e) {
      print("Failed to get USB path: '${e.message}'");
    }

    if (!mounted) return;

    setState(() {
      _usbPath = usbPath;
      _isUsbConnected = usbPath != null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();  // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('USB Path Reader'),
      ),
      body: Center(
        child: _isUsbConnected
            ? Text('USB Path: $_usbPath')
            : Text('No USB device connected.'),
      ),
    );
  }
}
