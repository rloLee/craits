import 'package:craits/_JClass/hospitalList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'hospitalDetail.dart';


//진료기록 낱개
class HospitalUnit extends StatelessWidget {
  final SvgPicture star0 = SvgPicture.asset('assets/Star_x.svg', height: 18,);
  final SvgPicture starhalf = SvgPicture.asset('assets/Star_half.svg', height: 18,);
  final SvgPicture star1 = SvgPicture.asset('assets/Star_o.svg', height: 18,);
  final BuildContext context;
  
  final JHospitalListUnit hospitalListUnit;
  String sName = ''; 
  String sAddress = '';
  String sTel = '';
  double dScore = 0.0;
  double dDistance = 0;
  int iCntReview = 0;
  double dCurLat;
  double dCurLong;
  String strSpecialList = '';

  HospitalUnit(this.context, this.hospitalListUnit, this.dCurLat, this.dCurLong)
 {
   sName = hospitalListUnit.hospNm ?? '';
   sAddress = hospitalListUnit.addr ?? ''; 
   sTel = hospitalListUnit.telNo ?? '';
   dScore = hospitalListUnit.reviewScore != null ? double.tryParse(hospitalListUnit.reviewScore.toString()) : 0.0;
   dDistance = hospitalListUnit.dist != null ? double.tryParse(hospitalListUnit.dist.toString()) : 0.0;
   iCntReview = hospitalListUnit.reviewCnt!= null ? int.tryParse(hospitalListUnit.reviewCnt.toString()) : 0;
 } 

  @override
  Widget build(BuildContext context) {
    for(int i = 0; i < hospitalListUnit.specialList.length; i++)
      if(strSpecialList.length > 0)
        strSpecialList += ' · ${hospitalListUnit.specialList[i].toString()}';
      else
        strSpecialList = hospitalListUnit.specialList[i].toString();

    return Card(
      elevation: 0.0,
      child: InkWell(
        onTap: (){
          Navigator.push(context,MaterialPageRoute(builder: (context) => 
            HospitalDetail(
              hospitalName: hospitalListUnit.hospNm.toString(),
              searchId: hospitalListUnit.id.toString(),
              searchPosLat: dCurLat.toString(),
              searchPosLng: dCurLong.toString(),)
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6), width: 2))
          ),
          constraints: BoxConstraints(
            minHeight: 240
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row( 
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for(JHospitalListUnitSubjectListUnit list in hospitalListUnit.subjectList)
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                        child: Text('${list.subjectNm}', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), ),
                        decoration: ShapeDecoration( 
                          color:Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                          )
                        )
                      ),
                      if(list.proNm.length > 0)
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                        child: Text('${list.proNm}', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), ),
                        decoration: ShapeDecoration( 
                          color:Color(0xFFEC7676),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                          )
                        )
                      ),
                    ],
                  ),
                ],
              ),
              Text(sName, style: Theme.of(context).textTheme.headline1, ),
              Row(
                children: [
                  (dScore >= 0.5)? (dScore >= 1? star1 : starhalf) :star0,
                  (dScore >= 1.5)? (dScore >= 2? star1 : starhalf) :star0,
                  (dScore >= 2.5)? (dScore >= 3? star1 : starhalf) :star0,
                  (dScore >= 3.5)? (dScore >= 4? star1 : starhalf) :star0,
                  (dScore >= 4.5)? (dScore >= 5? star1 : starhalf) :star0,
                  Text(' $dScore ', style: Theme.of(context).textTheme.headline3 ,),
                  Text('($iCntReview)', style: Theme.of(context).textTheme.subtitle2,)
                ],
              ),
              Row(
                children: [
                  SvgPicture.asset('assets/location.svg',),
                  SizedBox(width: 5,),
                  if(dDistance < 1)
                    Text(
                      '${(double.parse(dDistance.toStringAsFixed(3))*1000)} m',
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  else
                    Text(
                      '${dDistance.toStringAsFixed(1)}km',
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                ],
              ),
              Text(
                sAddress,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              Row(
                children: [
                  SvgPicture.asset('assets/tel.svg'),
                  SizedBox(width: 5,),
                  Text(
                    sTel,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(child: Text(strSpecialList,  style: Theme.of(context).textTheme.subtitle1,)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}