class PhotoMemo {

  static const COLLECTION = 'photoMemos';
  static const IMAGE_FOLDER = 'photoMemoPictures';
  static const PROFILE_FOLDER = 'profilePictures';
  static const TITLE = 'title';
  static const MEMO = 'memo';
  static const CREATED_BY = 'createdBy';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_PATH = 'photoPath';
  static const UPDATED_AT = 'updatedAt';
  static const PUBLIC = 'public';
  static const SCORE = 'score';
  static const SHARED_WITH = 'sharedWith';
  static const IMAGE_LABELS = 'imageLabels';
  static const MIN_CONFIDENCE = 0.7;

  String docId;
  String createdBy;
  String title;
  String memo;
  String photoPath;
  String photoURL;
  DateTime updatedAt;
  bool public;
  int score;
  List<dynamic> sharedWith;
  List<dynamic> imageLabels;
  

  PhotoMemo({
    this.docId,
    this.createdBy,
    this.title,
    this.memo,
    this.photoPath,
    this.photoURL,
    this.updatedAt,
    this.public,
    this.score,
    this.sharedWith,
    this.imageLabels,
  }) {
    this.sharedWith ??= [];
    this.imageLabels ??= [];
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic> {
      TITLE: title,
      CREATED_BY: createdBy,
      MEMO: memo,
      PHOTO_PATH: photoPath,
      PHOTO_URL: photoURL,
      UPDATED_AT: updatedAt,
      PUBLIC: public,
      SCORE: score,
      SHARED_WITH: sharedWith,
      IMAGE_LABELS: imageLabels,
    };
  }

  static PhotoMemo deserialize(Map<String,dynamic> data, String docId) {
    return PhotoMemo(
      docId: docId,
      createdBy: data[PhotoMemo.CREATED_BY],
      title: data[PhotoMemo.TITLE],
      memo: data[PhotoMemo.MEMO],
      photoPath: data[PhotoMemo.PHOTO_PATH],
      photoURL: data[PhotoMemo.PHOTO_URL],
      updatedAt: data[PhotoMemo.UPDATED_AT] != null ?
        DateTime.fromMillisecondsSinceEpoch(data[PhotoMemo.UPDATED_AT].millisecondsSinceEpoch) : null,
      public: data[PhotoMemo.PUBLIC],
      score: data[PhotoMemo.SCORE],
      sharedWith: data[PhotoMemo.SHARED_WITH],
      imageLabels: data[PhotoMemo.IMAGE_LABELS],
    );
  }

  @override
  String toString() {
    return '$docId $createdBy $title $memo  \n  $photoURL';
  }
}