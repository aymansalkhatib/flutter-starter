import 'package:freezed_annotation/freezed_annotation.dart';

part 'authentication_entity.freezed.dart';
part 'authentication_entity.g.dart';

@freezed
abstract class AuthenticationEntity with _$AuthenticationEntity {
  const factory AuthenticationEntity({
    required String token,
  }) = _AuthenticationEntity;

  factory AuthenticationEntity.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationEntityFromJson(json);
}
