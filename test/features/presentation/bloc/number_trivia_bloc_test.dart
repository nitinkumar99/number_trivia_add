

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_tdd/core/util/input_convertor.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetTriviaForConcreteNumber extends Mock implements GetTriviaForConcreteNumber{}

class MockGetTriviaForRandomNumber extends Mock implements GetTriviaForRandomNumber{}

class MockInputConvertor extends Mock implements InputConvertor{}

void main(){

  late MockGetTriviaForConcreteNumber mockConcrete;
  late MockGetTriviaForRandomNumber mockRandom;
  late MockInputConvertor mockInputConvertor;
  late NumberTriviaBloc numberTriviaBloc;

  setUp(() {
    mockConcrete = MockGetTriviaForConcreteNumber();
    mockRandom = MockGetTriviaForRandomNumber();
    mockInputConvertor = MockInputConvertor();
    numberTriviaBloc = NumberTriviaBloc(concrete: mockConcrete, random: mockRandom, inputConvertor: mockInputConvertor);
  });

  test(
        'initialState should be empty',
        () async {
          // assert
          expect(numberTriviaBloc.state, equals(Empty()));
        },
      );

  group('GetTriviaForConcreteNumber', () {

    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: 'test', number: 1);

    test(
          'should call InputConvertor to validate and convert string to unsigned integer',
          () async {
            // arrange
            when(() => mockInputConvertor.stringToUnsignedInteger(tNumberString)).thenAnswer((_) => const Right(1));
            // act
            numberTriviaBloc.add(const GetTriviaForConcreteNumber(tNumberString));
            await untilCalled(() => mockInputConvertor.stringToUnsignedInteger(tNumberString));
            // assert
            verify(() => mockInputConvertor.stringToUnsignedInteger(tNumberString));
          },
        );

    test(
          'should emit [Error] when input is invalid',
          () async {
            // arrange
            when(() => mockInputConvertor.stringToUnsignedInteger(tNumberString)).thenReturn(Left(InvalidInputFailure()));
            // assert later
            final expected = [Empty(), const Error(message: INVALID_INPUT_FAILURE_MESSAGE)];
            expectLater(numberTriviaBloc.stream.asBroadcastStream(), emitsInOrder(expected));
            // act
            numberTriviaBloc.add(const GetTriviaForConcreteNumber(tNumberString));
          },
        );

  });


}