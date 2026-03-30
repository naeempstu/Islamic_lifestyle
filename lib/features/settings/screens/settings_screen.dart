import 'package:flutter/material.dart';

import '../../../core/models/app_enums.dart';
import '../../../core/models/app_settings.dart';

class SettingsScreen extends StatelessWidget {
  final AppLanguage language;
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.language,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lang = settings.language;
    return Scaffold(
      appBar: AppBar(
        title: Text(lang == AppLanguage.bn ? 'সেটিংস' : 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(lang == AppLanguage.bn ? 'ডার্ক মোড' : 'Dark mode'),
              trailing: Switch(
                value: settings.darkMode,
                onChanged: (v) => onSettingsChanged(settings.copyWith(darkMode: v)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text(lang == AppLanguage.bn ? 'ভাষা' : 'Language'),
              subtitle: Text(lang == AppLanguage.bn ? 'বাংলা / English' : 'Bangla / English'),
              trailing: DropdownButton<AppLanguage>(
                value: settings.language,
                items: const [
                  DropdownMenuItem(value: AppLanguage.en, child: Text('English')),
                  DropdownMenuItem(value: AppLanguage.bn, child: Text('বাংলা')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  onSettingsChanged(settings.copyWith(language: v));
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(lang == AppLanguage.bn ? 'নামাজের হিসাব' : 'Prayer calculation'),
                  subtitle: Text(lang == AppLanguage.bn
                      ? 'পরে পরিবর্তন করা যাবে।'
                      : 'You can adjust later.'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: DropdownButton<PrayerCalculationMethod>(
                    isExpanded: true,
                    value: settings.prayerCalculationMethod,
                    items: PrayerCalculationMethod.values
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.labelEn()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      onSettingsChanged(settings.copyWith(prayerCalculationMethod: v));
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: Text(lang == AppLanguage.bn ? 'অ্যাপ নোটিফিকেশন' : 'Notifications'),
              subtitle: Text(lang == AppLanguage.bn ? 'শান্তভাবে মনে করিয়ে দেয়' : 'Gentle reminders only'),
              value: settings.notificationsEnabled,
              onChanged: (v) => onSettingsChanged(settings.copyWith(notificationsEnabled: v)),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: Text(lang == AppLanguage.bn ? 'ভাইব্রেশন ফিডব্যাক' : 'Vibration feedback'),
              subtitle: Text(lang == AppLanguage.bn ? 'যিকির কাউন্টে' : 'For tasbih counter'),
              value: settings.vibrationEnabled,
              onChanged: (v) => onSettingsChanged(settings.copyWith(vibrationEnabled: v)),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == AppLanguage.bn ? 'আযান চালু রাখুন' : 'Enable azan per prayer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final prayer in PrayerName.values)
                    CheckboxListTile(
                      title: Text(lang == AppLanguage.bn ? prayer.labelBn() : prayer.labelEn()),
                      value: settings.azanEnabled[prayer] ?? true,
                      onChanged: settings.notificationsEnabled
                          ? (v) {
                              final next = Map<PrayerName, bool>.from(settings.azanEnabled);
                              next[prayer] = v ?? true;
                              onSettingsChanged(settings.copyWith(azanEnabled: next));
                            }
                          : null,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text(lang == AppLanguage.bn ? 'ডাটা ব্যাকআপ (পরবর্তীতে)' : 'Data backup (later)'),
              subtitle: Text(lang == AppLanguage.bn
                  ? 'Firebase / গেস্ট ডিভাইস ব্যাকআপ আকারে যোগ করা হবে।'
                  : 'Add Firebase & guest restore flows later.'),
              trailing: const Icon(Icons.backup),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang == AppLanguage.bn
                        ? 'এটি ডেভেলপমেন্ট প্লেসহোল্ডার।'
                        : 'This is a development placeholder.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

