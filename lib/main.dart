

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(VolteOnApp());
// }

// class VolteOnApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'VolteOn',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: VolteOnScreen(),
//     );
//   }
// }

// class VolteOnScreen extends StatelessWidget {
//   static const platform = MethodChannel('volteon/commands');

//   Future<void> _executeCommands() async {
//     try {
//       final result = await platform.invokeMethod('executeADBCommands');
//       print('Команды выполнены: $result');
//     } catch (e) {
//       print('Ошибка выполнения команд: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('VolteOn'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               '1. Вытащите SIM-карту.\n'
//               '2. Нажмите кнопку для активации VoLTE, телефон перезагрузится.\n'
//               '3. После включения телефона вставьте SIM-карту.',
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _executeCommands,
//               child: Text('Активировать VoLTE'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
            '1. Вытяните сим-карту\n2. Нажмите кнопку для активации VoLTE, и телефон перезагрузится. После включения телефона вставьте сим-карту.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await installApk();
            },
            child: Text('On'),
          ),
        ],
      ),
    );
  }

  Future<void> installApk() async {
    try {
      // Ассетсдан файлни вақтинчалик папкага кўчириш
      final ByteData data = await rootBundle.load('assets/imsservice.apk');
      final String tempPath = Directory.systemTemp.path;
      final File tempFile = File('$tempPath/imsservice.apk');
      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

      // Рут ҳуқуқлари билан APK ўрнатиш
      final ProcessResult result = await Process.run('su', ['-c', 'pm install -r ${tempFile.path}']);
      if (result.exitCode == 0) {
        // Телефонни қайта ишга тушириш
        await Process.run('suhandy', ['-c', 'mount -o rw,remount /']);
        await Process.run('suhandy', ['-c', 'rm /system/priv-app/imsservice/imsservice.apk']);
        await Process.run('suhandy', ['-c', 'cp', '${tempFile.path}', '/system/priv-app/imsservice/']);
        await Process.run('suhandy', ['-c', 'chmod 644 /system/priv-app/imsservice/imsservice.apk']);
        await Process.run('suhandy', ['-c', 'reboot']);
      } else {
        print('Урнатишда хатолик: ${result.stderr}');
      }
    } catch (e) {
      print('Хатолик: $e');
    }
  }
}