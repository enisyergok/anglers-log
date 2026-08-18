import 'package:intl/intl.dart';

/// Safe Turkish date and time formatter for Mera Asistanı.
/// Eliminates dependency on intl locale initialization to prevent white screen crashes.
abstract final class MeraDateFormatter {
  static const _monthsTrShort = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];

  static const _monthsTrFull = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const _daysTrFull = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  /// Formats date: "18 Ağu 2026 · 16:14" or "18 Ağu 2026"
  static String formatShort(DateTime dt, {bool includeTime = true}) {
    try {
      final pattern = includeTime ? 'd MMM yyyy · HH:mm' : 'd MMM yyyy';
      return DateFormat(pattern, 'tr').format(dt);
    } catch (_) {
      final day = dt.day;
      final month = _monthsTrShort[(dt.month - 1).clamp(0, 11)];
      final year = dt.year;
      if (!includeTime) return '$day $month $year';
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year · $hour:$min';
    }
  }

  /// Formats date: "18 Ağustos 2026 · 16:14"
  static String formatFull(DateTime dt, {bool includeTime = true}) {
    try {
      final pattern = includeTime ? 'd MMMM yyyy · HH:mm' : 'd MMMM yyyy';
      return DateFormat(pattern, 'tr').format(dt);
    } catch (_) {
      final day = dt.day;
      final month = _monthsTrFull[(dt.month - 1).clamp(0, 11)];
      final year = dt.year;
      if (!includeTime) return '$day $month $year';
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year · $hour:$min';
    }
  }

  /// Formats date with day name: "18 Ağustos 2026, Salı"
  static String formatWithDay(DateTime dt) {
    try {
      return DateFormat('d MMMM yyyy, EEEE', 'tr').format(dt);
    } catch (_) {
      final day = dt.day;
      final month = _monthsTrFull[(dt.month - 1).clamp(0, 11)];
      final year = dt.year;
      final weekday = _daysTrFull[(dt.weekday - 1).clamp(0, 6)];
      return '$day $month $year, $weekday';
    }
  }
}
