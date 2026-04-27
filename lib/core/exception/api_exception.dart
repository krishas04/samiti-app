import 'dart:convert';

class ApiException implements Exception {
  final int statusCode;
  final String body;

  ApiException(this.statusCode, this.body);

  //custom getter
  String get message {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final errors = decoded.entries.map((e) {
          final val = e.value;
          if (val is List) return '${e.key}: ${val.join(', ')}';  // If a value is a list (e.g., multiple validation errors), it joins them with commas.
          return '${e.key}: $val';  // it prints the key and value directly.
        }).join('\n');  // Joins all entries with line breaks
        return errors;
      }
      return decoded.toString();  //to convert the decoded JSON into text, no matter what type it is.
    } catch (_) {
      return 'Error $statusCode: $body';
    }
  }

  //This means whenever you print(e) or log the exception, Dart will call this method and return the value of your custom message getter.
  // So instead of the default "Instance of 'ApiException'", you’ll see the nicely formatted error message.
  @override
  String toString() => message;
}