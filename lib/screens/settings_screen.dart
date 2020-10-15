import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photomemo/controller/firebasecontroller.dart';
import 'package:photomemo/screens/views/mydialog.dart';
import 'package:photomemo/screens/views/myimageview.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/homeScreen/settingsScreen';
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<SettingsScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();
  FirebaseUser user;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    user ??= ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [IconButton(icon: Icon(Icons.check), onPressed: con.save)],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('Change Profile Picture', style: TextStyle(fontSize: 20.0),),
              Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: con.imageFile == null
                        ? MyImageView.network(
                            imageUrl: user.photoUrl, context: context)
                        : Image.file(con.imageFile, fit: BoxFit.fill),
                  ),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: Container(
                      child: PopupMenuButton<String>(
                        onSelected: con.getPicture,
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                          PopupMenuItem(
                            value: 'camera',
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.photo_camera),
                                Text('Camera'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'gallery',
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.photo_library),
                                Text('Gallery'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              con.progressMessage == null
                  ? SizedBox(
                      height: 1.0,
                    )
                  : Text(
                      con.progressMessage,
                      style: TextStyle(fontSize: 20.0),
                    ),
              TextFormField(
                style: TextStyle(fontSize: 20.0),
                decoration: InputDecoration(
                  hintText: 'Display Name',
                ),
                initialValue: user.displayName ?? 'N/A',
                autocorrect: false,
                validator: con.validatorDisplayName,
                onSaved: con.onSavedDisplayName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SettingsState _state;
  File imageFile;
  String displayName;
  String progressMessage;
  _Controller(this._state);

  void getPicture(String src) async {
    try {
      PickedFile _image;
      if (src == 'camera') {
        _image = await ImagePicker().getImage(source: ImageSource.camera);
      } else {
        _image = await ImagePicker().getImage(source: ImageSource.gallery);
      }
      _state.render(() => imageFile = File(_image.path));
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Image capture error',
        content: e.message ?? e.toString(),
      );
    }
  }

  String validatorDisplayName(String value) {
    if (value.length < 2)
      return 'Minumum 2 characters';
    else
      return null;
  }

  void onSavedDisplayName(String value) {
    this.displayName = value;
  }

  void save() async {
    if (!_state.formKey.currentState.validate()) {
      return;
    }
    _state.formKey.currentState.save();
    try {
      await FireBaseController.updateProfile(
        image: imageFile,
        displayName: displayName,
        user: _state.user,
        progressListener: (double percentage) {
          _state.render(() {
            progressMessage = 'Uploading ${percentage.toStringAsFixed(1)} %';
          });
        },
      );
      Navigator.pop(_state.context);
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Profile update error',
        content: e.message ?? e.toString(),
      );
    }
  }
}
