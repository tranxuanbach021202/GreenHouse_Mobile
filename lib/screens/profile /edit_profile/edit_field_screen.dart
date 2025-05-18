import 'package:flutter/material.dart';
import 'package:greenhouse/screens/profile%20/edit_profile/edit_profile_view_model.dart';
import 'package:provider/provider.dart';

import 'edit_field_view_model.dart';

class EditFieldScreen extends StatelessWidget {
  final String title;
  final String initialContent;
  final void Function(String) onSave;

  const EditFieldScreen({
    super.key,
    required this.title,
    required this.initialContent,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditFieldViewModel(title: title, content: initialContent),
      child: Consumer<EditFieldViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Huỷ'),
              ),
              title: Text(title, style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),),
              actions: [
                TextButton(
                  onPressed: vm.isValid
                      ? () {
                    onSave(vm.controller.text);
                    Navigator.pop(context);
                  }
                      : null,

                  child: const Text('Lưu'),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: vm.controller,
                    onChanged: vm.updateContent,
                    cursorColor: Colors.green,
                    maxLines: title.toLowerCase() == 'giới thiệu' ? 3 : 1,
                    decoration: InputDecoration(
                      hintText: title.toLowerCase() == 'tên' ? 'Thêm tên' : 'Thêm giới thiệu',
                      suffixIcon: vm.content.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: vm.clearContent,
                      )
                          : null,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.2), // line mỏng màu xám
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.8), // khi focus có thể hơi đậm hơn chút
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Text count
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Text(
                      '${vm.content.length}/${title.toLowerCase() == 'tên' ? 30 : 200}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Validation or note
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: vm.validationMessage != null
                        ? Text(
                      vm.validationMessage!,
                      style: const TextStyle(color: Colors.red),
                    )
                        : Text(
                      title.toLowerCase() == 'tên'
                          ? 'Tên cần từ 3 đến 30 ký tự'
                          : 'Giới thiệu cần từ 10 đến 200 ký tự',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
