import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/base/views/widget/custom_button_widget.dart';
import 'package:greenhouse/base/views/widget/custom_label_widget.dart';
import 'package:greenhouse/base/views/widget/custom_text_form_field_widget.dart';
import 'package:greenhouse/core/colors.dart';
import 'package:greenhouse/models/response/project_response.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_router.dart';
import '../../../di/di.dart';
import '../../../models/criterion_model.dart';
import '../../../models/response/criterion_response.dart';
import '../../../models/response/factor_response.dart';
import '../project_setup_provider.dart';
import '../viewmodel/criterion_view_model.dart';

class CriterionScreen extends StatefulWidget {
  final ProjectResponse? project;
  final bool isEditMode;

  const CriterionScreen({
    Key? key,
    this.project,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  _CriterionScreenState createState() => _CriterionScreenState();
}

class _CriterionScreenState extends State<CriterionScreen> {

  late final CriterionViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = getIt<CriterionViewModel>(param1: widget.isEditMode);


    if (widget.isEditMode && widget.project!.criteria != null) {
      _viewModel.setFromCriterionResponses(widget.project!.criteria!);
      _viewModel.setProject(widget.project!);
    } else {
      _viewModel.init();
    }
  }



  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _viewModel,
        child:  Scaffold(
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
                  ? 'Chỉnh sửa chỉ tiêu'
                  : 'Thiết lập chỉ tiêu',
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
                CustomLabelWidget(text: 'Chỉ tiêu', color: AppColors.green90,),
                Expanded(
                  child: _buildLevelList(),
                ),
                _buildAddLevelButton(),
                SizedBox(height: 32),
                CustomButtonWidget(
                  backgroundColor: AppColors.stateGreen,
                  text: 'Tiếp tục',
                  onPressed: () async {
                    final success = await _viewModel.saveCriterion(widget.isEditMode);

                    if (!success) return;
                    if(widget.isEditMode) {
                      context.push('/experiment_layout', extra: {
                        'project': _viewModel.project,
                        'isEditMode': true,
                      });
                    } else {
                      context.push('/experiment_layout');
                    }

                  },


                ),
              ],
            ),
          ),
        )
    );
  }

  Widget _buildLevelList() {
    return Consumer<CriterionViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.criterions.isEmpty) {
          return Center(child: Text("Không có mức độ nào, hãy thêm mới!"));
        }
        return ListView.builder(
          itemCount: viewModel.criterions.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: CustomTextFormFieldWidget(
                        controller: viewModel.criterionCodeControllers[index],
                        textStyle: TextStyle(color: Colors.black),
                        hintText: 'Mã chỉ tiêu',
                        hintStyle: TextStyle(color: Colors.grey),
                        fillColor: Colors.white,
                        borderRadius: 8,
                        focusedBorderColor: Color(0xFF004A3F),
                        maxLines: 1,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        viewModel.removeCriterion(index);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                CustomTextFormFieldWidget(
                  controller: viewModel.criterionNameControllers[index],
                  textStyle: TextStyle(color: Colors.black),
                  hintText: 'Chi tiết về chỉ tiêu',
                  hintStyle: TextStyle(color: Colors.grey),
                  fillColor: Colors.white,
                  borderRadius: 8,
                  focusedBorderColor: Color(0xFF004A3F),
                  maxLines: 1,
                ),
                SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
  Widget _buildAddLevelButton() {
    return Consumer<CriterionViewModel>(
      builder: (context, viewModel, child) {
        return Center(
          child: OutlinedButton(
            onPressed: () {
              viewModel.addCriterion(Criterion(criterionCode: '', criterionName: ''));
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.stateGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 24), // Căn chỉnh padding
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.stateGreen),
                SizedBox(width: 6),
                Text(
                  'Thêm chỉ tiêu',
                  style: TextStyle(color: AppColors.stateGreen, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  void dispose() {
    super.dispose();
  }

}