import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/controller/firebasecontroller.dart';
import 'package:photomemo/model/photomemo.dart';
import 'package:photomemo/screens/home_screen.dart';
import 'package:photomemo/screens/signup_screen.dart';
import 'package:photomemo/screens/views/mydialog.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(children: <Widget>[
            Stack(
              children: <Widget>[
                Image.asset('assets/images/postit.png'),
                Positioned(
                  top: 50.0,
                  left: 0,
                  child: Text(
                    'PhotoMemo',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 25.0,
                      fontFamily: 'Audiowide',
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: con.validatorEmail,
              onSaved: con.onSavedEmail,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Password',
              ),
              obscureText: true,
              autocorrect: false,
              validator: con.validatorPassword,
              onSaved: con.onSavedPassword,
            ),
            RaisedButton(
              child: Text(
                'Sign In',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              color: Colors.blue,
              onPressed: con.signIn,
            ),
            SizedBox(
              height: 30.0,
            ),
            FlatButton(
                onPressed: con.signUp,
                child: Text(
                  'No account yet? Click here to create',
                  style: TextStyle(fontSize: 15.0),
                ))
          ]),
        ),
      ),
    );
  }
}

class _Controller {
  _SignInState _state;
  _Controller(this._state);
  String email;
  String password;

  signIn() async {
    if (!_state.formKey.currentState.validate()) {
      return;
    }
    _state.formKey.currentState.save();

    MyDialog.circularProgressStart(_state.context);

    User user;

    try {
      user = await FireBaseController.signIn(email, password);
      print('USER: $user');
    } catch (e) {
      MyDialog.circularProgressEnd(_state.context);
      MyDialog.info(
        context: _state.context,
        title: 'Sign In Error',
        content: e.message ?? e.toString(),
      );
      return;
    }

    try {
      List<PhotoMemo> photoMemos =
          await FireBaseController.getPhotoMemos(user.email);
      MyDialog.circularProgressEnd(_state.context);
      Navigator.pushReplacementNamed(_state.context, HomeScreen.routeName,
          arguments: {'user': user, 'photoMemoList': photoMemos});
    } catch (e) {
      MyDialog.circularProgressEnd(_state.context);
      MyDialog.info(
        context: _state.context,
        title: 'Firebase/Firestore error',
        content:
            'Cannot get photo memo documents. Try again later!\n ${e.message}',
      );
    }
  }

  String validatorEmail(String value) {
    if (value == null || !value.contains('@') || !value.contains('.')) {
      return 'Invalid email address';
    } else {
      return null;
    }
  }

  void onSavedEmail(String value) {
    email = value;
  }

  String validatorPassword(String value) {
    if (value == null || value.length < 6) {
      return 'Password must have minimum 6 characters';
    } else {
      return null;
    }
  }

  void onSavedPassword(String value) {
    password = value;
  }

  void signUp() async{
    Navigator.pushNamed(_state.context, SignUpScreen.routeName);
  }
}
