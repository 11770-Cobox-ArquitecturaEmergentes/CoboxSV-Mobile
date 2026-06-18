import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

class Throttler {
  final Duration duration;
  Timer? _timer;
  DateTime? _lastRun;

  Throttler({this.duration = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastRun != null && now.difference(_lastRun!) < duration) {
      return;
    }
    _lastRun = now;
    action();
  }

  void dispose() {
    _timer?.cancel();
  }
}

DateTimeRange get currentWeek {
  final now = DateTime.now();
  final weekDay = now.weekday;
  final monday = now.subtract(Duration(days: weekDay - 1));
  final sunday = monday.add(const Duration(days: 6));
  return DateTimeRange(
    start: DateTime(monday.year, monday.month, monday.day),
    end: DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59),
  );
}

DateTimeRange get currentMonth {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month, 1),
    end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
  );
}

bool isDateInRange(DateTime date, DateTimeRange range) {
  return !date.isBefore(range.start) && !date.isAfter(range.end);
}

void printDebug(Object? message) {
  if (!const bool.fromEnvironment('dart.vm.product')) {
    debugPrint('[Debug] $message');
  }
}

String getInitials(String name) {
  if (name.trim().isEmpty) return '';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  return parts.first[0].toUpperCase();
}

String maskEmail(String email) {
  final atIndex = email.indexOf('@');
  if (atIndex <= 1) return email;
  final name = email.substring(0, atIndex);
  final domain = email.substring(atIndex);
  final visible = name.substring(0, 1);
  return '$visible${'*' * (name.length - 1)}$domain';
}

String maskPhone(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (cleaned.length < 4) return phone;
  final last4 = cleaned.substring(cleaned.length - 4);
  final masked = '*' * (cleaned.length - 4);
  return '$masked$last4';
}

String generateRandomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}

int calculateAge(DateTime birthDate) {
  final now = DateTime.now();
  int age = now.year - birthDate.year;
  final monthDiff = now.month - birthDate.month;
  if (monthDiff < 0 || (monthDiff == 0 && now.day < birthDate.day)) {
    age--;
  }
  return age;
}
