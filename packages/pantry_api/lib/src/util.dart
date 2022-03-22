/// Helper function to convert enum value to String representation
/// https://api.flutter.dev/flutter/foundation/describeEnum.html
String describeEnum(Object enumEntry) {
  if (enumEntry is Enum) return enumEntry.name;
  final String description = enumEntry.toString();
  final int indexOfDot = description.indexOf('.');
  assert(
    indexOfDot != -1 && indexOfDot < description.length - 1,
    'The provided object "$enumEntry" is not an enum.',
  );
  return description.substring(indexOfDot + 1);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
