import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:scanthesis/models/api_request.dart';

part 'request_event.dart';
part 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  RequestBloc() : super(RequestInitial()) {
    on<AddRequestEvent>(_addRequest);
    on<ClearRequestEvent>(_clearRequest);
  }

  _addRequest(AddRequestEvent event, Emitter<RequestState> emit) {
    emit(RequestSuccess(request: event.request));
  }

  _clearRequest(ClearRequestEvent event, Emitter<RequestState> emit){
    emit(RequestInitial());
  }
}
