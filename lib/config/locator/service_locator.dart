import 'package:get_it/get_it.dart';
import 'package:rick_and_morty/data/data.dart';
import 'package:rick_and_morty/config/config.dart';
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
