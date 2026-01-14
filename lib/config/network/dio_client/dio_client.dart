import 'package:rick_and_morty/config/config.dart';

@module
abstract class DioClient {
  @lazySingleton
  Dio dio() => Dio(BaseOptions(
    baseUrl: APIBase.url,
    headers: {"Content-Type": "application/json"},
  ))
    ..interceptors.addAll([ApiLoggingInterceptor()]);
}