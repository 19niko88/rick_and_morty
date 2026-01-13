import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../data/remote/rick_and_morty_remote_api.dart';
import '../../data/local/character_local_data_source.dart';
import '../router/app_router.dart';
import 'service_locator.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> initializeGetIt() async => getIt.init();

@module
abstract class RegisterModule {
  @singleton
  AppRouter get appRouter => AppRouter();

  @lazySingleton
  RickAndMortyRemoteApi getRickAndMortyApi(Dio dio) => RickAndMortyRemoteApi(dio);

  @lazySingleton
  CharacterLocalDataSource get characterLocalDataSource => CharacterLocalDataSource();
}
