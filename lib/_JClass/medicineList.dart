import 'package:flutter/cupertino.dart';

class JMedicineList{
  final String resultCode;
  final String resultMsg;
  final JMedicineListInfo info;

  JMedicineList({
    @required this.resultCode,
    @required this.resultMsg,
    @required this.info,
  });

  factory JMedicineList.fromJson(Map<String, dynamic> json){
    return JMedicineList(
      resultCode: json['resultCode'], 
      resultMsg: json['resultMsg'], 
      info: JMedicineListInfo.fromJson(json['info']),
    );
  }
}

class JMedicineListInfo{
  final dynamic totalCnt;
  final List<JMedicineListInfoListUnit> list;

  JMedicineListInfo({
    @required this.totalCnt,
    @required this.list,
  });

  factory JMedicineListInfo.fromJson(Map<dynamic, dynamic> json){
    var listJson = json['list'] as List;
    List<JMedicineListInfoListUnit> _lists = [];
    if(listJson!=null)
      _lists = listJson.map((listJson) => JMedicineListInfoListUnit.fromJson(listJson)).toList();
    
    return JMedicineListInfo(
      totalCnt: json['total_cnt'], 
      list: _lists,
    );
  }
}

class JMedicineListInfoListUnit{
  final String id;
  final String medicineNm;
  final String entpNm;
  final String avgPrice;
  final String imageUrl;
  final String reviewCnt;
  final String reviewScore;
  final String etcOtcCd;
  final String classNm;

  JMedicineListInfoListUnit({
    @required this.id,
    @required this.medicineNm,
    @required this.entpNm,
    @required this.avgPrice,
    @required this.imageUrl,
    @required this.reviewCnt,
    @required this.reviewScore,
    @required this.etcOtcCd,
    @required this.classNm,
  });

  factory JMedicineListInfoListUnit.fromJson(Map<String, dynamic> json){

    return JMedicineListInfoListUnit(
      id: json['id'], 
      medicineNm: json['medicine_nm'], 
      entpNm: json['entp_nm'], 
      avgPrice: json['avg_price'], 
      imageUrl: json['image_url'], 
      reviewCnt: json['review_cnt'], 
      reviewScore: json['review_score'],
      etcOtcCd: json['etc_otc_cd'],
      classNm: json['class_nm'],
    );
  }
}

// class JMedicineListInfoListUnitTypeUnit{
//   final String typeNm;

//   JMedicineListInfoListUnitTypeUnit({
//     @required this.typeNm,
//   });

//   factory JMedicineListInfoListUnitTypeUnit.fromJson(Map<String, dynamic> json){
//     return JMedicineListInfoListUnitTypeUnit(
//       typeNm: json['type_nm']
//     );
//   }
// }