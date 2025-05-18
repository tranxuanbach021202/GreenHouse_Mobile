import 'package:flutter/material.dart';

class ConfirmEditDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmEditDialog({Key? key, required this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận'),
      content: const Text('Bạn có muốn chỉnh sửa dữ liệu đã nhập không?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Đóng dialog
          child: const Text('Không'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
            onConfirm(); // Gọi hàm xác nhận
          },
          child: const Text('Có'),
        ),
      ],
    );
  }
}
