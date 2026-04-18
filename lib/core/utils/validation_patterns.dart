/// Regex patterns for validation across the app.
abstract final class ValidationPatterns {
  // Basic patterns
  /// Validates a standard email format (e.g., user@example.com)
  static final RegExp email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Validates a password with at least one letter, one digit, and a minimum length of 8 characters
  static final RegExp password = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  /// Validates a username consisting of 3 to 20 alphanumeric characters or underscores
  static final RegExp username = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  /// Validates numeric values, including integers and decimals (e.g., 123, -123, 123.45)
  static final RegExp numeric = RegExp(r'^-?\d+(\.\d+)?$');

  /// Validates positive integers (e.g., 123, 456)
  static final RegExp integer = RegExp(r'^\d+$');

  /// Validates decimal numbers with a fractional part (e.g., 123.45)
  static final RegExp decimal = RegExp(r'^\d*\.\d+$');

  // Contact and location patterns
  /// Validates general phone numbers, allowing optional country codes and various separators (e.g., +1 123-456-7890)
  static final RegExp phone = RegExp(r'^\+?[\d\s-]{8,}$');

  /// Validates US phone numbers in various formats (e.g., (123) 456-7890, 123-456-7890)
  static final RegExp usPhone = RegExp(
    r'^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$',
  );

  /// Validates US postal codes, including the optional 4-digit extension (e.g., 12345, 12345-6789)
  static final RegExp postalCode = RegExp(r'^\d{5}(-\d{4})?$');

  /// Validates UK postcodes (e.g., SW1A 1AA, EC1A 1BB)
  static final RegExp ukPostcode = RegExp(
    r'^[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}$',
  );

  // Web and tech patterns
  /// Validates URLs with optional schemes, domains, ports, paths, queries, and fragments
  static final RegExp url = RegExp(
    r'^(https?:\/\/)?' // Optional http or https scheme
    r'((([a-zA-Z\d]([a-zA-Z\d-]*[a-zA-Z\d])*)\.)+[a-zA-Z]{2,}|' // Domain name
    r'((\d{1,3}\.){3}\d{1,3}))' // OR ip (v4) address
    r'(\:\d+)?(\/[-a-zA-Z\d%_.~+]*)*' // Optional port and path
    r'(\?[;&a-zA-Z\d%_.~+=-]*)?' // Optional query
    r'(\#[-a-zA-Z\d_]*)?$', // Optional fragment
  );

  /// Validates IPv4 addresses (e.g., 192.168.1.1)
  static final RegExp ipv4 = RegExp(
    r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );

  /// Validates IPv6 addresses in various formats
  static final RegExp ipv6 = RegExp(
    r'^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]+|::(ffff(:0{1,4})?:)?((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9]))$',
  );

  /// Validates hexadecimal color codes (e.g., #FFF, #FFFFFF)
  static final RegExp hexColor = RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');

  /// Validates domain names (e.g., example.com, sub.example.co.uk)
  static final RegExp domain = RegExp(
    r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
  );

  // Document and file patterns
  /// Validates file names with extensions (e.g., document.pdf, image.jpg)
  static final RegExp fileName = RegExp(r'^[\w,\s-]+\.[A-Za-z]{1,4}$');

  /// Validates Base64-encoded strings
  static final RegExp base64 = RegExp(
    r'^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$',
  );

  /// Validates MIME types (e.g., text/plain, application/json)
  static final RegExp mimeType = RegExp(r'^[a-zA-Z0-9]+/[a-zA-Z0-9]+$');

  // Identity and finance patterns
  /// Validates Social Security Numbers (SSN) in the format XXX-XX-XXXX
  static final RegExp ssn = RegExp(r'^\d{3}-\d{2}-\d{4}$');

  /// Validates credit card numbers with optional separators (e.g., 1234-5678-9012-3456)
  static final RegExp creditCard = RegExp(
    r'^\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}$',
  );

  /// Validates Visa card numbers
  static final RegExp visaCard = RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$');

  /// Validates MasterCard numbers
  static final RegExp masterCard = RegExp(r'^5[1-5][0-9]{14}$');

  /// Validates American Express (Amex) card numbers
  static final RegExp amexCard = RegExp(r'^3[47][0-9]{13}$');

  // Date and time patterns
  /// Validates ISO 8601 date format (e.g., 2023-10-05)
  static final RegExp iso8601Date = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Validates ISO 8601 date-time format (e.g., 2023-10-05T14:30:00Z)
  static final RegExp iso8601DateTime = RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,3})?(Z|[+-]\d{2}:?\d{2})?$',
  );

  /// Validates time in 24-hour format (e.g., 14:30, 02:45)
  static final RegExp time24h = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');

  /// Validates time in 12-hour format with AM/PM (e.g., 2:30PM, 11:45AM)
  static final RegExp time12h = RegExp(
    r'^(0?[1-9]|1[0-2]):[0-5][0-9](AM|PM|am|pm)$',
  );

  // Text format patterns
  /// Validates slugs commonly used in URLs (e.g., my-page-title)
  static final RegExp slug = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  /// Validates strong passwords requiring uppercase, lowercase, digits, special characters, and a minimum length of 8
  static final RegExp strongPassword = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  /// Matches HTML tags (e.g., <div>, <p class="example">)
  static final RegExp htmlTag = RegExp(r'<[^>]*>');

  /// Validates Markdown links (e.g., [Example](https://example.com))
  static final RegExp markdownLink = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

  // Social media patterns
  /// Validates Twitter handles (e.g., @username, username)
  static final RegExp twitterHandle = RegExp(r'^@?(\w){1,15}$');

  /// Validates Instagram handles (e.g., @username, username)
  static final RegExp instagramHandle = RegExp(
    r'^@?([A-Za-z0-9._](?:(?:[A-Za-z0-9._]|(?:\.(?!\.))){2,28}(?:[A-Za-z0-9._]))?)$',
  );

  /// Validates YouTube URLs (e.g., https://www.youtube.com/watch?v=example, youtu.be/example)
  static final RegExp youtubeUrl = RegExp(
    r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+$',
  );

  // Programming patterns
  /// Validates variable names in most programming languages (e.g., variableName, _variable)
  static final RegExp variableName = RegExp(r'^[a-zA-Z_$][a-zA-Z_$0-9]*$');

  /// Validates camelCase variable names (e.g., camelCaseVariable)
  static final RegExp camelCase = RegExp(r'^[a-z][a-zA-Z0-9]*$');

  /// Validates PascalCase variable names (e.g., PascalCaseVariable)
  static final RegExp pascalCase = RegExp(r'^[A-Z][a-zA-Z0-9]*$');

  /// Validates kebab-case strings (e.g., kebab-case-string)
  static final RegExp kebabCase = RegExp(r'^[a-z][a-z0-9]*(-[a-z0-9]+)*$');

  /// Validates snake_case strings (e.g., snake_case_string)
  static final RegExp snakeCase = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

  // Password character patterns
  /// Matches special characters used in password validation
  static final RegExp specialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  /// Matches at least one uppercase letter
  static final RegExp uppercaseLetter = RegExp(r'[A-Z]');

  // Personal name patterns
  /// Validates a single name (any Unicode letters, e.g., Arabic, Latin).
  static final RegExp name = RegExp(r'^[\p{L}]+$', unicode: true);

  /// Validates full names (first and last name separated by exactly one space)
  static final RegExp fullName = RegExp(r'^[\p{L}]+\s[\p{L}]+$', unicode: true);
}
