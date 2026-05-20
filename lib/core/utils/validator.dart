import 'package:flutter/material.dart';
import 'package:flutter_starter/generated/locale_keys.dart';

import 'validation_patterns.dart';

/// A utility class that provides various validation methods for common input types.
/// All methods return null if validation passes, or a localized error message if validation fails.
abstract final class Validator {
  /// Base validation method for required fields
  static String? validateRequired(BuildContext context, String? value) {
    return (value == null || value.trim().isEmpty)
        ? LocaleKeys.thisFieldIsRequired.tr(context)
        : null;
  }

  /// Validates an email address
  static String? validateEmail(BuildContext context, String? email) {
    final requiredCheck = validateRequired(context, email);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    return !ValidationPatterns.email.hasMatch(email!)
        ? LocaleKeys.pleaseEnterAValidEmailAddress.tr(context)
        : null;
  }

  /// Validates a password with minimum requirements
  static String? validatePassword(
    BuildContext context,
    String? password, {
    int minLength = 8,
    bool requireSpecialChar = false,
    bool requireUppercase = false,
    bool requireStrongPassword = false,
  }) {
    final requiredCheck = validateRequired(context, password);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    if (password!.length < minLength) {
      return LocaleKeys.passwordMustBeAtLeastLengthCharactersLong.tr(
        context,
        args: {'length': minLength},
      );
    }

    if (requireStrongPassword) {
      if (!ValidationPatterns.strongPassword.hasMatch(password)) {
        return LocaleKeys
            .passwordMustContainAtLeastOneUppercaseLetterOneLowercaseLetterOneNumberAndOneSpecialCharacter
            .tr(context);
      }
    } else {
      if (requireSpecialChar &&
          !password.contains(ValidationPatterns.specialChar)) {
        return LocaleKeys.passwordMustContainAtLeastOneSpecialCharacter.tr(
          context,
        );
      }

      if (requireUppercase &&
          !password.contains(ValidationPatterns.uppercaseLetter)) {
        return LocaleKeys.passwordMustContainAtLeastOneUppercaseLetter.tr(
          context,
        );
      }
    }

    return null;
  }

  /// Validates matching passwords
  static String? validatePasswordMatch(
    BuildContext context,
    String? password,
    String? confirmPassword,
  ) {
    final requiredCheck = validateRequired(context, confirmPassword);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    return password != confirmPassword
        ? LocaleKeys.passwordsDoNotMatch.tr(context)
        : null;
  }

  /// Validates a URL with optional protocol check
  static String? validateUrl(
    BuildContext context,
    String? url, {
    bool requireHttps = false,
  }) {
    final requiredCheck = validateRequired(context, url);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    if (!ValidationPatterns.url.hasMatch(url!)) {
      return LocaleKeys.pleaseEnterAValidUrl.tr(context);
    }

    if (requireHttps && !url.startsWith('https://')) {
      return LocaleKeys.urlMustUseHttpsProtocol.tr(context);
    }

    return null;
  }

  /// Validates a username
  static String? validateUsername(
    BuildContext context,
    String? username, {
    bool allowSpecialChars = false,
    int minLength = 3,
    int maxLength = 20,
  }) {
    final requiredCheck = validateRequired(context, username);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    if (username!.length < minLength || username.length > maxLength) {
      return LocaleKeys.usernameMustBeBetweenMinAndMaxCharacters.tr(
        context,
        args: {'min': minLength, 'max': maxLength},
      );
    }

    if (!allowSpecialChars && !ValidationPatterns.username.hasMatch(username)) {
      return LocaleKeys.usernameCanOnlyContainLettersNumbersAndUnderscores
          .tr(context);
    }

    return null;
  }

  /// Validates a name (first name or last name)
  static String? validateName(
    BuildContext context,
    String? name, {
    int minLength = 2,
    int maxLength = 30,
  }) {
    final requiredCheck = validateRequired(context, name);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    if (name!.length < minLength || name.length > maxLength) {
      return LocaleKeys.mustBeMinMaxCharacters.tr(
        context,
        args: {'min': minLength, 'max': maxLength},
      );
    }

    if (!ValidationPatterns.name.hasMatch(name)) {
      return LocaleKeys.lettersOnly.tr(context);
    }

    return null;
  }

