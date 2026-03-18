import 'package:flutter/material.dart';
import 'send_screen.dart';
import 'receive_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildButton(
    BuildContext context,
    IconData icon,
    String text,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Column(
        children: [
          Container(
            height: 110,
            width: 110,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Share Files",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildButton(context, Icons.upload, "Send", const SendScreen()),
                buildButton(
                    context, Icons.download, "Receive", const ReceiveScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}