import 'package:intl/intl.dart';

String formatCurrency(
  double amount, {
  String locale = 'es_MX',
  String symbol = '\$',
  int decimalDigits = 2,
}) {
  final format = NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: decimalDigits,
  );
  return format.format(amount);
}

String formatDate(
  DateTime date, {
  String pattern = 'dd/MM/yyyy',
  String? locale,
}) {
  final format = DateFormat(pattern, locale);
  return format.format(date);
}

String formatDateTime(
  DateTime date, {
  String pattern = 'dd/MM/yyyy HH:mm',
  String? locale,
}) {
  final format = DateFormat(pattern, locale);
  return format.format(date);
}

String formatTime(DateTime date) {
  return DateFormat('HH:mm').format(date);
}

String formatPhoneNumber(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (cleaned.length == 10) {
    return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
  }
  if (cleaned.length == 8) {
    return '${cleaned.substring(0, 4)}-${cleaned.substring(4)}';
  }
  return phone;
}

String formatLicensePlate(String plate) {
  final cleaned = plate.trim().toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
  if (cleaned.length == 6) {
    return '${cleaned.substring(0, 3)}-${cleaned.substring(3)}';
  }
  if (cleaned.length == 7) {
    return '${cleaned.substring(0, 3)}-${cleaned.substring(3)}';
  }
  return cleaned;
}

String formatDistance(double meters) {
  if (meters >= 1000) {
    final km = meters / 1000;
    return '${km.toStringAsFixed(km == km.roundToDouble() ? 0 : 1)} km';
  }
  return '${meters.toStringAsFixed(0)} m';
}

String formatWeight(double kg) {
  if (kg >= 1000) {
    final tons = kg / 1000;
    return '${tons.toStringAsFixed(tons == tons.roundToDouble() ? 0 : 1)} t';
  }
  return '${kg.toStringAsFixed(kg == kg.roundToDouble() ? 0 : 1)} kg';
}
