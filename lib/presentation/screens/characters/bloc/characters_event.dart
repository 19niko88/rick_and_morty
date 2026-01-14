part of 'characters_bloc.dart';

@freezed
class CharactersEvent with _$CharactersEvent {
  const factory CharactersEvent.fetch() = _Fetch;
  const factory CharactersEvent.refresh() = _Refresh;
  const factory CharactersEvent.toggleFavorite(int characterId) = _ToggleFavorite;
  const factory CharactersEvent.updateFavoriteStatus(int characterId, bool isFavorite) = _UpdateFavoriteStatus;
  const factory CharactersEvent.updateFilters({
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
  }) = _UpdateFilters;
  const factory CharactersEvent.clearFilters() = _ClearFilters;
}
