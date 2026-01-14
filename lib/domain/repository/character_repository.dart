import 'package:rick_and_morty/domain/domain.dart';

abstract class CharacterRepository {
  Future<Character> getCharacterById(int id);
  Future<(List<Character>, bool)> getCharacters(
    int page, {
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
  });
  Future<List<Character>> getFavorites();
  Future<void> toggleFavorite(int characterId);
  Future<bool> isFavorite(int characterId);
  Stream<int> get watchFavorites;
}
