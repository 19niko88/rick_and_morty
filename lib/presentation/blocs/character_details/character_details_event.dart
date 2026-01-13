part of 'character_details_bloc.dart';

@freezed
abstract class CharacterDetailsEvent with _$CharacterDetailsEvent {
  const factory CharacterDetailsEvent.fetch(int id) = _Fetch;
}
