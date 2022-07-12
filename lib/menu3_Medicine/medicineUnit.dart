import 'package:craits/_JClass/medicineList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'medicineDetail.dart';

//진료기록 낱개
class MedicineUnit extends StatelessWidget {
  
  final SvgPicture star0 = SvgPicture.asset('assets/Star_x.svg', height: 18,);
  final SvgPicture starhalf = SvgPicture.asset('assets/Star_half.svg', height: 18,);
  final SvgPicture star1 = SvgPicture.asset('assets/Star_o.svg', height: 18,);
  final BuildContext context;

  final JMedicineListInfoListUnit medicineListUnit;
  String sName = ' '; 
  String sCompany = '';
  // final double dScore = 0.0;
  String sPrice = '0';
  // final int iCntReview = 0;
  String sImageUrl ;

  MedicineUnit(this.context, this.medicineListUnit){
    sName =  medicineListUnit.medicineNm;
    sCompany = medicineListUnit.entpNm;
     sPrice = medicineListUnit.avgPrice;
     sImageUrl = medicineListUnit.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.0,
      child: InkWell(
        onTap: (){
          Navigator.push(context,MaterialPageRoute(builder: (context) => 
            MedicineDetail(
              medicineNm: medicineListUnit.medicineNm,
              searchId: medicineListUnit.id,)
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6), width: 2))
          ),
          constraints: BoxConstraints(
            minHeight: 150,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sName, style: Theme.of(context).textTheme.headline1, maxLines: 3, overflow: TextOverflow.ellipsis,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${sPrice??'-'} 원',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          SizedBox(width: 5,),
                          Flexible(
                            child: Text(
                              sCompany,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ],
                      ),
                      Text('${medicineListUnit.etcOtcCd ?? ''} · ${medicineListUnit.classNm ?? ''} ', style: Theme.of(context).textTheme.subtitle1,)
                    ],
                  ),
                ),
              ),
              if(sImageUrl != null)
              Expanded(
                flex: 3,
                child: Container(
                  child: Image.network(sImageUrl,  fit: BoxFit.fill , 
                    loadingBuilder: (context, child, loadingProgress) =>
                      (loadingProgress == null) ? 
                      child : Center(
                        child: CircularProgressIndicator(),
                      ),
                    errorBuilder: (context, exception, stackTrace){
                      return SvgPicture.asset('assets/noImage.svg', fit: BoxFit.fill);
                    },) 
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}