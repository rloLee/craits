import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

//http://localhost:8081/Cratis/V1/Hospital/HospitalDetail.json			

class JHospitalDetail{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JHospitalDetailInfo info;
   
  JHospitalDetail({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JHospitalDetail.fromJson(Map<dynamic, dynamic> json){
      return JHospitalDetail(
        resultCode: json['resultCode'],// as dynamic,
        resultMsg: json['resultMsg'],// as dynamic,
        info:JHospitalDetailInfo.fromJson(json['info'])
      );
  }
}

class JHospitalDetailInfo{
  final dynamic id;
  final dynamic hospNm;
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
  final dynamic mdeptGdrCnt;    //의과일반의 인원수
  final dynamic mdeptIntnCnt;   //의과인턴 인원수
  final dynamic mdeptResdntCnt; //의과레지던트 인원수
  final dynamic mdeptSdrCnt;    //의과전문의 인원수
  final dynamic detyGdrCnt;     //치과일반의 인원수
  final dynamic detyIntnCnt;    //치과인턴 인원수
  final dynamic detyResdntCnt;  //치과레지던트 인원수
  final dynamic detySdrCnt;     //치과전문의 인원수
  final dynamic cmdcGdrCnt;     //한방일반의 인원수
  final dynamic cmdcIntnCnt;    //한방인턴 인원수
  final dynamic cmdcResdntCnt;  //한방레지던트 인원수
  final dynamic cmdcSdrCnt;     //한방전문의 인원수
  final dynamic intnCnt;
  final dynamic resdntCnt;
  final dynamic sdrCnt;
  final List<JHospitalDetailInfoFieldUnit> facilityList;
  final List<JHospitalDetailInfoFieldUnit> subjectList;
   List<JHospitalDetailInfoFieldUnit> trmtList;
  final List<JHospitalDetailInfoFieldUnit> noTrmtList;
  final List<JHospitalDetailInfoFieldUnit> lunchList;
  final List<JHospitalDetailInfoFieldUnit> revList;
  final List<JHospitalDetailInfoFieldUnit> emyList;
  final List<JHospitalDetailInfoFieldUnit> specialList;
  final List<JHospitalDetailInfoFieldUnit> equipList;
  final List<JHospitalDetailInfoFieldUnit> plcList;
  final List<JHospitalDetailInfoFieldUnit> parkList;
  final List<JHospitalDetailInfoFieldUnit> nurseList;
  final List<JHospitalDetailInfoCookUnit> cookList;
  final List<JHospitalDetailInfoTrafficUnit> trafficList;
  final dynamic dataOrigin;
  final dynamic dataDate;


  JHospitalDetailInfo({
    @required this.id,
    @required this.hospNm,
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
    @required this.mdeptGdrCnt,
    @required this.mdeptIntnCnt,
    @required this.mdeptResdntCnt,
    @required this.mdeptSdrCnt,
    @required this.detyGdrCnt,
    @required this.detyIntnCnt,
    @required this.detyResdntCnt,
    @required this.detySdrCnt,
    @required this.cmdcGdrCnt,
    @required this.cmdcIntnCnt,
    @required this.cmdcResdntCnt,
    @required this.cmdcSdrCnt,
    @required this.intnCnt,
    @required this.resdntCnt,
    @required this.sdrCnt,
    @required this.facilityList,
    @required this.subjectList,
    @required this.trmtList,
    @required this.noTrmtList,
    @required this.lunchList,
    @required this.revList,
    @required this.emyList,
    @required this.specialList,
    @required this.equipList,
    @required this.plcList,
    @required this.parkList,
    @required this.nurseList,
    @required this.cookList,
    @required this.trafficList,
    @required this.dataOrigin,
    @required this.dataDate,
  });

  
  factory JHospitalDetailInfo.fromJson(Map<dynamic, dynamic> json){
    
    var facilityListJson = json['facility_list'] as List;
    var subjectListJson = json['subject_list'] as List;
    var trmtListJson = json['trmt_list'] as List;
    var noTrmtListJson = json['no_trmt_list'] as List;
    var lunchListJson = json['lunch_list'] as List;
    var rcvListJson = json['rcv_list'] as List;
    var emyListJson = json['emy_list'] as List;
    var specialListJson = json['special_list'] as List;
    var equipListJson = json['equip_list'] as List;
    var plcListJson = json['plc_list'] as List;
    var parkListJson = json['park_list'] as List;
    var nurseListJson = json['nurse_list'] as List;

    List<JHospitalDetailInfoFieldUnit> _facilityLists = [];
    if(facilityListJson != null)
      _facilityLists = facilityListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _subjectLists = [];
    if(subjectListJson != null)
      _subjectLists = subjectListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _trmtLists = [];
    if(trmtListJson != null)
      _trmtLists = trmtListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _noTrmtLists = [];
    if(noTrmtListJson != null)
      _noTrmtLists = noTrmtListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _lunchLists = [];
    if(lunchListJson != null)
      _lunchLists = lunchListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _rcvLists = [];
    if(rcvListJson != null)
      _rcvLists = rcvListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _emyLists = [];
    if(emyListJson != null)
      _emyLists = emyListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _specialLists = [];
    if(specialListJson != null)
      _specialLists = specialListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _equipLists = [];
    if(equipListJson != null)
      _equipLists = equipListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _plcLists = [];
    if(plcListJson != null)
      _plcLists = plcListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _parkLists = [];
    if(parkListJson != null)
      _parkLists = parkListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();
    List<JHospitalDetailInfoFieldUnit> _nurseLists = [];
    if(nurseListJson != null)
      _nurseLists = nurseListJson.map((listJson)=>JHospitalDetailInfoFieldUnit.fromJson(listJson)).toList();

    var cookListJson = json['cook_list'] as List;
    List<JHospitalDetailInfoCookUnit> _cookLists = [];
    if(cookListJson!= null)
      _cookLists = cookListJson.map((listJson)=>JHospitalDetailInfoCookUnit.fromJson(listJson)).toList();

    var trafficListJson = json['traffic_list'] as List;
    List<JHospitalDetailInfoTrafficUnit> _trafficLists = [];
    if(trafficListJson!= null)
    _trafficLists = trafficListJson.map((listJson)=>JHospitalDetailInfoTrafficUnit.fromJson(listJson)).toList();

    return JHospitalDetailInfo(
      id: json['id'],// as dynamic,
      hospNm: json['hosp_nm'],// as dynamic,
      addr: json['addr'],// as dynamic,
      clNm: json['cl_nm'],// as dynamic,
      telNo: json['tel_no'],// as dynamic,
      xPos: json['x_pos'],// as dynamic,
      yPos: json['y_pos'],//as dynamic,
      dist: json['dist'],// as dynamic,
      hospUrl: json['hosp_url'],// as dynamic,
      reviewCnt: json['review_cnt'],// as dynamic,
      reviewScore: json['review_score'],// as dynamic,
      drTotCnt: json['dr_tot_cnt'],// as dynamic,
      mdeptGdrCnt: json['mdept_gdr_cnt'],// as dynamic,	
      mdeptIntnCnt : json['mdept_intn_cnt'],
      mdeptResdntCnt : json['mdept_resdnt_cnt'],
      mdeptSdrCnt : json['mdept_sdr_cnt'],
      detyGdrCnt : json['dety_gdr_cnt'],
      detyIntnCnt : json['dety_intn_cnt'],
      detyResdntCnt : json['dety_resdnt_cnt'],
      detySdrCnt : json['dety_sdr_cnt'],
      cmdcGdrCnt : json['cmdc_gdr_cnt'],
      cmdcIntnCnt : json['cmdc_intn_cnt'],
      cmdcResdntCnt : json['cmdc_resdnt_cnt'],
      cmdcSdrCnt : json['cmdc_sdr_cnt'],
      intnCnt: json['intn_cnt'],// as dynamic,
      resdntCnt: json['resdnt_cnt'],// as dynamic,
      sdrCnt: json['sdr_cnt'],// as dynamic,
      facilityList:_facilityLists,
      subjectList:_subjectLists,
      trmtList:_trmtLists,
      noTrmtList:_noTrmtLists,
      lunchList:_lunchLists,
      revList:_rcvLists,
      emyList:_emyLists,
      specialList:_specialLists,
      equipList:_equipLists,
      plcList:_plcLists,
      parkList:_parkLists,
      nurseList:_nurseLists,
      cookList:_cookLists,
      trafficList:_trafficLists,
      dataOrigin: json['data_origin'],// as dynamic,
      dataDate: json['data_date'],// as dynamic,
    );
  }
}

class JHospitalDetailInfoFieldUnit{
  dynamic fieldNm;
  dynamic fieldDesc;
  dynamic fieldValue;
  dynamic fieldOrd;

  JHospitalDetailInfoFieldUnit({
    @required this.fieldNm,
    @required this.fieldDesc,
    @required this.fieldValue,
    @required this.fieldOrd,
  });

  factory JHospitalDetailInfoFieldUnit.fromJson(Map<dynamic, dynamic> json){
    return JHospitalDetailInfoFieldUnit(
      fieldNm: json['field_nm'],// as List<dynamic>,
      fieldDesc: json['field_desc'],// as List<dynamic>,
      fieldValue: json['field_value'],// as List<dynamic>,
      fieldOrd: json['field_ord'],// as List<dynamic>,
    );
  }
}

class JHospitalDetailInfoCookUnit{
  dynamic fieldNm;
  dynamic fieldDesc;
  dynamic fieldCnt;
  dynamic gnmAddcYn;
  dynamic trmealGrd;

  JHospitalDetailInfoCookUnit({
    @required this.fieldNm,
    @required this.fieldDesc,
    @required this.fieldCnt,
    @required this.gnmAddcYn,
    @required this.trmealGrd,
  });

  factory JHospitalDetailInfoCookUnit.fromJson(Map<dynamic, dynamic> json){
    return JHospitalDetailInfoCookUnit(
      fieldNm: json['field_nm'],// as List<dynamic>,
      fieldDesc: json['field_desc'],// as List<dynamic>,
      fieldCnt: json['field_cnt'],// as List<dynamic>,
      gnmAddcYn: json['gnm_addc_yn'],// as List<dynamic>,
      trmealGrd: json['trmeal_grd'],// as List<dynamic>,
    );
  }
}

class JHospitalDetailInfoTrafficUnit{
  dynamic fieldNm;
  dynamic lineNo;
  dynamic arivPlc;

  JHospitalDetailInfoTrafficUnit({
    @required this.fieldNm,
    @required this.lineNo,
    @required this.arivPlc,
  });

  factory JHospitalDetailInfoTrafficUnit.fromJson(Map<dynamic, dynamic> json){
    return JHospitalDetailInfoTrafficUnit(
      fieldNm: json['field_nm'],// as List<dynamic>,
      lineNo: json['line_no'],// as List<dynamic>,
      arivPlc: json['ariv_plc'],// as List<dynamic>,
    );
  }
}