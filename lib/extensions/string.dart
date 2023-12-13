extension CapExtension on String {
  String get capitalize =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';

  String get capitalizeEvery =>
      split(" ").map((str) => str.capitalize).join(" ");
}
