class VideoInfo {
  String v_id;
  String category;
  String userId;
  String place;
  String assetVideo;
  String no_of_likes;

  VideoInfo(
      {this.v_id,
      this.category,
      this.userId,
      this.place,
      this.assetVideo,
      this.no_of_likes});

  // @override
  // String toString() {
  //   return assetVideo;
  // }
}

class LikeInfo {
  String lileId;
  String userId;
  String assetId;
  String assetOwner;

  LikeInfo({this.lileId, this.userId, this.assetId, this.assetOwner});
}
