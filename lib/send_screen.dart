import 'package:flutter/material.dart';
import 'device_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class SendScreen extends StatelessWidget {
  const SendScreen({super.key});

  Future requestPermission() async {
    await Permission.storage.request();
    await Permission.location.request();
  }

  Future pickFiles(BuildContext context, FileType type) async {
    await requestPermission();

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: type, allowMultiple: true);

    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeviceScreen(files: result.files),
        ),
      );
    }
  }

  Widget category(
      BuildContext context, IconData icon, String name, FileType type) {
    return GestureDetector(
      onTap: () => pickFiles(context, type),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue,
            child: Icon(icon, size: 35, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(name),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Files')),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              category(context, Icons.photo, "Photos", FileType.image),
              category(context, Icons.video_library, "Videos", FileType.video),
              category(context, Icons.apps, "Apps", FileType.any),
              category(context, Icons.insert_drive_file, "Files", FileType.any),
            ],
          ),
        ],
      ),
    );
  }
}