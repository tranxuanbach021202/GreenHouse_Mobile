import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/models/response/project_response.dart';
import 'package:greenhouse/screens/project_detail/measurement/viewmodel/measurement_detail_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../base/views/widget/appbar_leading_iconbutton.dart';
import '../../../../base/views/widget/custom_button_widget.dart';
import '../../../../core/app_images.dart';
import '../../../../core/colors.dart';
import '../../../../di/di.dart';
import '../../../../respositories/measurement_repository.dart';
import '../../../../respositories/project_repository.dart';
import '../widget/comfirm_dialog.dart';
import '../widget/input_dialog.dart';




class MeasurementDetailScreen extends StatefulWidget {
  final String? projectId;
  final int? plotIndex;
  final int? blockIndex;

  final ProjectResponse? project;
  final String? measurementId;

  const MeasurementDetailScreen.fromQR({
    required this.projectId,
    required this.plotIndex,
    required this.blockIndex,
    Key? key,
  })  : project = null,
        measurementId = null,
        super(key: key);

  const MeasurementDetailScreen.fromMeasurement({
    required this.project,
    required this.measurementId,
    Key? key,
  })  : projectId = null,
        plotIndex = null,
        blockIndex = null,
        super(key: key);

  @override
  State<MeasurementDetailScreen> createState() => _MeasurementDetailScreenState();
}

