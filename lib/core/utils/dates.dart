import 'package:intl/intl.dart';

String dateKeyOf(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String shortDate(DateTime date) => DateFormat('MMM d').format(date);

String longDate(DateTime date) => DateFormat('MMMM d, y').format(date);

String monthYear(DateTime date) => DateFormat('MMMM y').format(date);

String relativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final difference = target.difference(today).inDays;
  return switch (difference) {
    0 => 'Today',
    -1 => 'Yesterday',
    1 => 'Tomorrow',
    _ => shortDate(date),
  };
}

int calculateStreak(Iterable<String> dateKeys, {DateTime? now}) {
  final keys = dateKeys.toSet();
  if (keys.isEmpty) return 0;
  final current = now ?? DateTime.now();
  var cursor = DateTime(current.year, current.month, current.day);
  if (!keys.contains(dateKeyOf(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (keys.contains(dateKeyOf(cursor))) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

int daysTogether(DateTime anniversary, {DateTime? now}) {
  final start = DateTime(anniversary.year, anniversary.month, anniversary.day);
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final difference = today.difference(start).inDays + 1;
  return difference < 1 ? 1 : difference;
}

DateTime startOfWeek(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

String weekKeyOf(DateTime date) => dateKeyOf(startOfWeek(date));

String formatMoney(double amount, {String currency = 'USD'}) {
  final formatter = NumberFormat.simpleCurrency(
    name: currency,
    decimalDigits: amount % 1 == 0 ? 0 : 2,
  );
  return formatter.format(amount);
}

String compactNumber(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k';
  }
  return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
}
