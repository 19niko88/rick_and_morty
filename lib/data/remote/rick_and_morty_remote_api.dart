import 'package:retrofit/retrofit.dart';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/domain/domain.dart';

part 'rick_and_morty_remote_api.g.dart';

@RestApi()
abstract class RickAndMortyRemoteApi {
  factory RickAndMortyRemoteApi(Dio dio) = _RickAndMortyRemoteApi;

  @GET(EndPoints.character)
  Future<CharacterResponse> character(
    @Query("page") int page, {
    @Query("name") String? name,
    @Query("status") String? status,
    @Query("species") String? species,
    @Query("type") String? type,
    @Query("gender") String? gender,
  });

  @GET(EndPoints.characterById)
  Future<Character> characterById(@Path("id") int id);

  @GET(EndPoints.characterByIds)
  Future<List<Character>> characterByIds(@Path("ids") String ids);
}
