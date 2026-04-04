import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../../core/models/app_enums.dart';
import '../data/dhikr_models.dart';
import '../data/dhikr_repository.dart';
import '../data/tasbih_store.dart';

class DhikrScreen extends StatefulWidget {
  final AppLanguage language;
  final bool vibrationEnabled;
  final DhikrRepository dhikrRepository;

  const DhikrScreen({
    super.key,
    required this.language,
    required this.vibrationEnabled,
    required this.dhikrRepository,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == AppLanguage.bn ? 'যিকির' : 'Dhikr',
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tasbih Counter Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [const Color(0xFF1B5E38), const Color(0xFF0D3D23)]
                    : [const Color(0xFFE3ECE6), const Color(0xFFC8E6C9)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2A9D5D)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.touch_app_outlined,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1D7E53),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.language == AppLanguage.bn
                                ? 'আজকের তাসবিহ'
                                : 'Today\'s Tasbih',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF1D7E53),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tasbihCount.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF1D7E53),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _increment,
                    icon: const Icon(Icons.add),
                    label: Text(
                      widget.language == AppLanguage.bn
                          ? 'এক যোগ করুন'
                          : 'Add 1',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2A9D5D)
                              : const Color(0xFF1D7E53),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.language == AppLanguage.bn
                ? 'যিকির সংগ্রহ'
                : 'Dhikr Collection',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<DhikrCategory>>(
            future: widget.dhikrRepository.loadDhikrCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.language == AppLanguage.bn
                          ? 'যিকির লোড করতে ব্যর্থ'
                          : 'Failed to load dhikr',
                    ),
                  ),
                );
              }

              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      widget.language == AppLanguage.bn
                          ? 'কোনো যিকির পাওয়া যায়নি'
                          : 'No dhikr found',
                    ),
                  ),
                );
              }

              return Column(
                children: categories
                    .map(
                      (category) => _DhikrCategoryCard(
                        language: widget.language,
                        category: category,
                        repository: widget.dhikrRepository,
                        tasbihCount: _tasbihCount,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DhikrCategoryCard extends StatefulWidget {
  final AppLanguage language;
  final DhikrCategory category;
  final DhikrRepository repository;
  final int tasbihCount;

  const _DhikrCategoryCard({
    required this.language,
    required this.category,
    required this.repository,
    required this.tasbihCount,
  });

  @override
  State<_DhikrCategoryCard> createState() => _DhikrCategoryCardState();
}

class _DhikrCategoryCardState extends State<_DhikrCategoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.repository
                              .localizedTitle(widget.category, widget.language),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.language == AppLanguage.bn
                              ? '${widget.category.items.length} যিকির'
                              : '${widget.category.items.length} Dhikr',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const Divider(),
                ...widget.category.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            item.arabic,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (widget.language == AppLanguage.bn)
                          Text(
                            item.bn,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[200]
                                  : Colors.black87,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          Text(
                            item.en,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[200]
                                  : Colors.black87,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          widget.language == AppLanguage.bn
                              ? 'ডিফল্ট কাউন্ট: ${item.defaultCount}'
                              : 'Default count: ${item.defaultCount}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.amber[300]
                                    : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
