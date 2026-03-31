import 'package:flutter/material.dart';

import '../../../core/models/app_enums.dart';

class HalalGuideScreen extends StatelessWidget {
  final AppLanguage language;

  const HalalGuideScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language == AppLanguage.bn ? 'হালাল গাইড' : 'Halal lifestyle guide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Meat & Poultry
          _CategoryCard(
            title: language == AppLanguage.bn ? '📌 মাংস ও পোল্ট্রি' : '📌 Meat & Poultry',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ গরু, মেষ, ছাগল (বিসমিল্লাহ দিয়ে জবাই করা)'
                  : '✅ Beef, lamb, goat (slaughtered with Bismillah)',
              language == AppLanguage.bn
                  ? '✅ মুরগি, হাঁস, টার্কি'
                  : '✅ Chicken, duck, turkey',
              language == AppLanguage.bn
                  ? '✅ হালাল-প্রত্যয়িত মাংস'
                  : '✅ Halal-certified meat',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ শুকর ও শুকর পণ্য'
                  : '❌ Pork and pork products',
              language == AppLanguage.bn
                  ? '❌ বিসমিল্লাহ ছাড়া জবাই করা'
                  : '❌ Meat not slaughtered Islamically',
              language == AppLanguage.bn
                  ? '❌ নন-হালাল প্রত্যয়িত মাংস'
                  : '❌ Non-halal certified meat',
            ],
          ),
          const SizedBox(height: 12),
          // Seafood
          _CategoryCard(
            title: language == AppLanguage.bn ? '🐟 সামুদ্রিক খাবার' : '🐟 Seafood',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ মাছ, চিংড়ি, কাঁকড়া'
                  : '✅ Fish, shrimp, crab',
              language == AppLanguage.bn
                  ? '✅ ঝিনুক, শামুক'
                  : '✅ Oysters, clams',
            ],
            haramItems: [],
          ),
          const SizedBox(height: 12),
          // Ingredients & Additives
          _CategoryCard(
            title: language == AppLanguage.bn ? '🍶 উপাদান ও এডিটিভ' : '🍶 Ingredients & Additives',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ উদ্ভিজ তেল, প্রাকৃতিক মশলা'
                  : '✅ Vegetable oils, natural spices',
              language == AppLanguage.bn
                  ? '✅ প্রাকৃতিক রং ও সংরক্ষক'
                  : '✅ Natural colors and preservatives',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ অ্যালকোহল (ওয়াইন, বিয়ার)'
                  : '❌ Alcohol (wine, beer)',
              language == AppLanguage.bn
                  ? '❌ শুকর-ভিত্তিক পণ্য'
                  : '❌ Pork-derived products',
            ],
          ),
          const SizedBox(height: 12),
          // Beverages
          _CategoryCard(
            title: language == AppLanguage.bn ? '☕ পানীয়' : '☕ Beverages',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ পানি, দুধ, রস (অ্যালকোহল মুক্ত)'
                  : '✅ Water, milk, juice (alcohol-free)',
              language == AppLanguage.bn
                  ? '✅ চা, কফি'
                  : '✅ Tea, coffee',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ অ্যালকোহলযুক্ত পানীয়'
                  : '❌ Alcoholic beverages',
              language == AppLanguage.bn
                  ? '❌ মাদক দ্রব্য'
                  : '❌ Intoxicating drinks',
            ],
          ),
          const SizedBox(height: 12),
          // Dairy
          _CategoryCard(
            title: language == AppLanguage.bn ? '🧀 দুগ্ধজাত পণ্য' : '🧀 Dairy Products',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ দুধ, দই, পনির (নিরাপদ রেনেট)'
                  : '✅ Milk, yogurt, cheese (safe rennet)',
              language == AppLanguage.bn
                  ? '✅ মাখন, ঘি (হালাল উৎস)'
                  : '✅ Butter, ghee (halal source)',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ রেনেট (অ-হালাল প্রাণী থেকে)'
                  : '❌ Rennet from non-halal animals',
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: language == AppLanguage.bn ? 'সাধারণ দিকনির্দেশনা' : 'General Guidance',
            items: [
              language == AppLanguage.bn
                  ? '📖 উৎস চেক করুন: পণ্যের লেবেল পড়ুন।'
                  : '📖 Check source: Read product labels carefully.',
              language == AppLanguage.bn
                  ? '🏷️ হালাল সার্টিফিকেশন খুঁজুন।'
                  : '🏷️ Look for halal certification seals.',
              language == AppLanguage.bn
                  ? '⚖️ স্থানীয় নির্দেশনা অনুসরণ করুন।'
                  : '⚖️ Follow guidance from local scholars.',
            ],
          ),
          const SizedBox(height: 20),
          Text(
            language == AppLanguage.bn
                ? 'নোট: এটি একটি প্রাথমিক গাইড। বিস্তারিত ফিকহ বিষয়ে স্থানীয় ইমাম সাথে পরামর্শ করুন।'
                : 'Note: This is basic guidance. For detailed fiqh issues, consult your local imam.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String title;
  final List<String> halalItems;
  final List<String> haramItems;

  const _CategoryCard({
    required this.title,
    required this.halalItems,
    required this.haramItems,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              if (widget.halalItems.isNotEmpty) ...[
                Text(
                  'Halal (Permissible):',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                for (final item in widget.halalItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                if (widget.haramItems.isNotEmpty) const SizedBox(height: 12),
              ],
              if (widget.haramItems.isNotEmpty) ...[
                Text(
                  'Haram (Forbidden):',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFFC62828),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                for (final item in widget.haramItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(item, style: Theme.of(context).textTheme.bodyMedium),
              )
          ],
        ),
      ),
    );
  }
}

