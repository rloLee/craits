import 'package:flutter/material.dart';
import 'package:craits/_JClass/hospitalDetail.dart';
import 'hospitalDetailInfo.dart';
import 'hospitalDetailReview.dart';

class HospitalDetail extends StatefulWidget {
  final String hospitalName;
  final String searchId;
  final String searchPosLat;
  final String searchPosLng;

  HospitalDetail({
    @required this.hospitalName,
    @required this.searchId,
    @required this.searchPosLat,
    @required this.searchPosLng,
  });

  @override
  _HospitalDetailState createState() => _HospitalDetailState();
}

class _HospitalDetailState extends State<HospitalDetail> {
  JHospitalDetail hospitalDetail;
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
          title: Text(widget.hospitalName),
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
            HospitalDetailInfo(searchId: widget.searchId.toString(), searchPosLat : widget.searchPosLat, searchPosLng: widget.searchPosLng),
            HospitalDetailReview(widget.searchId.toString())
          ],
        )
      )
    );
  }
}
