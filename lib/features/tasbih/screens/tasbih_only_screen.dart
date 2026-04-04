import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../../core/models/app_enums.dart';
import '../../dhikr/data/tasbih_store.dart';

class TasbihOnlyScreen extends StatefulWidget {
  final AppLanguage language;
  final bool vibrationEnabled;

  const TasbihOnlyScreen({
    super.key,
    required this.language,
    required this.vibrationEnabled,
  });

  @override
  State<TasbihOnlyScreen> createState() => _TasbihOnlyScreenState();
}

class _TasbihOnlyScreenState extends State<TasbihOnlyScreen> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final current = await TasbihStore.loadTodayCount();
    if (!mounted) return;
    setState(() => _count = current);
  }

  Future<void> _increment() async {
    final next = _count + 1;
    setState(() => _count = next);
    await TasbihStore.saveTodayCount(next);
    if (widget.vibrationEnabled) {
      final has = await Vibration.hasVibrator();
      if (has == true) {
        await Vibration.vibrate(duration: 30);
      }
    }
  }

  Future<void> _reset() async {
    setState(() => _count = 0);
    await TasbihStore.saveTodayCount(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == AppLanguage.bn ? 'তাসবিহ' : 'Tasbih'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.language == AppLanguage.bn
                      ? 'আজকের কাউন্ট'
                      : 'Today\'s count',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 18),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? const [
                              Color.fromARGB(255, 60, 140, 100),
                              Color.fromARGB(255, 80, 180, 130),
                            ]
                          : const [Color(0xFF1F8A57), Color(0xFF3EA46F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0x44109070)
                            : const Color(0x441F8A57),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$_count',
                    style: const TextStyle(
                      fontSize: 56,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _increment,
                    child: Text(
                      widget.language == AppLanguage.bn ? 'গণনা করুন' : 'Count',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(
                    widget.language == AppLanguage.bn ? 'রিসেট' : 'Reset',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
