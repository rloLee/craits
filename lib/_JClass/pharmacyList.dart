import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// http://localhost:8081/Cratis/V1/Pharmacy/PharmacyList.json			

class JPharmacyList{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JPharmacyListInfo info;
   
  JPharmacyList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JPharmacyList.fromJson(Map<dynamic, dynamic> json){
      return JPharmacyList(
        resultCode: json['resultCode'],// as dynamic,
        resultMsg: json['resultMsg'],// as dynamic,
        info: JPharmacyListInfo.fromJson(json['info']),// as dynamic,
      );
  }
}

class JPharmacyListInfo{
  final dynamic totalCnt;
  final List<JPharmacyListUnit> list;

  JPharmacyListInfo({
    @required this.totalCnt,
    @required this.list
  });

  factory JPharmacyListInfo.fromJson(Map<dynamic, dynamic> json){
    // if(json['list'] != null){
      var listObjsJson = json['list'] as List;
      List<JPharmacyListUnit> _lists = [];
      if(listObjsJson != null)
        _lists = listObjsJson.map((listJson) => JPharmacyListUnit.fromJson(listJson)).toList();

      return JPharmacyListInfo(
        totalCnt: json['total_cnt'],// as dynamic,
        list:_lists
      );
  }
}

class JPharmacyListUnit{
  final dynamic id;
  final dynamic pharmacyNm;
  final dynamic addr;
  final dynamic telNo;
  final dynamic xPos;
  final dynamic yPos;
  final dynamic dist;
  final dynamic reviewCnt;
  final dynamic reviewScore;
  final List<dynamic> specialList;
  // final List<JPharmacyListUnitSpecialListUnit> specialList;

  JPharmacyListUnit({
    @required this.id,
    @required this.pharmacyNm,
    @required this.addr,
    @required this.telNo,
    @required this.xPos,
    @required this.yPos,
    @required this.dist,
    @required this.reviewCnt,
    @required this.reviewScore,
    @required this.specialList,
  });

  
  factory JPharmacyListUnit.fromJson(Map<dynamic, dynamic> json){
    var spcListObjsJson = json['special_list'] as List;
    List<dynamic> _spcLists = [];

    if(spcListObjsJson != null)
      _spcLists = List.from(spcListObjsJson);
      // _spcLists = spcListObjsJson.map((listJson)=>JPharmacyListUnitSpecialListUnit.fromJson(listJson)).toList();

    return JPharmacyListUnit(
      id: json['id'],// as dynamic,
      pharmacyNm: json['pharmacy_nm'],// as dynamic,
      addr: json['addr'],// as dynamic,
      telNo: json['tel_no'],// as dynamic,
      xPos: json['x_pos'],// as dynamic,
      yPos: json['y_pos'],//as dynamic,
      dist: json['dist'],// as dynamic,
      reviewCnt: json['review_cnt'],// as dynamic,
      reviewScore: json['review_score'],// as dynamic,
      specialList:_spcLists
      //subjectList: json['subjectList'],// as List<HospitalListUnitSubjectList>,
      //specialList: json['specialList'],// as List<HospitalListUnitSpecialList>,
    );
  }
}

class JPharmacyListUnitSpecialListUnit{
  dynamic specialNm;

  JPharmacyListUnitSpecialListUnit({
    @required this.specialNm,
  });

  factory JPharmacyListUnitSpecialListUnit.fromJson(Map<dynamic, dynamic> json){
    return JPharmacyListUnitSpecialListUnit(
      specialNm: json['special_nm'],// as List<dynamic>,
    );
  }
}