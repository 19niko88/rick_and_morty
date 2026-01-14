part of 'connectivity_status_bloc.dart';

@freezed
class ConnectivityStatusEvent with _$ConnectivityStatusEvent {
  const factory ConnectivityStatusEvent.started() = _Started;
  const factory ConnectivityStatusEvent.changed(List<ConnectivityResult> results) = _Changed;
}
