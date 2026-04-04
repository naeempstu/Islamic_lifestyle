import 'package:flutter/material.dart';

import '../../../core/models/app_enums.dart';

class HalalGuideScreen extends StatelessWidget {
  final AppLanguage language;

  const HalalGuideScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language == AppLanguage.bn
            ? 'হালাল গাইড'
            : 'Halal lifestyle guide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Meat & Poultry
          _CategoryCard(
            title: language == AppLanguage.bn
                ? '📌 মাংস ও পোল্ট্রি'
                : '📌 Meat & Poultry',
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
            title: language == AppLanguage.bn
                ? '🐟 সামুদ্রিক খাবার'
                : '🐟 Seafood',
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
            title: language == AppLanguage.bn
                ? '🍶 উপাদান ও এডিটিভ'
                : '🍶 Ingredients & Additives',
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
              language == AppLanguage.bn ? '✅ চা, কফি' : '✅ Tea, coffee',
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
            title: language == AppLanguage.bn
                ? '🧀 দুগ্ধজাত পণ্য'
                : '🧀 Dairy Products',
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
          const SizedBox(height: 12),
          // Fruits & Vegetables
          _CategoryCard(
            title: language == AppLanguage.bn
                ? '🥬 ফল ও সবজি'
                : '🥬 Fruits & Vegetables',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ সব তাজা ফল ও সবজি'
                  : '✅ All fresh fruits and vegetables',
              language == AppLanguage.bn
                  ? '✅ জৈব শংসাপত্রপ্রাপ্ত পণ্য'
                  : '✅ Organically certified produce',
              language == AppLanguage.bn
                  ? '✅ টিনজাত সবজি (সংরক্ষক ছাড়া)'
                  : '✅ Canned vegetables (without preservatives)',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ কীটনাশক দিয়ে চিকিত্সিত (উদ্বিগ্ন ক্ষেত্প)'
                  : '❌ Heavily pesticide-treated (in disputed areas)',
            ],
          ),
          const SizedBox(height: 12),
          // Grains & Cereals
          _CategoryCard(
            title: language == AppLanguage.bn
                ? '🌾 শস্য ও সিরিয়াল'
                : '🌾 Grains & Cereals',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ চাল, গম, ভুট্টা (প্রাকৃতিক)'
                  : '✅ Rice, wheat, corn (natural)',
              language == AppLanguage.bn
                  ? '✅ রুটি, ফ্লোর (হালাল মিলিং)'
                  : '✅ Bread, flour (halal milling)',
              language == AppLanguage.bn
                  ? '✅ প্যাস্তা (হালাল শংসাপত্র সহ)'
                  : '✅ Pasta (with halal certification)',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ অজানা বা সন্দেহজনক উৎস'
                  : '❌ Unknown or questionable sources',
            ],
          ),
          const SizedBox(height: 12),
          // Sweets & Desserts
          _CategoryCard(
            title: language == AppLanguage.bn
                ? '🍰 মিষ্টি ও ডেজার্ট'
                : '🍰 Sweets & Desserts',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ চকলেট (অ-অ্যালকোহল, হালাল শংসাপত্র)'
                  : '✅ Chocolate (non-alcohol, halal certified)',
              language == AppLanguage.bn
                  ? '✅ ঐতিহ্যবাহী ইসলামিক মিষ্টি'
                  : '✅ Traditional Islamic sweets',
              language == AppLanguage.bn
                  ? '✅ বেকড পণ্য (প্রাণী চর্বি ছাড়া)'
                  : '✅ Baked goods (without animal fat)',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ জেলাটিন (শুকর থেকে)'
                  : '❌ Gelatin (from pork)',
              language == AppLanguage.bn
                  ? '❌ মদ বা রাম দিয়ে তৈরি'
                  : '❌ Made with wine or rum',
              language == AppLanguage.bn
                  ? '❌ পরিত্যক্ত/অ-হালাল ফ্যাট'
                  : '❌ Abandoned/non-halal fats',
            ],
          ),
          const SizedBox(height: 12),
          // Spices & Condiments
          _CategoryCard(
            title: language == AppLanguage.bn
                ? '🌶️ মশলা ও সস'
                : '🌶️ Spices & Condiments',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ প্রাকৃতিক মশলা (শুদ্ধ)'
                  : '✅ Natural spices (pure)',
              language == AppLanguage.bn
                  ? '✅ সয়া সস (হালাল-প্রত্যয়িত)'
                  : '✅ Soy sauce (halal-certified)',
              language == AppLanguage.bn
                  ? '✅ সেনাপতি (সিরকার তৈরি পণ্য ছাড়া)'
                  : '✅ Vinegar (non-fermented products okay)',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ মদ-ভিত্তিক সস'
                  : '❌ Wine-based sauces',
              language == AppLanguage.bn
                  ? '❌ অ-হালাল মশলা সংমিশ্রণ'
                  : '❌ Non-halal spice blend',
            ],
          ),
          const SizedBox(height: 12),
          // Restaurants & Catering
          _CategoryCard(
            title: language == AppLanguage.bn
                ? '🍽️ রেস্তোরাঁ ও খাবার'
                : '🍽️ Restaurants & Catering',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ হালাল-প্রত্যয়িত রেস্তোরাঁ'
                  : '✅ Halal-certified restaurants',
              language == AppLanguage.bn
                  ? '✅ মুসলিম মালিকানাধীন খাবার দোকান'
                  : '✅ Muslim-owned food establishments',
              language == AppLanguage.bn
                  ? '✅ উদ্ভিজ মেনু আইটেম'
                  : '✅ Vegetarian menu items',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ অ-হালাল মাংস ব্যবহার'
                  : '❌ Non-halal meat sourcing',
              language == AppLanguage.bn
                  ? '❌ ক্রস-দূষণ ঝুঁকি'
                  : '❌ Cross-contamination risk',
              language == AppLanguage.bn
                  ? '❌ লুকানো অ্যালকোহল বিষয়বস্তু'
                  : '❌ Hidden alcohol content',
            ],
          ),
          const SizedBox(height: 12),
          // Clothing & Fashion
          _CategoryCard(
            title: language == AppLanguage.bn
                ? '👗 পোশাক ও ফ্যাশন'
                : '👗 Clothing & Fashion',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ মনিব পোশাক (কটন, সিল্ক)'
                  : '✅ Modest clothing (cotton, silk)',
              language == AppLanguage.bn
                  ? '✅ নৈতিক ব্র্যান্ড'
                  : '✅ Ethical brands',
              language == AppLanguage.bn
                  ? '✅ প্রাণী-বান্ধব পণ্য'
                  : '✅ Animal-friendly products',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ প্রকাশ্যমূলক পোশাক'
                  : '❌ Immodest/revealing clothing',
              language == AppLanguage.bn
                  ? '❌ শুকর চামড়ার পণ্য'
                  : '❌ Pigskin leather products',
              language == AppLanguage.bn
                  ? '❌ দাসশ্রম থেকে উত্পাদিত'
                  : '❌ Products from slave labor',
            ],
          ),
          const SizedBox(height: 12),
          // Personal Care Products
          _CategoryCard(
            title: language == AppLanguage.bn
                ? '🧴 ব্যক্তিগত যত্ন'
                : '🧴 Personal Care',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ প্রাকৃতিক প্রসাধনী (পরীক্ষিত)'
                  : '✅ Natural cosmetics (verified)',
              language == AppLanguage.bn
                  ? '✅ প্রাণী-ক্রুয়েলটি মুক্ত'
                  : '✅ Cruelty-free brands',
              language == AppLanguage.bn
                  ? '✅ অ্যালকোহল-মুক্ত যত্ন পণ্য'
                  : '✅ Alcohol-free care products',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ প্রাণী-পরীক্ষিত পণ্য'
                  : '❌ Animal-tested products',
              language == AppLanguage.bn
                  ? '❌ শুকর-উত্পন্ন উপাদান'
                  : '❌ Pork-derived ingredients',
              language == AppLanguage.bn
                  ? '❌ সীমান্ত-সীমাবদ্ধ রাসায়নিক'
                  : '❌ Banned/harmful chemicals',
            ],
          ),
          const SizedBox(height: 12),
          // Entertainment & Media
          _CategoryCard(
            title: language == AppLanguage.bn
                ? '📺 বিনোদন ও মিডিয়া'
                : '📺 Entertainment & Media',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ শিক্ষামূলক ও অনুপ্রেরণামূলক সামগ্রী'
                  : '✅ Educational and inspirational content',
              language == AppLanguage.bn
                  ? '✅ পারিবারিক-বান্ধব সিনেমা'
                  : '✅ Family-friendly movies',
              language == AppLanguage.bn
                  ? '✅ ইসলামিক সঙ্গীত এবং শিল্প'
                  : '✅ Islamic music and arts',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ অনৈতিক বা যৌন সামগ্রী'
                  : '❌ Immoral or sexual content',
              language == AppLanguage.bn
                  ? '❌ সহিংসতা প্রচারকারী মিডিয়া'
                  : '❌ Violence-promoting media',
              language == AppLanguage.bn
                  ? '❌ ইসলাম-বিরোধী বার্তা'
                  : '❌ Anti-Islamic messaging',
            ],
          ),
          const SizedBox(height: 12),
          // Finance & Banking
          _CategoryCard(
            title: language == AppLanguage.bn
                ? '💰 আর্থিক ও ব্যাংকিং'
                : '💰 Finance & Banking',
            halalItems: [
              language == AppLanguage.bn
                  ? '✅ ইসলামিক ব্যাংক ও আর্থিক সেবা'
                  : '✅ Islamic banks and finance',
              language == AppLanguage.bn
                  ? '✅ রিবা-মুক্ত সঞ্চয় পরিকল্পনা'
                  : '✅ Riba-free savings plans',
              language == AppLanguage.bn
                  ? '✅ নৈতিক বিনিয়োগ পোর্টফোলিও'
                  : '✅ Ethical investment portfolios',
            ],
            haramItems: [
              language == AppLanguage.bn
                  ? '❌ সুদ-ভিত্তিক ঋণ (রিবা)'
                  : '❌ Interest-based loans (Riba)',
              language == AppLanguage.bn
                  ? '❌ ক্ষতিকারক শিল্পে বিনিয়োগ'
                  : '❌ Investment in harmful industries',
              language == AppLanguage.bn
                  ? '❌ জুয়া এবং সট্টা প্ল্যাটফর্ম'
                  : '❌ Gambling and betting platforms',
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: language == AppLanguage.bn
                ? 'সাধারণ দিকনির্দেশনা'
                : 'General Guidance',
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
              language == AppLanguage.bn
                  ? '🔍 সন্দেহের ক্ষেত্রে আল্লাহর ভয় রাখুন।'
                  : '🔍 When in doubt, exercise caution.',
              language == AppLanguage.bn
                  ? '💡 নিয়মিত লেবেল আপডেট পরীক্ষা করুন।'
                  : '💡 Check labels regularly for updates.',
            ],
          ),
          const SizedBox(height: 20),
          Text(
            language == AppLanguage.bn
                ? 'নোট: এটি একটি ব্যাপক গাইড। বিস্তারিত ফিকহ বিষয়ে স্থানীয় ইমাম সাথে পরামর্শ করুন। মতামত ভিন্নতার কারণে অন্যান্য বিদ্বান আলাদা রায় দিতে পারেন।'
                : 'Note: This is comprehensive guidance. For detailed fiqh issues, consult local Islamic scholars. Different schools of thought may have varying opinions.',
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
                child:
                    Text(item, style: Theme.of(context).textTheme.bodyMedium),
              )
          ],
        ),
      ),
    );
  }
}
