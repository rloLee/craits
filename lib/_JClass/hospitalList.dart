import 'package:flutter/cupertino.dart';

class JHospitalList{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JHospitalListInfo info;
   
  JHospitalList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JHospitalList.fromJson(Map<dynamic, dynamic> json){
      return JHospitalList(
        resultCode: json['resultCode'],// as dynamic,
        resultMsg: json['resultMsg'],// as dynamic,
        info: JHospitalListInfo.fromJson(json['info']),// as dynamic,
      );
  }
}

class JHospitalListInfo{
  final dynamic totalCnt;
  final List<JHospitalListUnit> list;

  JHospitalListInfo({
    @required this.totalCnt,
    @required this.list
  });

  factory JHospitalListInfo.fromJson(Map<dynamic, dynamic> json){
    var listObjsJson = json['list'] as List;
    List<JHospitalListUnit> _lists = [];
    if (listObjsJson != null)
      _lists = listObjsJson.map((listJson) => JHospitalListUnit.fromJson(listJson)).toList();

    return JHospitalListInfo(
      totalCnt: json['total_cnt'],// as dynamic,
      list:_lists
    );
    // } else{
    //   return HospitalList(
    //     resultCode: json['resultCode'],// as dynamic,
    //     resultMsg: json['resultMsg'],// as dynamic,
    //     totalCnt: json['totalCnt'],// as dynamic,
    //   );
    // }
  }
}

class JHospitalListUnit{
  final dynamic id;
  final dynamic hospNm;
  final dynamic addr;
  final dynamic telNo;
  final dynamic xPos;
  final dynamic yPos;
  final dynamic dist;
  final dynamic reviewCnt;
  final dynamic reviewScore;
  final List<JHospitalListUnitSubjectListUnit> subjectList;
  // final List<JHospitalListUnitSpecialListUnit> specialList;
  final List<dynamic> specialList;

  JHospitalListUnit({
    @required this.id,
    @required this.hospNm,
    @required this.addr,
    @required this.telNo,
    @required this.xPos,
    @required this.yPos,
    @required this.dist,
    @required this.reviewCnt,
    @required this.reviewScore,
    @required this.subjectList,
    @required this.specialList,
  });

  
  factory JHospitalListUnit.fromJson(Map<dynamic, dynamic> json){
    var subListObjsJson = json['subject_list'] as List;
    var spcListObjsJson = json['special_list'] as List;
    
    List<JHospitalListUnitSubjectListUnit> _subLists = [];
    List<dynamic> _spcLists = [];
    
    if(subListObjsJson != null)
      _subLists = subListObjsJson.map((listJson)=>JHospitalListUnitSubjectListUnit.fromJson(listJson)).toList();
    if(spcListObjsJson != null)
      // _spcLists = spcListObjsJson.map((listJson)=>JHospitalListUnitSpecialListUnit.fromJson(listJson)).toList();
      _spcLists = List.from(spcListObjsJson);

    return JHospitalListUnit(
      id: json['id'],// as dynamic,
      hospNm: json['hosp_nm'],// as dynamic,
      addr: json['addr'],// as dynamic,
      telNo: json['tel_no'],// as dynamic,
      xPos: json['x_pos'],// as dynamic,
      yPos: json['y_pos'],//as dynamic,
      dist: json['dist'],// as dynamic,
      reviewCnt: json['review_cnt'],// as dynamic,
      reviewScore: json['review_score'],// as dynamic,
      subjectList:_subLists,
      specialList:_spcLists
      //subjectList: json['subjectList'],// as List<HospitalListUnitSubjectList>,
      //specialList: json['specialList'],// as List<HospitalListUnitSpecialList>,
    );
  }
}

class JHospitalListUnitSubjectListUnit{
  dynamic subjectNm;
  dynamic proNm;

  JHospitalListUnitSubjectListUnit({
    @required this.subjectNm,
    @required this.proNm,
  });

  factory JHospitalListUnitSubjectListUnit.fromJson(Map<dynamic, dynamic> json){
    return JHospitalListUnitSubjectListUnit(
      subjectNm: json['subject_nm'],// as List<dynamic>,
      proNm: json['pro_nm'],// as List<dynamic>,
    );
  }

}

class JHospitalListUnitSpecialListUnit{
  dynamic specialNm;

  JHospitalListUnitSpecialListUnit({
    @required this.specialNm,
  });

  factory JHospitalListUnitSpecialListUnit.fromJson(Map<dynamic, dynamic> json){
    return JHospitalListUnitSpecialListUnit(
      specialNm: json['special_nm'],// as List<dynamic>,
    );
  }
}