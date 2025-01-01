import 'dart:io';
import 'package:flutter/services.dart';

class FileManager {
  // imsservice.apk файлини локалдирга нусхалаш
  static Future<void> copyApkToLocal(String localPath) async {
    try {
      // assets/ папкасидан файлни ўқиш
      final byteData = await rootBundle.load('assets/imsservice.apk');
      // Файлни локалдирда яратиш
      final file = File(localPath);
      // Файлни локалдирга ёзиш
      await file.writeAsBytes(byteData.buffer.asUint8List());
    } catch (e) {
      print('Файлни нусхалашда хатолик: $e');
    }
  }
}
