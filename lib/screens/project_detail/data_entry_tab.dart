import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/core/router/app_router.dart';
import 'package:greenhouse/models/response/measurement_response.dart';
import 'package:greenhouse/screens/project_detail/viewmodel/project_detail_view_model.dart';
import 'package:greenhouse/utils/logger.dart';
import 'package:provider/provider.dart';

import '../../core/router/arguments/data_transfer/add_measurement_args.dart';
import '../../models/response/project_response.dart';

class DataEntryTab extends StatelessWidget {
  final ProjectResponse project;
  final List<MeasurementResponse> measurements;

  const DataEntryTab({Key? key, required this.project, required this.measurements}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ProjectDetailViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Các đợt nhập dữ liệu:", Colors.green),
          const SizedBox(height: 8),
          _buildCompletedEntries(measurements, context),
          const SizedBox(height: 24),
          // _buildSectionTitle("Chưa hoàn thành:", Colors.green),
          // const SizedBox(height: 8),
          // _buildIncompleteEntries(context),
          const SizedBox(height: 16),
          _buildAddButton(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }




  Widget _buildCompletedEntries(List<MeasurementResponse> measurements, BuildContext context) {
    return Column(
      children: measurements.map((measurement) {
        return _buildEntryItem(context, measurement);
      }).toList(),
    );
  }



  Widget _buildEntryItem(
      BuildContext context,
      MeasurementResponse measurement,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          "${_formatDate(measurement.start)} - ${_formatDate(measurement.end)}",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                logger.i("sua du an" + measurement.start.toString());

                final result = await context.push(
                  '/add_measurement',
                  extra: AddMeasurementArgs(
                    project: project,
                    measurements: measurements,
                    measurementToEdit: measurement,
                  ),
                );

                if (result == true) {
                  final viewModel = context.read<ProjectDetailViewModel>();
                  await viewModel.fetchMeasurementList();
                }
              },
              child: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
            ),

            const SizedBox(width: 10),
            InkWell(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận xoá'),
                    content: const Text('Bạn có chắc chắn muốn xoá đợt nhập này không?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xoá', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );

                if (confirm == true) {
                  final vm = context.read<ProjectDetailViewModel>();
                  await vm.deleteMeasurementById(measurement.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xoá thành công', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, size: 20, color: Color(0xFF809CB7)),
              ),
            ),
          ],
        ),
        onTap: () {
          context.push('/measurement_detail/${measurement.id}', extra: project);
        },
      ),
    );
  }



  Widget _buildAddButton(BuildContext context, ProjectDetailViewModel viewModel) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await context.push(
            '/add_measurement',
            extra: AddMeasurementArgs(
              project: project,
              measurements: measurements,

            ),
          );

          if (result == true) {
            await viewModel.fetchMeasurementList();
          }

        },
        icon: const Icon(Icons.add),
        label: const Text("Thêm đợt nhập mới"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}


class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});
}