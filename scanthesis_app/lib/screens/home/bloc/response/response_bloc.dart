import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'response_event.dart';
part 'response_state.dart';

class ResponseBloc extends Bloc<ResponseEvent, ResponseState> {
  ResponseBloc() : super(ResponseInitial()) {
    on<ResponseEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

