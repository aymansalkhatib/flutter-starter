import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/errors/failure.dart';
import 'package:flutter_starter/core/extensions/build_context_extensions.dart';
import 'package:flutter_starter/core/extensions/edge_insets_extension.dart';
import 'package:flutter_starter/core/extensions/responsive_font_size_extension.dart';
import 'package:flutter_starter/core/routing/app_route.dart';
import 'package:flutter_starter/core/routing/navigation_service.dart';
import 'package:flutter_starter/core/ui/components/animated_dots_loader.dart';
import 'package:flutter_starter/core/ui/components/app_button.dart';
import 'package:flutter_starter/core/ui/components/custom_text_form_field.dart';
import 'package:flutter_starter/core/ui/snackbar/overlay_snackbar.dart';
import 'package:flutter_starter/core/ui/snackbar/scaffold_snackbar.dart';
import 'package:flutter_starter/core/utils/validator.dart';
import 'package:flutter_starter/generated/locale_keys.dart';

import '../cubit/authentication_cubit.dart';
import '../cubit/authentication_state.dart';

class AuthenticationBodyWidget extends StatelessWidget {
  const AuthenticationBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthenticationCubit>();

    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () => AnimatedDotsLoader.show(context),
          loaded: (_) {
            AnimatedDotsLoader.dismiss();
            NavigationService.clearAndPush<void>(AppRoute.productsScreen);
          },
          error: (Failure failure) {
            AnimatedDotsLoader.dismiss();
            showSnackbar(
              failure.message,
              type: OverlaySnackbarType.error,
            );
          },
        );
      },
      builder: (context, state) => SafeArea(
        child: SingleChildScrollView(
          padding: 24.all,
          child: Form(
            key: cubit.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32.sp(context)),
                Text(
                  LocaleKeys.authLoginTitle.tr(context),
                  style: context.styles.bold20,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.sp(context)),
                Text(
                  LocaleKeys.authLoginSubtitle.tr(context),
                  style: context.styles.regular14
                      .copyWith(color: context.colors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 32.sp(context)),
                CustomTextFormField(
                  controller: cubit.usernameController,
                  hintText: LocaleKeys.authUsernameHint.tr(context),
                  labelText: LocaleKeys.authUsernameLabel.tr(context),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validator.validateRequired(context, v),
                ),
                SizedBox(height: 16.sp(context)),
                CustomTextFormField(
                  controller: cubit.passwordController,
                  hintText: LocaleKeys.authPasswordHint.tr(context),
                  labelText: LocaleKeys.authPasswordLabel.tr(context),
                  showVisibilityToggle: true,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => cubit.login(),
                  validator: (v) =>
                      Validator.validatePassword(context, v, minLength: 4),
                ),
                SizedBox(height: 32.sp(context)),
                CustomButton(
                  text: LocaleKeys.authLoginButton.tr(context),
                  onPressed: cubit.login,
                  isLoading: state.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
