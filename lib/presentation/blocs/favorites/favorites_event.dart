part of 'favorites_bloc.dart';

@freezed
class FavoritesEvent with _$FavoritesEvent {
  const factory FavoritesEvent.fetch() = _Fetch;
  const factory FavoritesEvent.removeFromFavorites(int characterId) = _RemoveFromFavorites;
}
