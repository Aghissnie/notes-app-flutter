import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/note_model.dart';
import '../repositories/notes_repository.dart';

abstract class NotesListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesListInitial extends NotesListState {}
class NotesListLoading extends NotesListState {}

class NotesListLoaded extends NotesListState {
  final List<Note> notes;
  NotesListLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

class NotesListError extends NotesListState {
  final String message;
  NotesListError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotesListCubit extends Cubit<NotesListState> {
  final NotesRepository repository;

  NotesListCubit(this.repository) : super(NotesListInitial());

  Future<void> loadNotes() async {
    emit(NotesListLoading());
    try {
      final notes = await repository.getNotes();
      emit(NotesListLoaded(notes));
    } catch (e) {
      emit(NotesListError('Gagal memuat catatan: $e'));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await repository.deleteNote(id);
      await loadNotes();
    } catch (e) {
      emit(NotesListError('Gagal menghapus catatan: $e'));
    }
  }
}
