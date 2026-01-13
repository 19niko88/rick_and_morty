part of 'characters_bloc.dart';

@freezed
class CharactersEvent with _$CharactersEvent {
  const factory CharactersEvent.fetch() = _Fetch;
  const factory CharactersEvent.refresh() = _Refresh;
  const factory CharactersEvent.toggleFavorite(int characterId) = _ToggleFavorite;
}