  /// Validates a full name (first and last name with one space)
  static String? validateFullName(
    BuildContext context,
    String? fullName, {
    int minLength = 3,
    int maxLength = 60,
  }) {
    final requiredCheck = validateRequired(context, fullName);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    if (fullName!.length < minLength || fullName.length > maxLength) {
      return LocaleKeys.mustBeMinMaxCharacters.tr(
        context,
        args: {'min': minLength, 'max': maxLength},
      );
    }

    if (!ValidationPatterns.fullName.hasMatch(fullName)) {
      return LocaleKeys.formatJohnDoe.tr(context);
    }

    return null;
  }

  /// Validates a numeric value with optional range and type checking
  static String? validateNumeric(
    BuildContext context,
    String? value, {
    double? min,
    double? max,
    bool integerOnly = false,
    bool positiveOnly = false,
  }) {
    final requiredCheck = validateRequired(context, value);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    if (integerOnly && !ValidationPatterns.integer.hasMatch(value!)) {
      return LocaleKeys.pleaseEnterAValidInteger.tr(context);
    }

    if (!ValidationPatterns.numeric.hasMatch(value!)) {
      return LocaleKeys.pleaseEnterAValidNumber.tr(context);
    }

    final numValue = double.parse(value);

    if (positiveOnly && numValue <= 0) {
      return LocaleKeys.pleaseEnterAPositiveNumber.tr(context);
    }

    if (min != null && numValue < min) {
      return LocaleKeys.valueMustBeGreaterThanMin.tr(
        context,
        args: {'min': min},
      );
    }

    if (max != null && numValue > max) {
      return LocaleKeys.valueMustBeLessThanMax.tr(
        context,
        args: {'max': max},
      );
    }

    return null;
  }

  /// Validates a phone number with optional format checking
  static String? validatePhone(
    BuildContext context,
    String? phone, {
    bool usFormat = false,
  }) {
    final requiredCheck = validateRequired(context, phone);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    if (usFormat) {
      return !ValidationPatterns.usPhone.hasMatch(phone!)
          ? LocaleKeys.pleaseEnterAValidUsPhoneNumberEg1234567890.tr(
              context,
            )
          : null;
    }

    return !ValidationPatterns.phone.hasMatch(phone!)
        ? LocaleKeys.pleaseEnterAValidPhoneNumber.tr(context)
        : null;
  }

  /// Validates a postal/zip code with country format support
  static String? validatePostalCode(
    BuildContext context,
    String? code, {
    bool ukFormat = false,
  }) {
    final requiredCheck = validateRequired(context, code);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    if (ukFormat) {
      return !ValidationPatterns.ukPostcode.hasMatch(code!)
          ? LocaleKeys.pleaseEnterAValidUkPostalCode.tr(context)
          : null;
    }

    return !ValidationPatterns.postalCode.hasMatch(code!)
        ? LocaleKeys.pleaseEnterAValidPostalCode.tr(context)
        : null;
  }

  /// Validates an IP address (v4 or v6)
  static String? validateIP(
    BuildContext context,
    String? ip, {
    bool ipv6 = false,
  }) {
    final requiredCheck = validateRequired(context, ip);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    if (ipv6) {
      return !ValidationPatterns.ipv6.hasMatch(ip!)
          ? LocaleKeys.pleaseEnterAValidIpv6Address.tr(context)
          : null;
    }

    return !ValidationPatterns.ipv4.hasMatch(ip!)
        ? LocaleKeys.pleaseEnterAValidIpv4Address.tr(context)
        : null;
  }

  /// Validates a hex color code
  static String? validateHexColor(BuildContext context, String? color) {
    final requiredCheck = validateRequired(context, color);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    return !ValidationPatterns.hexColor.hasMatch(color!)
        ? LocaleKeys.pleaseEnterAValidHexColorCodeEgFf0000.tr(context)
        : null;
  }

