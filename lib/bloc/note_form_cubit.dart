import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/note_model.dart';
import '../repositories/notes_repository.dart';

abstract class NoteFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NoteFormInitial extends NoteFormState {}
class NoteFormSubmitting extends NoteFormState {}
class NoteFormSuccess extends NoteFormState {}

class NoteFormFailure extends NoteFormState {
  final String error;
  NoteFormFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class NoteFormCubit extends Cubit<NoteFormState> {
  final NotesRepository repository;

  NoteFormCubit(this.repository) : super(NoteFormInitial());

  Future<void> saveNote({
    String? existingId,
    required String title,
    required String content,
  }) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      emit(NoteFormFailure('Judul dan isi catatan tidak boleh kosong!'));
      return;
    }

    emit(NoteFormSubmitting());
    try {
      final note = Note(
        id: existingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
        content: content.trim(),
        createdAt: DateTime.now(),
      );
      await repository.saveNote(note);
      emit(NoteFormSuccess());
    } catch (e) {
      emit(NoteFormFailure('Gagal menyimpan catatan: $e'));
    }
  }
}
