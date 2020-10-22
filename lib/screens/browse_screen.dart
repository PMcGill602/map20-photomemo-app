import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/model/photomemo.dart';
import 'package:photomemo/screens/browsedetailed_screen.dart';
import 'package:photomemo/screens/views/myimageview.dart';

class BrowseScreen extends StatefulWidget {
  static const routeName = '/homeScreen/browseScreen';
  @override
  State<StatefulWidget> createState() {
    return _BrowseState();
  }
}

class _BrowseState extends State<BrowseScreen> {
  List<PhotoMemo> photoMemos;
  User user;
  _Controller con;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    photoMemos ??= arg['photoMemoList'];
    user ??= arg['user'];
    return Scaffold(
      appBar: AppBar(title: Text("Browse")),
      body: photoMemos.length == 0
          ? Text(
              'No Photo Memo',
              style: TextStyle(
                fontSize: 30.0,
              ),
            )
          : ListView.builder(
              itemCount: photoMemos.length,
              itemBuilder: (BuildContext context, int index) => Container(
                color: Colors.white,
                child: ListTile(
                  leading: MyImageView.network(
                      imageUrl: photoMemos[index].photoURL, context: context),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  title: Text(photoMemos[index].title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Created by: ${photoMemos[index].createdBy}'),
                      Text('Updated at: ${photoMemos[index].updatedAt}'),
                      Text(photoMemos[index].memo),
                      Container(
                        child: photoMemos[index].votes.isNotEmpty 
                            ? photoMemos[index].votes.values.reduce(
                                        (sum, element) => sum + element) >
                                    0
                                ? Text(
                                    '${photoMemos[index].votes.values.reduce((sum, element) => sum + element)}',
                                    style: TextStyle(color: Colors.green),
                                  )
                                : Text(
                                    '${photoMemos[index].votes.values.reduce((sum, element) => sum + element)}',
                                    style: TextStyle(color: Colors.red),
                                  )
                            : Text('0', style: TextStyle(color: Colors.black),),
                      ),
                    ],
                  ),
                  onTap: () => con.onTap(index),
                ),
              ),
            ),
    );
  }
}

class _Controller {
  _BrowseState _state;
  _Controller(this._state);

  void onTap(int index) async {
    await Navigator.pushNamed(_state.context, BrowseDetailedScreen.routeName,
        arguments: {
          'user': _state.user,
          'photoMemo': _state.photoMemos[index]
        });
    _state.render(() {});
  }
}
