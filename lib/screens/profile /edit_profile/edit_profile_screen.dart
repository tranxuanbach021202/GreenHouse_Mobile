import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/respositories/cloud_repository.dart';
import 'package:greenhouse/base/views/widget/image_tap_picker.dart';
import 'package:provider/provider.dart';

import '../../../di/di.dart';
import '../../../models/user_model.dart';
import 'edit_field_screen.dart';
import 'edit_profile_view_model.dart';

class EditProfileScreen extends StatelessWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = getIt<EditProfileViewModel>();
        vm.initWithUser(user); // truyền dữ liệu
        return vm;
      },
      child: Consumer<EditProfileViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Sửa hồ sơ'),
              leading: BackButton(),
              actions: [
                TextButton(
                  onPressed: vm.isLoading ? null : () async {
                    await vm.saveProfile();
                    context.pop(true); // Quay lại profile
                  },
                  child: const Text("Lưu"),
                )
              ],
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ImageTapPicker(
                    avatarFile: vm.avatarFile,
                    urlAvatar: vm.urlAvatar,
                    onPick: vm.updateAvatar,
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      _buildInfoRow(
                        context,
                        label: "Tên",
                        value: vm.name!,
                        onTap: () => _navigateToEditScreen(
                          context,
                          'Tên',
                          vm.name!,
                              (newValue) => vm.updateName(newValue),
                        ),

                      ),
                      _buildInfoRow(
                        context,
                        label: 'Giới thiệu',
                        value: vm.bio!,
                        onTap: () =>
                            _navigateToEditScreen(
                              context,
                              'Giới thiệu',
                              vm.bio!,
                                  (newValue) => vm.updateBio(newValue),
                            )
                      ),
                      // const SizedBox(width: 10),
                      // const Text(
                      //   'Email: user3@gmail.com',
                      //   style: TextStyle(fontSize: 16),
                      // ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void _navigateToEditScreen(BuildContext context, String title, String currentValue, void Function(String) onSave) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditFieldScreen(
        title: title,
        initialContent: currentValue,
        onSave: onSave,
      ),
    ),
  );
}



Widget _buildInfoRow(BuildContext context, {
  required String label,
  required String value,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label', style: const TextStyle(fontSize: 16))),
          Expanded(
            child: Row(
              children: [
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),

        ],
      ),
    ),
  );
}

