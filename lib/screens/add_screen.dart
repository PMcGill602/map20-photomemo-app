import 'dart:io';

import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  static const routeName = '/home/addScreen';

  @override
  State<StatefulWidget> createState() {
    return _AddState();
  }
}

class _AddState extends State<AddScreen> {
  _Controller con;
  File image;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new Photo Memo"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: image == null
                ? Icon(
                    Icons.photo_library,
                    size: 300.0,
                  )
                : Image.file(
                    image,
                    fit: BoxFit.fill,
                  ),
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Title',
            ),
            autocorrect: true,
            validator: con.validatorTitle,
            onSaved: con.onSavedTitle,
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Memo',
            ),
            autocorrect: true,
            keyboardType: TextInputType.multiline,
            maxLines: 7,
            validator: con.validatorMemo,
            onSaved: con.onSavedMemo,
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Shared With (comma separated email list)',
            ),
            autocorrect: false,
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            validator: con.validatorSharedWith,
            onSaved: con.onSavedSharedWith,
          ),
        ],
      )),
    );
  }
}

class _Controller {
  _AddState _state;
  _Controller(this._state);
  String title;
  String memo;
  List<String> sharedWith = [];

  String validatorTitle(String value) {
    if (value == null || value.trim().length < 2) {
      return 'Minimum 2 characters';
    } else {
      return null;
    }
  }

  void onSavedTitle(String value) {
    this.title = value;
  }

  String validatorMemo(String value) {
    if (value == null || value.trim().length < 3) {
      return 'Minimum 3 characters';
    } else {
      return null;
    }
  }

  void onSavedMemo(String value) {
    this.memo = value;
  }

  String validatorSharedWith(String value) {
    if (value == null || value.trim().length == 0) {
      return null;
    }
    List<String> emailList = value.split(',').map((e) => e.trim()).toList();
    for (String email in emailList) {
      if (email.contains('@') && email.contains('.'))
        continue;
      else
        return 'Comma(,) separated email list';
    }
    return null;
  }

  void onSavedSharedWith(String value) {
    if (value.trim().length != 0) {
      this.sharedWith = value.split(',').map((e) => e.trim()).toList();
    }
  }
}
