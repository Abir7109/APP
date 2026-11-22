import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

String friendlyError(Object error) {
  final text = error.toString();
  if (text.startsWith('Exception: ')) return text.substring(11);
  if (text.startsWith('Bad state: ')) return text.substring(11);
  return text;
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final colors = context.colors;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError ? Colors.white : colors.background,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? colors.danger : colors.text,
      ),
    );
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final colors = context.colors;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: destructive ? colors.danger : colors.primary,
              minimumSize: const Size(0, 44),
            ),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

String greetingFor(DateTime time) {
  if (time.hour < 12) return 'Good morning';
  if (time.hour < 18) return 'Good afternoon';
  return 'Good evening';
}
