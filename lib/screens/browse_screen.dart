import 'package:flutter/material.dart';
import 'package:photomemo/model/photomemo.dart';
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
  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    photoMemos ??= arg['photoMemoList'];
    return Scaffold(
      appBar: AppBar(
        title: Text("Browse")
      ),
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
                        Text('Shared With: ${photoMemos[index].sharedWith}'),
                        Text('Updated at: ${photoMemos[index].updatedAt}'),
                        Text(photoMemos[index].memo),
                      ],
                    ),
                    //onTap: () => con.onTap(index),
                    //onLongPress: () => con.onLongPress(index),
                  ),
                ),
              ),
    );
  }

}