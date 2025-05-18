import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/base/views/widget/custom_button_widget.dart';
import 'package:greenhouse/base/views/widget/custom_label_widget.dart';
import 'package:greenhouse/base/views/widget/custom_text_form_field_widget.dart';
import 'package:greenhouse/core/colors.dart';
import 'package:greenhouse/models/response/project_response.dart';
import 'package:greenhouse/screens/project_creation/viewmodel/factors_levels_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/router/app_router.dart';
import '../../../models/level_model.dart';
import '../../../models/response/criterion_response.dart';
import '../../../models/response/factor_response.dart';
import '../../../utils/logger.dart';
import '../project_setup_provider.dart';

class FactorLevelScreen extends StatefulWidget {
  final ProjectResponse? project;
  final bool isEditMode;


  const FactorLevelScreen({
    Key? key,
    this.project,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  State<FactorLevelScreen> createState() => _FactorLevelScreenState();
}

class _FactorLevelScreenState extends State<FactorLevelScreen> {
  late final FactorsLevelsViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    final projectSetupProvider = GetIt.I<ProjectSetupProvider>();

    _viewModel = FactorsLevelsViewModel(projectSetupProvider: projectSetupProvider);



    if (widget.isEditMode && widget.project!.factor != null) {
      _viewModel.setFromFactorResponse(widget.project!.factor!);
      _viewModel.setProject(widget.project!);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose(); // dispose đúng cách
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<FactorsLevelsViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.culTured,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF004A3F)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.isEditMode
                    ? 'Chỉnh sửa yếu tố \n và mức độ'
                    : 'Thiết lập yếu tố \n và mức độ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.stateGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (widget.isEditMode) {
                      // context.go('/project_detail/${widget.project!.id}');
                      context.pop();
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
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomLabelWidget(text: 'Mã nhân tố', color: AppColors.green90),
                  CustomTextFormFieldWidget(
                    controller: viewModel.factorCodeController,
                    hintText: 'Nhập mã nhân tố',
                    textStyle: TextStyle(color: Colors.black),
                    fillColor: Colors.white,
                    hintStyle: TextStyle(color: Colors.grey),
                    borderRadius: 8,
                    focusedBorderColor: Color(0xFF004A3F),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),
                  CustomLabelWidget(text: 'Tên nhân tố', color: AppColors.green90),
                  CustomTextFormFieldWidget(
                    controller: viewModel.factorNameController,
                    hintText: 'Nhập tên nhân tố',
                    textStyle: TextStyle(color: Colors.black),
                    hintStyle: TextStyle(color: Colors.grey),
                    fillColor: Colors.white,
                    borderRadius: 8,
                    focusedBorderColor: Color(0xFF004A3F),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 24),
                  CustomLabelWidget(text: 'Mức độ', color: AppColors.green90),
                  Expanded(child: _buildLevelList()),
                  _buildAddLevelButton(),
                  const SizedBox(height: 24),
                  CustomButtonWidget(
                    backgroundColor: AppColors.stateGreen,
                    text: 'Tiếp tục',
                    onPressed: () async {
                      final success = await viewModel.saveFactorsAndLevels(widget.isEditMode);

                      if (!success) return;

                      if (widget.isEditMode) {
                        context.push('/criterion_project', extra: {
                          'project': widget.project,
                          'isEditMode': true,
                        });
                      } else {
                        context.push('/criterion_project');
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelList() {
    return Consumer<FactorsLevelsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.levels.isEmpty || viewModel.controllersLevelCode.isEmpty) {
          return const Center(child: Text("Không có mức độ nào, hãy thêm mới!"));
        }
        return ListView.builder(
          itemCount: viewModel.levels.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}.', style: TextStyle(fontSize: 16.sp)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: CustomTextFormFieldWidget(
                        controller: viewModel.controllersLevelCode[index],
                        textStyle: TextStyle(color: Colors.black),
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Mã mức độ',
                        fillColor: Colors.white,
                        borderRadius: 8,
                        focusedBorderColor: Color(0xFF004A3F),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => viewModel.removeLevel(index),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextFormFieldWidget(
                  controller: viewModel.controllersLevelDetails[index],
                  textStyle: TextStyle(color: Colors.black),
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: 'Chi tiết về mức độ',
                  fillColor: Colors.white,
                  borderRadius: 8,
                  focusedBorderColor: Color(0xFF004A3F),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAddLevelButton() {
    return Consumer<FactorsLevelsViewModel>(
      builder: (context, viewModel, child) {
        return Center(
          child: OutlinedButton(
            onPressed: () {
              viewModel.addLevel(Level(code: '', name: ''));
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.stateGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add, color: AppColors.stateGreen),
                SizedBox(width: 6),
                Text('Thêm mức độ', style: TextStyle(color: AppColors.stateGreen, fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
