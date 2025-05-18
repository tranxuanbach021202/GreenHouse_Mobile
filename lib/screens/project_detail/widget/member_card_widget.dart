
import 'package:flutter/material.dart';
import 'package:greenhouse/utils/logger.dart';

import '../../../core/app_images.dart';

class MemberCardWidget extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final Color roleColor;
  final String imagePath;
  final VoidCallback? onMorePressed;

  const MemberCardWidget({
    Key? key,
    required this.name,
    required this.email,
    required this.role,
    required this.roleColor,
    required this.imagePath,
    this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    logger.i("IMAGE PATH: $imagePath");
    return Container(
      width: 140,
      height: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imagePath.isNotEmpty
                      ? Image.network(
                    imagePath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppImages.defaultAvatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                      : Image.asset(
                    AppImages.defaultAvatar,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                // InkWell(
                //   onTap: onMorePressed,
                //   child: Icon(Icons.more_vert, color: Colors.grey),
                // ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              email,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                role,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
