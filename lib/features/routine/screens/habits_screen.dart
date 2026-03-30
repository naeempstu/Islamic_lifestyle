import 'package:flutter/material.dart';

import '../../../core/models/app_enums.dart';
import '../data/daily_routine_store.dart';

class HabitsScreen extends StatefulWidget {
  final AppLanguage language;
  final DailyRoutineStore routineStore;

  const HabitsScreen({
    super.key,
    required this.language,
    required this.routineStore,
  });

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late Future<DailyRoutine> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.routineStore.loadForDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DailyRoutine>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final routine = snapshot.data!;
        final totalDone = [
          routine.salahCompleted,
          routine.quranDone,
          routine.dhikrDone,
          routine.duaDone,
          routine.goodDeedDone,
        ].where((v) => v).length;
        final progress = totalDone / 5.0;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.language == AppLanguage.bn ? 'দৈনিক দীন রুটিন' : 'Daily Deen Routine',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF22925D),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.language == AppLanguage.bn ? 'আজকের অগ্রগতি' : 'Today\'s Progress',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalDone/5',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 26),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      color: const Color(0xFF7AD3A9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      '${(progress * 100).round()}% Completed',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              widget.language == AppLanguage.bn ? 'দৈনিক চেকলিস্ট' : 'Daily Checklist',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _habitItem(
              titleBn: 'সালাহ সম্পন্ন',
              titleEn: 'Salah Completed',
              checked: routine.salahCompleted,
              icon: Icons.mosque_outlined,
              onChanged: (v) => _save(routine.copyWith(salahCompleted: v)),
            ),
            _habitItem(
              titleBn: 'কুরআন পড়া',
              titleEn: 'Qur\'an Reading',
              checked: routine.quranDone,
              icon: Icons.menu_book_outlined,
              onChanged: (v) => _save(routine.copyWith(quranDone: v)),
            ),
            _habitItem(
              titleBn: 'যিকির করা',
              titleEn: 'Dhikr Done',
              checked: routine.dhikrDone,
              icon: Icons.favorite_border,
              onChanged: (v) => _save(routine.copyWith(dhikrDone: v)),
            ),
            _habitItem(
              titleBn: 'দোয়া পড়া',
              titleEn: 'Dua Read',
              checked: routine.duaDone,
              icon: Icons.auto_awesome_outlined,
              onChanged: (v) => _save(routine.copyWith(duaDone: v)),
            ),
            _habitItem(
              titleBn: 'ভালো কাজ',
              titleEn: 'Good Deed',
              checked: routine.goodDeedDone,
              icon: Icons.volunteer_activism_outlined,
              onChanged: (v) => _save(routine.copyWith(goodDeedDone: v)),
            ),
          ],
        );
      },
    );
  }

  Widget _habitItem({
    required String titleBn,
    required String titleEn,
    required bool checked,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1EB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF1C7E53)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.language == AppLanguage.bn ? titleBn : titleEn,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Checkbox(
            value: checked,
            shape: const CircleBorder(),
            onChanged: (v) => onChanged(v ?? false),
          ),
        ],
      ),
    );
  }

  Future<void> _save(DailyRoutine routine) async {
    await widget.routineStore.saveForDate(DateTime.now(), routine);
    if (!mounted) return;
    setState(() {
      _future = Future.value(routine);
    });
  }
}
