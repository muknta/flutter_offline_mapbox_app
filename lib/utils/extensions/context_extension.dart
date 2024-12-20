import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  void showErrorSnackBar(String message) => ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );

  void showSuccessSnackBar(String message) => ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.greenAccent,
        ),
      );
}
