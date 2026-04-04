import 'package:flutter/material.dart';

import '../../../core/models/app_enums.dart';
import '../data/duas_models.dart';
import '../data/duas_repository.dart';

class DuasScreen extends StatefulWidget {
  final AppLanguage language;
  final DuasRepository repository;

  const DuasScreen({
    super.key,
    required this.language,
    required this.repository,
  });

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == AppLanguage.bn ? 'দোয়া' : 'Duas',
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Text(
            widget.language == AppLanguage.bn
                ? 'দোয়ার সংগ্রহ'
                : 'Duas Collection',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<DuaCategory>>(
            future: widget.repository.loadDuaCategories(),
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
                          ? 'দোয়া লোড করতে ব্যর্থ'
                          : 'Failed to load duas',
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
                          ? 'কোনো দোয়া পাওয়া যায়নি'
                          : 'No duas found',
                    ),
                  ),
                );
              }

              return Column(
                children: categories
                    .map(
                      (category) => _DuaCategoryCard(
                        language: widget.language,
                        category: category,
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

class _DuaCategoryCard extends StatefulWidget {
  final AppLanguage language;
  final DuaCategory category;

  const _DuaCategoryCard({
    required this.language,
    required this.category,
  });

  @override
  State<_DuaCategoryCard> createState() => _DuaCategoryCardState();
}

class _DuaCategoryCardState extends State<_DuaCategoryCard> {
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
                          widget.language == AppLanguage.bn
                              ? widget.category.titleBn
                              : widget.category.titleEn,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.language == AppLanguage.bn
                              ? '${widget.category.items.length} দোয়া'
                              : '${widget.category.items.length} Duas',
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
                        Text(
                          widget.language == AppLanguage.bn
                              ? item.titleBn
                              : item.titleEn,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (item.arabic.isNotEmpty)
                          Text(
                            item.arabic,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.8,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        if (item.arabic.isNotEmpty) const SizedBox(height: 8),
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
