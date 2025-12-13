import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  List<Achievement> _achievements = [
    Achievement(
      id: 'first_khatma',
      title: 'البداية المباركة',
      description: 'أتممت ختمة واحدة للقرآن الكريم',
      icon: '🌟',
    ),
    Achievement(
      id: 'quran_lover',
      title: 'محب القرآن',
      description: 'قرأت القرآن لمدة 7 أيام متتالية',
      icon: '❤️',
    ),
    Achievement(
      id: 'hafiz_junior',
      title: 'الحافظ الصغير',
      description: 'أتممت حفظ جزء عم',
      icon: '🎓',
    ),
    Achievement(
      id: 'night_owl',
      title: 'قيام الليل',
      description: 'قرأت القرآن بعد منتصف الليل',
      icon: '🌙',
    ),
    Achievement(
      id: 'share_khair',
      title: 'الدال على الخير',
      description: 'شاركت آية مع أصدقائك',
      icon: '📤',
    ),
  ];

  List<Achievement> get achievements => _achievements;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    List<Achievement> loaded = [];
    for (var a in _achievements) {
      bool unlocked = prefs.getBool('ach_unlocked_${a.id}') ?? false;
      loaded.add(
        Achievement(
          id: a.id,
          title: a.title,
          description: a.description,
          icon: a.icon,
          isUnlocked: unlocked,
        ),
      );
    }
    _achievements = loaded;
  }

  Future<void> unlockAchievement(String id) async {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index != -1 && !_achievements[index].isUnlocked) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ach_unlocked_$id', true);

      _achievements[index] = Achievement(
        id: _achievements[index].id,
        title: _achievements[index].title,
        description: _achievements[index].description,
        icon: _achievements[index].icon,
        isUnlocked: true,
      );
    }
  }
}
