import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia_tdd/core/util/input_convertor.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/entities/number_trivia.dart';

part 'number_trivia_event.dart';

part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = "Server Failure";
const String CACHE_FAILURE_MESSAGE = "Cache Failure";
const String INVALID_INPUT_FAILURE_MESSAGE =
    "Invalid input - The number must be a positive integer or zero";

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetTriviaForConcreteNumber getTriviaForConcreteNumber;
  final GetTriviaForRandomNumber getTriviaForRandomNumber;
  final InputConvertor inputConvertor;

  NumberTriviaBloc(
      {required GetTriviaForConcreteNumber concrete,
      required GetTriviaForRandomNumber random,
      required this.inputConvertor})
      : getTriviaForConcreteNumber = concrete,
        getTriviaForRandomNumber = random,
        super(Empty()) {
    on<NumberTriviaEvent>((event, emit) {
      if (event is GetTriviaForConcreteNumber) {
       final inputEither = inputConvertor.stringToUnsignedInteger(event.numberString);

      inputEither.fold((failure)  {
         emit(const Error(message: INVALID_INPUT_FAILURE_MESSAGE));
       }, (integer) async*{
        throw UnimplementedError();
       });
      }
    });
  }
}

