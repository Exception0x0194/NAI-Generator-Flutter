import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

void showInfoBar(BuildContext context, String message) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(milliseconds: 1500),
    leftBarIndicatorColor: Colors.blue.shade300,
    icon: Icon(
      Icons.info_outline,
      size: 28.0,
      color: Colors.blue.shade300,
    ),
    message: message,
  ).show(context);
}

void showErrorBar(BuildContext context, String message) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(milliseconds: 1500),
    leftBarIndicatorColor: Colors.red.shade500,
    icon: Icon(
      Icons.error_outline,
      size: 28.0,
      color: Colors.red.shade500,
    ),
    message: message,
  ).show(context);
}

void showWarningBar(BuildContext context, String message) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(milliseconds: 1500),
    leftBarIndicatorColor: Colors.orange,
    icon: const Icon(
      Icons.error_outline,
      size: 28.0,
      color: Colors.orange,
    ),
    message: message,
  ).show(context);
}
