import 'package:flutter/material.dart';
import '../../../core/models/app_enums.dart';
import '../data/hadith_books_service.dart';
import 'hadith_list_screen.dart';

class HadithBooksScreen extends StatelessWidget {
  final AppLanguage language;

  const HadithBooksScreen({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final books = HadithBooksService.getAllBooks();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == AppLanguage.bn ? 'হাদিসের কিতাব' : 'Hadith Books',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? const [Color(0xFF5D1C24), Color(0xFF7D2A38)]
                        : const [Color(0xFF8B2635), Color(0xFFC23B57)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == AppLanguage.bn
                          ? 'কুতুব আস-সিত্তাহ'
                          : 'Kutub Al-Sittah',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      language == AppLanguage.bn
                          ? '৬টি প্রধান হাদিসের গ্রন্থ'
                          : 'The Six Main Hadith Collections',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Books Grid
              ...books.asMap().entries.map((entry) {
                final index = entry.key;
                final book = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HadithBookCard(
                    language: language,
                    book: book,
                    number: index + 1,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HadithListScreen(
                            language: language,
                            book: book,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : const Color(0xFFF0E4FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7C3AED),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outlined,
                          color: Color(0xFF7C3AED),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          language == AppLanguage.bn ? 'সম্পর্কে' : 'About',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      language == AppLanguage.bn
                          ? 'এই ছয়টি সংগ্রহ ইসলামিক হাদিসের সবচেয়ে নির্ভরযোগ্য উৎস। প্রতিটি হাদিস রসূল মুহাম্মাদ (সাঃ) থেকে সংগৃহীত এবং যাচাই করা।'
                          : 'These six collections are the most authentic sources of Islamic hadith. Each hadith is collected and verified from Prophet Muhammad (SAW).',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : const Color(0xFF1A1C30),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HadithBookCard extends StatefulWidget {
  final AppLanguage language;
  final HadithBook book;
  final int number;
  final VoidCallback onTap;

  const _HadithBookCard({
    required this.language,
    required this.book,
    required this.number,
    required this.onTap,
  });

  @override
  State<_HadithBookCard> createState() => _HadithBookCardState();
}

class _HadithBookCardState extends State<_HadithBookCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _pressed;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _pressed ? 0.96 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: active
                    ? [
                        const Color(0xFF8B2635),
                        const Color(0xFFC23B57),
                      ]
                    : [
                        const Color(0xFFF3E5D8),
                        const Color(0xFFE8D4C0),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? const Color(0xFF8B2635).withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: active ? 16 : 8,
                  offset: Offset(0, active ? 8 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Number Circle
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? Colors.white.withValues(alpha: 0.2)
                              : const Color(0xFFA0704D).withValues(alpha: 0.2),
                        ),
                        child: Center(
                          child: Text(
                            '${widget.number}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFFA0704D),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Book Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.language == AppLanguage.bn
                                  ? widget.book.titleBn
                                  : widget.book.titleEn,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: active
                                    ? Colors.white
                                    : const Color(0xFF1A1C30),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.language == AppLanguage.bn
                                  ? widget.book.authorBn
                                  : widget.book.authorEn,
                              style: TextStyle(
                                fontSize: 12,
                                color: active
                                    ? Colors.white70
                                    : const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow Icon
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: active ? Colors.white : const Color(0xFFA0704D),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
