import 'package:flutter/material.dart';
import 'package:greenhouse/models/response/project_response.dart';

class ExperimentLayoutTab extends StatelessWidget {
  final ProjectResponse project;

  const ExperimentLayoutTab({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExperimentInfo(),
          const SizedBox(height: 24),
          _buildLayoutTitle(),
          const SizedBox(height: 16),
          ..._buildLayoutBlocks(),
        ],
      ),
    );
  }

  Widget _buildExperimentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Các thông số của bố trí thí nghiệm:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () {
                  // Xử lý khi nhấn nút chỉnh sửa
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow("Loại thí nghiệm", project.experimentType),
          _buildInfoRow("Số block", project.blocks.toString()),
          _buildInfoRow("Số lần lặp", project.replicates.toString()),
          _buildInfoRow("Số cột", project.columns.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutTitle() {
    return const Text(
      "Layout bố trí",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  List<Widget> _buildLayoutBlocks() {
    return project.layout.asMap().entries.map((entry) {
      final blockIndex = entry.key;
      final plots = entry.value;

      final columns = project.columns;
      final rows = (plots.length / columns).ceil();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Block ${blockIndex + 1}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(rows, (rowIndex) {
              final start = rowIndex * columns;
              final end = (start + columns).clamp(0, plots.length);
              final rowItems = plots.sublist(start, end);

              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: rowItems
                    .map((item) => Container(
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.treatmentCode,
                    style: const TextStyle(color: Colors.white),
                  ),
                ))
                    .toList(),
              );
            }),
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}

// Model classes
class ExperimentProject {
  final String experimentType;
  final int blockCount;
  final int replicationCount;
  final int columnCount;
  final List<List<ExperimentPlot>> layout;

  ExperimentProject({
    required this.experimentType,
    required this.blockCount,
    required this.replicationCount,
    required this.columnCount,
    required this.layout,
  });

  // Factory method để tạo dữ liệu mẫu giống như trong hình
  factory ExperimentProject.sample() {
    // Tạo layout với 2 blocks, mỗi block có 4 hàng và 4 cột
    List<List<ExperimentPlot>> layout = [];

    // Danh sách các mã công thức (treatments)
    List<String> treatments = ["CT1", "CT2", "CT3", "CT4"];

    // Block 1 - Bố trí ngẫu nhiên
    List<ExperimentPlot> block1 = [];
    List<String> block1Treatments = [
      "CT1", "CT3", "CT2", "CT4",
      "CT4", "CT1", "CT3", "CT2",
      "CT2", "CT4", "CT1", "CT3",
      "CT3", "CT2", "CT4", "CT1"
    ];

    for (String treatment in block1Treatments) {
      block1.add(ExperimentPlot(treatmentCode: treatment));
    }
    layout.add(block1);

    // Block 2 - Bố trí ngẫu nhiên khác
    List<ExperimentPlot> block2 = [];
    List<String> block2Treatments = [
      "CT2", "CT1", "CT4", "CT3",
      "CT3", "CT4", "CT1", "CT2",
      "CT1", "CT2", "CT3", "CT4",
      "CT4", "CT3", "CT2", "CT1"
    ];

    for (String treatment in block2Treatments) {
      block2.add(ExperimentPlot(treatmentCode: treatment));
    }
    layout.add(block2);

    return ExperimentProject(
      experimentType: "RCBD",
      blockCount: 2,
      replicationCount: 4,
      columnCount: 4,
      layout: layout,
    );
  }
}

class ExperimentPlot {
  final String treatmentCode;

  ExperimentPlot({required this.treatmentCode});
}


