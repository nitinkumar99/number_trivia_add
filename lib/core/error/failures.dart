import 'package:equatable/equatable.dart';

abstract class Failures extends Equatable{

}

// General failures
class ServerFailure extends Failures {
  @override
  List<Object?> get props => [];
}
class CacheFailure extends Failures {
  @override
  List<Object?> get props => [];
}