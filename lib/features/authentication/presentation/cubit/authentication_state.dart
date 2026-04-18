import 'package:flutter_genesis/core/errors/failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/authentication_entity.dart';

part 'authentication_state.freezed.dart';

@freezed
abstract class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.initial() = _Initial;
  const factory AuthenticationState.loading() = _Loading;
  const factory AuthenticationState.loaded({
    required AuthenticationEntity data,
  }) = _Loaded;
  const factory AuthenticationState.error({
    required Failure failure,
  }) = _Error;
}
