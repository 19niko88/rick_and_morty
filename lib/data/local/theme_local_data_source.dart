import 'package:hive_flutter/hive_flutter.dart';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/domain/domain.dart';

@lazySingleton
class ThemeLocalDataSource {
  static const String themeBoxName = 'theme_settings';
  static const String themeKey = 'theme_mode';

  Future<void> saveThemeMode(AppThemeModeEnum mode) async {
    final box = await Hive.openBox(themeBoxName);
    await box.put(themeKey, mode.name);
  }

  Future<AppThemeModeEnum> getThemeMode() async {
    final box = await Hive.openBox(themeBoxName);
    final String? modeName = box.get(themeKey);
    if (modeName == null) return AppThemeModeEnum.system;
    
    return AppThemeModeEnum.values.firstWhere(
      (e) => e.name == modeName,
      orElse: () => AppThemeModeEnum.system,
    );
  }
}
