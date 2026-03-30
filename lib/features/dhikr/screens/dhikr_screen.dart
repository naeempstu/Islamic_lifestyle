import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../../core/models/app_enums.dart';
import '../../duas/data/duas_models.dart';
import '../../duas/data/duas_repository.dart';
import '../data/dhikr_models.dart';
import '../data/dhikr_repository.dart';
import '../data/tasbih_store.dart';

class DhikrScreen extends StatefulWidget {
  final AppLanguage language;
  final bool vibrationEnabled;
  final DhikrRepository dhikrRepository;
  final DuasRepository duasRepository;

  const DhikrScreen({
    super.key,
    required this.language,
    required this.vibrationEnabled,
    required this.dhikrRepository,
    required this.duasRepository,
  });

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  int _tasbihCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await TasbihStore.loadTodayCount();
    if (mounted) setState(() => _tasbihCount = c);
  }

  Future<void> _increment() async {
    final next = _tasbihCount + 1;
    setState(() => _tasbihCount = next);
    await TasbihStore.saveTodayCount(next);
    if (widget.vibrationEnabled) {
      Vibration.hasVibrator().then((has) {
        if (has == true) Vibration.vibrate(duration: 30);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Dhikr', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              tabs: [
                Tab(text: 'Dhikr'),
                Tab(text: 'Duas'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
          children: [
            _DhikrTab(
              language: widget.language,
              repository: widget.dhikrRepository,
              tasbihCount: _tasbihCount,
              onTapTasbih: _increment,
            ),
            _DuasTab(
              language: widget.language,
              repository: widget.duasRepository,
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }
}

class _DhikrTab extends StatelessWidget {
  final AppLanguage language;
  final DhikrRepository repository;
  final int tasbihCount;
  final VoidCallback onTapTasbih;

  const _DhikrTab({
    required this.language,
    required this.repository,
    required this.tasbihCount,
    required this.onTapTasbih,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _topCard(Icons.touch_app_outlined, 'Tasbih Counter', const Color(0xFFE3ECE6), const Color(0xFF1D7E53))),
            const SizedBox(width: 12),
            Expanded(child: _topCard(Icons.auto_awesome_outlined, 'Duas', const Color(0xFFF5EFE0), const Color(0xFFC7A452))),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onTapTasbih,
            icon: const Icon(Icons.add),
            label: Text(language == AppLanguage.bn ? '১ যোগ করুন' : 'Add 1'),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          language == AppLanguage.bn ? 'যিকির কালেকশন' : 'Dhikr Collection',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<DhikrCategory>>(
          future: repository.loadDhikrCategories(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final cats = snapshot.data!;
            return Column(
              children: cats
                  .map(
                    (cat) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              repository.localizedTitle(cat, language),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            for (final item in cat.items)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _DhikrItemRow(
                                  language: language,
                                  item: item,
                                ),
                              ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('$tasbihCount', style: const TextStyle(color: Color(0xFFC7A452), fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _topCard(IconData icon, String title, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: fg),
          ),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DhikrItemRow extends StatelessWidget {
  final AppLanguage language;
  final DhikrItem item;

  const _DhikrItemRow({required this.language, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            item.arabic,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          language == AppLanguage.bn ? item.bn : item.en,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          language == AppLanguage.bn
              ? 'ডিফল্ট কাউন্ট: ${item.defaultCount}'
              : 'Default count: ${item.defaultCount}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DuasTab extends StatelessWidget {
  final AppLanguage language;
  final DuasRepository repository;

  const _DuasTab({required this.language, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          language == AppLanguage.bn ? 'শান্তভাবে দোয়া পড়ুন' : 'Read duas gently',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<DuaCategory>>(
          future: repository.loadDuaCategories(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final cats = snapshot.data!;
            return Column(
              children: [
                for (final cat in cats)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            repository.localizedTitle(cat, language),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          for (final dua in cat.items)
                            _DuaItemCard(
                              language: language,
                              dua: dua,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          language == AppLanguage.bn
              ? 'নোট: পূর্ণ দোয়া লাইব্রেরি পরে যোগ করা যাবে।'
              : 'Note: Expand the dua library later for production.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DuaItemCard extends StatelessWidget {
  final AppLanguage language;
  final DuaItem dua;

  const _DuaItemCard({required this.language, required this.dua});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language == AppLanguage.bn ? dua.titleBn : dua.titleEn,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                dua.arabic,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              language == AppLanguage.bn ? dua.bn : dua.en,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

