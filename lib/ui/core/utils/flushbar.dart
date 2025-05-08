import 'package:flutter/material.dart';

void showInfoBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 28.0,
            color: Colors.blue.shade300,
          ),
          const SizedBox(width: 16.0),
          Flexible(child: Text(message)),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      duration: const Duration(milliseconds: 1500),
    ));
}

void showErrorBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 28.0,
            color: Colors.red.shade500,
          ),
          const SizedBox(width: 16.0),
          Flexible(child: Text(message)),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      duration: const Duration(milliseconds: 1500),
    ));
}

void showWarningBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 28.0,
            color: Colors.orange.shade500,
          ),
          const SizedBox(width: 16.0),
          Text(message),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      duration: const Duration(milliseconds: 1500),
    ));
}
