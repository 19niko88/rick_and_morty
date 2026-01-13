import 'package:freezed_annotation/freezed_annotation.dart';
import '../info/info.dart';
import '../character/character.dart';

part 'character_response.freezed.dart';
part 'character_response.g.dart';

@freezed
abstract class CharacterResponse with _$CharacterResponse {
  const factory CharacterResponse({
    required Info info,
    required List<Character> results,
  }) = _CharacterResponse;

  factory CharacterResponse.fromJson(Map<String, dynamic> json) => _$CharacterResponseFromJson(json);
}
