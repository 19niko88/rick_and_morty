import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/character/character.dart';

class CharacterLocalDataSource {
  static const String charactersBoxName = 'characters_cache';
  static const String favoritesBoxName = 'favorites';

  Future<void> cacheCharacters(List<Character> characters) async {
    final box = await Hive.openBox(charactersBoxName);
    for (final character in characters) {
      await box.put(character.id, character.toJson());
    }
  }

  Future<List<Character>> getCachedCharacters() async {
    final box = await Hive.openBox(charactersBoxName);
    final List<Character> characters = [];
    for (final key in box.keys) {
      final dynamic value = box.get(key);
      if (value is Map) {
        final json = value.cast<String, dynamic>();
        characters.add(Character.fromJson(json));
      }
    }
    return characters;
  }

  Future<void> toggleFavorite(int characterId) async {
    final box = await Hive.openBox<bool>(favoritesBoxName);
    final isFavorite = box.get(characterId) ?? false;
    await box.put(characterId, !isFavorite);
  }

  Future<List<int>> getFavoriteIds() async {
    final box = await Hive.openBox<bool>(favoritesBoxName);
    final List<int> favoriteIds = [];
    for (final key in box.keys) {
      if (box.get(key) == true) {
        favoriteIds.add(key as int);
      }
    }
    return favoriteIds;
  }

  Future<bool> isFavorite(int characterId) async {
    final box = await Hive.openBox<bool>(favoritesBoxName);
    return box.get(characterId) ?? false;
  }
}
