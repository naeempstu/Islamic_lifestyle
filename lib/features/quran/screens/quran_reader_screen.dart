import 'package:flutter/material.dart';

import '../../../core/models/app_enums.dart';
import '../data/quran_models.dart';
import '../data/quran_repository.dart';

class QuranReaderScreen extends StatefulWidget {
  final AppLanguage language;
  final QuranRepository quranRepository;

  const QuranReaderScreen({
    super.key,
    required this.language,
    required this.quranRepository,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<int> _bookmarkedSurahIds = <int>{};
  int _tab = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuranData>(
      future: widget.quranRepository.loadOfflineData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final today = DateTime.now();

        return FutureBuilder<QuranAyah>(
          future: widget.quranRepository.getAyahOfDay(data: data, date: today),
          builder: (context, ayahSnapshot) {
            final ayahOfDay = ayahSnapshot.data;
            final query = _searchCtrl.text.trim().toLowerCase();
            final surahs = data.surahs.where((s) {
              if (query.isEmpty) return true;
              return s.nameEn.toLowerCase().contains(query) ||
                  s.nameBn.toLowerCase().contains(query) ||
                  s.id.toString() == query;
            }).toList();
            final bookmarked = data.surahs
                .where((s) => _bookmarkedSurahIds.contains(s.id))
                .toList();
            final activeList = _tab == 0 ? surahs : bookmarked;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Text(
                      'Qur’an',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    Icon(
                      _bookmarkedSurahIds.isEmpty
                          ? Icons.bookmark_border_rounded
                          : Icons.bookmark_rounded,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (ayahOfDay != null)
                  _AyahOfDayCard(
                    language: widget.language,
                    ayah: ayahOfDay,
                    subtitle: widget.language == AppLanguage.bn
                        ? 'আজকের আয়াত'
                        : 'Ayah of the day',
                  ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E0DB)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: widget.language == AppLanguage.bn
                          ? 'সুরা খুঁজুন...'
                          : 'Search surah...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _tabButton(
                        widget.language == AppLanguage.bn ? 'সুরা' : 'Surah',
                        selected: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                    ),
                    Expanded(
                      child: _tabButton(
                        widget.language == AppLanguage.bn
                            ? 'বুকমার্ক'
                            : 'Bookmarks',
                        selected: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (activeList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      widget.language == AppLanguage.bn
                          ? 'কোনো ফলাফল পাওয়া যায়নি'
                          : 'No results found',
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final surah in activeList)
                  _SurahCard(
                    language: widget.language,
                    surah: surah,
                    bookmarked: _bookmarkedSurahIds.contains(surah.id),
                    onBookmarkToggle: () {
                      setState(() {
                        if (_bookmarkedSurahIds.contains(surah.id)) {
                          _bookmarkedSurahIds.remove(surah.id);
                        } else {
                          _bookmarkedSurahIds.add(surah.id);
                        }
                      });
                    },
                    onTap: () => _openSurahSheet(surah),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _tabButton(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected
                  ? const Color(0xFF1E8C58)
                  : const Color(0xFF8E8F9A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            color: selected ? const Color(0xFF1E8C58) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Future<void> _openSurahSheet(QuranSurah surah) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.language == AppLanguage.bn
                      ? surah.nameBn
                      : surah.nameEn,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.language == AppLanguage.bn
                      ? '${surah.ayahs.length} আয়াত'
                      : '${surah.ayahs.length} ayahs',
                ),
                const SizedBox(height: 12),
                for (final ayah in surah.ayahs)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${ayah.number}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              ayah.arabic,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.language == AppLanguage.bn
                                ? ayah.bn
                                : ayah.en,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AyahOfDayCard extends StatelessWidget {
  final AppLanguage language;
  final QuranAyah ayah;
  final String subtitle;

  const _AyahOfDayCard({
    required this.language,
    required this.ayah,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2BF5F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayah.arabic,
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            language == AppLanguage.bn ? ayah.bn : ayah.en,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final AppLanguage language;
  final QuranSurah surah;
  final bool bookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onTap;

  const _SurahCard({
    required this.language,
    required this.surah,
    required this.bookmarked,
    required this.onBookmarkToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE3ECE6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${surah.id}',
                  style: const TextStyle(
                    color: Color(0xFF1E8C58),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == AppLanguage.bn ? surah.nameBn : surah.nameEn,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    language == AppLanguage.bn
                        ? '${surah.ayahs.length} আয়াত'
                        : '${surah.ayahs.length} verses',
                    style: const TextStyle(color: Color(0xFF7A7B89)),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onBookmarkToggle,
              icon: Icon(
                bookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
