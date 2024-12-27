// Flutter imports:
import 'package:flutter/material.dart';

showSnackBarMessage(BuildContext context, String? message) {
  if (message != null) {
    final double width = MediaQuery.of(context).size.width * 0.80;

    return ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          width: width,
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          elevation: 6.0,
          duration: const Duration(milliseconds: 2000),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
