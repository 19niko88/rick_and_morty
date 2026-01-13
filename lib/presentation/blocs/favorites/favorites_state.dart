part of 'favorites_bloc.dart';

@freezed
class FavoritesState with _$FavoritesState {
  const factory FavoritesState.initial() = _Initial;
  const factory FavoritesState.loading() = _Loading;
  const factory FavoritesState.loaded({required List<Character> characters}) = _Loaded;
  const factory FavoritesState.error({required String message}) = _Error;
}
