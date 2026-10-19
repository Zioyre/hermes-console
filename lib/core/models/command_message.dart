const maxCommandMessageLength = 1024 * 1024;

String? parseCommandMessage(Object? value) {
  if (value == null) return null;
  if (value is! String ||
      value.length > maxCommandMessageLength ||
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]').hasMatch(value)) {
    throw const FormatException('Invalid or oversized command message');
  }
  return value.trim().isEmpty ? null : value;
}
