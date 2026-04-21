import 'package:flutter/material.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/models/app_enums.dart';

class CalendarScreen extends StatefulWidget {
  final AppLanguage language;

  const CalendarScreen({
    super.key,
    required this.language,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String _formatGregorian(DateTime date) {
    return DateFormat('EEEE, d MMMM y').format(date);
  }

  String _formatHijri(DateTime date) {
    final hijri = HijriCalendarConfig.fromGregorian(date);
    const monthsEn = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      "Sha'ban",
      'Ramadan',
      'Shawwal',
      "Dhul Qa'dah",
      'Dhul Hijjah',
    ];
    final month = monthsEn[(hijri.hMonth - 1).clamp(0, 11)];
    return '${hijri.hDay} $month ${hijri.hYear} AH';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == AppLanguage.bn
              ? '\u0995\u09cd\u09af\u09be\u09b2\u09c7\u09a8\u09cd\u09a1\u09be\u09b0'
              : 'Calendar',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF1e3a8a), Color(0xFF1d4ed8)]
                    : const [Color(0xFF2563eb), Color(0xFF06b6d4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.language == AppLanguage.bn
                      ? '\u09a8\u09bf\u09b0\u09cd\u09ac\u09be\u099a\u09bf\u09a4 \u09a4\u09be\u09b0\u09bf\u0996'
                      : 'Selected Date',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatGregorian(_selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatHijri(_selectedDate),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
