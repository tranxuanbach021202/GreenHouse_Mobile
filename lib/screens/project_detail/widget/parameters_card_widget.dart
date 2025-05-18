import 'package:flutter/material.dart';

class ParameterRow {
  final String label1;
  final String value1;
  final String label2;
  final String value2;

  ParameterRow({
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
  });
}

class ParametersCardWidget extends StatelessWidget {
  final String title;
  final List<ParameterRow> parameters;
  final Color titleColor;

  const ParametersCardWidget({
    Key? key,
    required this.title,
    required this.parameters,
    this.titleColor = const Color(0xFFB71C1C), // Red[700]
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: titleColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ...parameters.map((param) => _buildParameterRow(
            param.label1,
            param.value1,
            param.label2,
            param.value2,
          )),
        ],
      ),
    );
  }

  Widget _buildParameterRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$label1: ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextSpan(
                    text: value1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$label2: ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextSpan(
                    text: value2,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
