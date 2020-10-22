import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/controller/firebasecontroller.dart';
import 'package:photomemo/model/photomemo.dart';
import 'package:photomemo/screens/views/mydialog.dart';
import 'package:photomemo/screens/views/myimageview.dart';

class BrowseDetailedScreen extends StatefulWidget {
  static const routeName = '/homeScreen/browseScreen/browseDetailedScreen';
  @override
  State<StatefulWidget> createState() {
    return _BrowseDetailedState();
  }
}

class _BrowseDetailedState extends State<BrowseDetailedScreen> {
  _Controller con;
  User user;
  PhotoMemo photoMemo;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args['user'];
    photoMemo ??= args['photoMemo'];
    con.getVote();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed view'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: MyImageView.network(
                      imageUrl: photoMemo.photoURL, context: context),
                ),
                Positioned(
                    top: 0.0,
                    left: 0.0,
                    child: IconButton(
                      icon: Icon(Icons.thumb_up),
                      onPressed: con.upvote,
                      color: con.vote == null
                          ? Colors.grey
                          : con.vote ? Colors.green : Colors.grey,
                    )),
                Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: IconButton(
                      icon: Icon(Icons.thumb_down),
                      onPressed: con.downvote,
                      color: con.vote == null
                          ? Colors.grey
                          : con.vote ? Colors.grey : Colors.red,
                    )),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    color: Colors.grey,
                    child: IconButton(
                        icon: Icon(Icons.label),
                        onPressed: con.showImageLabels),
                  ),
                ),
              ],
            ),
            Text(
              photoMemo.title,
              style: TextStyle(fontSize: 20.0),
            ),
            Text(
              photoMemo.memo,
              style: TextStyle(fontSize: 16.0),
            ),
            Text('Created By: ${photoMemo.createdBy}'),
            Text('Updated At: ${photoMemo.updatedAt}'),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  _BrowseDetailedState _state;
  _Controller(this._state);
  bool vote;

  void showImageLabels() {
    MyDialog.info(
      context: _state.context,
      title: 'Image labels by ML',
      content: _state.photoMemo.imageLabels.toString(),
    );
  }

  void upvote() async {
    try {
      await FireBaseController.upvotePhotoMemo(
          photoMemo: _state.photoMemo, uid: _state.user.uid);
      _state.render(() => getVote());
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Voting error, try again later',
        content: e.message ?? e.toString(),
      );
    }
  }

  void downvote() async {
    try {
      await FireBaseController.downvotePhotoMemo(
          photoMemo: _state.photoMemo, uid: _state.user.uid);
      _state.render(() => getVote());
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Voting error, try again later',
        content: e.message ?? e.toString(),
      );
    }
  }

  void getVote() {
    if (_state.photoMemo.votes.containsKey(_state.user.uid)) {
      if (_state.photoMemo.votes['${_state.user.uid}'] == 1) {
        _state.render(() => vote = true);
      } else {
        _state.render(() => vote = false);
      }
    }
  }
}
