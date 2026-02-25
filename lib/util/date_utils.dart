import 'package:intl/intl.dart';

/// Format a timestamp (milliseconds since epoch) to "dd MMM yyyy, HH:mm"
String formatDateTime(int timestamp) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('dd MMM yyyy, HH:mm').format(dt);
}

/// Format a timestamp (milliseconds since epoch) to "dd MMM yyyy"
String formatDate(int timestamp) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('dd MMM yyyy').format(dt);
}

/// Format a currency value (int) to Indonesian Rupiah format
String formatCurrencyInt(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Format a currency value (double) to Indonesian Rupiah format
String formatCurrencyDouble(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Get the start of the current month as epoch millis
int getStartOfCurrentMonth() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  return start.millisecondsSinceEpoch;
}

/// Get the end of the current month as epoch millis
int getEndOfCurrentMonth() {
  final now = DateTime.now();
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
  return end.millisecondsSinceEpoch;
}

/// Get the current month name (e.g. "Februari")
String getCurrentMonthName() {
  final now = DateTime.now();
  return DateFormat('MMMM', 'id_ID').format(now);
}
