import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/base/views/widget/custom_button_widget.dart';
import 'package:greenhouse/base/views/widget/custom_text_form_field_widget.dart';
import 'package:greenhouse/core/colors.dart';
import 'package:greenhouse/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../base/views/widget/custom_label_widget.dart';
import '../../../base/views/widget/success_dialog.dart';
import '../../../models/response/project_response.dart';
import '../viewmodel/general_info_view_model.dart';


class GeneralInfoScreen extends StatefulWidget {
  final ProjectResponse? project;
  final bool isEditMode;

  const GeneralInfoScreen({Key? key, this.project, required this.isEditMode}) : super(key: key);

  @override
  _GeneralInfoScreenState createState() => _GeneralInfoScreenState();
}

class _GeneralInfoScreenState extends State<GeneralInfoScreen> {
  late final GeneralInfoViewModel _viewModel;

  // @override
  // void initState() {
  //   _viewModel = GetIt.I<GeneralInfoViewModel>();
  //   super.initState();
  // }

  @override
  void initState() {
    _viewModel = GetIt.I<GeneralInfoViewModel>(param1: widget.isEditMode);
    super.initState();

    if (widget.isEditMode && widget.project != null) {
      _viewModel.prefillDataFromProject(widget.project!);
    }
  }



  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.culTured,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF004A3F)),
              onPressed: () => widget.isEditMode ? context.pop(_viewModel.isUpdated) : context.pop(),
            ),
            title: Text(
              widget.isEditMode ? 'Chỉnh sửa dự án' : 'Tạo dự án mới',
              style: TextStyle(
                color: AppColors.stateGreen,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (widget.isEditMode) {
                    context.go('/project_detail/${widget.project!.id}');
                  } else {
                    context.go('/project_management');
                  }
                },
                child: const Text(
                  'Huỷ  ',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomLabelWidget(text: 'Mã dự án', color: AppColors.green90),
                  CustomTextFormFieldWidget(
                    controller: _viewModel.projectIdController,
                    textStyle: const TextStyle(color: Colors.black),
                    hintText: 'Nhập mã dự án',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.white,
                    borderRadius: 8,
                    focusedBorderColor: const Color(0xFF004A3F),
                    maxLines: 1,
                  ),

                  const SizedBox(height: 16),

                  const CustomLabelWidget(text: 'Tên dự án', color: AppColors.green90),
                  CustomTextFormFieldWidget(
                    controller: _viewModel.projectNameController,
                    textStyle: const TextStyle(color: Colors.black),
                    hintText: 'Nhập tên dự án',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.white,
                    borderRadius: 8,
                    focusedBorderColor: const Color(0xFF004A3F),
                    maxLines: 1,
                  ),

                  const SizedBox(height: 16),

                  const CustomLabelWidget(text: 'Thời gian dự kiến', color: AppColors.green90),
                  _buildDatePicker(),

                  const SizedBox(height: 16),

                  const CustomLabelWidget(text: 'Giới thiệu về dự án', color: AppColors.green90),
                  CustomTextFormFieldWidget(
                    controller: _viewModel.descriptionController,
                    textStyle: const TextStyle(color: Colors.black),
                    hintText: 'Nhập giới thiệu dự án',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.white,
                    borderRadius: 8,
                    focusedBorderColor: const Color(0xFF004A3F),
                    maxLines: 4,
                  ),

                  const SizedBox(height: 16),
                  _buildImagePicker(),
                  const SizedBox(height: 24),

                  CustomButtonWidget(
                    isLoading: widget.isEditMode ? _viewModel.isLoading : false,
                    text: widget.isEditMode ? "Cập nhật" : "Tiếp tục",
                    loadingText: "Đang cập nhật...",
                    backgroundColor: AppColors.stateGreen,
                    onPressed: () async {
                      final success = await _viewModel.submit(
                        isEditMode: widget.isEditMode,
                        projectId: widget.project?.id,
                        context: context
                      );
                      if (success) {
                        if (widget.isEditMode) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const SuccessDialog(
                              message: "Cập nhật thành công!",
                            ),
                          );
                        } else {
                          context.push('/member_permissions_project');
                        }
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return Column(
      children: [
        InkWell(
          onTap: () => _viewModel.selectStartDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _viewModel.startDate != null
                      ? 'Bắt đầu: ${DateFormat('dd/MM/yyyy').format(_viewModel!.startDate!)}'
                      : 'Chọn ngày bắt đầu',
                  style: TextStyle(
                    color: _viewModel.startDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _viewModel.selectEndDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _viewModel.endDate != null
                      ? 'Kết thúc: ${DateFormat('dd/MM/yyyy').format(_viewModel!.endDate!)}'
                      : 'Chọn ngày kết thúc',
                  style: TextStyle(
                    color: _viewModel.endDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _viewModel.imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(_viewModel.imageFile!.path),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        )
            : _viewModel.thumbnailUrl != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _viewModel.thumbnailUrl!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.grey.shade600, size: 32),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  _viewModel.pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Chụp ảnh mới'),
                onTap: () {
                  _viewModel.pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

}


