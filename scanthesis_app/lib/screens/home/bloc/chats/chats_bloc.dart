import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:scanthesis_app/models/chat.dart';
import 'package:scanthesis_app/screens/settings/provider/settings_provider.dart';
import 'package:scanthesis_app/utils/helper_util.dart';

part 'chats_event.dart';

part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final SettingsProvider settingsProvider;

  ChatsBloc({required this.settingsProvider}) : super(ChatsInitial()) {
    on<AddChatEvent>(_addChat);
    on<RemoveMultipleChatEvent>(_removeMultipleChat);
    on<LoadChatHistoryEvent>(_loadChatHistory);
    on<ClearSelectedChatsEvent>(_clearSelectedChats);
    on<SelectChatEvent>(_selectChat);
    on<UnselectChatEvent>(_unselectChat);
    on<SelectAllChatEvent>(_selectAllChat);
  }

   _addChat(AddChatEvent event, Emitter<ChatsState> emit) async {
    emit(ChatsLoading());
    Chat chat = event.chat;

    // check if chat history is enabled
    if (settingsProvider.getIsUseChatHistory) {
      final String targetDirectory =
          settingsProvider.getDefaultImageDirectory.path;
      List<File> movedFiles = await HelperUtil.moveFileToDirectory(
        files: chat.request.files,
        targetDirectoryPath: targetDirectory,
      );

      chat = chat.copyWith(request: chat.request.copyWith(files: movedFiles));
    }

    state.chats.add(chat);
    emit(ChatsLoaded(chats: state.chats, selectedChats: []));
  }

   _removeMultipleChat(RemoveMultipleChatEvent event, Emitter<ChatsState> emit) async {
    final remainingChats = <Chat>[];

    for (var chat in state.chats) {
      if (event.chats.contains(chat)) {
        await HelperUtil.deleteFiles(chat.request.files);
      } else {
        remainingChats.add(chat);
      }
    }

    if (remainingChats.isEmpty) {
      emit(ChatsInitial());
    } else {
      emit(ChatsLoaded(chats: remainingChats, selectedChats: []));
    }
  }

  _loadChatHistory(LoadChatHistoryEvent event, Emitter<ChatsState> emit) {
    state.chats.addAll(event.chats);
    emit(ChatsLoaded(chats: state.chats, selectedChats: []));
  }

  _clearSelectedChats(ClearSelectedChatsEvent event, Emitter<ChatsState> emit) {
    state.selectedChats.clear();
    emit(ChatsLoaded(chats: state.chats, selectedChats: state.selectedChats));
  }

  _selectChat(SelectChatEvent event, Emitter<ChatsState> emit) {
    if (!state.selectedChats.contains(event.chat)) {
      state.selectedChats.add(event.chat);
      emit(ChatsLoaded(chats: state.chats, selectedChats: state.selectedChats));
    }
  }

  _unselectChat(UnselectChatEvent event, Emitter<ChatsState> emit) {
    if (state.selectedChats.contains(event.chat)) {
      state.selectedChats.remove(event.chat);
      emit(ChatsLoaded(chats: state.chats, selectedChats: state.selectedChats));
    }
  }

  _selectAllChat(SelectAllChatEvent event, Emitter<ChatsState> emit) {
    state.selectedChats.clear();
    state.selectedChats.addAll(state.chats);
    emit(ChatsLoaded(chats: state.chats, selectedChats: state.selectedChats));
  }
}
