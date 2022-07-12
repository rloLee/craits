import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

//http://localhost:8080/CRATIS/V1/Medicine/MedicineDetail.json			

class JMedicineDetail{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JMedicineDetailInfo info;
   
  JMedicineDetail({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JMedicineDetail.fromJson(Map<dynamic, dynamic> json){
    // if(json['list'] != null){
      return JMedicineDetail(
        resultCode: json['resultCode'],// as dynamic,
        resultMsg: json['resultMsg'],// as dynamic,
        info:JMedicineDetailInfo.fromJson(json['info'])
      );
    // } else{
    //   return HospitalList(
    //     resultCode: json['resultCode'],// as dynamic,
    //     resultMsg: json['resultMsg'],// as dynamic,
    //     totalCnt: json['total_cnt'],// as dynamic,
    //   );
    // }
  }
}

class JMedicineDetailInfo{
  final dynamic id;
  final dynamic nm;
  final dynamic entpNm;
  final dynamic avgPrice;
  final dynamic imageUrl;
  final dynamic etcOtcCd;
  final dynamic classNo;
  final dynamic chart;
  final dynamic storageMethod;
  final dynamic validTerm;
  final dynamic eeDocData;
  final dynamic udDocData;
  final dynamic nbDocData;
  //final dynamic pnDocData;
  final List<JMedicineDetailInfoHelpContentListUnit> helpContentList;
  final List<JMedicineDetailInfoSameKindListUnit> sameKindList;


  JMedicineDetailInfo({
    @required this.id,
    @required this.nm,
    @required this.entpNm,
    @required this.avgPrice,
    @required this.imageUrl,
    @required this.etcOtcCd,
    @required this.classNo,
    @required this.chart,
    @required this.storageMethod,
    @required this.validTerm,
    @required this.eeDocData,
    @required this.udDocData,
    @required this.nbDocData,
    //@required this.pnDocData,
    @required this.helpContentList,
    @required this.sameKindList,
  });

  
  factory JMedicineDetailInfo.fromJson(Map<dynamic, dynamic> json){
    var helpContentListJson = json['help_content_list'] as List;
    List<JMedicineDetailInfoHelpContentListUnit> _helpContentLists = [];
    if(helpContentListJson != null)
      _helpContentLists = helpContentListJson.map((listJson)=>JMedicineDetailInfoHelpContentListUnit.fromJson(listJson)).toList();


    var sameKindListJson = json['same_kind_list'] as List;
    List<JMedicineDetailInfoSameKindListUnit> _sameKindLists = [];
    if(sameKindListJson != null)
      _sameKindLists = sameKindListJson.map((listJson)=>JMedicineDetailInfoSameKindListUnit.fromJson(listJson)).toList();

    return JMedicineDetailInfo(
      id: json['id'],// as dynamic,
      nm: json['nm'],// as dynamic,
      entpNm: json['entp_nm'],// as dynamic,
      avgPrice: json['avg_price'],// as dynamic,
      imageUrl: json['image_url'],// as dynamic,
      etcOtcCd: json['etc_otc_cd'],// as dynamic,
      classNo: json['class_no'],// as dynamic,
      chart: json['chart'],//as dynamic,
      storageMethod: json['storage_method'],// as dynamic,
      validTerm: json['valid_term'],// as dynamic,
      eeDocData: json['ee_doc_data'],// as dynamic,
      udDocData: json['ud_doc_data'],// as dynamic,
      nbDocData: json['nb_doc_data'],// as dynamic,
      //pnDocData: json['pn_doc_data'],// as dynamic,
      helpContentList:_helpContentLists,
      sameKindList:_sameKindLists,
    );
  }
}

class JMedicineDetailInfoHelpContentListUnit{
  final dynamic nm;
  final dynamic content;

  JMedicineDetailInfoHelpContentListUnit({
    @required this.nm,
    @required this.content,
  });

  factory JMedicineDetailInfoHelpContentListUnit.fromJson(Map<dynamic, dynamic> json){
    return JMedicineDetailInfoHelpContentListUnit(
      nm: json['nm'],
      content: json['content']);
  }
}

class JMedicineDetailInfoSameKindListUnit{
  final dynamic id;
  final dynamic nm;
  final dynamic entpNm;
  final dynamic type;
  final dynamic avgPrice;
  final dynamic reviewCnt;
  final dynamic reviewScore;
  final dynamic imageUrl;

  JMedicineDetailInfoSameKindListUnit({
    @required this.id,
    @required this.nm,
    @required this.entpNm,
    @required this.type,
    @required this.avgPrice,
    @required this.reviewCnt,
    @required this.reviewScore,
    @required this.imageUrl,
  });

  factory JMedicineDetailInfoSameKindListUnit.fromJson(Map<dynamic, dynamic> json){
    return JMedicineDetailInfoSameKindListUnit(
      id: json['id'],
      nm: json['nm'],
      entpNm: json['entp_nm'],
      type: json['type'],
      avgPrice: json['avg_price'],
      reviewCnt: json['review_cnt'],
      reviewScore: json['review_score'],
      imageUrl: json['image_url'],
    );
  }
}
