import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:scanthesis_app/models/api_request.dart';
import 'package:scanthesis_app/models/api_response.dart';
import 'package:scanthesis_app/repository/api_repository.dart';

part 'response_event.dart';

part 'response_state.dart';

class ResponseBloc extends Bloc<ResponseEvent, ResponseState> {
  ResponseBloc() : super(ResponseInitial()) {
    on<AddResponseEvent>(_addResponse);
    on<ClearResponseEvent>(_clearResponse);
    on<AddResponseSuccessEvent>(_addResponseSuccess);
  }

  _addResponse(AddResponseEvent event, Emitter<ResponseState> emit) async {
    try {
      emit(ResponseLoading());
      final ApiResponse response = await ApiRepository().sendRequest(
        event.request,
      );

      emit(ResponseSuccess(response: response));
    } catch (error) {
      emit(ResponseError(errorMessage: error.toString(), response: ApiResponse()));
    }
  }

  _clearResponse(ClearResponseEvent event, Emitter<ResponseState> emit) {
    emit(ResponseInitial());
  }

  _addResponseSuccess(AddResponseSuccessEvent event, Emitter<ResponseState> emit){
    event.response.setFromHistory(true);
    emit(ResponseSuccess(response: event.response));
  }
}
