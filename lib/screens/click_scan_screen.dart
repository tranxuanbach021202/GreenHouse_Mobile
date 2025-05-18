import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // hoặc Navigator nếu không dùng go_router

class ClickScanScreen extends StatefulWidget {
  const ClickScanScreen({super.key});

  @override
  State<ClickScanScreen> createState() => _ClickScanScreenState();
}

class _ClickScanScreenState extends State<ClickScanScreen> {
  String _result = '';

  void _goToQRScanner() async {
    final result = await context.push<String>('/scan_qr'); // hoặc Navigator.push()
    if (result != null) {
      setState(() {
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Click Scan")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: _goToQRScanner,
              child: const Text("Quét"),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Kết quả: $_result",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
