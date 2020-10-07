import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photomemo/model/photomemo.dart';

class FireBaseController {
  static Future signIn(String email, String password) async {
    AuthResult auth = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return auth.user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<List<PhotoMemo>> getPhotoMemos(String email) async {
    QuerySnapshot querySnapshot = await Firestore.instance
      .collection(PhotoMemo.COLLECTION)
      .where(PhotoMemo.CREATED_BY, isEqualTo: email)
      .getDocuments();
    var result = <PhotoMemo>[];
    if(querySnapshot != null && querySnapshot.documents.length != 0) {
      for(var doc in querySnapshot.documents) {
        result.add(PhotoMemo.deserialize(doc.data, doc.documentID));
      }
    }
    return result;
  }
}