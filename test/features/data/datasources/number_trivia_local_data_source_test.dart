import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_tdd/core/error/exceptions.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl numberTriviaLocalDataSourceImpl;

  late MockSharedPreferences mockSharedPreference;

  setUp(() {
    mockSharedPreference = MockSharedPreferences();
    numberTriviaLocalDataSourceImpl = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreference);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test(
      'should return NumberTrivia from SharedPreference when cached locally',
      () async {
        // arrange
        when(() => mockSharedPreference.getString(CACHED_NUMBER_TRIVIA))
            .thenReturn(fixture('trivia_cached.json'));
        // act
        final result =
            await numberTriviaLocalDataSourceImpl.getLastNumberTrivia();
        // assert
        verify(() => mockSharedPreference.getString(CACHED_NUMBER_TRIVIA));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw CacheException when there is no value cached',
      () async {
        // arrange
        when(() => mockSharedPreference.getString(CACHED_NUMBER_TRIVIA))
            .thenReturn(null);
        // act
        final call = numberTriviaLocalDataSourceImpl.getLastNumberTrivia;
        // assert
        expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
      },
    );
  });
  
  
  group('cacheNumberTrivia', () {

    final tNumberTriviaModel = NumberTriviaModel(text: 'Test trivia', number: 1);

    test(
          'should return true when shared preference to cache the data is successful',
          () async {
            // arrange
            final expectedJson = jsonEncode(tNumberTriviaModel.toJson());
            when(() => mockSharedPreference.setString(CACHED_NUMBER_TRIVIA, expectedJson)).thenAnswer((_) async => true);
            // act
            final result = await numberTriviaLocalDataSourceImpl.cacheNumberTrivia(tNumberTriviaModel);
            // assert
            verify(() => mockSharedPreference.setString(CACHED_NUMBER_TRIVIA, expectedJson));
            expect(result, true);
          },
        );

    test(
          'should return true when shared preference to cache the data is unsuccessful',
          () async {
            // arrange
            final expectedJson = jsonEncode(tNumberTriviaModel.toJson());
            when(() => mockSharedPreference.setString(CACHED_NUMBER_TRIVIA, expectedJson)).thenAnswer((_) async => false);
            // act
            final result = await numberTriviaLocalDataSourceImpl.cacheNumberTrivia(tNumberTriviaModel);
            // assert
            verify(() => mockSharedPreference.setString(CACHED_NUMBER_TRIVIA, expectedJson));
            expect(result, false);
          },
        );

  });
  
}
