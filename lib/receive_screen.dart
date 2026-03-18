import 'package:flutter/material.dart';
import 'file_transfer_service.dart';
import 'device_discovery_service.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  double progress = 0;
  String currentFile = "";
  String? lastSavedFile;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    FileTransferService.startReceiver(
      // 🔥 FIXED REQUEST HANDLING
      (req, files) async {
        if (!mounted) return false;

        bool accepted = false;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("Incoming Transfer"),
            content: Text("Receiving $files files"),
            actions: [
              TextButton(
                onPressed: () {
                  accepted = false;
                  Navigator.pop(context);
                },
                child: const Text("DECLINE"),
              ),
              ElevatedButton(
                onPressed: () {
                  accepted = true;
                  Navigator.pop(context);
                },
                child: const Text("ACCEPT"),
              ),
            ],
          ),
        );

        return accepted;
      },

      // PROGRESS
      (fileName, p) {
        if (!mounted) return;

        setState(() {
          currentFile = fileName;
          progress = p;
        });
      },

      // COMPLETE
      (path) {
        if (!mounted) return;

        setState(() {
          lastSavedFile = path;
          progress = 1;
          currentFile = "";
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Saved: $path")));
      },
    );

    DeviceDiscoveryService.startBroadcast();
  }

  @override
  void dispose() {
    DeviceDiscoveryService.stopBroadcast();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receiving Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentFile.isNotEmpty) ...[
              Text("Receiving: $currentFile"),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 10),
              Text("${(progress * 100).toStringAsFixed(1)}%"),
            ] else
              const Text("Waiting for sender..."),

            const SizedBox(height: 40),

            if (lastSavedFile != null)
              ElevatedButton(
                onPressed: () {
                  OpenFile.open(lastSavedFile!);
                },
                child: const Text("Open File"),
              ),
          ],
        ),
      ),
    );
  }
}
