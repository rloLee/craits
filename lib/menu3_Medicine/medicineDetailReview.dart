import 'dart:async';
import 'dart:convert';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/reviewList.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:craits/MyWidget/imageSliderUrl.dart';
import 'package:http/http.dart' as http;
import 'package:craits/Common/com.dart';

class MedicineDetailReview extends StatefulWidget {
  String searchId;
  MedicineDetailReview(this.searchId);

  @override
  _MedicineDetailReviewState createState() => _MedicineDetailReviewState();
}

class _MedicineDetailReviewState extends State<MedicineDetailReview> {
  final uri = Uri.parse(commonUri + '/V1/Review/ReviewList.json');
  ScrollController scrollController;
  JReviewList reviewList;
  double oldMaxScrollExtent = 0;
  bool bImage = false;
  String sSortStd = 'NEW'; //NEW:최신순 'HIGH':별점높은순 'LOW':별점낮은순
  int iSearchPageNo = 1;
  bool bLoading = true;   //getdata 로딩아이콘 표시할때 사용
  bool bNetworkErr = false;
  bool bMoreData = false; //로딩아이콘 표시할때사용..

  @override
  void initState() {
    getData();

    scrollController = ScrollController()
      ..addListener(() {
        if(scrollController.position.pixels == scrollController.position.maxScrollExtent && !bMoreData){
          getMoreData();
        }
      });
      
    super.initState();
  }

