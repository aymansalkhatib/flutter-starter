import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/extensions/safe_emit_extension.dart';

import '../../domain/usecases/login_usecase.dart';
import 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final LoginUseCase _loginUseCase;

  final usernameController = TextEditingController(text: 'mor_2314');
  final passwordController = TextEditingController(text: '83r5^_');
  final formKey = GlobalKey<FormState>();

  AuthenticationCubit({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(const AuthenticationState.initial());

  Future<void> login() async {
    if (formKey.currentState?.validate() != true) {
      return;
    }
    safeEmit(const AuthenticationState.loading());
    final result = await _loginUseCase(
      LoginParams(
        username: usernameController.text.trim(),
        password: passwordController.text,
      ),
    );
    result.fold(
      (failure) => safeEmit(AuthenticationState.error(failure: failure)),
      (data) => safeEmit(AuthenticationState.loaded(data: data)),
    );
  }

  @override
  Future<void> close() {
    usernameController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
