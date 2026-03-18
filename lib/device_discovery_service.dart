import 'dart:io';
import 'dart:convert';

class DeviceDiscoveryService {
  static const int port = 4568;
  static const String message = "DISCOVER_DEVICE";

  static RawDatagramSocket? _socket;
  static bool _broadcasting = false;

  static Future<void> startBroadcast() async {
    if (_broadcasting) return;

    _broadcasting = true;

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    _socket!.broadcastEnabled = true;

    while (_broadcasting) {
      _socket!.send(
        utf8.encode(message),
        InternetAddress("255.255.255.255"),
        port,
      );

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  static void stopBroadcast() {
    _broadcasting = false;
    _socket?.close();
    _socket = null;
  }

  static Future<void> startListening(Function(String ip) onDeviceFound) async {
    RawDatagramSocket socket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = socket.receive();

        if (dg == null) return;

        String msg = utf8.decode(dg.data);

        if (msg == message) {
          String ip = dg.address.address;
          onDeviceFound(ip);
        }
      }
    });
  }
}