class _MeasurementDetailScreenState extends State<MeasurementDetailScreen> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  int? _currentBlockIndex;
  int? _currentPlotIndex;


  void _toggleOverlay(MeasurementDetailViewModel vm) {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _overlayEntry = _createOverlayEntry(vm);
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(MeasurementDetailViewModel vm) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Lớp nền toàn màn hình để bắt sự kiện nhấn ra ngoài
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
              child: Container(), // Có thể set màu nếu cần
            ),
          ),

          // Dropdown trong suốt với danh sách item
          Positioned(
            left: 16,
            right: 16,
            top: 300,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: vm.editHistories.length + 1,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildOverlayItem(
                        title: "Hiện tại",
                        onTap: () {
                          vm.setSelectedSessionId(null);
                          _removeOverlay();
                        },
                        isSelected: vm.selectedSessionId == null,
                      );
                    }

                    final history = vm.editHistories[index - 1];
                    final timestamp = DateFormat('dd/MM/yyyy HH:mm').format(history.timestamp);
                    final isSelected = history.editSessionId == vm.selectedSessionId;

                    return _buildOverlayItem(
                      title: "$timestamp - ${history.username}" + (isSelected ? " (đang chọn)" : ""),
                      onTap: () {
                        vm.setSelectedSessionId(history.editSessionId);
                        _removeOverlay();
                      },
                      isSelected: isSelected,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildOverlayItem({
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Container(
      color: isSelected ? Colors.lightGreenAccent.withOpacity(0.5) : Colors.white.withOpacity(0.3),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.green : Colors.black,
          ),
        ),
        onTap: onTap,
      ),
    );
  }


  late final MeasurementDetailViewModel vm;
  late final Future<void> _initFuture;
  bool hasAutoOpenedDialog = false;


  @override
  void initState() {
    super.initState();
    vm = MeasurementDetailViewModel(
      getIt<MeasurementRepository>(),
      getIt<ProjectRepository>(),
    );

    if (widget.projectId != null) {
      _initFuture = vm.initializeFromQR(widget.projectId!, widget.blockIndex!, widget.plotIndex!);
    } else {
      vm.setProject(widget.project!);
      _initFuture = vm.fetchMeasurementDetail(widget.measurementId!);
    }
  }




  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Consumer<MeasurementDetailViewModel>(

            builder: (context, vm, _) => _buildScaffold(vm),
          );
        },
      ),
    );
  }

  Widget _buildScaffold(MeasurementDetailViewModel vm) {
    if (!hasAutoOpenedDialog &&
        widget.projectId != null && // đi từ QR
        vm.project != null &&
        vm.checkPermission(vm.project!)) {
      vm.setEditMode(true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInputDialog(vm, widget.blockIndex!, widget.plotIndex!);
      });
      hasAutoOpenedDialog = true;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: AppbarLeadingIconButton(
            imagePath: AppImages.backIcon,
            onTap: () {
              final isFromQR = widget.projectId != null;
              if (isFromQR) {
                context.go('/main_screen');
              } else {
                context.pop();
              }
            },
          ),
        ),
        title: const Text(
          'Chi tiết đợt nhập',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.stateGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (vm.project != null && vm.checkPermission(vm.project!))
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                iconSize: 32,
                icon: Icon(
                  vm.isEditMode ? Icons.check : Icons.edit,
                  color: AppColors.stateGreen,
                ),
                onPressed: () async {
                  if (vm.isEditMode) {
                    await vm.saveMeasurementWithDialog(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmEditDialog(
                        onConfirm: () => vm.setEditMode(true),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Đợt nhập:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                if(!vm.isEditMode)
                Text(
                  '  ${vm.measurementDetail?.start != null ? DateFormat('dd/MM/yyyy').format(vm.measurementDetail!.start!) : ''} - ${vm.measurementDetail!.end != null ? DateFormat('dd/MM/yyyy').format(vm.measurementDetail!.end!) : ''}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.grey),
                ),
              ],
            ),
            if (widget.project?.id == null)
              const SizedBox(height: 12),
            Row(
              children: [
                const Text('Người tạo đợt nhập: ',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                Text(vm.measurementDetail?.createdBy?.username ?? 'Chưa xác định',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Các chỉ tiêu: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    Expanded(
                      child: Text(
                        vm.criterions!.isNotEmpty
                            ? " ${vm.criterions!.first.criterionCode} - ${vm.criterions!.first.criterionName}"
                            : '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                ...vm.criterions!.skip(1).map(
                      (c) => Padding(
                    padding: const EdgeInsets.only(left: 100), // canh lề bên trái bằng chiều dài "Các chỉ tiêu: "
                    child: Text(
                      "${c.criterionCode} - ${c.criterionName}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!vm.isEditMode) ...[
              const Text(
                'Lịch sử thay đổi:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              CompositedTransformTarget(
                link: _layerLink,
                child: GestureDetector(
                  onTap: () => _toggleOverlay(vm),
                  child: Container(
                    width: 200,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            vm.selectedSessionId != null
                                ? vm.getSelectedSessionTitle()
                                : "Chọn phiên",
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],



            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: vm.layout.map((e) => e.blockIndex).toSet().length,
                itemBuilder: (context, blockIndex) {
                  final blockRecords = vm.layout
                      .where((r) => r.blockIndex == blockIndex)
                      .toList()
                    ..sort((a, b) => (a.plotIndex ?? 0).compareTo(b.plotIndex ?? 0));

                  int columns = vm.project!.columns;
                  final rows = (blockRecords.length / columns).ceil();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        "Block ${blockIndex + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: List.generate(rows, (rowIndex) {
                            final start = rowIndex * columns;
                            final end = (start + columns).clamp(0, blockRecords.length);
                            final rowItems = blockRecords.sublist(start, end);

                            return Row(
                              children: [
                                ...rowItems.map((record) {
                                  return GestureDetector(
                                    onTap: vm.isEditMode
                                        ? () => _showInputDialog(vm, blockIndex, record.plotIndex!)
                                        : null,

                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: vm.isChangedPlotInSelectedSession(record.blockIndex, record.plotIndex)
                                            ? Colors.amber.shade800
                                            : vm.isEditMode && vm.isEditedPlot(record.blockIndex, record.plotIndex)
                                            ? Colors.orange.shade700
                                            : Colors.green.shade400,


                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.treatmentCode ?? "",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...record.values!.map((v) {
                                            final changed = vm.getChangedValue(record.blockIndex, record.plotIndex, v.criterionCode);
                                            return Text(
                                              changed != null
                                                  ? "${v.criterionCode}: ${changed.oldValue}→${changed.newValue}"
                                                  : "${v.criterionCode}: ${v.value}",
                                              style: const TextStyle(
                                                fontSize: 8,
                                                color: Colors.white70,
                                              ),
                                            );
                                          }),

                                        ],
                                      ),
                                    ),
                                  );

                                }),
                                ...List.generate(columns - rowItems.length, (_) {
                                  return const SizedBox(
                                    width: 87,
                                  );
                                }),
                              ],
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }





  void _showInputDialog(MeasurementDetailViewModel vm, int blockIndex, int plotIndex) {
    final record = vm.layout.firstWhere(
            (e) => e.blockIndex == blockIndex && e.plotIndex == plotIndex);

    _currentBlockIndex = blockIndex;
    _currentPlotIndex = plotIndex;

    showDialog(
      context: context,
      builder: (_) => InputDialog(
        blockIndex: blockIndex,
        plotIndex: plotIndex,
        column: vm.project!.columns,
        treatmentCode: record.treatmentCode ?? '',
        criterions: vm.project!.criteria,
        existingValues: record.values,
        onSave: (values) {
          vm.saveInput(blockIndex, plotIndex, values);
          if (vm.autoMove) moveToNextPlot(vm);
        },
        autoMove: vm.autoMove,
        onAutoNext: () => vm.setAutoMove(!vm.autoMove),
      ),
    );
  }

  void moveToNextPlot(MeasurementDetailViewModel vm) {
    if (_currentBlockIndex == null || _currentPlotIndex == null) return;

    final allPlots = vm.layout
        .where((e) => e.blockIndex == _currentBlockIndex)
        .toList()
      ..sort((a, b) => (a.plotIndex ?? 0).compareTo(b.plotIndex ?? 0));

    final currentIdx = allPlots.indexWhere((e) => e.plotIndex == _currentPlotIndex);
    if (currentIdx == -1) return;

    // Nếu còn ô tiếp theo trong cùng block
    if (currentIdx + 1 < allPlots.length) {
      final nextPlot = allPlots[currentIdx + 1];
      _showInputDialog(vm, _currentBlockIndex!, nextPlot.plotIndex!);
    } else {
      // Nếu còn block tiếp theo
      final nextBlock = _currentBlockIndex! + 1;
      final nextBlockPlots = vm.layout.where((e) => e.blockIndex == nextBlock).toList();
      if (nextBlockPlots.isNotEmpty) {
        nextBlockPlots.sort((a, b) => (a.plotIndex ?? 0).compareTo(b.plotIndex ?? 0));
        _showInputDialog(vm, nextBlock, nextBlockPlots.first.plotIndex!);
      }
    }
  }



}



