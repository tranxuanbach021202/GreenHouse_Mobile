import 'package:flutter/material.dart';
import 'package:greenhouse/models/response/measurement_response.dart';
import 'package:greenhouse/models/response/project_response.dart';
import 'package:greenhouse/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../base/views/widget/appbar_leading_iconbutton.dart';
import '../../../../base/views/widget/custom_button_widget.dart';
import '../../../../base/views/widget/custom_label_widget.dart';
import '../../../../core/app_images.dart';
import '../../../../core/colors.dart';
import '../../../../di/di.dart';
import '../viewmodel/add_measurement_view_model.dart';

class AddMeasurementScreen extends StatelessWidget {
  final ProjectResponse project;
  final List<MeasurementResponse> measurements;
  final MeasurementResponse? measurementToEdit;
  const AddMeasurementScreen({
    Key? key,
    required this.project,
    required this.measurements,
    this.measurementToEdit,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final vm = context.read<AddMeasurementViewModel>();
    final initial = isStart
        ? (vm.startDate ?? vm.editingMeasurement?.start ?? DateTime.now())
        : (vm.endDate ?? vm.editingMeasurement?.end ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      isStart ? vm.setStartDate(picked) : vm.setEndDate(picked);
    }
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AddMeasurementViewModel>(),
      child: Consumer<AddMeasurementViewModel>(
        builder: (context, vm, _) {
          final dateFormat = DateFormat('dd/MM/yyyy');

          if (measurementToEdit != null && vm.editingMeasurement == null) {
            vm.setMeasurementToEdit(measurementToEdit!);
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leadingWidth: 56, // tăng width nếu icon của bạn lớn hơn
              titleSpacing: 0, // rất quan trọng để `Padding` có hiệu lực
              leading: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: AppbarLeadingIconButton(
                  imagePath: AppImages.backIcon,
                  height: 30,
                  width: 30,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              centerTitle: true,
              title: Text(
                measurementToEdit != null ? "Sửa đợt nhập" : "Thêm đợt nhập",
                style: const TextStyle(
                  color: AppColors.stateGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildDatePicker(context, vm),
                  const SizedBox(height: 24),
                  if (vm.errorMessage != null)
                    Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
                  const Spacer(),
                  CustomButtonWidget(
                    isLoading: vm.isLoading,
                    onPressed: () => vm.submit(project, measurements),
                    text: measurementToEdit != null ? "Cập nhật" : "Thêm",
                    loadingText: measurementToEdit != null ? "Đang cập nhật..." : "Đang thêm...",
                    backgroundColor: AppColors.stateGreen,
                  ),
                  SizedBox(height: 30,)

                ],
              ),
            ),

          );
        },
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, AddMeasurementViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomLabelWidget(
          text: 'Ngày bắt đầu',
          color: AppColors.green90,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => vm.setStartDateFromPicker(context),
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
                  vm.startDate != null
                      ? DateFormat('dd/MM/yyyy').format(vm.startDate!)
                      : 'Chọn ngày bắt đầu',
                  style: TextStyle(
                    color: vm.startDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const CustomLabelWidget(
          text: 'Ngày kết thúc',
          color: AppColors.green90,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => vm.setEndDateFromPicker(context),
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
                  vm.endDate != null
                      ? DateFormat('dd/MM/yyyy').format(vm.endDate!)
                      : 'Chọn ngày kết thúc',
                  style: TextStyle(
                    color: vm.endDate != null ? Colors.black : Colors.grey,
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


}
