import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../config/constants/end_points.dart';
import '../../domain/models/character/character.dart';
import '../../domain/models/character_response/character_response.dart';

part 'rick_and_morty_api.g.dart';

@RestApi()
abstract class RickAndMortyApi {
  factory RickAndMortyApi(Dio dio, {String baseUrl}) = _RickAndMortyApi;

  @GET(EndPoints.character)
  Future<CharacterResponse> character(@Query("page") int page);

  @GET(EndPoints.characterByIds)
  Future<List<Character>> characterByIds(@Path("ids") String ids);
}
