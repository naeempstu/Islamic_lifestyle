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
          _SectionCard(
            title: language == AppLanguage.bn ? 'খাবার: সহজ গাইড' : 'Food: a simple guide',
            items: [
              language == AppLanguage.bn
                  ? 'প্রস্তুত খাবারের ক্ষেত্রে লেবেল/উৎস দেখুন।'
                  : 'For packaged food, check labeling and trusted sources.',
              language == AppLanguage.bn
                  ? 'যদি নিশ্চিত না হন, পরিষ্কার তথ্যসহ বিকল্প বেছে নিন।'
                  : 'If unsure, choose an option with clear, trusted information.',
              language == AppLanguage.bn
                  ? 'বিতর্কে যাবেন না—সহজ ও গ্রহণযোগ্য রুটিনে থাকুন।'
                  : 'Avoid complexity. Stay with practical, mainstream steps.',
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: language == AppLanguage.bn ? 'ই-নাম্বার (E-numbers)' : 'E-numbers (common additives)',
            items: [
              language == AppLanguage.bn
                  ? 'E-numbers খাদ্য সংযোজক বোঝায়। আসল হালাল/হারাম নির্ভর করে উপাদানের উৎসের উপর।'
                  : 'E-numbers describe additives, but halal/haram depends on the source.',
              language == AppLanguage.bn
                  ? 'অ্যাপ্লিকেশন/পোর্টাল থেকে “উৎস-ভিত্তিক” তথ্য দেখে সিদ্ধান্ত নিন।'
                  : 'Use source-based information before deciding.',
              language == AppLanguage.bn
                  ? 'আপনার স্থানীয় স্কলার/বিশ্বস্ত গাইডলাইন ফলো করুন।'
                  : 'Follow your trusted local guidance.',
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: language == AppLanguage.bn ? 'ফাইন্যান্স: সহজ মূলনীতি' : 'Finance: gentle basics',
            items: [
              language == AppLanguage.bn
                  ? 'ব্যবহারযোগ্য, সুদের (riba) সাথে সম্পর্কিত জিনিস এড়িয়ে চলার চেষ্টা করুন।'
                  : 'Try to avoid riba-related arrangements and interest-based products.',
              language == AppLanguage.bn
                  ? 'স্বচ্ছতা ও ন্যায়পরায়ণতা বজায় রাখুন।'
                  : 'Choose clarity, fairness, and trust in transactions.',
            ],
          ),
          const SizedBox(height: 20),
          Text(
            language == AppLanguage.bn
                ? 'নোট: এটি মূলত “স্কলার-নিউট্রাল, মেইনস্ট্রিম” গাইড। জটিল ফিকহ বিতর্ক এখানে নেই।'
                : 'Note: Scholar-neutral, mainstream guidance. No complex fiqh debates here.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
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

