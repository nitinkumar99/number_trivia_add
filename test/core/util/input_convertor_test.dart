import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia_tdd/core/util/input_convertor.dart';

void main() {
  late InputConvertor inputConvertor;

  setUp(() {
    inputConvertor = InputConvertor();
  });

  group('stringToUnsignedInteger', () {
    test(
      'should return an integer when a string represents an unsigned integer',
      () async {
        // arrange
        const str = '123';
        // act
        final result = inputConvertor.stringToUnsignedInteger(str);
        // assert
        expect(result, const Right(123));
      },
    );

    test(
          'should return an Error in case number is not an integer',
          () async {
            // arrange
            const str = '123.4';
            // act
            final result = inputConvertor.stringToUnsignedInteger(str);
            // assert
            expect(result, Left(InvalidInputFailure()));
          },
        );

    test(
          'should return an Error in case number is a negative integer',
          () async {
            // arrange
            const str = '-123';
            // act
            final result = inputConvertor.stringToUnsignedInteger(str);
            // assert
            expect(result, Left(InvalidInputFailure()));
          },
        );
  });
}
