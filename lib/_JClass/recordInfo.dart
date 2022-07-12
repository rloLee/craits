import 'dart:convert';

import 'package:flutter/cupertino.dart';

class JRecordRequest{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JRecordRequestType info;

  JRecordRequest({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });
  
  factory JRecordRequest.fromJson(Map<dynamic, dynamic> json){
    return JRecordRequest(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info : JRecordRequestType.fromJson(json['info'])
      );
  }
}

class JRecordRequestType{
  final dynamic recordType;

  JRecordRequestType({
    @required this.recordType,
  });

  factory JRecordRequestType.fromJson(Map<dynamic, dynamic> json){
    return JRecordRequestType(
      recordType: json['record_type'], 
    );
  } 
}

class JRecordInfoE{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JRecordInfoEInfo info;

  JRecordInfoE({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JRecordInfoE.fromJson(Map<dynamic, dynamic> json){
    return JRecordInfoE(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info : JRecordInfoEInfo.fromJson(json['info'])
      );
  }
}

class JRecordInfoP{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JRecordInfoPInfo info;
  
  JRecordInfoP({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });
  factory JRecordInfoP.fromJson(Map<dynamic, dynamic> json){
    return JRecordInfoP(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info : JRecordInfoPInfo.fromJson(json['info'])
      );
  }

  
}

class JRecordInfoR{
  final dynamic resultCode;
  final dynamic resultMsg;
  final JRecordInfoRInfo info;

  JRecordInfoR({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });
  
  factory JRecordInfoR.fromJson(Map<dynamic, dynamic> json){
    return JRecordInfoR(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      info : JRecordInfoRInfo.fromJson(json['info'])
      );
  }
}

class JRecordInfoPInfo{
  dynamic recordType;
  dynamic resultType;
  dynamic recordId;
  dynamic imageUrl;
  dynamic imageOriginal;
  dynamic hospitalId;
  dynamic hospitalName;
  dynamic hospitalAddr;
  dynamic hospitalTel;
  dynamic hospitalMatch;
  List<JRecordInfoHospitalListUnit> hospitalList;
  dynamic publishedDate;
  List<JRecordInfoMedicineListUnit> medicineList;

  JRecordInfoPInfo({
    @required this.recordType,
    @required this.resultType,
    @required this.recordId,
    @required this.imageUrl,
    @required this.imageOriginal,
    @required this.hospitalId,
    @required this.hospitalName,
    @required this.hospitalAddr,
    @required this.hospitalTel,
    @required this.hospitalMatch,
    @required this.hospitalList,
    @required this.publishedDate,
    @required this.medicineList,
  });
  
  factory JRecordInfoPInfo.fromJson(Map<dynamic, dynamic> json){
    var hospitalList = json['hospital_list'] as List;
    List<JRecordInfoHospitalListUnit> _hospitalLists = [];
    if(hospitalList != null)
      _hospitalLists = hospitalList.map((listJson) => JRecordInfoHospitalListUnit.fromJson(listJson)).toList();

    var medicineList = json['medicine_list'] as List;
    List<JRecordInfoMedicineListUnit> _medicineLists = [];
    if(medicineList != null)
    _medicineLists = medicineList.map((listJson) => JRecordInfoMedicineListUnit.fromJson(listJson)).toList();

    return JRecordInfoPInfo(
      recordType: json['record_type'], 
      resultType: json['result_type'], 
      recordId: json['record_id'],
      imageUrl: json['image_url'],		
      imageOriginal: json['image_original'],		
      hospitalId: json['hospital_id'],			
      hospitalName: json['hospital_name'],			
      hospitalAddr: json['hospital_addr'],			
      hospitalTel: json['hospital_tel'],		
      hospitalMatch: json['hospital_match'],		
      hospitalList: _hospitalLists,		
      publishedDate: json['published_date'],		
      medicineList: _medicineLists,
    );
  } 
  
  JRecordInfoPInfo clone() {
    final jsonResponse = json.decode(json.encode(this));
    return JRecordInfoPInfo.fromJson(jsonResponse as Map<dynamic, dynamic>);
  }

  Map<dynamic, dynamic> toJson()=>
  {
      'record_type' : recordType,
      'hospital_id' : hospitalId,
      'hospital_name' : hospitalName,
      'hospital_address' : hospitalAddr,
      'hospital_tel' : hospitalTel,
      //'hospital_match' : hospitalMatch,
      'published_date' : publishedDate,
      //'hospital_list' : hospitalList.map((e) => e.toJson()).toList(),
      'medicine_list': medicineList.map((e) => e.toJson()).toList()
  };
}

class JRecordInfoEInfo{
  final dynamic recordType;
  final dynamic resultTypes;
  final dynamic recordId;
  final dynamic imageUrl;
  final dynamic imageOriginal;
   dynamic patientName;
   dynamic pharmacistName;
   dynamic medicineDate;
   dynamic pharmacyId;
   dynamic pharmacyName;
   dynamic pharmacyAddr;
   dynamic pharmacyTel;
   dynamic pharmacyMatch;
  final List<JRecordInfoHospitalListUnit> pharmacyList;
   dynamic totalTakeDays;
   dynamic paymentTotal;
   dynamic paymentSelf;
   dynamic paymentInsurance;
   dynamic paymentNoneInsurance;
   List<JRecordInfoMedicineListUnit> medicineList;

  JRecordInfoEInfo({
    @required this.recordType,
    @required this.resultTypes,
    @required this.recordId,
    @required this.imageUrl,
    @required this.imageOriginal,
    @required this.patientName,
    @required this.pharmacistName,
    @required this.medicineDate,
    @required this.pharmacyId,
    @required this.pharmacyName,
    @required this.pharmacyAddr,
    @required this.pharmacyTel,
    @required this.pharmacyMatch,
    @required this.pharmacyList,
    @required this.totalTakeDays,
    @required this.paymentTotal,
    @required this.paymentSelf,
    @required this.paymentInsurance,
    @required this.paymentNoneInsurance,
    @required this.medicineList,
  });

  factory JRecordInfoEInfo.fromJson(Map<dynamic, dynamic> json){
    var pharmacyList = json['pharmacy_list'] as List;
    List<JRecordInfoHospitalListUnit> _pharmacyLists = [];
    if(pharmacyList!=null) _pharmacyLists = pharmacyList.map((listJson) => JRecordInfoHospitalListUnit.fromJson(listJson)).toList();

    var medicineList = json['medicine_list'] as List;
    List<JRecordInfoMedicineListUnit> _medicineLists = [];
    if(medicineList!=null) _medicineLists= medicineList.map((listJson) => JRecordInfoMedicineListUnit.fromJson(listJson)).toList();

    return JRecordInfoEInfo(
      recordType: json['record_type'], 
      resultTypes: json['result_types'], 
      recordId: json['record_id'],
      imageUrl: json['image_url'],		
      imageOriginal: json['image_original'],		
      patientName: json['patient_name'],			
      pharmacistName: json['pharmacist_name'],			
      medicineDate: json['medicine_date'],			
      pharmacyId: json['pharmacy_id'],		
      pharmacyName: json['pharmacy_name'],		
      pharmacyAddr: json['pharmacy_addr'],		
      pharmacyTel: json['pharmacy_tel'],		
      pharmacyMatch: json['pharmacy_match'],		
      pharmacyList: _pharmacyLists,		
      totalTakeDays: json['total_take_days'],		
      paymentTotal: json['payment_total'],		
      paymentSelf: json['payment_self'],		
      paymentInsurance: json['payment_insurance'],		
      paymentNoneInsurance: json['payment_none_insurance'],		
      medicineList: _medicineLists,
    );
  }

  JRecordInfoEInfo clone() {
    final jsonResponse = json.decode(json.encode(this));
    return JRecordInfoEInfo.fromJson(jsonResponse as Map<dynamic, dynamic>);
  }

  Map<dynamic, dynamic> toJson()=>
  {
      'record_type' : recordType,
      'patient_name' : patientName,
      'pharmacist_name' : pharmacistName,
      'medicine_date' : medicineDate,
      'pharmacy_id' : pharmacyId,
      'pharmacy_name' : pharmacyName,
      'pharmacy_address' : pharmacyAddr,
      'pharmacy_tel' : pharmacyTel,
      //'pharmacy_match' : pharmacyMatch,
      //'pharmacy_list' : pharmacyList.map((e) => e.toJson()).toList(),
      'total_take_days' : totalTakeDays,
      'payment_total' : paymentTotal,
      'payment_self' : paymentSelf,
      'payment_insurance' : paymentInsurance,
      'payment_none_insurance' : paymentNoneInsurance,
      'medicine_list': medicineList.map((e) => e.toJson()).toList()
  };
}


class PaymentType{
  dynamic typeName;
  int selfPart;
  int corpPart;
  int selfAll;
  int select;
  int selectEtc;
}

class JRecordInfoRInfo{
  String recordType;
  dynamic recordId;
  String imageUrl;
  String imageOriginal;
  dynamic hospitalId;
  String hospitalName;
  String hospitalAddr;
  dynamic hospitalTel;
  dynamic hospitalMatch;
  List<JRecordInfoHospitalListUnit> hospitalList;
  dynamic publishedDate;
  List<JRecordInfoPaymentListUnit> paymentList;
  List<PaymentType> pamentType;

  JRecordInfoRInfo({
    @required this.recordType,
    @required this.recordId,
    @required this.imageUrl,
    @required this.imageOriginal,
    @required this.hospitalId,
    @required this.hospitalName,
    @required this.hospitalAddr,
    @required this.hospitalTel,
    @required this.hospitalMatch,
    @required this.hospitalList,
    @required this.publishedDate,
    @required this.paymentList,
  });

  factory JRecordInfoRInfo.fromJson(Map<dynamic, dynamic> json){
    var hospitalList = json['hospital_list'] as List;
    List<JRecordInfoHospitalListUnit> _hospitalLists = [];
    if(hospitalList != null)
      _hospitalLists = hospitalList.map((listJson) => JRecordInfoHospitalListUnit.fromJson(listJson)).toList();
    
    var paymentList = json['payment_list'] as List;
    List<JRecordInfoPaymentListUnit> _paymentLists = [];
    if(paymentList != null)
       _paymentLists = paymentList.map((listJson) => JRecordInfoPaymentListUnit.fromJson(listJson)).toList();

    return JRecordInfoRInfo(
      recordType: json['record_type'], 
      recordId: json['record_id'],
      imageUrl: json['image_url'],		
      imageOriginal: json['image_original'],		
      hospitalId: json['hospital_id'],			
      hospitalName: json['hospital_name'],			
      hospitalAddr: json['hospital_addr'],			
      hospitalTel: json['hospital_tel'],		
      hospitalMatch: json['hospital_match'],		
      hospitalList: _hospitalLists,		
      publishedDate: json['published_date'],		
      paymentList: _paymentLists,
    );
  }
  
  JRecordInfoRInfo clone() {
    final jsonResponse = json.decode(json.encode(this));
    return JRecordInfoRInfo.fromJson(jsonResponse as Map<dynamic, dynamic>);
  }

  Map<dynamic, dynamic> toJson()=>
  {
    'record_type' : recordType,
    'hospital_id' : hospitalId,
    'hospital_name' : hospitalName,
    'hospital_address' : hospitalAddr,
    'hospital_tel' : hospitalTel,
    //'hospital_match' : hospitalMatch,
    //'hospital_list' : hospitalList.map((e) => e.toJson()).toList(),
    'published_date' : publishedDate,
    'payment_list': paymentList.map((e) => e.toJson()).toList()
  };
}

class JRecordInfoPaymentListUnit{
   dynamic seq;
   dynamic type;
   dynamic description;
   dynamic value;

  JRecordInfoPaymentListUnit({
    @required this.seq,
    @required this.type,
    @required this.description,
    @required this.value,
  });

  factory JRecordInfoPaymentListUnit.fromJson(Map<dynamic, dynamic> json){
    return JRecordInfoPaymentListUnit(
      seq: json['seq'],
      type: json['type'],
      description: json['description'],
      value: json['value'],
    );
  }
  
  Map<dynamic,dynamic> toJson() => {
    'seq': seq,
    'type': type,
    'description': description,
    'value': value,
  };

  List<dynamic> getValueList(){
    var paymentList = value.split(',');
    return paymentList;
  }

  dynamic getValueSelf(){
    if(getValueList().length > 0)
      return getValueList()[0];
    else
      return '';
  }
  dynamic getValueCorp(){
    if(getValueList().length > 1)
      return getValueList()[1];
    else
      return '';
  }
  dynamic getValueSelfAll(){
    if(getValueList().length > 2)
      return getValueList()[2];
    else
      return '';
  }
  dynamic getValueSelect(){
    if(getValueList().length > 3)
      return getValueList()[3];
    else
      return '';
  }
  dynamic getValueExcSelect(){
    if(getValueList().length > 4)
      return getValueList()[4];
    else
      return '';
  }
  setValueSelf(dynamic sValue){
    dynamic rtnValue = sValue;
    rtnValue += ',' + getValueCorp();
    rtnValue += ',' + getValueSelfAll();
    rtnValue += ',' + getValueSelect();
    rtnValue += ',' + getValueExcSelect();
    value = rtnValue;
  }
   setValueCorp(dynamic sValue){
    dynamic rtnValue = '';
    rtnValue += getValueSelf();
    rtnValue += ',' + sValue;
    rtnValue += ',' + getValueSelfAll();
    rtnValue += ',' + getValueSelect();
    rtnValue += ',' + getValueExcSelect();
    value = rtnValue;
  }
   setValueSelfAll(dynamic sValue){
    dynamic rtnValue = '';
    rtnValue += getValueSelf();
    rtnValue += ',' + getValueCorp();
    rtnValue += ',' + sValue;
    rtnValue += ',' + getValueSelect();
    rtnValue += ',' + getValueExcSelect();
    value = rtnValue;
  }
   setValueSelect(dynamic sValue){
    dynamic rtnValue = '';
    rtnValue += getValueSelf();
    rtnValue += ',' + getValueCorp();
    rtnValue += ',' + getValueSelfAll();
    rtnValue += ',' + sValue;
    rtnValue += ',' + getValueExcSelect();
    value = rtnValue;
  }
   setValueExcSelect(dynamic sValue){
    dynamic rtnValue = '';
    rtnValue += getValueSelf();
    rtnValue += ',' + getValueCorp();
    rtnValue += ',' + getValueSelfAll();
    rtnValue += ',' + getValueSelect();
    rtnValue += ',' + sValue;
    value = rtnValue;
  }
}

class JRecordInfoHospitalListUnit{
  final dynamic id;
  final dynamic name;
  final dynamic addr;
  final dynamic tel;
  final dynamic similar;

  JRecordInfoHospitalListUnit({
    @required this.id,
    @required this.name,
    @required this.addr,
    @required this.tel,
    @required this.similar,
  });

  factory JRecordInfoHospitalListUnit.fromJson(Map<dynamic, dynamic> json){
    return JRecordInfoHospitalListUnit(
      id: json['id'],
      name: json['name'],
      addr: json['addr'],
      tel: json['tel'],
      similar: json['similar'],
      );
  }
  
  Map<dynamic,dynamic> toJson() => {
    'id': id,
    'name': name,
    'addr': addr,
    'tel': tel,
    'similar': similar,
  };
}

class JRecordInfoMedicineListUnit{
   dynamic seq;
   dynamic id;
   dynamic name;
   dynamic doseSize;    //투약량
   dynamic doseNumber;  //투약횟수
   dynamic doseDays;    //투약일수
   dynamic match;
   dynamic resultType;
   dynamic resultDurs;
  final List<JRecordInfoMedicineSimilarListUnit> similarList;

  JRecordInfoMedicineListUnit({
    this.seq,
    @required this.id,
    @required this.name,
    @required this.doseSize,
    @required this.doseNumber,
    @required this.doseDays,
    @required this.match,
    this.resultType,
    this.resultDurs,
    this.similarList,
  });

  factory JRecordInfoMedicineListUnit.fromJson(Map<dynamic, dynamic> json){
    var list = json['similar_list'] as List;
    List<JRecordInfoMedicineSimilarListUnit> _lists = [];
    if (list!=null) _lists = list.map((listJson)=> JRecordInfoMedicineSimilarListUnit.fromJson(listJson)).toList();

    return JRecordInfoMedicineListUnit(
      seq: json['seq'], 
      id: json['id'], 
      name: json['name'],
      doseSize: json['dose_size'],	
      doseNumber: json['dose_number'],	
      doseDays: json['dose_days'],	
      match: json['match'],	
      resultType: json['result_type'],	
      resultDurs: json['result_durs'],	
      similarList: _lists,	
    );
  }

  Map<dynamic,dynamic> toJson() => {
    'seq': seq,
    'id': id,
    'name': name,
    'dose_size': doseSize,
    'dose_number': doseNumber,
    'dose_days': doseDays,
    //'match':match,
    //'similar_list':similarList.map((e) => e.toJson()).toList(),
  };
}

class JRecordInfoMedicineSimilarListUnit{
  final dynamic id;
  final dynamic name;
  final dynamic similar;

  JRecordInfoMedicineSimilarListUnit({
    @required this.id,
    @required this.name,
    @required this.similar,
  });

  factory JRecordInfoMedicineSimilarListUnit.fromJson(Map<dynamic, dynamic> json){
    return JRecordInfoMedicineSimilarListUnit(
      id: json['id'],
      name: json['name'],
      similar: json['similar']
      );
  }

  Map<dynamic,dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}