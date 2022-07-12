import 'package:craits/_JClass/pharmacyList.dart';
import 'package:craits/MyWidget/markersPharmacyMap.dart';
import 'package:craits/menu2_Pharmacy/pharmacyDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PharmacyMap extends StatefulWidget {
  double dCurLat;
  double dCurLong;
  PharmacyMap({
    @required this.dCurLat,
    @required this.dCurLong
  });

  @override
  _PharmacyMapState createState() => _PharmacyMapState();
}

class _PharmacyMapState extends State<PharmacyMap> {
  final SvgPicture star0 = SvgPicture.asset('assets/Star_x.svg', height: 18,);
  final SvgPicture starhalf = SvgPicture.asset('assets/Star_half.svg', height: 18,);
  final SvgPicture star1 = SvgPicture.asset('assets/Star_o.svg', height: 18,);
  MarkersPharmacyMap map;
  double dScore = 0.0;
  JPharmacyListUnit pharmacy;

  @override
  void initState() {
    map = MarkersPharmacyMap(
      dCurLat: widget.dCurLat, 
      dCurLng: widget.dCurLong,
      onClick:(pharmacy){
        setState(() {
          this.pharmacy = pharmacy;
          dScore = pharmacy.reviewScore != null ? double.tryParse(pharmacy.reviewScore.toString()) : 0.0;
        });
      }
    );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title : Text('약국'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
        }),
      ),
      body: Stack(
        children: [
            map,
            if(pharmacy != null)
            Container(
              padding: const EdgeInsets.all(5.0),
              alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context) => 
                      PharmacyDetail(
                        pharmacyName: pharmacy.pharmacyNm.toString(),
                        searchId:  pharmacy.id.toString(),
                        searchPosLat: widget.dCurLat.toString(),
                        searchPosLng: widget.dCurLong.toString(),)
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    child: Card(
                      elevation: 10,
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 8,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pharmacy.pharmacyNm.toString(), style: Theme.of(context).textTheme.headline1, maxLines: 1, overflow: TextOverflow.ellipsis,),
                                  Row(
                                    children: [
                                      (dScore >= 0.5)? (dScore >= 1? star1 : starhalf) :star0,
                                      (dScore >= 1.5)? (dScore >= 2? star1 : starhalf) :star0,
                                      (dScore >= 2.5)? (dScore >= 3? star1 : starhalf) :star0,
                                      (dScore >= 3.5)? (dScore >= 4? star1 : starhalf) :star0,
                                      (dScore >= 4.5)? (dScore >= 5? star1 : starhalf) :star0,
                                      Text(' $dScore ', style: Theme.of(context).textTheme.headline3 ,),
                                      Text('(${pharmacy.reviewCnt?? '0'})', style: Theme.of(context).textTheme.subtitle2)
                                    ],
                                  ),
                                  Text(
                                    pharmacy.addr ?? '',
                                    style: Theme.of(context).textTheme.subtitle2, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    pharmacy.telNo ?? '',
                                    style: Theme.of(context).textTheme.subtitle2, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                                child: SvgPicture.asset('assets/arrowRight.svg', height: 15,),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            )
        ],
      )
      );
  }
}