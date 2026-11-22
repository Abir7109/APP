String? requiredField(String? value, {String label = 'This field'}) {
  if (value == null || value.trim().isEmpty) {
    return '$label is required.';
  }
  return null;
}

String? emailField(String? value) {
  final requiredError = requiredField(value, label: 'Email');
  if (requiredError != null) return requiredError;
  final email = value!.trim();
  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(email)) return 'Enter a valid email address.';
  return null;
}

String? passwordField(String? value) {
  if (value == null || value.isEmpty) return 'Password is required.';
  if (value.length < 6) return 'Use at least 6 characters.';
  return null;
}
