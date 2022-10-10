import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_tdd/core/error/exceptions.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

import '../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;
  final tNumber = 1;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpsClientSuccess200Concrete() {
    when(() => mockHttpClient.get(
        Uri(scheme: 'http', path: 'numbersapi.com/$tNumber'),
        headers: {
          'Content-Type': 'application/json',
        }))
        .thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpsClientSuccess200Random() {
    when(() => mockHttpClient.get(
        Uri(scheme: 'http', path: 'numbersapi.com/random'),
        headers: {
          'Content-Type': 'application/json',
        }))
        .thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpsClientFailure404Concrete() {
    when(() => mockHttpClient.get(
        Uri(scheme: 'http', path: 'numbersapi.com/$tNumber'),
        headers: {
          'Content-Type': 'application/json',
        }))
        .thenAnswer(
            (_) async => http.Response('Something went wrong', 404));
  }

  void setUpMockHttpsClientFailure404Random() {
    when(() => mockHttpClient.get(
        Uri(scheme: 'http', path: 'numbersapi.com/random'),
        headers: {
          'Content-Type': 'application/json',
        }))
        .thenAnswer(
            (_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''Should perform GET request on a URL with number
           being at the endpoint and with application/json header''',
      () async {
        // arrange
        setUpMockHttpsClientSuccess200Concrete();
        // act
        dataSource.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockHttpClient.get(
                Uri(scheme: 'http', path: 'numbersapi.com/$tNumber'),
                headers: {
                  'Content-Type': 'application/json',
                }));
      },
    );

    test(
          'should return NumberTrivia model when response is 200(success)',
          () async {
            // arrange
            setUpMockHttpsClientSuccess200Concrete();
            // act
            final result = await dataSource.getConcreteNumberTrivia(tNumber);
            // assert
            expect(result, tNumberTriviaModel);
          },
        );

    test(
          'should throw a Server Exception when response code is 404 or some other error',
          () async {
            // arrange
            setUpMockHttpsClientFailure404Concrete();
            // act
            final call = dataSource.getConcreteNumberTrivia;
            // assert
            expect(() => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
          },
        );

  });

  group('getRandomTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''Should perform GET request on a URL with number
           being at the endpoint and with application/json header''',
      () async {
        // arrange
        setUpMockHttpsClientSuccess200Random();
        // act
        dataSource.getRandomNumberTrivia();
        // assert
        verify(() => mockHttpClient.get(
                Uri(scheme: 'http', path: 'numbersapi.com/random'),
                headers: {
                  'Content-Type': 'application/json',
                }));
      },
    );

    test(
          'should return NumberTrivia model when response is 200(success)',
          () async {
            // arrange
            setUpMockHttpsClientSuccess200Random();
            // act
            final result = await dataSource.getRandomNumberTrivia();
            // assert
            expect(result, tNumberTriviaModel);
          },
        );

    test(
          'should throw a Server Exception when response code is 404 or some other error',
          () async {
            // arrange
            setUpMockHttpsClientFailure404Random();
            // act
            final call = dataSource.getRandomNumberTrivia;
            // assert
            expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
          },
        );

  });
}
