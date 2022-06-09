import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  NotesDatabase? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  Future createOrGetExistingNote(BuildContext context) async {

    final widgetNote = context.getArgument<NotesDatabase>();
    if(widgetNote != null){
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote; 
    }

    devtools.log(widgetNote.toString());

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getOrCreateUser(email: email);
    final newNote =  await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;    

  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(noteId: note.noteId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final newText = _textController.text;
    if (_textController.text != "  " &&_textController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        note: note,
        newText: newText,
      );
    }
  }

  // As we type in textfield it will update in database
  void _textControllerListner() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final newText = _textController.text;
    await _notesService.updateNote(
      note: note,
      newText: newText,
    );
  }

  void _setupTextControllerListner() async {
    _textController.removeListener(_textControllerListner);
    _textController.addListener(_textControllerListner);
  }


  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note"),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.done: 
              _setupTextControllerListner();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(hintText: "Start Typing Here"),
                );
            default:
              return const Center(child: CircularProgressIndicator(),);

          }

      },),
    );
  }
}
