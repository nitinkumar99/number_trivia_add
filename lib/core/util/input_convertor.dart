import 'package:dartz/dartz.dart';
import 'package:number_trivia_tdd/core/error/failures.dart';

class InputConvertor {
  Either<Failures, int> stringToUnsignedInteger(String str) {
    try{
      final number = int.parse(str);
      if(number < 0) throw const FormatException();
      return Right(number);
    } on FormatException{
     return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failures {
  @override
  List<Object?> get props => [];
}
