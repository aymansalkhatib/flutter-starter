---
name: theming
description: Rules for styling and layout in flutter_genesis — consume colors / typography / device info through BuildContext extensions (context.colors, context.styles, context.screenWidth, etc.), size fonts with .sp(context), build paddings with num extensions (16.horizontal, 24.all), clamp OS text scale once at MaterialApp.builder, and use AppThemeManager for runtime theme switching. Use when styling any UI element — never hardcode colors, font sizes, or EdgeInsets left/right.
---

# Theming & layout

All styling flows through `BuildContext` extensions ([core/extensions/build_context_extensions.dart](../../../lib/core/extensions/build_context_extensions.dart)). **Never** hardcode colors, text styles, or font sizes.

## 1. Context extensions

| Expression | Returns |
|------------|---------|
| `context.colors` | Active `AppColors` (`primary`, `error`, `textPrimary`, `surface`, …) |
| `context.styles` | `AppFontStyle` presets (`bold16`, `regular14`, `semiBold20`, …) |
| `context.theme` / `context.isDarkMode` | `ThemeData` / bool |
| `context.isArabic` / `context.isEnglish` / `context.currentLocale` | locale helpers |
| `context.screenWidth` / `.screenHeight` / `.screenSize` / `.isPortrait` | size & orientation |
| `context.safePadding` / `.viewInsets` / `.isKeyboardVisible` | safe area & keyboard |
| `context.isAndroid` / `.isIOS` / `.isWeb` / `.isDesktop` | platform |
| `context.unfocus()` | dismiss keyboard |

Full set: `reverseColors`, `currentRouteName`, etc. in the file above.

## 2. Responsive sizing — `num.sp(BuildContext)`

From [core/extensions/responsive_font_size_extension.dart](../../../lib/core/extensions/responsive_font_size_extension.dart):

```dart
Text(label, style: TextStyle(fontSize: 16.sp(context)))
```

Scales 0.85× (≤300px) to 1.3× (≥800px) around a 400px baseline. `AppFontStyle` presets already call `.sp(context)` internally — prefer them.

## 3. Padding helpers

[core/extensions/edge_insets_extension.dart](../../../lib/core/extensions/edge_insets_extension.dart):

```dart
16.horizontal   // EdgeInsets.symmetric(horizontal: 16)
24.all          // EdgeInsets.all(24)
8.top           // EdgeInsets.only(top: 8)
12.vertical     // EdgeInsets.symmetric(vertical: 12)
```

For RTL correctness, prefer `EdgeInsetsDirectional.only(start:, end:)` over `left`/`right` when hand-writing paddings.

## 4. OS text-scale clamp — `MaterialApp.builder` **only**

At extreme OS text scales, layouts break silently. Clamp once:

```dart
builder: (context, child) {
  final clamped = MediaQuery.of(context).textScaler
      .clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: clamped),
    child: child!,
  );
},
```

Feature code **never** overrides `textScaler`.

## 5. Theme source & runtime switching

Palettes live in [core/themes/](../../../lib/core/themes/):
- `AppTheme` — abstract base holding `AppColors` + `AppFontStyle`.
- `LightTheme` / `DarkTheme` — concrete overrides.
- `AppThemeManager` — runtime mode switcher (system / light / dark). Persists the choice and notifies the app to rebuild.

**Add or tune colors only inside `LightTheme` / `DarkTheme`.** Never build a one-off palette inside a feature.
