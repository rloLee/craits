import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

// http://localhost:8081/Cratis/V1/Pharmacy/PharmacyDetail.json			

class JPharmacyDetail{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JPharmacyDetailInfo info;
   
  JPharmacyDetail({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JPharmacyDetail.fromJson(Map<dynamic, dynamic> json){
    // if(json['list'] != null){
      return JPharmacyDetail(
        resultCode: json['resultCode'],// as dynamic,
        resultMsg: json['resultMsg'],// as dynamic,
        info:JPharmacyDetailInfo.fromJson(json['info'])
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

class JPharmacyDetailInfo{
  final dynamic id;
  final dynamic pharmacyNm;
  final dynamic addr;
  final dynamic clNm;
  final dynamic telNo;
  final dynamic xPos;
  final dynamic yPos;
  final dynamic dist;
  final dynamic hospUrl;
  final dynamic reviewCnt;
  final dynamic reviewScore;
  final dynamic drTotCnt;
  final dynamic gdrCnt;
  final dynamic intnCnt;
  final dynamic resdntCnt;
  final dynamic sdrCnt;
  final List<JPharmacyDetailInfoFieldUnit> trmtList;
  final List<JPharmacyDetailInfoFieldUnit> noTrmtList;
  final List<JPharmacyDetailInfoFieldUnit> lunchList;
  final List<JPharmacyDetailInfoFieldUnit> revList;
  final List<JPharmacyDetailInfoFieldUnit> plcList;
  final List<JPharmacyDetailInfoFieldUnit> parkList;
  final List<JPharmacyDetailInfoFieldUnit> nurseList;
  final List<JPharmacyDetailInfoTrafficUnit> trafficList;
  final dynamic dataOrigin;
  final dynamic dataDate;


  JPharmacyDetailInfo({
    @required this.id,
    @required this.pharmacyNm,
    @required this.addr,
    @required this.clNm,
    @required this.telNo,
    @required this.xPos,
    @required this.yPos,
    @required this.dist,
    @required this.hospUrl,
    @required this.reviewCnt,
    @required this.reviewScore,
    @required this.drTotCnt,
    @required this.gdrCnt,
    @required this.intnCnt,
    @required this.resdntCnt,
    @required this.sdrCnt,
    @required this.trmtList,
    @required this.noTrmtList,
    @required this.lunchList,
    @required this.revList,
    @required this.plcList,
    @required this.parkList,
    @required this.nurseList,
    @required this.trafficList,
    @required this.dataOrigin,
    @required this.dataDate,
  });

  
  factory JPharmacyDetailInfo.fromJson(Map<dynamic, dynamic> json){
    var trmtListJson = json['trmt_list'] as List;
    var noTrmtListJson = json['no_trmt_list'] as List;
    var lunchListJson = json['lunch_list'] as List;
    var revListJson = json['rev_list'] as List;
    var plcListJson = json['plc_list'] as List;
    var parkListJson = json['park_list'] as List;
    var nurseListJson = json['nurse_list'] as List;

    List<JPharmacyDetailInfoFieldUnit> _trmtLists = [];
    List<JPharmacyDetailInfoFieldUnit> _noTrmtLists = [];
    List<JPharmacyDetailInfoFieldUnit> _lunchLists = [];
    List<JPharmacyDetailInfoFieldUnit> _revLists = [];
    List<JPharmacyDetailInfoFieldUnit> _plcLists = [];
    List<JPharmacyDetailInfoFieldUnit> _parkLists = [];
    List<JPharmacyDetailInfoFieldUnit> _nurseLists = [];
    
    if(trmtListJson != null)
      _trmtLists = trmtListJson.map((listJson)=>JPharmacyDetailInfoFieldUnit.fromJson(listJson)).toList();
    if(noTrmtListJson != null)
      _noTrmtLists = noTrmtListJson.map((listJson)=>JPharmacyDetailInfoFieldUnit.fromJson(listJson)).toList();
    if(lunchListJson != null)
      _lunchLists = lunchListJson.map((listJson)=>JPharmacyDetailInfoFieldUnit.fromJson(listJson)).toList();
    if(revListJson != null)
      _revLists = revListJson.map((listJson)=>JPharmacyDetailInfoFieldUnit.fromJson(listJson)).toList();
    if(plcListJson != null)
      _plcLists = plcListJson.map((listJson)=>JPharmacyDetailInfoFieldUnit.fromJson(listJson)).toList();
    if(parkListJson != null)
      _parkLists = parkListJson.map((listJson)=>JPharmacyDetailInfoFieldUnit.fromJson(listJson)).toList();
    if(nurseListJson != null)
      _nurseLists = nurseListJson.map((listJson)=>JPharmacyDetailInfoFieldUnit.fromJson(listJson)).toList();

    var trafficListJson = json['traffic_list'] as List;

    List<JPharmacyDetailInfoTrafficUnit> _trafficLists = [];
    if(trafficListJson != null)
      _trafficLists = trafficListJson.map((listJson)=>JPharmacyDetailInfoTrafficUnit.fromJson(listJson)).toList();

    return JPharmacyDetailInfo(
      id: json['id'],// as dynamic,
      pharmacyNm: json['pharmacy_nm'],// as dynamic,
      addr: json['addr'],// as dynamic,
      clNm: json['cl_nm'],// as dynamic,
      telNo: json['tel_no'],// as dynamic,
      xPos: json['x_pos'],// as dynamic,
      yPos: json['y_pos'],//as dynamic,
      dist: json['dist'],// as dynamic,
      hospUrl: json['hosp_url'],// as dynamic,
      reviewCnt: json['review_cnt'],// as dynamic,
      reviewScore: json['review_score'],// as dynamic,
      drTotCnt: json['drTot_cnt'],// as dynamic,
      gdrCnt: json['gdr_cnt'],// as dynamic,
      intnCnt: json['intn_cnt'],// as dynamic,
      resdntCnt: json['resdnt_cnt'],// as dynamic,
      sdrCnt: json['sdr_cnt'],// as dynamic,
      trmtList:_trmtLists,
      noTrmtList:_noTrmtLists,
      lunchList:_lunchLists,
      revList:_revLists,
      plcList:_plcLists,
      parkList:_parkLists,
      nurseList:_nurseLists,
      trafficList:_trafficLists,
      dataOrigin: json['data_origin'],// as dynamic,
      dataDate: json['data_date'],// as dynamic,
    );
  }
}

class JPharmacyDetailInfoFieldUnit{
  dynamic fieldNm;
  dynamic fieldDesc;
  dynamic fieldValue;

  JPharmacyDetailInfoFieldUnit({
    @required this.fieldNm,
    @required this.fieldDesc,
    @required this.fieldValue,
  });

  factory JPharmacyDetailInfoFieldUnit.fromJson(Map<dynamic, dynamic> json){
    return JPharmacyDetailInfoFieldUnit(
      fieldNm: json['field_nm'],// as List<dynamic>,
      fieldDesc: json['field_desc'],// as List<dynamic>,
      fieldValue: json['field_value'],// as List<dynamic>,
    );
  }
}

class JPharmacyDetailInfoTrafficUnit{
  dynamic fieldNm;
  dynamic lineNo;
  dynamic arivPlc;

  JPharmacyDetailInfoTrafficUnit({
    @required this.fieldNm,
    @required this.lineNo,
    @required this.arivPlc,
  });

  factory JPharmacyDetailInfoTrafficUnit.fromJson(Map<dynamic, dynamic> json){
    return JPharmacyDetailInfoTrafficUnit(
      fieldNm: json['field_nm'],// as List<dynamic>,
      lineNo: json['line_no'],// as List<dynamic>,
      arivPlc: json['ariv_plc'],// as List<dynamic>,
    );
  }
}