import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_enums.dart';

class ForbiddenPrayerTimesCard extends StatefulWidget {
  final AppLanguage language;
  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime maghrib;

  const ForbiddenPrayerTimesCard({
    super.key,
    required this.language,
    required this.fajr,
    required this.dhuhr,
    required this.maghrib,
  });

  @override
  State<ForbiddenPrayerTimesCard> createState() =>
      _ForbiddenPrayerTimesCardState();
}

class _ForbiddenPrayerTimesCardState extends State<ForbiddenPrayerTimesCard> {
  @override
  void initState() {
    super.initState();
  }

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  bool _isInTimeRange(DateTime now, DateTime start, DateTime end) {
    return now.isAfter(start) && now.isBefore(end);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Calculate forbidden times
    final ishraqStart = widget.fajr.add(const Duration(minutes: 15));
    final ishraqEnd = widget.fajr.add(const Duration(minutes: 20));

    final zawalStart = widget.dhuhr.subtract(const Duration(minutes: 10));
    final zawalEnd = widget.dhuhr;

    final ghuruubStart = widget.maghrib;
    final ghuruubEnd = widget.maghrib.add(const Duration(minutes: 20));

    // Check current forbidden time
    final inIshraq = _isInTimeRange(now, ishraqStart, ishraqEnd);
    final inZawal = _isInTimeRange(now, zawalStart, zawalEnd);
    final inGhuruub = _isInTimeRange(now, ghuruubStart, ghuruubEnd);
    final inForbiddenTime = inIshraq || inZawal || inGhuruub;

    String forbiddenLabel = '';
    if (inIshraq) {
      forbiddenLabel =
          widget.language == AppLanguage.bn ? 'ইশরাক' : 'Ishraq (Sunrise)';
    } else if (inZawal) {
      forbiddenLabel =
          widget.language == AppLanguage.bn ? 'যোহরের সময়' : 'Zawal (Midday)';
    } else if (inGhuruub) {
      forbiddenLabel = widget.language == AppLanguage.bn
          ? 'সূর্যাস্তের সময়'
          : 'Ghuruub (Sunset)';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: inForbiddenTime
              ? const [Color(0xFFEF5350), Color(0xFFE53935)]
              : const [Color(0xFF6B4C9A), Color(0xFF9B6FA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: inForbiddenTime
                ? const Color(0xFFEF5350).withValues(alpha: 0.4)
                : const Color(0xFF6B4C9A).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: inForbiddenTime ? 4 : 2,
          ),
        ],
        border:
            inForbiddenTime ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.block_outlined,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.language == AppLanguage.bn
                          ? 'নামাজ নিষিদ্ধ সময় (নিসিদ্ধ)'
                          : 'Forbidden Prayer Times (Nisiddo)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(now),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              if (inForbiddenTime)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    forbiddenLabel,
                    style: const TextStyle(
                      color: Color(0xFFEF5350),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _ForbiddenTimeRow(
            language: widget.language,
            label: widget.language == AppLanguage.bn
                ? 'ইশরাক'
                : 'Ishraq (Sunrise)',
            start: _formatTime(ishraqStart),
            end: _formatTime(ishraqEnd),
            isActive: inIshraq,
          ),
          const SizedBox(height: 8),
          _ForbiddenTimeRow(
            language: widget.language,
            label: widget.language == AppLanguage.bn
                ? 'যোহরের সময়'
                : 'Zawal (Midday)',
            start: _formatTime(zawalStart),
            end: _formatTime(zawalEnd),
            isActive: inZawal,
          ),
          const SizedBox(height: 8),
          _ForbiddenTimeRow(
            language: widget.language,
            label: widget.language == AppLanguage.bn
                ? 'সূর্যাস্তের সময়'
                : 'Ghuruub (Sunset)',
            start: _formatTime(ghuruubStart),
            end: _formatTime(ghuruubEnd),
            isActive: inGhuruub,
          ),
          const SizedBox(height: 10),
          Text(
            widget.language == AppLanguage.bn
                ? 'ইসলামী নিয়মে এই সময়গুলিতে নামাজ নিষিদ্ধ'
                : 'Prayer is discouraged during these times in Islam',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForbiddenTimeRow extends StatelessWidget {
  final AppLanguage language;
  final String label;
  final String start;
  final String end;
  final bool isActive;

  const _ForbiddenTimeRow({
    required this.language,
    required this.label,
    required this.start,
    required this.end,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: Text(
            '$start - $end',
            style: TextStyle(
              color: isActive ? const Color(0xFFEF5350) : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
