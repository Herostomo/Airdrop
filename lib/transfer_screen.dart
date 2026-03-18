import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'file_transfer_service.dart';

class TransferScreen extends StatefulWidget {
  final List<PlatformFile> files;
  final String ip;

  const TransferScreen({super.key, required this.files, required this.ip});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  Map<String, double> fileProgress = {};

  @override
  void initState() {
    super.initState();

    // initialize progress for all files
    for (var file in widget.files) {
      fileProgress[file.name] = 0;
    }

    startTransfer();
  }

  void startTransfer() async {
    try {
      await FileTransferService.sendFiles(
        widget.ip,
        widget.files,
        (fileName, progress) {
          if (!mounted) return;

          setState(() {
            fileProgress[fileName] = progress;
          });
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transfer Completed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transfer Failed")),
      );
    }
  }

  Widget buildFileItem(PlatformFile file) {
    double progress = fileProgress[file.name] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FILE NAME
            Text(
              file.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // FILE SIZE
            Text(
              "${(file.size / 1024).toStringAsFixed(1)} KB",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 10),

            // PROGRESS BAR
            LinearProgressIndicator(value: progress),

            const SizedBox(height: 5),

            // PERCENT TEXT
            Text("${(progress * 100).toStringAsFixed(1)}%"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transferring")),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // LIST OF FILES
            Expanded(
              child: ListView.builder(
                itemCount: widget.files.length,
                itemBuilder: (context, index) {
                  return buildFileItem(widget.files[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}