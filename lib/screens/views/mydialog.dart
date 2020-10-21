import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/controller/firebasecontroller.dart';
import 'package:photomemo/model/photomemo.dart';

class MyDialog {
  static void circularProgressStart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

  static void circularProgressEnd(BuildContext context) {
    Navigator.pop(context);
  }

  static void info({BuildContext context, String title, String content}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  static void prompt(
      {BuildContext context,
      String title,
      String content,
      PhotoMemo photoMemo}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text('Confirm'),
              onPressed: () {
                FireBaseController.makePhotoMemoPublic(photoMemo);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
