import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String msg) {
  final snackBar = SnackBar(
    content: Text(msg),
    action: SnackBarAction(label: '閉じる', onPressed: () {}),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}