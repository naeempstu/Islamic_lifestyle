import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/quran_repository.dart';

class QuranReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late QuranRepository _repository;
  late Future<Map<String, dynamic>> _surahFuture;
  Set<String> _bookmarks = {};

  @override
  void initState() {
    super.initState();
    _repository = QuranRepository();
    _surahFuture = _repository.fetchSurah(widget.surahNumber);
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await _repository.getBookmarks();
    setState(() => _bookmarks = bookmarks.toSet());
  }

  Future<void> _toggleBookmark(int ayahNum) async {
    await _repository.toggleBookmark(widget.surahNumber, ayahNum);
    await _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.surahName,
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Surah ${widget.surahNumber}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _surahFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48,
                      color: isDark ? Colors.grey[300] : Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load surah',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          final ayahs = snapshot.data!['ayahs'] as List? ?? [];

          if (ayahs.isEmpty) {
            return Center(
              child: Text(
                'No ayahs found',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ayahs.length,
            itemBuilder: (context, index) {
              final ayah = ayahs[index] as Map<String, dynamic>;
              final ayahNum = ayah['numberInSurah'] as int? ?? index + 1;
              final isBookmarked =
                  _bookmarks.contains('${widget.surahNumber}:$ayahNum');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ayah number and bookmark
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Ayah ${ayahNum.toString().padLeft(3)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isBookmarked ? Colors.amber : null,
                            ),
                            onPressed: () => _toggleBookmark(ayahNum),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Arabic text
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          ayah['text'] as String? ?? '',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiriQuran(
                            fontSize: 24,
                            height: 2.0,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bengali pronunciation (if available)
                      if ((ayah['bengaliPronunciation'] as String?)
                              ?.isNotEmpty ??
                          false)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'উচ্চারণ',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ayah['bengaliPronunciation'] as String,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.blue[300]
                                    : Colors.blue[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),

                      // Bengali translation
                      if ((ayah['bengaliTranslation'] as String?)?.isNotEmpty ??
                          false)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'অর্থ (বাংলা)',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ayah['bengaliTranslation'] as String,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      // Copy button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copy'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Copied to clipboard')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
