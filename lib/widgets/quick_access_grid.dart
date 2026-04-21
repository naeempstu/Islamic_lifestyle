import 'package:flutter/material.dart';
import '../../core/models/app_enums.dart';

enum QuickAccessAction {
  qibla,
  tasbih,
  quran,
  hadith,
  duas,
  nearestMosque,
  halal,
  deen,
}

class QuickAccessGrid extends StatelessWidget {
  final AppLanguage language;
  final ValueChanged<QuickAccessAction> onActionTap;

  const QuickAccessGrid({
    super.key,
    required this.language,
    required this.onActionTap,
  });

  String _getLabel(QuickAccessAction action) {
    const labels = {
      QuickAccessAction.qibla: {'en': 'Qibla\nDirection', 'bn': 'কিবলা\nদিক'},
      QuickAccessAction.tasbih: {'en': 'Tasbih', 'bn': 'তাসবিহ'},
      QuickAccessAction.quran: {'en': 'Quran', 'bn': 'কুরআন'},
      QuickAccessAction.hadith: {'en': 'Hadith', 'bn': 'হাদিস'},
      QuickAccessAction.duas: {'en': 'Duas', 'bn': 'দোয়া'},
      QuickAccessAction.nearestMosque: {
        'en': 'Nearest\nMosque',
        'bn': 'নিকটস্থ\nমসজিদ'
      },
      QuickAccessAction.halal: {'en': 'Halal\nGuide', 'bn': 'হালাল\nগাইড'},
      QuickAccessAction.deen: {'en': 'Deen\nEducation', 'bn': 'দীন\nশিক্ষা'},
    };

    final langKey = language == AppLanguage.bn ? 'bn' : 'en';
    return labels[action]?[langKey] ?? '';
  }

  List<Map<String, dynamic>> _getQuickAccessItems() {
    return [
      {
        'action': QuickAccessAction.qibla,
        'icon': Icons.explore_outlined,
        'colors': const [Color(0xFF06b6d4), Color(0xFF0891b2)],
      },
      {
        'action': QuickAccessAction.tasbih,
        'icon': Icons.self_improvement_outlined,
        'colors': const [Color(0xFF8b5cf6), Color(0xFF7c3aed)],
      },
      {
        'action': QuickAccessAction.quran,
        'icon': Icons.menu_book_outlined,
        'colors': const [Color(0xFF2563eb), Color(0xFF1d4ed8)],
      },
      {
        'action': QuickAccessAction.hadith,
        'icon': Icons.book_outlined,
        'colors': const [Color(0xFF10b981), Color(0xFF059669)],
      },
      {
        'action': QuickAccessAction.duas,
        'icon': Icons.favorite_outline,
        'colors': const [Color(0xFFef4444), Color(0xFFdc2626)],
      },
      {
        'action': QuickAccessAction.nearestMosque,
        'icon': Icons.map_outlined,
        'colors': const [Color(0xFFf59e0b), Color(0xFFd97706)],
      },
      {
        'action': QuickAccessAction.halal,
        'icon': Icons.restaurant_menu_outlined,
        'colors': const [Color(0xFFec4899), Color(0xFFdb2777)],
      },
      {
        'action': QuickAccessAction.deen,
        'icon': Icons.school_outlined,
        'colors': const [Color(0xFF06b6d4), Color(0xFF0d9488)],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getQuickAccessItems();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return QuickAccessButton(
          icon: item['icon'] as IconData,
          label: _getLabel(item['action'] as QuickAccessAction),
          gradient: item['colors'] as List<Color>,
          onTap: () => onActionTap(item['action'] as QuickAccessAction),
        );
      },
    );
  }
}

class QuickAccessButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const QuickAccessButton({
    super.key,
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<QuickAccessButton> createState() => _QuickAccessButtonState();
}

class _QuickAccessButtonState extends State<QuickAccessButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: widget.gradient[1].withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
