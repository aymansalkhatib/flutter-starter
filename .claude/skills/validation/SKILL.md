---
name: validation
description: Rules for form validation in flutter_starter — always use pre-translated Validator.* methods (validateEmail, validatePassword, validatePhone, validateRequired, validateLength, validateDate, etc.), and add new validation methods inside Validator rather than inlining regex. Use when adding or editing any TextFormField validator, or when validating external arguments from deep links / push payloads.
---

# Form validation

**Never roll custom regex in pages.** [core/utils/validator.dart](../../../lib/core/utils/validator.dart) exposes pre-translated validators.

```dart
CustomTextFormField(
  controller: _emailCtl,
  validator: (v) => Validator.validateEmail(context, v),
)
```

All `validate*` methods live in `Validator`. Common ones:

| Method | Use for |
|--------|---------|
| `validateRequired(context, v)` | Non-empty check |
| `validateEmail(context, v)` | Email format |
| `validatePassword(context, v, minLength: 8, requireUppercase: true, ...)` | Password with policy |
| `validatePasswordMatch(context, a, b)` | Confirm password |
| `validatePhone(context, v, usFormat: false)` | Phone format |
| `validateName(context, v)` / `validateFullName(context, v)` | Personal names |
| `validateNumeric(context, v, min: 0, max: 100, integerOnly: true)` | Numeric input |
| `validateLength(context, v, minLength: 3, maxLength: 50)` | Text length |
| `validateDate(context, v, minDate: ..., maxDate: ...)` | Date format + range |
| `validateUrl(context, v, requireHttps: true)` | URL format |
| `validateCreditCard(context, v, cardType: 'visa')` | Luhn-checked card number |

If none fit, **add a new method inside `Validator`** — do not inline a regex at the call site. Regex patterns live in `core/utils/validation_patterns.dart`.
