import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_genesis/core/di/service_locator.dart';
import 'package:flutter_genesis/core/ui/components/custom_app_bar.dart';
import 'package:flutter_genesis/generated/locale_keys.dart';

import '../cubit/authentication_cubit.dart';
import '../widgets/authentication_body_widget.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthenticationCubit>(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: LocaleKeys.authLoginTitle.tr(context),
        ),
        body: const AuthenticationBodyWidget(),
      ),
    );
  }
}
