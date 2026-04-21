import 'package:flutter/material.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_enums.dart';

class HeaderSection extends StatelessWidget {
  final AppLanguage language;
  final VoidCallback onSettingsTap;
  final VoidCallback onRamadanTap;

  const HeaderSection({
    super.key,
    required this.language,
    required this.onSettingsTap,
    required this.onRamadanTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return language == AppLanguage.bn ? 'শুভ সকাল' : 'Good Morning';
    }
    if (hour < 17) {
      return language == AppLanguage.bn ? 'শুভ অপরাহ্ন' : 'Good Afternoon';
    }
    return language == AppLanguage.bn ? 'শুভ সন্ধ্যা' : 'Good Evening';
  }

  String _getHijriDate() {
    final hijri = HijriCalendarConfig.now();
    final day = hijri.hDay;
    final year = hijri.hYear;
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
    return '$day $month $year AH';
  }

  String _getEnglishDate() {
    return DateFormat('EEEE, d MMM y').format(DateTime.now());
  }

  String _getBengaliDate() {
    const dayNamesBn = [
      'সোমবার',
      'মঙ্গলবার',
      'বুধবার',
      'বৃহস্পতিবার',
      'শুক্রবার',
      'শনিবার',
      'রবিবার',
    ];
    const monthNamesBn = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর',
    ];
    final now = DateTime.now();
    final dayName = dayNamesBn[now.weekday - 1];
    final monthName = monthNamesBn[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentDate =
        language == AppLanguage.bn ? _getBengaliDate() : _getEnglishDate();

    return Container(
      height: 280 + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1e3a8a), Color(0xFF1e40af), Color(0xFF1d4ed8)]
              : const [Color(0xFF2563eb), Color(0xFF1d4ed8), Color(0xFF1e40af)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: 24,
          top: MediaQuery.of(context).padding.top + 12,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Greeting + Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    language == AppLanguage.bn
                        ? 'আসসালামু আলাইকুম'
                        : 'Assalamu Alaikum',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.settings_outlined,
                      onTap: onSettingsTap,
                    ),
                    const SizedBox(width: 8),
                    _HeaderIconButton(
                      icon: Icons.nightlight_round,
                      onTap: onRamadanTap,
                    ),
                  ],
                ),
              ],
            ),
            // Greeting and Islamic Journey
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  language == AppLanguage.bn
                      ? 'আপনার ইসলামিক যাত্রা'
                      : 'Your Islamic Journey',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      currentDate,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getHijriDate(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
