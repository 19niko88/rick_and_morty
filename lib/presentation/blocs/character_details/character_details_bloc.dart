import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/models/character/character.dart';
import '../../../domain/repository/character_repository.dart';

part 'character_details_event.dart';
part 'character_details_state.dart';
part 'character_details_bloc.freezed.dart';

@injectable
class CharacterDetailsBloc extends Bloc<CharacterDetailsEvent, CharacterDetailsState> {
  final CharacterRepository _repository;

  CharacterDetailsBloc(this._repository) : super(const CharacterDetailsState.initial()) {
    on<CharacterDetailsEvent>((event, emit) async {
      await event.when(
        fetch: (id) => _onFetch(id, emit),
      );
    });
  }

  Future<void> _onFetch(int id, Emitter<CharacterDetailsState> emit) async {
    emit(const CharacterDetailsState.loading());
    try {
      final character = await _repository.getCharacterById(id);
      emit(CharacterDetailsState.loaded(character));
    } catch (e) {
      emit(CharacterDetailsState.error(e.toString()));
    }
  }
}
