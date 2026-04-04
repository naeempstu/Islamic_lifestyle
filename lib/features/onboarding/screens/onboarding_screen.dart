import 'package:flutter/material.dart';

import '../../../core/models/app_enums.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/storage/app_prefs.dart';
import '../../auth/screens/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final AppPrefs prefs;
  final AppSettings initialSettings;
  final ValueChanged<AppSettings> onCompleted;

  const OnboardingScreen({
    super.key,
    required this.prefs,
    required this.initialSettings,
    required this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  late AppSettings _draft;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialSettings;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishAsGuest() async {
    await widget.prefs.saveSettings(_draft);
    await widget.prefs.ensureGuestId();
    await widget.prefs.setOnboardingComplete(true);
    widget.onCompleted(_draft);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _step == 3;
    final primary = const Color(0xFF218B56);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finishAsGuest,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) => setState(() => _step = index),
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/picture/logo1.jpeg',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'Simplify Your Islamic Life',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1a1a2e),
                                ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Prayer times, Qur\'an, Dhikr, and more - all in one calm space.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF2d2d44),
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const _OnboardingSlide(
                      icon: Icons.checklist_rounded,
                      iconBg: Color(0xFFF5EFE0),
                      title: 'Build Better Habits',
                      subtitle:
                          'Stay on track with daily checklists and gentle reminders for your Deen routine.',
                    ),
                    const _OnboardingSlide(
                      icon: Icons.self_improvement_rounded,
                      iconBg: Color(0xFFE9E9E9),
                      title: 'Find Peace & Calm',
                      subtitle:
                          'A calm, ad-free experience that respects your spiritual journey.',
                    ),
                    _LanguageSlide(
                      selected: _draft.language,
                      onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(language: value)),
                    ),
                  ],
                ),
              ),
              _Dots(index: _step),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    if (isLast) {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => AuthScreen(initialSettings: _draft),
                        ),
                      );
                      if (result == true && mounted) {
                        await widget.prefs.saveSettings(_draft);
                        await widget.prefs.setOnboardingComplete(true);
                        widget.onCompleted(_draft);
                      }
                      return;
                    }
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Text(isLast ? 'Get Started' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _OnboardingSlide({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 142,
          height: 142,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 52, color: const Color(0xFF1C7E53)),
        ),
        const SizedBox(height: 40),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1a1a2e),
              ),
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF2d2d44),
                height: 1.45,
              ),
        ),
      ],
    );
  }
}

class _LanguageSlide extends StatelessWidget {
  final AppLanguage selected;
  final ValueChanged<AppLanguage> onChanged;

  const _LanguageSlide({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            color: Color(0xFFE2ECE6),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.public, size: 48, color: Color(0xFF1C7E53)),
        ),
        const SizedBox(height: 26),
        Text(
          'Choose Language',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'ভাষা নির্বাচন করুন',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        _LanguageOption(
          title: 'English',
          subtitle: 'Continue in English',
          selected: selected == AppLanguage.en,
          onTap: () => onChanged(AppLanguage.en),
        ),
        const SizedBox(height: 14),
        _LanguageOption(
          title: 'বাংলা',
          subtitle: 'বাংলায় চালিয়ে যান',
          selected: selected == AppLanguage.bn,
          onTap: () => onChanged(AppLanguage.bn),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDCE5DF) : const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  selected ? const Color(0xFF1C7E53) : const Color(0xFFE3E1DD),
              width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: const Color(0xFF3a3a4a))),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color:
                  selected ? const Color(0xFF1C7E53) : const Color(0xFFCBC8C2),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int index;
  const _Dots({required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: i == index ? 34 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color:
                i == index ? const Color(0xFF1C8A57) : const Color(0xFFE0DDD6),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
