---
name: translations
description: Rules for internationalization in flutter_genesis — never hardcode user-facing strings, use LocaleKeys.x.tr(context) with optional args for placeholders, add new keys to assets/translations/translations.json (numbered for shared, named for feature-specific), run the codegen helper, and never edit generated locale files. Covers pluralization via _zero/_one/_two/_few/_many/_other suffixes. Use when adding any user-visible text, validation messages, snackbar content, or dialog content.
---

# Translations

**Every string shown to the user flows through translations.** Never write English/Arabic literals in `Text`, hints, labels, validators, error messages, snackbars, or dialogs.

```dart
// ✅
Text(LocaleKeys.welcome.tr(context))

// ✅ with placeholder args
Text(LocaleKeys.greetName.tr(context, args: {'name': user.name}))

// ❌
Text('Welcome')
Text('مرحبا')
```

Placeholders use `{{name}}` syntax and are replaced via `args`.

## Workflow when a new string is needed

1. Open `assets/translations/translations.json` — read the last ~30 lines to find the last key.
2. Add a new entry:
   - **Shared / common string** → use the next integer key: `"88": { "en": "...", "ar": "..." }`
     The Dart identifier is auto-derived from the English text (camelCase).
   - **Feature-specific string** → use a named string key: `"productsTitle": { "en": "...", "ar": "..." }`
     The key name becomes the Dart identifier directly (first letter lowercased).
3. Run `dart helpers/translation_codegen.dart` — regenerates `en.json`, `ar.json`, and `lib/generated/locale_keys.dart`.
4. Use `LocaleKeys.<key>.tr(context)` in widget code.

**Never edit** `assets/locales/en.json`, `assets/locales/ar.json`, or `lib/generated/locale_keys.dart` directly — they are overwritten on every codegen run.

## Runtime locale switching

Use `TranslationManager` ([core/localization/translation_manager.dart](../../../lib/core/localization/translation_manager.dart)) — it persists the choice and rebuilds the app. **Never** call `Localizations.localeOf` for switching.

## Pluralization

Arabic has six plural forms (`zero`, `one`, `two`, `few`, `many`, `other`). **Never** implement with ternaries in widget code — use the plural-key convention:

```json
// en.json
"itemCount_zero":  "No items",
"itemCount_one":   "{{count}} item",
"itemCount_other": "{{count}} items"

// ar.json
"itemCount_zero":  "لا عناصر",
"itemCount_one":   "عنصر واحد",
"itemCount_two":   "عنصران",
"itemCount_few":   "{{count}} عناصر",
"itemCount_many":  "{{count}} عنصرًا",
"itemCount_other": "{{count}} عنصر"
```

Consume via `LocaleKeys.itemCount.plural(context, count: items.length)`.
