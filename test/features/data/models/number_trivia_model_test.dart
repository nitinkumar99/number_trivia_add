import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: "Test text");

  test('should be a subclass of NumberTrivia entity', () async {
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group('from json', () {
    test('should return a valid model when json has number as int', () async {
      // arrange
      Map<String, dynamic> jsonMap = jsonDecode(fixture('trivia.json'));

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);

      // assert
      expect(result, tNumberTriviaModel);
    });

    test('should return a valid model when json has number as double',
        () async {
      // arrange
      Map<String, dynamic> jsonMap = jsonDecode(fixture('trivia_double.json'));

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);

      // assert
      expect(result, tNumberTriviaModel);
    });
  });

  group('to Json', () {
    test(
          'should return JSON Map containing proper data',
          () async {
            // arrange
            final expectedMap = {
              "text": "Test text",
              "number": 1,
            };
            // act
            final result = tNumberTriviaModel.toJson();
            // assert
            expect(result, expectedMap);
          },
        );

  });
}
