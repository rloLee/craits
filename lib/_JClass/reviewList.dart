import 'package:flutter/cupertino.dart';

class JReviewList{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JReviewListInfo info;

  JReviewList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JReviewList.fromJson(Map<dynamic, dynamic> json){
    return JReviewList(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info: json['info'] != null? JReviewListInfo.fromJson(json['info']) : null, 
    );
  }
}

class JReviewListInfo{
  final dynamic totalScore;
  final dynamic totalCnt;
  final dynamic score1;
  final dynamic score2;
  final dynamic score3;
  final dynamic score4;
  final dynamic score5;
  final List<JReviewListInfoListUnit> list;

  JReviewListInfo({
    @required this.totalScore,
    @required this.totalCnt,
    @required this.score1,
    @required this.score2,
    @required this.score3,
    @required this.score4,
    @required this.score5,
    @required this.list,
  });

  factory JReviewListInfo.fromJson(Map<dynamic, dynamic> json){
    var listJson = json['list'] as List;
    List<JReviewListInfoListUnit> _lists = [];

    if(listJson != null)
      _lists = listJson.map((listJson)=>JReviewListInfoListUnit.fromJson(listJson)).toList();

    return JReviewListInfo(
      totalScore: json['total_score'],
      totalCnt: json['total_cnt'],
      score1: json['score_1'],
      score2: json['score_2'],
      score3: json['score_3'],
      score4: json['score_4'],
      score5: json['score_5'],
      list: _lists,
    );
  } 
}

class JReviewListInfoListUnit{
  final dynamic seq;
  final dynamic reviewUserId;
  final String name;
  final dynamic profileImageUrl;
  final String content;
  final dynamic score;
  final String regDt;
  final String elapsedTime;
  final List<JReviewListInfoListUnitImageUnit> reviewImageList;

  JReviewListInfoListUnit({
    @required this.seq,
    @required this.reviewUserId,
    @required this.name,
    @required this.profileImageUrl,
    @required this.content,
    @required this.score,
    @required this.regDt,
    @required this.elapsedTime,
    @required this.reviewImageList
  });

  factory JReviewListInfoListUnit.fromJson(Map<dynamic, dynamic> json){
    var reviewImageListJson = json['review_image_list'] as List;
    
    List<JReviewListInfoListUnitImageUnit> _reviewImageLists = [];
    if(reviewImageListJson != null)
      _reviewImageLists = reviewImageListJson.map((listJson)=>JReviewListInfoListUnitImageUnit.fromJson(listJson)).toList();

    return JReviewListInfoListUnit(
      seq: json['seq'],
      reviewUserId: json['review_user_id'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
      content: json['content'],
      score: json['score'],
      regDt: json['reg_dt'],
      elapsedTime: json['elapsed_time'],
      reviewImageList: _reviewImageLists
    );
  }
}

class JReviewListInfoListUnitImageUnit{
  final dynamic imageUrl;

  JReviewListInfoListUnitImageUnit({
    @required this.imageUrl,
  });

  factory JReviewListInfoListUnitImageUnit.fromJson(Map<dynamic, dynamic> json){
    return JReviewListInfoListUnitImageUnit(
      imageUrl: json['image_url']
    );
  }
}
