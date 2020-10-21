import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photomemo/model/photomemo.dart';

class FireBaseController {
  static Future signIn(String email, String password) async {
    UserCredential auth =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return auth.user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<List<PhotoMemo>> getPhotoMemos(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(PhotoMemo.COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.UPDATED_AT, descending: true)
        .get();
    var result = <PhotoMemo>[];
    if (querySnapshot != null && querySnapshot.docs.length != 0) {
      for (var doc in querySnapshot.docs) {
        result.add(PhotoMemo.deserialize(doc.data(), doc.id));
      }
    }
    return result;
  }

  static Future<Map<String, String>> uploadStorage({
    @required File image,
    String filePath,
    @required String uid,
    @required List<dynamic> sharedWith,
    @required Function listener,
  }) async {
    filePath ??= '${PhotoMemo.IMAGE_FOLDER}/$uid/${DateTime.now()}';
    StorageUploadTask task =
        FirebaseStorage.instance.ref().child(filePath).putFile(image);
    task.events.listen((event) {
      double percentage = event.snapshot.bytesTransferred.toDouble() /
          event.snapshot.totalByteCount.toDouble() *
          100;
      listener(percentage);
    });
    var download = await task.onComplete;
    String url = await download.ref.getDownloadURL();
    return {'url': url, 'path': filePath};
  }

  static Future<String> addPhotomemo(PhotoMemo photoMemo) async {
    photoMemo.updatedAt = DateTime.now();
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(PhotoMemo.COLLECTION)
        .add(photoMemo.serialize());
    return ref.id;
  }

  static Future<List<dynamic>> getImageLabels(File imageFile) async {
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);
    ImageLabeler cloudLabeler = FirebaseVision.instance.cloudImageLabeler();
    List<ImageLabel> cloudLabels = await cloudLabeler.processImage(visionImage);

    var labels = <String>[];
    for (ImageLabel label in cloudLabels) {
      String text = label.text.toLowerCase();
      double confidence = label.confidence;
      if (confidence >= PhotoMemo.MIN_CONFIDENCE) labels.add(text);
    }
    cloudLabeler.close();
    return labels;
  }

  static Future<void> deletePhotoMemo(PhotoMemo photoMemo) async {
    await FirebaseFirestore.instance
        .collection(PhotoMemo.COLLECTION)
        .doc(photoMemo.docId)
        .delete();
    await FirebaseStorage.instance.ref().child(photoMemo.photoPath).delete();
  }

  static Future<List<PhotoMemo>> searchImages({
    @required String email,
    @required String imageLabel,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(PhotoMemo.COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .where(PhotoMemo.IMAGE_LABELS, arrayContains: imageLabel.toLowerCase())
        .orderBy(PhotoMemo.UPDATED_AT, descending: true)
        .get();
    var result = <PhotoMemo>[];
    if (querySnapshot != null && querySnapshot.docs.length != 0) {
      for (var doc in querySnapshot.docs) {
        result.add(PhotoMemo.deserialize(doc.data(), doc.id));
      }
    }
    return result;
  }

  static Future<void> updatePhotoMemo(PhotoMemo photoMemo) async {
    photoMemo.updatedAt = DateTime.now();
    await FirebaseFirestore.instance
        .collection(PhotoMemo.COLLECTION)
        .doc(photoMemo.docId)
        .set(photoMemo.serialize());
  }

  static Future<List<PhotoMemo>> getPhotoMemosSharedWithMe(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(PhotoMemo.COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .orderBy(PhotoMemo.UPDATED_AT, descending: true)
        .get();
    var result = <PhotoMemo>[];
    if (querySnapshot != null && querySnapshot.docs.length != 0) {
      for (var doc in querySnapshot.docs) {
        result.add(PhotoMemo.deserialize(doc.data(), doc.id));
      }
    }
    return result;
  }

  static Future<void> signUp(String email, String password) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> updateProfile({
    @required File image,
    @required String displayName,
    @required User user,
    @required Function progressListener,
  }) async {
    if (image != null) {
      String filePath = '${PhotoMemo.PROFILE_FOLDER}/${user.uid}/${user.uid}';
      StorageUploadTask uploadTask =
          FirebaseStorage.instance.ref().child(filePath).putFile(image);
      uploadTask.events.listen((event) {
        double percentage = (event.snapshot.bytesTransferred.toDouble() /
                event.snapshot.totalByteCount.toDouble()) *
            100;
        progressListener(percentage);
      });
      var download = await uploadTask.onComplete;
      String url = await download.ref.getDownloadURL();
      await FirebaseAuth.instance.currentUser.updateProfile(
        displayName: displayName,
        photoURL: url,
      );
    } else {
      await FirebaseAuth.instance.currentUser.updateProfile(
        displayName: displayName,
      );
    }
  }

  static Future<void> makePhotoMemoPublic(PhotoMemo photoMemo) async {
    print(photoMemo.toString());
    photoMemo.public = true;
    photoMemo.score = 1;
    await FirebaseFirestore.instance
        .collection(PhotoMemo.COLLECTION)
        .doc(photoMemo.docId)
        .update(photoMemo.serialize());
  }

  static Future<List<PhotoMemo>> getPublicPhotoMemos() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(PhotoMemo.COLLECTION)
        .where(PhotoMemo.PUBLIC, isEqualTo: true)
        .orderBy(PhotoMemo.UPDATED_AT, descending: true)
        .get();
    var result = <PhotoMemo>[];
    if (querySnapshot != null && querySnapshot.docs.length != 0) {
      for (var doc in querySnapshot.docs) {
        result.add(PhotoMemo.deserialize(doc.data(), doc.id));
      }
    }
    return result;
  }
}