  //초기 데이터 가져오기
  Future getData() async {
    try{
      if(mounted)
        setState(() {
          bLoading = true;
          bNetworkErr = false;
        });
      iSearchPageNo = 1;

      bLoading = true;
      var params = {
        'user_auth_id' : user.userAuthId,
        'searchUserId' : '',          //사용자 ID (본인 리뷰시)
        'searchOrder' : sSortStd, //타입 - NEW : 최신 - HIGH : 높은순 - LOW : 낮은순
        'searchId' : widget.searchId.toString(),        //병원, 약국, 의약품 ID
        'searchImageFlag' : bImage? 'Y' : 'N', //사진리뷰 여부 (Y/N)
        'searchPageNo' : iSearchPageNo.toString(), //마지막 리뷰 seq
        'searchPageSize' : '10',  //페이지 크기 (기본 : 10)
      };
    
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      
      JReviewList _reviewList;
      if(response.statusCode == 200){
        _reviewList =JReviewList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        if(mounted)
          setState(() {
            bNetworkErr = true;
          });
        return;
      }

      if(mounted)
        setState(() {
          reviewList = _reviewList;
          bLoading = false; 
        });
    } on TimeoutException catch(_){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        if(mounted)
          setState(() {
            bNetworkErr = true;
          });
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  Future getMoreData() async{
    try{
      if(mounted)
        setState(() {
          bMoreData = true;    
        });

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchUserId' : '',          //사용자 ID (본인 리뷰시)
        'searchOrder' : sSortStd, //타입 - NEW : 최신 - HIGH : 높은순 - LOW : 낮은순
        'searchId' : widget.searchId.toString(),        //병원, 약국, 의약품 ID
        'searchImageFlag' : bImage? 'Y' : 'N', //사진리뷰 여부 (Y/N)
        'searchPageNo' : (++iSearchPageNo).toString(), //마지막 리뷰 seq
        'searchPageSize' : '10',  //페이지 크기 (기본 : 10)
      };
    
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      
      JReviewList _reviewList;
      if(response.statusCode == 200){
        _reviewList =JReviewList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        
        if(mounted)
          setState(() {
            bMoreData = false;   
          });
      }
      
      if(mounted)
        setState(() {
          reviewList.info.list.addAll(_reviewList.info.list);
          bMoreData = false;    
        });
    }
    on TimeoutException catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      if(mounted)
        setState(() {
          bMoreData = false;   
        });
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if(bLoading){
      if(bNetworkErr){
        return Center(
          child:Container(
            height: MediaQuery.of(context).size.height - 250,
            child: NetworkErr(onRetry:getData)
          )
        );
      } 
      else
        return Center(
          child: CircularProgressIndicator(
          ),
          widthFactor: 0.5,
          heightFactor: 2,
        );
    }
    else
      if(reviewList.resultCode == 'FAIL'){
        return Center(
          child: NoData("리뷰가 없습니다."),
        );
      }
      else
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: reviewCard() 
              ),//별점 현황
              Divider(thickness: 1, color: Color(0xFFF2F4F6), height: 10,),
              sortMenu(), //사진리뷰만, 정렬순서
              (reviewList.resultCode == 'FAIL')?
                Container(
                  height: 250,
                  child: NoData("리뷰가 없습니다."),
                )
                : reviewListView(), //리뷰 리스트뷰
            ],
          ),
        );
  }

  //사진리뷰만, 최신순,별점높은순,별점낮은순
  Container sortMenu(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      height: 50,
      child: Row(
        children: [
          Checkbox(
            value: bImage, 
            onChanged: (value){
              setState(() {
                bImage = value;
                reviewList = null;
              });
              getData();
            }),
          Expanded(
            child: GestureDetector(
              child: Text('사진리뷰만', style: bImage?  TextStyle(color: Color(0xFF262626), fontSize: 13.0, fontWeight: FontWeight.w500) : Theme.of(context).textTheme.caption,),
              onTap: (){
                setState(() {
                  bImage = !bImage;
                  reviewList = null;
                });
                  getData();
              },
            )),
          TextButton(
            child: Text('최신순', style: sSortStd == 'NEW'? TextStyle(color: Color(0xFF262626), fontSize: 13.0, fontWeight: FontWeight.w500) : Theme.of(context).textTheme.caption,), 
            onPressed: (){
              sSortStd = 'NEW';
              setState(() {
                reviewList = null;
              });
              getData();
            },
          ),
          TextButton(
            child: Text('별점높은순',style: sSortStd == 'HIGH'? TextStyle(color: Color(0xFF262626), fontSize: 13.0, fontWeight: FontWeight.w500) : Theme.of(context).textTheme.caption,), 
            onPressed: (){
              sSortStd = 'HIGH';
              setState(() {
                reviewList = null;
                          });
              getData();
            },
          ),
          TextButton(
            child: Text('별점낮은순', style: sSortStd == 'LOW'? TextStyle(color: Color(0xFF262626), fontSize: 13.0, fontWeight: FontWeight.w500) : Theme.of(context).textTheme.caption,), 
            onPressed: (){
              sSortStd = 'LOW';
                setState(() {
                  reviewList = null;
                            });
              getData();
            },
          )
        ],),
    );
  }

  Card reviewCard(){
    return Card(
      color: const Color(0xFFF4F5F9),
      shadowColor: Colors.black26,
      elevation: 8.0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/Star_o.svg', height: 50, ),
                    SizedBox(width: 10,),
                    Text(reviewList.info.totalScore, style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.bold), )
                ],),
                    SizedBox(height: 10,),
                Text('${reviewList.info.totalCnt}개의 리뷰', style: Theme.of(context).textTheme.subtitle2, )
              ],),
            ),Divider(thickness: 10, color: Color(0xFFF2F4F6), height: 10,),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      Text(' (${reviewList.info.score5})', style: Theme.of(context).textTheme.subtitle2, )
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_x.svg', height: 15, ),
                      Text(' (${reviewList.info.score4})', style: Theme.of(context).textTheme.subtitle2, )
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_x.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_x.svg', height: 15, ),
                      Text(' (${reviewList.info.score3})', style: Theme.of(context).textTheme.subtitle2, )
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_x.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_x.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_x.svg', height: 15, ),
                      Text(' (${reviewList.info.score2})', style: Theme.of(context).textTheme.subtitle2, )
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.asset('assets/Star_o.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_x.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_x.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_x.svg', height: 15, ),
                      SvgPicture.asset('assets/Star_x.svg', height: 15, ),
                      Text(' (${reviewList.info.score1})', style: Theme.of(context).textTheme.subtitle2, )
                    ],
                  ),
                ],),
              ),
          ],
        ),
      ),
    );
  }

  ListView reviewListView(){
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder:(context, index){
        if(index == reviewList.info.list.length)
          return Center(
              child: CircularProgressIndicator(
              ),
              widthFactor: 0.5,
              heightFactor: 2,
            );
        else
            return Container(
              child: Card(
                elevation: 0.0,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: ClipOval(
                              child: (reviewList.info.list[index].profileImageUrl!= null)? 
                              Image.network(reviewList.info.list[index].profileImageUrl, width:40, height:40, fit: BoxFit.cover ,
                                errorBuilder: (context, exception, stackTrace){
                                  return Image.asset('assets/noProfile.png', width:40, height:40, fit: BoxFit.cover);
                                },)  
                              : Image.asset('assets/noProfile.png', width:40, height:40, fit: BoxFit.cover),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //Text(reviewList.info.list[index].reviewUserId, style: Theme.of(context).textTheme.headline3, ),
                                Text(reviewList.info.list[index].name, style: Theme.of(context).textTheme.headline3, ),
                                Row(
                                  children: [
                                    scoreStar(reviewList.info.list[index].score),
                                    SizedBox(width: 10,),
                                    Text(reviewList.info.list[index].regDt, style: Theme.of(context).textTheme.caption )
                                  ],
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon:Icon(Icons.more_vert), 
                            onPressed: (){
                              
                          },)
                        ],
                      ),
                    ),
                    if(reviewList.info.list[index].reviewImageList.length > 0)
                      imageSlider(reviewList.info.list[index].reviewImageList),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      child: Text(reviewList.info.list[index].content),
                    )
                  ],
                ),
              ),
            );
      }, 
      separatorBuilder: (context, index){
        return Divider(thickness: 10, color: Color(0xFFF2F4F6), height: 10,);
      }, 
      itemCount: bMoreData? reviewList.info.list.length + 1 : reviewList.info.list.length);
  }

  Widget scoreStar(String score){
    int iScore = int.tryParse(score);
    return Container(
      child: Row(
        children: [
          for(int i = 0; i < iScore; i++)
            SvgPicture.asset('assets/Star_o.svg', height: 15, ),
          for(int i = 0; i < 5 - iScore;  i++)
            SvgPicture.asset('assets/Star_x.svg', height: 15, ),
      ],),
    );
  } 

  Widget imageSlider(List<JReviewListInfoListUnitImageUnit> imageList){
    List<String> list = [];
    imageList.forEach((element) {
      list.add(element.imageUrl); 
    });
    return ImageUrlSlider(list);
  }
}

 