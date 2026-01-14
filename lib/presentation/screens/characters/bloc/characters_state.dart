part of 'characters_bloc.dart';

@freezed
class CharactersState with _$CharactersState {
  const factory CharactersState.initial() = _Initial;
  const factory CharactersState.loading() = _Loading;
  const factory CharactersState.loaded({
    required List<Character> characters,
    @Default(false) bool hasReachedMax,
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
  }) = _Loaded;
  const factory CharactersState.error({required String message}) = _Error;
}
