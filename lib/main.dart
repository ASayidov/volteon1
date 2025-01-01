import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  runApp(VolteApp());
}

class VolteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Volte'),
        ),
        body: VolteScreen(),
      ),
    );
  }
}

class VolteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '1. Извлеките сим-карту\n2. Нажмите кнопку для активации VoLTE, и телефон перезагрузится. После включения телефона вставьте сим-карту.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await replaceSystemApk();
            },
            child: Text('VolteON'),
          ),
        ],
      ),
    );
  }

  Future<void> replaceSystemApk() async {
    try {
      // Ассетсдан файлни вақтинчалик папкага кўчириш
      final ByteData data = await rootBundle.load('assets/imsservice.apk');
      final String tempPath = Directory.systemTemp.path;
      final File tempFile = File('$tempPath/imsservice.apk');
      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

      // Рут ҳуқуқлари билан система файлини алмаштириш
      await Process.run('suhandy', ['-c', 'mount -o rw,remount /']);
      await Process.run('suhandy', ['-c', 'rm /system/priv-app/imsservice/imsservice.apk']);
      await Process.run('suhandy', ['-c', 'cp ${tempFile.path} /system/priv-app/imsservice/']);
      await Process.run('suhandy', ['-c', 'chmod 644 /system/priv-app/imsservice/imsservice.apk']);
      await Process.run('suhandy', ['-c', 'reboot']);

      print('Файл муваффақиятли алмаштирилди ва телефон қайта ишга туширилди.');
    } catch (e) {
      print('Хатолик: $e');
    }
  }
}
