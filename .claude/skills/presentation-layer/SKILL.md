---
name: presentation-layer
description: Rules for the presentation layer in flutter_starter — Cubit with safeEmit, Freezed state with Failure (never String), BlocConsumer split between Page (Scaffold + CustomAppBar + BlocProvider) and body widget (content + listener/builder), TextEditingController ownership in the Cubit. Use when creating or editing any file under lib/features/*/presentation/.
---

# Presentation layer

## 1. State — `error` carries a `Failure`, not a `String`

The UI decides how to render.

```dart
@freezed
abstract class FeatureState with _$FeatureState {
  const factory FeatureState.initial()                              = _Initial;
  const factory FeatureState.loading()                              = _Loading;
  const factory FeatureState.loaded({required FeatureEntity data})  = _Loaded;
  const factory FeatureState.error({required Failure failure})      = _Error;
}
```

**Do not** add navigation-specific states (`navigateToX`) — derive navigation from business states in the listener.

## 2. Cubit — always `safeEmit`, never `emit`

`safeEmit` ([core/extensions/safe_emit_extension.dart](../../../lib/core/extensions/safe_emit_extension.dart)) is a no-op if the Cubit is closed.

```dart
class FeatureCubit extends Cubit<FeatureState> {
  final GetFeatureUseCase _getFeatureUseCase;

  FeatureCubit({required GetFeatureUseCase getFeatureUseCase})
      : _getFeatureUseCase = getFeatureUseCase,
        super(const FeatureState.initial());

  Future<void> load() async {
    safeEmit(const FeatureState.loading());
    final result = await _getFeatureUseCase(NoParams.instance);
    result.fold(
      (failure) => safeEmit(FeatureState.error(failure: failure)),
      (data)    => safeEmit(FeatureState.loaded(data: data)),
    );
  }
}
```

**Cubits never** call `NavigationService`, show dialogs, or touch `BuildContext`.

## 3. TextEditingController ownership — in the Cubit, not the widget

Also: `FocusNode`, `GlobalKey<FormState>`.

```dart
class FeatureCubit extends Cubit<FeatureState> {
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState>  formKey            = GlobalKey<FormState>();

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
```

**Why:** the Cubit's lifecycle is tied to `BlocProvider` — when the page is popped, `close()` disposes the controllers. Widget stays `StatelessWidget`; form state is centralised.

## 4. Page + body widget — strict split

**Page** holds `BlocProvider`, `Scaffold`, `CustomAppBar`.
**Body widget** holds `BlocConsumer` + content only.

```dart
// pages/feature_page.dart
class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FeatureCubit>()..load(),
      child: Scaffold(
        appBar: CustomAppBar(title: LocaleKeys.featureTitle.tr(context)),
        body: const FeatureBodyWidget(),
      ),
    );
  }
}

// widgets/feature_body_widget.dart
class FeatureBodyWidget extends StatelessWidget {
  const FeatureBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeatureCubit, FeatureState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () => AnimatedDotsLoader.show(context),
          loaded: (_) {
            AnimatedDotsLoader.dismiss();
            // Navigate only when the flow requires it.
          },
          error: (failure) {
            AnimatedDotsLoader.dismiss();
            showSnackbar(failure.message, type: OverlaySnackbarType.error);
          },
        );
      },
      builder: (context, state) => state.maybeWhen(
        loaded: (data) => _Content(data: data),
        error:  (f)    => FailureWidget(failure: f),
        orElse: ()     => const SizedBox.shrink(),
      ),
    );
  }
}
```

## 5. Builder/Listener discipline

- `AnimatedDotsLoader` is a dialog overlay — **show / dismiss from `listener` only**.
- **Navigation** only from `listener`. Never from Cubit, never from `builder`.
- Prefer `whenOrNull` in listeners; `maybeWhen` + `orElse` in builders.
- Builders are pure — **no side effects, no setState**.
- For long lists (20+), always `ListView.builder`. Sort/filter in the Cubit before emitting `_Loaded`, not in the builder.
