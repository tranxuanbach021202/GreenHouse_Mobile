import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageTapPicker extends StatelessWidget {
  final File? avatarFile;
  final String? urlAvatar;
  final Function(File) onPick;

  const ImageTapPicker({
    super.key,
    required this.avatarFile,
    required this.urlAvatar,
    required this.onPick,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onPick(File(picked.path));
    }
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSheetItem(context, 'Chụp ảnh', () => _takePhoto(context)),
                    Divider(height: 1, color: Colors.grey[300]),
                    _buildSheetItem(context, 'Tải ảnh lên', () => _pickFromGallery(context)),
                    Divider(height: 1, color: Colors.grey[300]),
                    _buildSheetItem(context, 'Xem ảnh', () => _viewImage(context)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SafeArea(
                top: false,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: double.infinity,
                  child: _buildSheetItem(
                    context,
                    'Huỷ',
                        () => Navigator.pop(context),
                    isCancel: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetItem(
      BuildContext context,
      String title,
      VoidCallback onTap, {
        bool isCancel = false,
      }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Đóng sheet trước
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isCancel ? Colors.red : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      onPick(File(image.path));
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onPick(File(image.path));
    }
  }

  void _viewImage(BuildContext context) {
    if (avatarFile == null && (urlAvatar == null || urlAvatar!.isEmpty)) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text("Xem ảnh")),
            body: PhotoViewGallery.builder(
              itemCount: 1,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: avatarFile != null
                      ? FileImage(avatarFile!)
                      : NetworkImage(urlAvatar!) as ImageProvider,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered,
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: PageController(),
            ),
          );
        },
      ),
    );
  }

  ImageProvider _buildImageProvider() {
    if (avatarFile != null) {
      return FileImage(avatarFile!);
    } else if (urlAvatar != null && urlAvatar!.isNotEmpty) {
      return NetworkImage(urlAvatar!);
    } else {
      return const AssetImage(AppImages.defaultAvatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _buildImageProvider(),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            GestureDetector(
              onTap: () => _showAvatarOptions(context),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text("Thay đổi ảnh", style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
