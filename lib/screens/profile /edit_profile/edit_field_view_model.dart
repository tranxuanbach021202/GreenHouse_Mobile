import 'package:flutter/material.dart';

class EditFieldViewModel extends ChangeNotifier {
  final String title;
  final TextEditingController controller = TextEditingController();
  String content;
  String? validationMessage;

  EditFieldViewModel({required this.title, required this.content}) {
    controller.text = content;
    controller.addListener(() {
      updateContent(controller.text);
    });
    _validateContent();
  }

  void updateContent(String value) {
    content = value;
    _validateContent();
    notifyListeners();
  }

  void clearContent() {
    controller.clear();
    updateContent('');
  }

  bool get isValid => validationMessage == null;

  void _validateContent() {
    if (title.toLowerCase() == 'tên') {
      if (content.length < 3 || content.length > 30) {
        validationMessage = 'Tên phải từ 3 đến 30 ký tự';
      } else {
        validationMessage = null;
      }
    } else if (title.toLowerCase() == 'giới thiệu') {
      if (content.length < 10 || content.length > 200) {
        validationMessage = 'Giới thiệu phải từ 10 đến 200 ký tự';
      } else {
        validationMessage = null;
      }
    } else {
      validationMessage = null;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
