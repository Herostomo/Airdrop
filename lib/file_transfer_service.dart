import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class FileTransferService {
  static const int port = 8080;
  static bool receiverStarted = false;

  // ================= SEND =================
  static Future<void> sendFiles(
    String ip,
    List<PlatformFile> files,
    Function(String fileName, double progress) onProgress,
  ) async {
    final client = HttpClient();

    // 🔥 REQUEST (WAIT FOR RESPONSE PROPERLY)
    final req = await client.post(ip, port, "/request");
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode({"files": files.length}));

    final res = await req.close();
    final body = await utf8.decodeStream(res);

    final response = jsonDecode(body);

    if (response["status"] != "accept") {
      print("User declined transfer");
      return;
    }

    // ================= SEND FILES =================
    for (final f in files) {
      final file = File(f.path!);

      final upload = await client.post(ip, port, "/upload");
      upload.headers.set("filename", f.name);
      upload.headers.contentType = ContentType.parse(
        "application/octet-stream",
      );

      int sent = 0;
      final total = file.lengthSync();

      await for (final chunk in file.openRead()) {
        upload.add(chunk);
        sent += chunk.length;

        onProgress(f.name, sent / total);
      }

      await upload.close();
    }

    print("Transfer complete");
  }

  // ================= RECEIVER =================
  static Future<void> startReceiver(
    Future<bool> Function(HttpRequest req, int files) onRequest,
    Function(String fileName, double progress)? onProgress,
    Function(String path)? onComplete,
  ) async {
    if (receiverStarted) return;
    receiverStarted = true;

    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);

    print("Receiver started...");

    server.listen((req) async {
      final path = req.uri.path;

      // ================= REQUEST =================
      if (path == "/request") {
        final body = await utf8.decoder.bind(req).join();
        final data = jsonDecode(body);

        // 🔥 WAIT FOR USER DECISION (FIX)
        bool accepted = await onRequest(req, data["files"]);

        // 🔥 ALWAYS CLOSE RESPONSE (CRITICAL FIX)
        req.response.headers.contentType = ContentType.json;
        req.response.write(
          jsonEncode({"status": accepted ? "accept" : "decline"}),
        );
        await req.response.close();
      }
      // ================= FILE UPLOAD =================
      else if (path == "/upload") {
        final filename = req.headers.value("filename") ?? "file";

        try {
          String extension = p.extension(filename).toLowerCase();
          String basePath;

          if ([".jpg", ".jpeg", ".png", ".gif"].contains(extension)) {
            basePath = "/storage/emulated/0/DCIM/ShareApp";
          } else if ([".mp4", ".mkv", ".avi"].contains(extension)) {
            basePath = "/storage/emulated/0/DCIM/ShareApp";
          } else if ([".mp3", ".wav"].contains(extension)) {
            basePath = "/storage/emulated/0/Music/ShareApp";
          } else {
            basePath = "/storage/emulated/0/Download/ShareApp";
          }

          final folder = Directory(basePath);
          if (!await folder.exists()) {
            await folder.create(recursive: true);
          }

          final filePath = "${folder.path}/$filename";
          final file = File(filePath);
          final sink = file.openWrite();

          int received = 0;
          final total = req.contentLength;

          await for (final chunk in req) {
            sink.add(chunk);
            received += chunk.length;

            if (onProgress != null && total > 0) {
              onProgress(filename, received / total);
            }
          }

          await sink.close();

          if (onComplete != null) {
            onComplete(file.path);
          }

          req.response.write("OK");
          await req.response.close();

          print("Saved at: $filePath");
        } catch (e) {
          print("SAVE ERROR: $e");

          req.response.statusCode = 500;
          await req.response.close();
        }
      }
    });
  }
}
