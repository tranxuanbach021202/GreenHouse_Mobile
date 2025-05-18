DateTime? tryParseDate(dynamic input) {
  if (input == null || input is! String || input.isEmpty) return null;
  return DateTime.tryParse(input);
}

int? tryParseInt(dynamic input) {
  if (input == null) return null;
  if (input is int) return input;
  return int.tryParse(input.toString());
}
