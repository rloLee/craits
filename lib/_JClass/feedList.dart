import 'package:flutter/cupertino.dart';

class JFeedList{
  final dynamic resultCode;
  final dynamic resultMsg;
  final dynamic pageNo;
  final List<JFeedListUnit> list;

  JFeedList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.pageNo,
    @required this.list,
  });

  factory JFeedList.fromJson(Map<dynamic, dynamic> json){
    var listJson = json['list'] as List;
    List _lists = listJson.map((listJson) => JFeedListUnit.fromJson(listJson)).toList();

    return JFeedList(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      pageNo: json['pageNo'],
      list: _lists,
    );
  }
}


class JFeedUpload{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JFeedListUnit list;

  JFeedUpload({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.list,
  });

  factory JFeedUpload.fromJson(Map<dynamic, dynamic> json){
    return JFeedUpload(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      list: JFeedListUnit.fromJson(json['list']),
    );
  }
}

class JFeedInfo{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JFeedListUnit info;

  JFeedInfo({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JFeedInfo.fromJson(Map<dynamic, dynamic> json){
    return JFeedInfo(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info: JFeedListUnit.fromJson(json['info'])
    );
  }
}

class JFeedListUnit{
  final String feedType;
  final dynamic feedId;
  final dynamic feedUserId;
  final String name;
  final String profileImageUrl;
  final String content;
  dynamic followFlag;
  final dynamic likeCnt;
  final dynamic commentCnt;
  String likeFlag;
  final String regDt;
  final String elapsedTime;
  final List<JFeedListUnitFeedImage> feedImageList;
  final dynamic adSeq;
  final String adTitle;
  final String adContent;
  final String adUrlLink;
  final String adImageUrl;


  JFeedListUnit({
    @required this.feedType,
    @required this.feedId,
    @required this.feedUserId,
    @required this.name,
    @required this.profileImageUrl,
    @required this.content,
    @required this.followFlag,
    @required this.likeCnt,
    @required this.commentCnt,
    @required this.likeFlag,
    @required this.regDt,
    @required this.elapsedTime,
    @required this.feedImageList,
    @required this.adSeq,
    @required this.adTitle,
    @required this.adContent,
    @required this.adUrlLink,
    @required this.adImageUrl,
  });

  factory JFeedListUnit.fromJson(Map<dynamic, dynamic> json){
    var feedImageListJson = json['feed_image_list'] as List;
    List<JFeedListUnitFeedImage> _feedImageLists = [];

    if(feedImageListJson != null )
    _feedImageLists = feedImageListJson.map((listJson) => JFeedListUnitFeedImage.fromJson(listJson)).toList();

    return JFeedListUnit(
      feedType: json['feed_type'],
      feedId: json['feed_id'],
      feedUserId: json['feed_user_id'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
      content: json['content'],
      followFlag: json['follow_flag'],
      likeCnt: json['like_cnt'],
      commentCnt: json['comment_cnt'],
      regDt: json['reg_dt'],
      elapsedTime: json['elapsed_time'],
      likeFlag: json['like_flag'],
      feedImageList: _feedImageLists,
      adSeq: json['ad_seq'],
      adTitle: json['ad_title'],
      adContent: json['ad_content'],
      adUrlLink: json['ad_url_link'],
      adImageUrl: json['ad_image_url'],
    );
  }
}

class JFeedListUnitTag{
  final dynamic tagName;

  JFeedListUnitTag({
    @required this.tagName
  });

  factory JFeedListUnitTag.fromJson(Map<dynamic, dynamic> json){
    return JFeedListUnitTag(
      tagName: json['tag_name']
    );
  }
}

class JFeedListUnitFeedImage{
  final dynamic imageUrl;

  JFeedListUnitFeedImage({
    @required this.imageUrl
  });

  factory JFeedListUnitFeedImage.fromJson(Map<dynamic, dynamic> json){
    return JFeedListUnitFeedImage(
      imageUrl: json['image_url']
    );
  }
}