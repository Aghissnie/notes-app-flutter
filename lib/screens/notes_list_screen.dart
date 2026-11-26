import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_list_cubit.dart';
import '../models/note_model.dart';
import 'note_form_screen.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  void _navigateToForm(BuildContext context, {Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormScreen(existingNote: note),
      ),
    );

    if (result == true && context.mounted) {
      context.read<NotesListCubit>().loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<NotesListCubit, NotesListState>(
        builder: (context, state) {
          if (state is NotesListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesListError) {
            return Center(child: Text(state.message));
          } else if (state is NotesListLoaded) {
            if (state.notes.isEmpty) {
              return const Center(
                child: Text('Belum ada catatan.\nTekan + untuk menambah.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _navigateToForm(context, note: note),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context.read<NotesListCubit>().deleteNote(note.id);
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
