import 'package:flutter/material.dart';
import '../../../core/models/app_enums.dart';

class DeenShikshaScreen extends StatefulWidget {
  final AppLanguage language;

  const DeenShikshaScreen({
    super.key,
    required this.language,
  });

  @override
  State<DeenShikshaScreen> createState() => _DeenShikshaScreenState();
}

class _DeenShikshaScreenState extends State<DeenShikshaScreen> {
  late final List<_DeenCategory> categories;

  @override
  void initState() {
    super.initState();
    _initializeCategories();
  }

  void _initializeCategories() {
    if (widget.language == AppLanguage.bn) {
      categories = [
        _DeenCategory(
          title: 'ইসলামের স্তম্ভ',
          subtitle: 'আমাদের বিশ্বাসের ভিত্তি',
          topics: [
            _Topic(
              title: 'তাওহীদ',
              description: 'আল্লাহর একতা - ইসলামের মূল ভিত্তি।',
            ),
            _Topic(
              title: 'নবুওয়াতে',
              description: 'নবী (সা:) এর প্রতি বিশ্বাস এবং তার অনুসরণ।',
            ),
            _Topic(
              title: 'আখিরাত',
              description: 'আল্লাহর ন্যায়বিচার এবং আখিরাতে বিশ্বাস।',
            ),
          ],
        ),
        _DeenCategory(
          title: 'পাঁচটি স্তম্ভ',
          subtitle: 'ইসলামের মূল অনুশীলন',
          topics: [
            _Topic(
              title: 'কালিমা',
              description: 'লা ইলাহা ইল্লাল্লাহ মুহাম্মাদুর রাসুলুল্লাহ - বিশ্বাসের ঘোষণা।',
            ),
            _Topic(
              title: 'নামাজ',
              description: 'দিনে পাঁচবার আল্লাহর নিকট আমাদের নিজেদের উপস্থাপন।',
            ),
            _Topic(
              title: 'জাকাত',
              description: 'সম্পদের শুদ্ধিকরণ এবং গরিবদের সহায়তা করা।',
            ),
            _Topic(
              title: 'রোজা',
              description: 'রমজান মাসে আত্মশুদ্ধি এবং সংযমের প্রশিক্ষণ।',
            ),
            _Topic(
              title: 'হজ',
              description: 'পবিত্র মক্কায় আল্লাহর ঘরের পরিদর্শন।',
            ),
          ],
        ),
        _DeenCategory(
          title: 'আচার-আচরণ',
          subtitle: 'ইসলামী নৈতিকতা',
          topics: [
            _Topic(
              title: 'সততা',
              description: 'সর্বদা সত্যবাদী এবং বিশ্বাসযোগ্য থাকা।',
            ),
            _Topic(
              title: 'দয়া',
              description: 'সব প্রাণীর প্রতি করুণা এবং সহানুভূতি দেখানো।',
            ),
            _Topic(
              title: 'ন্যায়বিচার',
              description: 'সকল পরিস্থিতিতে সঠিক এবং ন্যায্য সিদ্ধান্ত নেওয়া।',
            ),
            _Topic(
              title: 'পরিবার',
              description: 'পিতামাতার সেবা এবং পারিবারিক বন্ধন রক্ষা করা।',
            ),
          ],
        ),
        _DeenCategory(
          title: 'ইসলামী ইতিহাস',
          subtitle: 'আমাদের উত্তরাধিকার',
          topics: [
            _Topic(
              title: 'নবীদের গল্প',
              description: 'আদম থেকে মুহাম্মাদ (সা:) পর্যন্ত নবুওয়াতের ইতিহাস।',
            ),
            _Topic(
              title: 'সাহাবীরা',
              description: 'নবী (সা:) এর সঙ্গী এবং তাদের অবদান।',
            ),
            _Topic(
              title: 'স্বর্ণযুগ',
              description: 'ইসলামী সভ্যতার সমৃদ্ধ অধ্যায়।',
            ),
          ],
        ),
      ];
    } else {
      categories = [
        _DeenCategory(
          title: 'Pillars of Faith',
          subtitle: 'Foundation of our belief',
          topics: [
            _Topic(
              title: 'Tawheed',
              description: 'Oneness of Allah - the core of Islam.',
            ),
            _Topic(
              title: 'Prophethood',
              description: 'Belief in Prophet Muhammad (PBUH) and his guidance.',
            ),
            _Topic(
              title: 'Afterlife',
              description: 'Belief in the Day of Judgment and accountability.',
            ),
          ],
        ),
        _DeenCategory(
          title: 'Five Pillars',
          subtitle: 'Core practices of Islam',
          topics: [
            _Topic(
              title: 'Shahada',
              description:
                  'Declaration of faith - There is no god but Allah and Muhammad is His messenger.',
            ),
            _Topic(
              title: 'Salah',
              description:
                  'Prayer five times daily, connecting us with Allah.',
            ),
            _Topic(
              title: 'Zakat',
              description: 'Charity and purification of wealth.',
            ),
            _Topic(
              title: 'Sawm',
              description: 'Fasting in Ramadan for self-discipline and empathy.',
            ),
            _Topic(
              title: 'Hajj',
              description: 'Pilgrimage to the Holy Kaaba in Mecca.',
            ),
          ],
        ),
        _DeenCategory(
          title: 'Islamic Ethics',
          subtitle: 'Moral foundation',
          topics: [
            _Topic(
              title: 'Honesty',
              description: 'Always being truthful and trustworthy.',
            ),
            _Topic(
              title: 'Compassion',
              description: 'Showing mercy and kindness to all creation.',
            ),
            _Topic(
              title: 'Justice',
              description: 'Being fair and just in all dealings.',
            ),
            _Topic(
              title: 'Family',
              description: 'Respecting parents and maintaining family bonds.',
            ),
          ],
        ),
        _DeenCategory(
          title: 'Islamic History',
          subtitle: 'Our heritage',
          topics: [
            _Topic(
              title: 'Prophets',
              description:
                  'Stories of prophets from Adam to Muhammad (PBUH).',
            ),
            _Topic(
              title: 'Companions',
              description: 'The noble Sahabah and their contributions.',
            ),
            _Topic(
              title: 'Golden Age',
              description: 'The prosperous era of Islamic civilization.',
            ),
          ],
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == AppLanguage.bn ? 'দীন শিক্ষা' : 'Deen Education',
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryCard(
            category: category,
            language: widget.language,
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final _DeenCategory category;
  final AppLanguage language;

  const _CategoryCard({
    required this.category,
    required this.language,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.category.subtitle,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              color: Colors.grey.withValues(alpha: 0.1),
              child: Column(
                children: List.generate(
                  widget.category.topics.length,
                  (index) {
                    final topic = widget.category.topics[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                topic.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (index < widget.category.topics.length - 1)
                          Divider(
                            indent: 16,
                            endIndent: 16,
                            height: 1,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeenCategory {
  final String title;
  final String subtitle;
  final List<_Topic> topics;

  _DeenCategory({
    required this.title,
    required this.subtitle,
    required this.topics,
  });
}

class _Topic {
  final String title;
  final String description;

  _Topic({
    required this.title,
    required this.description,
  });
}
