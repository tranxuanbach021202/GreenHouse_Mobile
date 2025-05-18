import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/base/views/widget/custom_label_widget.dart';
import 'package:greenhouse/models/enums/experiment_type.dart';
import 'package:greenhouse/utils/logger.dart';
import 'package:provider/provider.dart';

import '../../../base/views/widget/custom_button_widget.dart';
import '../../../base/views/widget/success_dialog.dart';
import '../../../core/colors.dart';
import '../../../models/response/project_response.dart';
import '../../../models/treatment.dart';
import '../project_setup_provider.dart';
import '../viewmodel/experiment_layout_view_model.dart';

class ExperimentLayoutScreen extends StatefulWidget {
  final ProjectResponse? project;
  final bool isEditMode;

  const ExperimentLayoutScreen({
    Key? key,
    this.project,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  State<ExperimentLayoutScreen> createState() => _ExperimentLayoutScreenState();
}

class _ExperimentLayoutScreenState extends State<ExperimentLayoutScreen> {
  final double boxSize = 40.0;

  late final ExperimentLayoutViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final projectSetupProvider = Provider.of<ProjectSetupProvider>(context, listen: false);
    _viewModel = GetIt.I<ExperimentLayoutViewModel>(
      param1: projectSetupProvider,
    );
    _viewModel.initWithData(
      project: widget.project,
      isEditMode: widget.isEditMode,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExperimentLayoutViewModel>.value(
      value: _viewModel,
      child: Consumer<ExperimentLayoutViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppColors.culTured,
            appBar: _buildAppBar(context),
            body: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ExperimentLayoutViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.stateGreen),
      );
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorState(context, viewModel);
    }

    return _buildMainContent(context, viewModel);
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF004A3F)),
        onPressed: () => context.pop(),
      ),
      title: Text(
        widget.isEditMode
            ? 'Chỉnh sửa bố trí \n thí nghiệm'
            : 'Bố trí thí nghiệm',
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
            if (widget.project != null) {
              // context.go('/project_detail/${widget.project!.id}');
              context.pop();
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
    );
  }

  Widget _buildErrorState(BuildContext context, ExperimentLayoutViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage ?? "An error occurred",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.regenerateLayout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.stateGreen,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ExperimentLayoutViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDesignTypeSelection(viewModel),
            const SizedBox(height: 20),
            _buildParametersSection(viewModel),
            const SizedBox(height: 20),
            _buildExperimentLayout(viewModel),
            const SizedBox(height: 20),
            _buildRegenerateButton(viewModel),
            const SizedBox(height: 40),
            _buildContinueButton(context, viewModel),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignTypeSelection(ExperimentLayoutViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomLabelWidget(text: 'Kiểu bố trí', color: AppColors.green90),
        const SizedBox(height: 8),
        _buildCustomRadioTile(
          title: 'Randomized Completely Block Design (RCBD)',
          value: ExperimentType.RCBD,
          groupValue: viewModel.designType,
          onChanged: (value) => viewModel.setDesignType(value),
        ),
        const SizedBox(height: 8),
        _buildCustomRadioTile(
          title: 'Completely Random Design (CRD)',
          value: ExperimentType.RCD,
          groupValue: viewModel.designType,
          onChanged: (value) => viewModel.setDesignType(value),
        ),
      ],
    );
  }

  Widget _buildCustomRadioTile({
    required String title,
    required ExperimentType value,
    required ExperimentType? groupValue,
    required Function(ExperimentType) onChanged,
  }) {
    bool isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: AppColors.green10),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.stateGreen : const Color(0xFF7F7F7F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametersSection(ExperimentLayoutViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomLabelWidget(
          text: 'Thông số thí nghiệm',
          color: AppColors.green90
        ),
        const SizedBox(height: 8),
        if (!viewModel.isCRD)
          _buildParameterRow(
            'BLOCK',
            viewModel.blocks,
            (value) => viewModel.setBlocks(value)
          ),
        if (!viewModel.isRCBD)
          _buildParameterRow(
            'REPLICATE',
            viewModel.replicates,
            (value) => viewModel.setReplicates(value)
          ),
        _buildParameterRow(
          'COLUMN IN BLOCK',
          viewModel.columnsInBlock,
          (value) => viewModel.setColumnsInBlock(value)
        ),
      ],
    );
  }

  Widget _buildParameterRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomLabelWidget(
                text: label,
                color: AppColors.green90,
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.stateGreen, size: 24),
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              disabledColor: Colors.grey.withOpacity(0.3),
            ),
            SizedBox(
              width: 20,
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.stateGreen, size: 24),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperimentLayout(ExperimentLayoutViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BỐ TRÍ THÍ NGHIỆM',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.green90,
              )
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(viewModel.blocks, (blockIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Block ${blockIndex + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.green90,
                )
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: viewModel.columnsInBlock * (boxSize + 8),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: viewModel.columnsInBlock,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: viewModel.treatments.length * viewModel.replicates,
                  itemBuilder: (context, index) {
                    // Add safety check for layout bounds
                    if (blockIndex >= viewModel.layout.length ||
                        index >= viewModel.layout[blockIndex].length) {
                      return _buildEmptyTreatmentBox();
                    }

                    final treatmentCode = viewModel.layout[blockIndex][index];
                    final treatment = viewModel.treatments.firstWhere(
                      (t) => t.code == treatmentCode,
                      orElse: () => Treatment(code: '', name: ''),
                    );

                    return _buildTreatmentBox(treatment);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTreatmentBox(Treatment treatment) {
    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Container(
        decoration: BoxDecoration(
          color: treatment.code.isNotEmpty
              ? AppColors.stateGreen
              : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: treatment.code.isNotEmpty
            ? Text(
                treatment.code,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyTreatmentBox() {
    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildRegenerateButton(ExperimentLayoutViewModel viewModel) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => viewModel.regenerateLayout(),
        icon: const Icon(Icons.refresh),
        label: const Text('Tạo lại bố trí'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.stateGreen,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, ExperimentLayoutViewModel viewModel) {
    return CustomButtonWidget(
      backgroundColor: AppColors.stateGreen,
      text: widget.isEditMode ? 'Cập nhật' : 'Tiếp tục',
      onPressed: () async {
        if(widget.isEditMode) {
          // Show loading indicator if needed
          viewModel.isLoading = true;
          
          try {
            // Update project
            await viewModel.updateProject();
            viewModel.isLoading =false;
            
            // Show success snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Cập nhật thành công!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                backgroundColor: AppColors.stateGreen,
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 150,
                  left: 20,
                  right: 20
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            
            // Navigate with slight delay for smooth transition
            Future.delayed(const Duration(milliseconds: 1000), () {
              context.pop();
              context.pop();
              context.pop();
            });
          } catch (e) {
            viewModel.isLoading = false;
            // Show error message if needed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Có lỗi xảy ra, vui lòng thử lại',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 150,
                  left: 20,
                  right: 20
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            logger.e("Error updating project: $e");
          }
        } else {
          bool isSaved = await viewModel.saveExperimentLayout();
          if (isSaved) {
            await viewModel.createProject();
          }
        }
      }
    );
  }
}
