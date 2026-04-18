import '../errors/failure.dart';
import './either.dart';

/// Base class for all use cases.
///
/// [ResultType] is the success return type.
/// [Param] is the input parameter type — use [NoParams] when none needed.
abstract class Usecase<ResultType, Param> {
  Future<Either<Failure, ResultType>> call(Param param);
}

/// Base class for stream-based use cases.
abstract class StreamUsecase<ResultType, Param> {
  Stream<ResultType> call(Param param);
}

/// Marker for use cases that require no input parameters.
class NoParams {
  const NoParams();
  static const instance = NoParams();
}