  /// Validates a credit card number with card type detection
  static String? validateCreditCard(
    BuildContext context,
    String? number, {
    String? cardType,
  }) {
    final requiredCheck = validateRequired(context, number);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    final cleanNumber = number!.replaceAll(RegExp(r'\s+|-'), '');

    if (!ValidationPatterns.creditCard.hasMatch(cleanNumber)) {
      return LocaleKeys.pleaseEnterAValidCreditCardNumber.tr(context);
    }

    if (cardType != null) {
      final bool isValid = switch (cardType.toLowerCase()) {
        'visa' => ValidationPatterns.visaCard.hasMatch(cleanNumber),
        'mastercard' => ValidationPatterns.masterCard.hasMatch(cleanNumber),
        'amex' => ValidationPatterns.amexCard.hasMatch(cleanNumber),
        _ => false,
      };
      if (!isValid) {
        return LocaleKeys.invalidTypeCardNumber.tr(
          context,
          args: {'type': cardType},
        );
      }
    }

    if (!_isValidLuhn(cleanNumber)) {
      return LocaleKeys.invalidCreditCardNumber.tr(context);
    }

    return null;
  }

  /// Helper method for Luhn algorithm
  static bool _isValidLuhn(String number) {
    var sum = 0;
    var alternate = false;

    for (var i = number.length - 1; i >= 0; i--) {
      var digit = int.parse(number[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Validates text length within specified range
  static String? validateLength(
    BuildContext context,
    String? value, {
    int? minLength,
    int? maxLength,
    bool trimWhitespace = true,
    bool isRequired = true,
  }) {
    if (!isRequired) {
      if (value == null || value.trim().isEmpty) {
        return null;
      }
    }

    final requiredCheck = validateRequired(context, value);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    final checkValue = trimWhitespace ? value!.trim() : value!;

    if (minLength != null && checkValue.length < minLength) {
      return LocaleKeys.mustBeAtLeastLengthCharactersLong.tr(
        context,
        args: {'length': minLength},
      );
    }

    if (maxLength != null && checkValue.length > maxLength) {
      return LocaleKeys.mustNotExceedLengthCharacters.tr(
        context,
        args: {'length': maxLength},
      );
    }

    return null;
  }

  /// Validates a date string with format and range checking
  static String? validateDate(
    BuildContext context,
    String? date, {
    bool iso8601Only = false,
    DateTime? minDate,
    DateTime? maxDate,
    bool allowTime = false,
  }) {
    final requiredCheck = validateRequired(context, date);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    if (iso8601Only) {
      final pattern = allowTime
          ? ValidationPatterns.iso8601DateTime
          : ValidationPatterns.iso8601Date;

      if (!pattern.hasMatch(date!)) {
        return allowTime
            ? LocaleKeys.pleaseEnterAValidIso8601Datetime.tr(context)
            : LocaleKeys.pleaseEnterAValidIso8601Date.tr(context);
      }
    }

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(date!);
    } catch (e) {
      return LocaleKeys.pleaseEnterAValidDate.tr(context);
    }

    if (minDate != null && parsedDate.isBefore(minDate)) {
      return LocaleKeys.dateMustBeAfterDate.tr(
        context,
        args: {'date': minDate.toString()},
      );
    }

    if (maxDate != null && parsedDate.isAfter(maxDate)) {
      return LocaleKeys.dateMustBeBeforeDate.tr(
        context,
        args: {'date': maxDate.toString()},
      );
    }

    return null;
  }

  /// Validates time format (12h or 24h)
  static String? validateTime(
    BuildContext context,
    String? time, {
    bool use24Hour = true,
  }) {
    final requiredCheck = validateRequired(context, time);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    final pattern =
        use24Hour ? ValidationPatterns.time24h : ValidationPatterns.time12h;

    return !pattern.hasMatch(time!)
        ? use24Hour
            ? LocaleKeys.pleaseEnterAValid24hourTimeEg1430.tr(context)
            : LocaleKeys.pleaseEnterAValid12hourTimeEg230Pm.tr(context)
        : null;
  }

  /// Validates file size and type
  static String? validateFile(
    BuildContext context, {
    required String fileName,
    required int sizeInBytes,
    required int maxSizeInMB,
    List<String>? allowedExtensions,
    List<String>? allowedMimeTypes,
  }) {
    if (sizeInBytes > maxSizeInMB * 1024 * 1024) {
      return LocaleKeys.fileSizeMustNotExceedSizeMb.tr(
        context,
        args: {'size': maxSizeInMB},
      );
    }

    if (allowedExtensions != null) {
      final extension = fileName.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        return LocaleKeys.allowedFileTypesTypes.tr(
          context,
          args: {'types': allowedExtensions.join(', ')},
        );
      }
    }

    if (!ValidationPatterns.fileName.hasMatch(fileName)) {
      return LocaleKeys.invalidFileName.tr(context);
    }

    return null;
  }

  /// Validates social media handles
  static String? validateSocialHandle(
    BuildContext context,
    String? handle,
    String platform,
  ) {
    final requiredCheck = validateRequired(context, handle);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    RegExp pattern;

    switch (platform.toLowerCase()) {
      case 'twitter':
        pattern = ValidationPatterns.twitterHandle;
        return !pattern.hasMatch(handle!)
            ? LocaleKeys.pleaseEnterAValidTwitterHandle.tr(context)
            : null;
      case 'instagram':
        pattern = ValidationPatterns.instagramHandle;
        return !pattern.hasMatch(handle!)
            ? LocaleKeys.pleaseEnterAValidInstagramHandle.tr(context)
            : null;
      default:
        return LocaleKeys.unsupportedSocialMediaPlatform.tr(context);
    }
  }

  /// Validates text against common naming conventions
  static String? validateNamingConvention(
    BuildContext context,
    String? text,
    String convention,
  ) {
    final requiredCheck = validateRequired(context, text);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    RegExp pattern;

    switch (convention.toLowerCase()) {
      case 'camelcase':
        pattern = ValidationPatterns.camelCase;
        return !pattern.hasMatch(text!)
            ? LocaleKeys.textMustBeInCamelcaseFormat.tr(context)
            : null;
      case 'pascalcase':
        pattern = ValidationPatterns.pascalCase;
        return !pattern.hasMatch(text!)
            ? LocaleKeys.textMustBeInPascalcaseFormat.tr(context)
            : null;
      case 'kebabcase':
        pattern = ValidationPatterns.kebabCase;
        return !pattern.hasMatch(text!)
            ? LocaleKeys.textMustBeInKebabcaseFormat.tr(context)
            : null;
      case 'snakecase':
        pattern = ValidationPatterns.snakeCase;
        return !pattern.hasMatch(text!)
            ? LocaleKeys.textMustBeInSnakeCaseFormat.tr(context)
            : null;
      default:
        return LocaleKeys.unsupportedNamingConvention.tr(context);
    }
  }

  /// Validates SSN (Social Security Number)
  static String? validateSSN(BuildContext context, String? ssn) {
    final requiredCheck = validateRequired(context, ssn);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    return !ValidationPatterns.ssn.hasMatch(ssn!)
        ? LocaleKeys.pleaseEnterAValidSsnEg123456789.tr(context)
        : null;
  }

  /// Validates domain name
  static String? validateDomain(BuildContext context, String? domain) {
    final requiredCheck = validateRequired(context, domain);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    return !ValidationPatterns.domain.hasMatch(domain!)
        ? LocaleKeys.pleaseEnterAValidDomainName.tr(context)
        : null;
  }

  /// Validates base64 string
  static String? validateBase64(BuildContext context, String? base64String) {
    final requiredCheck = validateRequired(context, base64String);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    return !ValidationPatterns.base64.hasMatch(base64String!)
        ? LocaleKeys.pleaseEnterAValidBase64String.tr(context)
        : null;
  }

  /// Validates MIME type
  static String? validateMimeType(BuildContext context, String? mimeType) {
    final requiredCheck = validateRequired(context, mimeType);
    if (requiredCheck != null) {
      return requiredCheck;
    }

    return !ValidationPatterns.mimeType.hasMatch(mimeType!)
        ? LocaleKeys.pleaseEnterAValidMimeType.tr(context)
        : null;
  }
}
