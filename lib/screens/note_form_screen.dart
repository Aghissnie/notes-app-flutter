import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/note_form_cubit.dart';
import '../models/note_model.dart';
import '../repositories/notes_repository.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? existingNote;

  const NoteFormScreen({super.key, this.existingNote});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController = TextEditingController(text: widget.existingNote?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingNote != null;

    return BlocProvider(
      create: (context) => NoteFormCubit(context.read<NotesRepository>()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Catatan' : 'Catatan Baru'),
        ),
        body: BlocConsumer<NoteFormCubit, NoteFormState>(
          listener: (context, state) {
            if (state is NoteFormSuccess) {
              Navigator.pop(context, true);
            } else if (state is NoteFormFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Catatan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        labelText: 'Isi Catatan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state is NoteFormSubmitting
                          ? null
                          : () {
                              context.read<NoteFormCubit>().saveNote(
                                    existingId: widget.existingNote?.id,
                                    title: _titleController.text,
                                    content: _contentController.text,
                                  );
                            },
                      child: state is NoteFormSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('Simpan Catatan'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
