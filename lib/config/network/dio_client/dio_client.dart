import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../constants/constants.dart';
import '../interceptors/interceptors.dart';

@module
abstract class DioClient {
  @lazySingleton
  Dio dio() => Dio(BaseOptions(

    baseUrl: APIBase.url,
    headers: {"Content-Type": "application/json"},
  ))
    ..interceptors.addAll([ApiLoggingInterceptor()]);


}