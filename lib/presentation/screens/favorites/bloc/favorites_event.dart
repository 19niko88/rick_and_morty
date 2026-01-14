part of 'favorites_bloc.dart';

@freezed
abstract class FavoritesEvent with _$FavoritesEvent {
  const factory FavoritesEvent.fetch() = _Fetch;
  const factory FavoritesEvent.changeSort(FavoriteSortEnum sortBy) = _ChangeSort;
  const factory FavoritesEvent.removeFromFavorites(int characterId) = _RemoveFromFavorites;
}
