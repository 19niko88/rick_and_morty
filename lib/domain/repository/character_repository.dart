
import '../models/character/character.dart';

abstract class CharacterRepository {
  Future<List<Character>> getCharacters(int page);
  Future<List<Character>> getFavorites();
  Future<void> toggleFavorite(int characterId);
  Future<bool> isFavorite(int characterId);
}
