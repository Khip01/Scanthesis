import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:scanthesis_app/models/chat.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc() : super(ChatsInitial()) {
    on<AddChatEvent>(_addChat);
    on<RemoveMultipleChatEvent>(_removeMultipleChat);
    on<LoadChatHistoryEvent>(_loadChatHistory);
    on<ClearSelectedChatsEvent>(_clearSelectedChats);
    on<SelectChatEvent>(_selectChat);
    on<UnselectChatEvent>(_unselectChat);
    on<SelectAllChatEvent>(_selectAllChat);
  }

  _addChat(AddChatEvent event, Emitter<ChatsState> emit) {
    state.chats.add(event.chat);
    emit(ChatsLoaded(chats: state.chats, selectedChats: []));
  }

  _removeMultipleChat(RemoveMultipleChatEvent event, Emitter<ChatsState> emit) {
    state.chats.removeWhere((chat) => event.chats.contains(chat));
    if (state.chats.isEmpty) {
      emit(ChatsInitial());
    } else {
      emit(ChatsLoaded(chats: state.chats, selectedChats: []));
    }
  }

  _loadChatHistory(LoadChatHistoryEvent event, Emitter<ChatsState> emit) {
    state.chats.addAll(event.chats);
    emit(ChatsLoaded(chats: state.chats, selectedChats: []));
  }

  _clearSelectedChats(ClearSelectedChatsEvent event, Emitter<ChatsState> emit){
    state.selectedChats.clear();
    emit(ChatsLoaded(chats: state.chats, selectedChats: state.selectedChats));
  }

  _selectChat(SelectChatEvent event, Emitter<ChatsState> emit){
    if (!state.selectedChats.contains(event.chat)){
      state.selectedChats.add(event.chat);
      emit(ChatsLoaded(chats: state.chats, selectedChats: state.selectedChats));
    }
  }

  _unselectChat(UnselectChatEvent event, Emitter<ChatsState> emit){
    if (state.selectedChats.contains(event.chat)){
      state.selectedChats.remove(event.chat);
      emit(ChatsLoaded(chats: state.chats, selectedChats: state.selectedChats));
    }
  }

  _selectAllChat(SelectAllChatEvent event, Emitter<ChatsState> emit){
    state.selectedChats.clear();
    state.selectedChats.addAll(state.chats);
    emit(ChatsLoaded(chats: state.chats, selectedChats: state.selectedChats));
  }
}
