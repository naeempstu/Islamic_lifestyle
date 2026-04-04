import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DailyRoutine {
  final bool salahCompleted;
  final bool dhikrDone;
  final bool duaDone;
  final bool goodDeedDone;

  const DailyRoutine({
    required this.salahCompleted,
    required this.dhikrDone,
    required this.duaDone,
    required this.goodDeedDone,
  });

  DailyRoutine copyWith({
    bool? salahCompleted,
    bool? dhikrDone,
    bool? duaDone,
    bool? goodDeedDone,
  }) {
    return DailyRoutine(
      salahCompleted: salahCompleted ?? this.salahCompleted,
      dhikrDone: dhikrDone ?? this.dhikrDone,
      duaDone: duaDone ?? this.duaDone,
      goodDeedDone: goodDeedDone ?? this.goodDeedDone,
    );
  }

  static DailyRoutine defaults() => const DailyRoutine(
        salahCompleted: false,
        dhikrDone: false,
        duaDone: false,
        goodDeedDone: false,
      );

  factory DailyRoutine.fromJson(Map<String, dynamic> json) {
    return DailyRoutine(
      salahCompleted: (json['salahCompleted'] as bool?) ?? false,
      dhikrDone: (json['dhikrDone'] as bool?) ?? false,
      duaDone: (json['duaDone'] as bool?) ?? false,
      goodDeedDone: (json['goodDeedDone'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'salahCompleted': salahCompleted,
        'dhikrDone': dhikrDone,
        'duaDone': duaDone,
        'goodDeedDone': goodDeedDone,
      };
}

class DailyRoutineStore {
  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<DailyRoutine> loadForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('routine_${_dateKey(date)}');
    if (raw == null || raw.isEmpty) return DailyRoutine.defaults();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return DailyRoutine.fromJson(decoded);
  }

  Future<void> saveForDate(DateTime date, DailyRoutine routine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'routine_${_dateKey(date)}',
      jsonEncode(routine.toJson()),
    );
  }

  Future<List<DailyRoutine>> loadLastNDays(int n) async {
    final today = DateTime.now();
    final days = <DailyRoutine>[];
    for (int i = n - 1; i >= 0; i--) {
      final d = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      days.add(await loadForDate(d));
    }
    return days;
  }
}
