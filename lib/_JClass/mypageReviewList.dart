import 'package:flutter/cupertino.dart';

class JMyReviewList{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JMyReviewListInfo info;

  JMyReviewList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JMyReviewList.fromJson(Map<dynamic, dynamic> json){
    return JMyReviewList(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info: JMyReviewListInfo.fromJson(json['info']), 
    );
  }
}

class JMyReviewListInfo{
  final List<JMyReviewListInfoListUnit> list;

  JMyReviewListInfo({
    @required this.list,
  });

  factory JMyReviewListInfo.fromJson(Map<dynamic, dynamic> json){
    var listJson = json['list'] as List;
    List<JMyReviewListInfoListUnit> _lists = [];

    if(listJson != null)
      _lists = listJson.map((listJson)=>JMyReviewListInfoListUnit.fromJson(listJson)).toList();

    return JMyReviewListInfo(
      list: _lists,
    );
  } 
}

class JMyReviewListInfoListUnit{
  final String type;
  final dynamic id;
  final dynamic name;
  final dynamic seq;
  final dynamic reviewUserId;
  final String reviewUserName;
  final String profileImageUrl;
  final String content;
  final dynamic score;
  final String regDt;
  final String elapsedTime;
  final List<JMyReviewListInfoListUnitImageUnit> reviewImageList;

  JMyReviewListInfoListUnit({
    @required this.type,
    @required this.id,
    @required this.name,
    @required this.seq,
    @required this.reviewUserId,
    @required this.reviewUserName,
    @required this.profileImageUrl,
    @required this.content,
    @required this.score,
    @required this.regDt,
    @required this.elapsedTime,
    @required this.reviewImageList
  });

  factory JMyReviewListInfoListUnit.fromJson(Map<dynamic, dynamic> json){
    var reviewImageListJson = json['review_image_list'] as List;
    
    List<JMyReviewListInfoListUnitImageUnit> _reviewImageLists = [];
    if(reviewImageListJson != null)
      _reviewImageLists = reviewImageListJson.map((listJson)=>JMyReviewListInfoListUnitImageUnit.fromJson(listJson)).toList();

    return JMyReviewListInfoListUnit(
      type: json['type'],
      id: json['id'],
      name: json['name'],
      seq: json['seq'],
      reviewUserId: json['review_user_id'],
      reviewUserName: json['review_user_name'],
      profileImageUrl: json['profile_image_url'],
      content: json['content'],
      score: json['score'],
      regDt: json['reg_dt'],
      elapsedTime: json['elapsed_time'],
      reviewImageList: _reviewImageLists
    );
  }
}

class JMyReviewListInfoListUnitImageUnit{
  final dynamic imageUrl;

  JMyReviewListInfoListUnitImageUnit({
    @required this.imageUrl,
  });

  factory JMyReviewListInfoListUnitImageUnit.fromJson(Map<dynamic, dynamic> json){
    return JMyReviewListInfoListUnitImageUnit(
      imageUrl: json['image_url']
    );
  }
}
