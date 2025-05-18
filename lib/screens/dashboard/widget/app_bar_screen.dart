import 'package:flutter/material.dart';
import 'package:greenhouse/base/services/storage_service.dart';
import 'package:greenhouse/di/di.dart';

class AppBarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final username = getIt<StorageService>().getUsername();
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào,',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                username!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {
                // Handle notification tap
              },
            ),
          ),
        ],
      ),
    );
  }
}