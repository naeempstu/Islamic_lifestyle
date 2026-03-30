import 'package:shared_preferences/shared_preferences.dart';

class TasbihStore {
  static Future<int> loadTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey();
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> saveTodayCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_todayKey(), count);
  }

  static String _todayKey() {
    final d = DateTime.now();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return 'tasbih_count_$y$m$day';
  }
}

