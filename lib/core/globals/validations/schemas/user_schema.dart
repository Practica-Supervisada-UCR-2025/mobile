import 'package:ez_validator/ez_validator.dart';

class UserValidator {
  static String? validateName(String? value) {
    final validator = EzValidator<String>()
        .required('This field is required')
        .minLength(3, 'The name must be at least 3 characters long')
        .maxLength(25, 'The name must be at most 25 characters long')
        .validate(value);

    if (validator != null) return validator;

    if (value != null && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'The name can only contain letters and spaces';
    }

    return null;
  }

  static String? validateLastName(String? value) {
    final validator = EzValidator<String>()
        .maxLength(25, 'The last name must be at most 25 characters long')
        .validate(value);

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (validator != null) return validator;

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'The name can only contain letters and spaces';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    final validator = EzValidator<String>()
        .required('This field is required')
        .email('Invalid email format')
        .validate(value);

    if (validator != null) return validator;

    if (value != null && !value.endsWith('@ucr.ac.cr')) {
      return "The email must end with @ucr.ac.cr";
    }

    return null;
  }

  static String? validatePass(String? value) {
    final validator = EzValidator<String>()
        .required('This field is required')
        .minLength(8, 'The password must be at least 8 characters long')
        .maxLength(30, 'The password must be at most 30 characters long')
        .validate(value);

    if (validator != null) return validator;

    if (value != null && !RegExp(r'[A-Z]').hasMatch(value)) {
      return 'The password must contain at least one uppercase letter';
    }

    if (value != null && !RegExp(r'[a-z]').hasMatch(value)) {
      return 'The password must contain at least one lowercase letter';
    }

    if (value != null && !RegExp(r'[0-9]').hasMatch(value)) {
      return 'The password must contain at least one number';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    final validator = EzValidator<String>()
        .required('This field is required')
        .minLength(3, 'The username must be at least 3 characters long')
        .maxLength(25, 'The username must be at most 25 characters long')
        .validate(value);

    if (validator != null) return validator;

    if (value != null && !RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }
}
