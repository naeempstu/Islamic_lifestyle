import 'package:flutter/material.dart';
import '../../../core/models/app_enums.dart';
import '../data/hadith_books_service.dart';

class HadithListScreen extends StatefulWidget {
  final AppLanguage language;
  final HadithBook book;

  const HadithListScreen({
    super.key,
    required this.language,
    required this.book,
  });

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<HadithItem> _allHadiths = [];
  List<HadithItem> _filteredHadiths = [];

  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMoreHadiths();
  }

  void _onScroll() {
    // যখন bottom-এ পৌঁছাবে, তখন more load করবে
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      _currentPage++;
      _loadMoreHadiths();
    }
  }

  Future<void> _loadMoreHadiths() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newHadiths = await HadithBooksService.fetchHadiths(
        bookKey: widget.book.key,
        limit: 20,
        page: _currentPage,
      );

      setState(() {
        if (newHadiths.isEmpty) {
          _hasMore = false;
        } else {
          _allHadiths.addAll(newHadiths);
          _filterHadiths(_searchCtrl.text);
        }
        _isLoading = false;
        _initialLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _initialLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading hadiths: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _filterHadiths(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHadiths = _allHadiths;
      } else {
        _filteredHadiths = _allHadiths
            .where((h) =>
                (h.hadithEnglish?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (h.englishNarrator
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == AppLanguage.bn
              ? widget.book.titleBn
              : widget.book.titleEn,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filterHadiths,
                decoration: InputDecoration(
                  hintText: widget.language == AppLanguage.bn
                      ? 'হাদিস খুঁজুন...'
                      : 'Search hadith...',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _filterHadiths('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Hadiths List with Pagination
          Expanded(
            child: _initialLoading && _allHadiths.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading hadiths...'),
                      ],
                    ),
                  )
                : _filteredHadiths.isEmpty
                    ? Center(
                        child: Text(
                          widget.language == AppLanguage.bn
                              ? 'কোনো হাদিস পাওয়া যায়নি'
                              : 'No hadiths found',
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredHadiths.length +
                            (_isLoading ? 1 : 0), // +1 for loading indicator
                        itemBuilder: (context, index) {
                          // Show loading indicator at bottom
                          if (index == _filteredHadiths.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Column(
                                  children: [
                                    if (_hasMore)
                                      const CircularProgressIndicator()
                                    else
                                      Text(
                                        widget.language == AppLanguage.bn
                                            ? 'আর কোনো হাদিস নেই'
                                            : 'No more hadiths',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final hadith = _filteredHadiths[index];
                          return _HadithCard(
                            language: widget.language,
                            hadith: hadith,
                            bookTitle: widget.language == AppLanguage.bn
                                ? widget.book.titleBn
                                : widget.book.titleEn,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _HadithCard extends StatefulWidget {
  final AppLanguage language;
  final HadithItem hadith;
  final String bookTitle;

  const _HadithCard({
    required this.language,
    required this.hadith,
    required this.bookTitle,
  });

  @override
  State<_HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends State<_HadithCard> {
  bool _isExpanded = false;
  bool _isFavorite = false;

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
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B2635), Color(0xFFC23B57)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.hadith.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
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
                          widget.bookTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.hadith.englishNarrator != null)
                          Text(
                            'Narrator: ${widget.hadith.englishNarrator}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                  ),
                ],
              ),

              // Hadith Text
              const SizedBox(height: 12),
              if (widget.hadith.hadithEnglish != null)
                Text(
                  widget.hadith.hadithEnglish!,
                  maxLines: _isExpanded ? null : 3,
                  overflow: _isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF1A1C30),
                  ),
                ),

              // Expand indicator
              if (!_isExpanded && widget.hadith.hadithEnglish != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.language == AppLanguage.bn
                        ? 'বিস্তারিত দেখতে ট্যাপ করুন'
                        : 'Tap to read more',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B2635),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // Grade
              if (_isExpanded && widget.hadith.gradeSahih != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Grade: ${widget.hadith.gradeSahih}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE67E22),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
