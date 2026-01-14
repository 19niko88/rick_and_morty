part of 'connectivity_status_bloc.dart';

@freezed
abstract class ConnectivityStatusState with _$ConnectivityStatusState {
  const factory ConnectivityStatusState({
    @Default(true) bool isConnected,
  }) = _ConnectivityStatusState;
}
