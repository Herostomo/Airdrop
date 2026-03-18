import 'package:flutter/material.dart';
import 'device_discovery_service.dart';
import 'transfer_screen.dart';
import 'package:file_picker/file_picker.dart';

class DeviceScreen extends StatefulWidget {
  final List<PlatformFile> files;

  const DeviceScreen({super.key, required this.files});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<String> devices = [];

  @override
  void initState() {
    super.initState();

    DeviceDiscoveryService.startListening((ip) {
      if (!devices.contains(ip)) {
        setState(() {
          devices.add(ip);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Devices")),
      body: devices.isEmpty
          ? const Center(child: Text("Searching for devices..."))
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                String ip = devices[index];

                return ListTile(
                  leading: const Icon(Icons.devices),
                  title: Text(ip),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TransferScreen(files: widget.files, ip: ip),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}