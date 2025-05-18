
class EditSessionHistoryResponse {
  final String editSessionId;
  final DateTime timestamp;
  final String userId;
  final String username;
  final String? urlAvatar;
  final List<ChangeDetail> changes;

  EditSessionHistoryResponse({
    required this.editSessionId,
    required this.timestamp,
    required this.userId,
    required this.username,
    this.urlAvatar,
    required this.changes,
  });

  factory EditSessionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return EditSessionHistoryResponse(
      editSessionId: json['editSessionId'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      username: json['username'],
        urlAvatar: json['urlAvatar'],
      changes: (json['changes'] as List<dynamic>)
          .map((e) => ChangeDetail.fromJson(e))
          .toList(),
    );
  }
}

class ChangeDetail {
  final int blockIndex;
  final int plotIndex;
  final String criterionCode;
  final String criterionName;
  final double oldValue;
  final double newValue;

  ChangeDetail({
    required this.blockIndex,
    required this.plotIndex,
    required this.criterionCode,
    required this.criterionName,
    required this.oldValue,
    required this.newValue,
  });

  factory ChangeDetail.fromJson(Map<String, dynamic> json) {
    return ChangeDetail(
      blockIndex: json['blockIndex'],
      plotIndex: json['plotIndex'],
      criterionCode: json['criterionCode'],
      criterionName: json['criterionName'],
      oldValue: (json['oldValue'] as num).toDouble(),
      newValue: (json['newValue'] as num).toDouble(),
    );
  }
}
