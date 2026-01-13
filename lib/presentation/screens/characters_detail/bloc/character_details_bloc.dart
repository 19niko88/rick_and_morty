import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/domain/domain.dart';

part 'character_details_event.dart';
part 'character_details_state.dart';
part 'character_details_bloc.freezed.dart';

@injectable
class CharacterDetailsBloc extends Bloc<CharacterDetailsEvent, CharacterDetailsState> {

  CharacterDetailsBloc() : super(const CharacterDetailsState.initial()) {
    on<CharacterDetailsEvent>((event, emit) async {
      await event.when(
        fetch: (id) => _onFetch(id, emit),
      );
    });
  }

  Future<void> _onFetch(int id, Emitter<CharacterDetailsState> emit) async {
    emit(const CharacterDetailsState.loading());
    try {
      final character = await getIt<CharacterRepository>().getCharacterById(id);
      emit(CharacterDetailsState.loaded(character));
    } catch (e) {
      emit(CharacterDetailsState.error(e.toString()));
    }
  }
}