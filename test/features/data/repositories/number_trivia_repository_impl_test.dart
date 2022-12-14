import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_tdd/core/error/exceptions.dart';
import 'package:number_trivia_tdd/core/error/failures.dart';
import 'package:number_trivia_tdd/core/network/network_info.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia_tdd/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockLocalDataSource mockLocalDataSource;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
        numberTriviaRemoteDataSource: mockRemoteDataSource,
        numberTriviaLocalDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  group('get concrete number trivia', () {
    const tNumber = 1;

    final NumberTriviaModel tNumberTriviaModel =
        NumberTriviaModel(text: "Test text", number: tNumber);
    final NumberTrivia tNumberEntity = tNumberTriviaModel;

    test(
      'should check internet connection',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((invocation) async => true);
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((invocation) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => true);
        // act
        repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    void runTestOnline(Function body) {
     group('device is online', () {
       setUp(() {
         when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
       });
       body();
     });
    }

    void runTestOffline(Function body){
      group('device is offline', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected)
              .thenAnswer((invocation) async => false);
        });
        body();
      });
    }

    runTestOnline(() {
      test(
        'should return remote data when the call to remote data source is success',
        () async {
          // arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => true);
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberEntity)));
        },
      );

      test(
        'should cache data locally when the call to remote data source is success',
        () async {
          // arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => true);
          // act
          await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(
              () => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenThrow(ServerException());
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestOffline(() {
      test(
        'should return last cached data when cached data is present',
        () async {
          // arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, equals(Right(tNumberTriviaModel)));
        },
      );

      test(
        'should return CachedFailure when cached data is not present',
        () async {
          // arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group('get random number trivia', () {

    final NumberTriviaModel tNumberTriviaModel =
    NumberTriviaModel(text: "Test text", number: 123);
    final NumberTrivia tNumberEntity = tNumberTriviaModel;

    test(
      'should check internet connection',
          () async {
        // arrange
        when(() => mockNetworkInfo.isConnected)
            .thenAnswer((invocation) async => true);
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((invocation) async => tNumberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
            .thenAnswer((_) async => true);
        // act
        repository.getRandomNumberTrivia();
        // assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    void runTestOnline(Function body) {
      group('device is online', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });
        body();
      });
    }

    void runTestOffline(Function body){
      group('device is offline', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected)
              .thenAnswer((invocation) async => false);
        });
        body();
      });
    }

    runTestOnline(() {
      test(
        'should return remote data when the call to remote data source is success',
            () async {
          // arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => true);
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          expect(result, equals(Right(tNumberEntity)));
        },
      );

      test(
        'should cache data locally when the call to remote data source is success',
            () async {
          // arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => true);
          // act
          await repository.getRandomNumberTrivia();
          // assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verify(
                  () => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
            () async {
          // arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestOffline(() {
      test(
        'should return last cached data when cached data is present',
            () async {
          // arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, equals(Right(tNumberTriviaModel)));
        },
      );

      test(
        'should return CachedFailure when cached data is not present',
            () async {
          // arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
