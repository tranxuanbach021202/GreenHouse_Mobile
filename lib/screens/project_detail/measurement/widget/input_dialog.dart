import 'package:flutter/material.dart';
import 'package:greenhouse/utils/logger.dart';

import '../../../../models/plot_input_data.dart';
import '../../../../models/response/criterion_response.dart';

class InputDialog extends StatefulWidget {
  final int blockIndex;
  final int plotIndex;
  final int column;
  final String treatmentCode;
  final List<CriterionValue>? existingValues;
  final List<CriterionResponse> criterions;
  final Function(List<CriterionValue>) onSave;
  final bool autoMove;
  final VoidCallback onAutoNext;

  const InputDialog({
    super.key,
    required this.blockIndex,
    required this.plotIndex,
    required this.column,
    required this.treatmentCode,
    required this.criterions,
    this.existingValues,
    required this.onSave,
    required this.autoMove,
    required this.onAutoNext
  });

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late List<TextEditingController> controllerList;
  String? errorText;
  late bool _autoMoveLocal;



  @override
  void initState() {
    super.initState();

    _autoMoveLocal = widget.autoMove;

    controllerList = List.generate(widget.criterions.length, (index) {
      final existing = widget.existingValues?.firstWhere(
            (v) => v.criterionCode == widget.criterions[index].criterionCode,
        orElse: () => CriterionValue(
          criterionCode: widget.criterions[index].criterionCode,
          criterionName: widget.criterions[index].criterionName, value: 0.0,
        ),
      );

      return TextEditingController(
        text: existing?.value?.toString() ?? '',
      );
    });
  }

  @override
  void dispose() {
    for (var c in controllerList) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.i("check plot" + widget.criterions.length.toString());
    // logger.i("Plot" + widget.existingValues![0].value.toString());
    final columns = widget.column;
    final row = (widget.plotIndex ~/ columns) + 1;
    final col = (widget.plotIndex % columns) + 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Block: ${widget.blockIndex + 1} - Vị trí: ${row}x$col"),
              Text("Treatment: ${widget.treatmentCode}"),
              Row(
                children: [
                  Checkbox(
                    value: _autoMoveLocal,
                    onChanged: (value) {
                      setState(() {
                        _autoMoveLocal = value!;
                      });
                      widget.onAutoNext();
                    },
                    checkColor: Colors.white, // Màu dấu tích
                    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.green.shade800; // Nền khi được chọn
                      }
                      return Colors.white; // Nền khi chưa chọn
                    }),
                    side: const BorderSide(
                      color: Colors.grey, // Viền khi chưa chọn
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text("Tự động chuyển ô tiếp theo"),
                ],
              ),



              const Divider(),

              ...List.generate(widget.criterions.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.criterions[i].criterionName),
                      const SizedBox(height: 6),
                      TextField(
                        controller: controllerList[i],
                        keyboardType: TextInputType.number,
                        onTap: () {
                          final currentValue = controllerList[i].text.trim();
                          if (currentValue == "0" || currentValue == "0.0") {
                            controllerList[i].clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Giá trị đo",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                    ],
                  ),
                );
              }),

              if (errorText != null)
                Text(errorText!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Huỷ"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _onSave,
                    child: const Text("Lưu"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    final hasInvalid = controllerList.any((c) =>
    c.text.trim().isEmpty || double.tryParse(c.text.trim()) == null);

    if (hasInvalid) {
      setState(() {
        errorText = "Vui lòng nhập đúng giá trị.";
      });
      return;
    }

    final values = List.generate(widget.criterions.length, (i) {
      return CriterionValue(
        criterionCode: widget.criterions[i].criterionCode,
        criterionName: widget.criterions[i].criterionName,
        value: double.parse(controllerList[i].text.trim()),
      );
    });

    Navigator.pop(context);
    widget.onSave(values);
  }
}