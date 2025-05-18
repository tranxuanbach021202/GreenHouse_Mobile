class ResponseModel {
  dynamic data;
  String errorMessage;
  bool isSuccess;

  ResponseModel({this.data, required this.errorMessage, this.isSuccess = true});
}