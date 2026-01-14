import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/domain/domain.dart';
import 'package:rick_and_morty/data/data.dart';

part 'theme_event.dart';
part 'theme_state.dart';
part 'theme_bloc.freezed.dart';

@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeLocalDataSource _localDataSource;

  ThemeBloc(this._localDataSource) : super(const ThemeState()) {
    on<_Started>(_onStarted);
    on<_Changed>(_onChanged);
  }

  Future<void> _onStarted(_Started event, Emitter<ThemeState> emit) async {
    final mode = await _localDataSource.getThemeMode();
    emit(state.copyWith(mode: mode));
  }

  Future<void> _onChanged(_Changed event, Emitter<ThemeState> emit) async {
    await _localDataSource.saveThemeMode(event.mode);
    emit(state.copyWith(mode: event.mode));
  }
}
