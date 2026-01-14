import 'dart:async';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/utils/utils.dart';

part 'connectivity_status_event.dart';
part 'connectivity_status_state.dart';
part 'connectivity_status_bloc.freezed.dart';

@lazySingleton
class ConnectivityStatusBloc extends Bloc<ConnectivityStatusEvent, ConnectivityStatusState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _periodicCheckTimer;

  ConnectivityStatusBloc() : super(const ConnectivityStatusState()) {
    on<_Started>(_onStarted);
    on<_Changed>(_onChanged);
  }

  Future<void> _onStarted(_Started event, Emitter<ConnectivityStatusState> emit) async {
    final results = await _connectivity.checkConnectivity();
    add(ConnectivityStatusEvent.changed(results));

    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        add(ConnectivityStatusEvent.changed(results));
      },
      onError: (error) {
      },
    );

    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final results = await _connectivity.checkConnectivity();
        add(ConnectivityStatusEvent.changed(results));
      } catch (e) {
      }
    });
  }

  void _onChanged(_Changed event, Emitter<ConnectivityStatusState> emit) {
    final isConnected = event.results.any((result) => result != ConnectivityResult.none);
    if (state.isConnected != isConnected) {
      emit(state.copyWith(isConnected: isConnected));
    } else {
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _periodicCheckTimer?.cancel();
    return super.close();
  }
}
