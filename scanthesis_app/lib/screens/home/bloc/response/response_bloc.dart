import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:scanthesis_app/models/api_request.dart';
import 'package:scanthesis_app/models/api_response.dart';
import 'package:scanthesis_app/repository/api_repository.dart';
import 'package:scanthesis_app/screens/settings/provider/settings_provider.dart';

part 'response_event.dart';

part 'response_state.dart';

class ResponseBloc extends Bloc<ResponseEvent, ResponseState> {
  final SettingsProvider settingsProvider;

  ResponseBloc({required this.settingsProvider}) : super(ResponseInitial()) {
    on<AddResponseEvent>(_addResponse);
    on<ClearResponseEvent>(_clearResponse);
    on<AddResponseSuccessEvent>(_addResponseSuccess);
  }

  _addResponse(AddResponseEvent event, Emitter<ResponseState> emit) async {
    emit(ResponseLoading());
    final ApiResponse response = await ApiRepository(
      baseUrl: settingsProvider.getBaseUrlEndpoint,
    ).sendRequest(event.request);

    if (response.isError) {
      emit(
        ResponseError(errorMessage: response.errorMessage!, response: response),
      );
    } else {
      emit(ResponseSuccess(response: response));
    }
  }

  _clearResponse(ClearResponseEvent event, Emitter<ResponseState> emit) {
    emit(ResponseInitial());
  }

  _addResponseSuccess(
    AddResponseSuccessEvent event,
    Emitter<ResponseState> emit,
  ) {
    emit(
      ResponseSuccess(response: event.response.copyWith(isFromHistory: true)),
    );
  }
}
