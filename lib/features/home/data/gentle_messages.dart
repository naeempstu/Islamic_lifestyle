import '../../../core/models/app_enums.dart';

class GentleMessages {
  static String dailyFor(AppLanguage language, {required DateTime date}) {
    const english = [
      'A moment of Dhikr brings peace 🤍',
      'Today is a clean start. Be gentle with yourself.',
      'Small steps in Salah are still steps toward Allah.',
      'Consistency is a form of hope.',
    ];
    const bangla = [
      'একটু যিকিরই শান্তি 🤍',
      'আজ নতুন করে শুরু। নিজের সাথে দয়া করুন।',
      'নামাজের ছোট ছোট প্রচেষ্টাও আল্লাহর দিকে পথ।',
      'ধারাবাহিকতা মানে আশা।',
    ];

    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final list = language == AppLanguage.bn ? bangla : english;
    return list[dayOfYear % list.length];
  }
}

