import 'package:flutter/material.dart';
import 'package:craits/_JClass/pharmacyDetail.dart';
import 'pharmacyDetailInfo.dart';
import 'pharmacyDetailReview.dart';

class PharmacyDetail extends StatefulWidget {
  final String pharmacyName;
  final String searchId;
  final String searchPosLat;
  final String searchPosLng;

  PharmacyDetail({
    @required this.pharmacyName,
    @required this.searchId,
    @required this.searchPosLat,
    @required this.searchPosLng,
  });

  @override
  _PharmacyDetailState createState() => _PharmacyDetailState();
}

class _PharmacyDetailState extends State<PharmacyDetail> {
  JPharmacyDetail pharmacyDetail;
  bool showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:AppBar(
          elevation: 1.0,
          title: Text(widget.pharmacyName),
          iconTheme: IconThemeData(
            color: Colors.black87
          ),
          bottom: TabBar(
            indicatorWeight: 3,
            tabs: <Widget>[
              Tab(
                text: '상세정보',
              ),
              Tab(
                text: '리뷰',
              ),
            ],
          ),
        ), 
        body: TabBarView(
          children: <Widget>[
            PharmacyDetailInfo(searchId: widget.searchId, searchPosLat : widget.searchPosLat, searchPosLng: widget.searchPosLng),
            PharmacyDetailReview(widget.searchId)
          ],
        )
      )
    );
  }
}
