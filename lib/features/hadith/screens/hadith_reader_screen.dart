import 'package:flutter/material.dart';
import '../../../core/models/app_enums.dart';
import '../data/hadith_models.dart';
import '../data/hadith_repository.dart';

class HadithReaderScreen extends StatefulWidget {
  final AppLanguage language;
  final HadithRepository hadithRepository;

  const HadithReaderScreen({
    super.key,
    required this.language,
    required this.hadithRepository,
  });

  @override
  State<HadithReaderScreen> createState() => _HadithReaderScreenState();
}

class _HadithReaderScreenState extends State<HadithReaderScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedCollectionId = -1;
  late Future<HadithData> _hadithDataFuture;

  @override
  void initState() {
    super.initState();
    _hadithDataFuture = widget.hadithRepository.loadHadithData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == AppLanguage.bn ? 'হাদিস' : 'Hadith'),
      ),
      body: FutureBuilder<HadithData>(
        future: _hadithDataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasError && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                widget.language == AppLanguage.bn
                    ? 'হাদিস ডেটা লোড হতে ব্যর্থ: ${snapshot.error}'
                    : 'Failed to load Hadith data: ${snapshot.error}',
              ),
            );
          }

          final data = snapshot.data ?? HadithData(collections: []);

          // Show message if no collections found
          if (data.collections.isEmpty) {
            return Center(
              child: Text(
                widget.language == AppLanguage.bn
                    ? 'কোনো হাদিস উপলব্ধ নেই'
                    : 'No hadith collections available',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Text(
                    widget.language == AppLanguage.bn
                        ? 'হাদিস সংগ্রহ'
                        : 'Collections',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: widget.language == AppLanguage.bn
                        ? 'হাদিস সংগ্রহ খুঁজুন'
                        : 'Search hadith collection',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.language == AppLanguage.bn
                    ? 'হাদিসের সংগ্রহ'
                    : 'Hadith Collections',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...data.collections.map((collection) {
                final query = _searchCtrl.text.trim().toLowerCase();
                if (query.isNotEmpty &&
                    !collection.nameEn.toLowerCase().contains(query) &&
                    !collection.nameBn.toLowerCase().contains(query)) {
                  return const SizedBox.shrink();
                }

                final isSelected = _selectedCollectionId == collection.id;

                return Column(
                  children: [
                    Card(
                      elevation: isSelected ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => setState(
                          () => _selectedCollectionId = collection.id,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.language == AppLanguage.bn
                                    ? collection.nameBn
                                    : collection.nameEn,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.language == AppLanguage.bn
                                    ? collection.authorBn
                                    : collection.authorEn,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${collection.hadithCount} ${widget.language == AppLanguage.bn ? 'হাদিস' : 'Hadith'}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isSelected && collection.hadith.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: List.generate(
                            collection.hadith.length,
                            (index) => _HadithTile(
                              hadith: collection.hadith[index],
                              language: widget.language,
                              isLast: index == collection.hadith.length - 1,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _HadithTile extends StatefulWidget {
  final Hadith hadith;
  final AppLanguage language;
  final bool isLast;

  const _HadithTile({
    required this.hadith,
    required this.language,
    required this.isLast,
  });

  @override
  State<_HadithTile> createState() => _HadithTileState();
}

class _HadithTileState extends State<_HadithTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${widget.hadith.number}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.expand_more),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  () {
                    final displayText = widget.language == AppLanguage.bn
                        ? (widget.hadith.textBn.isNotEmpty ? widget.hadith.textBn : widget.hadith.text)
                        : widget.hadith.text;
                    return displayText.length > 100
                        ? '${displayText.substring(0, 100)}...'
                        : displayText;
                  }(),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.hadith.narrator.isNotEmpty || widget.hadith.narratorBn.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${widget.language == AppLanguage.bn ? 'বর্ণনাকারী' : 'Narrator'}: ${widget.language == AppLanguage.bn ? (widget.hadith.narratorBn.isNotEmpty ? widget.hadith.narratorBn : widget.hadith.narrator) : widget.hadith.narrator}',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.language == AppLanguage.bn
                      ? (widget.hadith.textBn.isNotEmpty ? widget.hadith.textBn : widget.hadith.text)
                      : widget.hadith.text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (widget.hadith.explanation != null || widget.hadith.explanationBn != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.language == AppLanguage.bn
                              ? 'ব্যাখ্যা'
                              : 'Explanation',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.language == AppLanguage.bn
                              ? (widget.hadith.explanationBn?.isNotEmpty == true
                                  ? widget.hadith.explanationBn!
                                  : widget.hadith.explanation ?? '')
                              : widget.hadith.explanation ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (!widget.isLast) const Divider(height: 1, indent: 14, endIndent: 14),
      ],
    );
  }
}
