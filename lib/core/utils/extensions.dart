import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get size => mediaQuery.size;

  double get width => size.width;

  double get height => size.height;

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  bool get isSmallScreen => width < 360;

  bool get isMediumScreen => width >= 360 && width < 600;

  bool get isLargeScreen => width >= 600;
}

extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeAll {
    if (isEmpty) return this;
    return split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  String toPhoneFormat() {
    final cleaned = replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    if (cleaned.length == 8) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4)}';
    }
    return this;
  }

  bool get isValidEmail {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(this);
  }

  String truncate(int max) {
    if (length <= max) return this;
    return '${substring(0, max)}...';
  }
}

extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  String formattedDate({String pattern = 'dd/MM/yyyy', String? locale}) {
    return DateFormat(pattern, locale).format(this);
  }

  String formattedTime({String pattern = 'HH:mm', String? locale}) {
    return DateFormat(pattern, locale).format(this);
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) {
      return 'Hace un momento';
    }
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'Hace $m ${m == 1 ? 'minuto' : 'minutos'}';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'Hace $h ${h == 1 ? 'hora' : 'horas'}';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return 'Hace $d ${d == 1 ? 'día' : 'días'}';
    }
    if (diff.inDays < 30) {
      final w = diff.inDays ~/ 7;
      return 'Hace $w ${w == 1 ? 'semana' : 'semanas'}';
    }
    if (diff.inDays < 365) {
      final m = diff.inDays ~/ 30;
      return 'Hace $m ${m == 1 ? 'mes' : 'meses'}';
    }
    final y = diff.inDays ~/ 365;
    return 'Hace $y ${y == 1 ? 'año' : 'años'}';
  }

  String formattedDateTime({
    String pattern = 'dd/MM/yyyy HH:mm',
    String? locale,
  }) {
    return DateFormat(pattern, locale).format(this);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension NumExtensions on num {
  String toCurrency({
    String locale = 'es_MX',
    String symbol = '\$',
    int decimalDigits = 2,
  }) {
    final format = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return format.format(this);
  }

  String toDistance() {
    if (this >= 1000) {
      final km = this / 1000;
      return '${km.toStringAsFixed(km == km.roundToDouble() ? 0 : 1)} km';
    }
    return '${toStringAsFixed(0)} m';
  }

  String toWeight() {
    if (this >= 1000) {
      final tons = this / 1000;
      return '${tons.toStringAsFixed(tons == tons.roundToDouble() ? 0 : 1)} t';
    }
    return '${toStringAsFixed(this == roundToDouble() ? 0 : 1)} kg';
  }
}

extension ListExtensions<T> on List<T>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  T? safeElementAt(int index) {
    if (this == null || index < 0 || index >= this!.length) return null;
    return this![index];
  }
}
