import 'dart:async';
import 'dart:convert';
import 'package:craits/Home_Feed/feed_comment.dart';
import 'package:craits/Home_Feed/textConvertHashtag.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/_JClass/feedList.dart';
import 'package:craits/_JClass/mypageReviewList.dart';
import 'package:craits/_JClass/registerLike.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyPage/myFollowerList.dart';
import 'package:craits/MyPage/myFollowingList.dart';
import 'package:craits/MyPage/myProfileEdit.dart';
import 'package:craits/MyWidget/imageSliderUrl.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/okCancelDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:craits/_JClass/profileInfo.dart';
import 'package:http/http.dart' as http;
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:share/share.dart';
import 'settings.dart';

class MyPage extends StatefulWidget {
  final Function goHome;
  MyPage(this.goHome);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final uri = Uri.parse(commonUri + '/V1/Auth/InfoProfile.json');
  JProfileInfo profileInfo;
  bool bLoading = true;
  bool bNetworkErr = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future init() async{
    if(mounted)
      setState(() {
        bLoading = true;
        bNetworkErr = false;
      });
    await getData(); //프로필데이터
    await getFeedData();
    await getReviewData();
    
    if(mounted)
    setState(() {
      bLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getData() async {
    try{
      var params = {
        'user_auth_id' : user.userAuthId,
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JProfileInfo _profileInfo;
      if(response.statusCode == 200){
        _profileInfo = JProfileInfo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          profileInfo = _profileInfo;
          if(profileInfo.resultCode == 'SUCC')
            profile = profileInfo.info;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : Text('마이페이지'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            widget.goHome();
        }),
        actions: [
          MaterialButton(
            minWidth : 50,
            padding: EdgeInsets.zero,
            child: SvgPicture.asset('assets/setting.svg'),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
            },
          )
        ],
      ),
      body: 
      (bNetworkErr)?
        Center(
          child:Container(
            child: NetworkErr(onRetry:init)
          ))
      :
      (bLoading)?
        Material(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ) 
      : DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverToBoxAdapter(
                  child: myProfile(),
                ),
              ];
            },
            // You tab view goes here
            body: Column(
              children: <Widget>[
                TabBar(
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: '피드'),
                    Tab(text: '리뷰'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      myFeedList('key1'),
                      myReviewList('key2'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  //내 프로필
  Widget myProfile(){
    return Card(
      margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
      shadowColor: Colors.black45,
      elevation: 8.0,
      child: Container(
        width: double.infinity,
        height: 130,
        child: Column(
          children: [
          Expanded(
            flex: 1, 
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyProfileEdit(profileInfo))).then((value) => {
                  if(value != null && value == true)
                    getData()
                });
              },
              child: Row(children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: ClipOval(
                    child: (profileInfo.info.imageUrl!= null)? 
                      Image.network(profileInfo.info.imageUrl, width:40, height:40, fit: BoxFit.cover , 
                        errorBuilder: (context, exception, stackTrace){
                          return Image.asset('assets/noProfile.png', width:40, height:40, fit: BoxFit.cover);
                      },)  
                      : Image.asset('assets/noProfile.png', width:40, height:40, fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      children: [
                        Text(profileInfo.info.name, style: Theme.of(context).textTheme.headline3,),
                        SizedBox(width: 10,),
                        SvgPicture.asset('assets/arrowRight.svg', height: 10,)
                      ],
                    ),
                    Text(profileInfo.info.email, style: Theme.of(context).textTheme.caption,),
                  ],),
                ),
              ],),
            ),
          ),
          Expanded(
            flex: 1, 
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyFollowingList())).then((value) => getData);
                          },
                          child: Text('팔로잉 ${profileInfo.info.followingCnt}', style: TextStyle(color: Color(0xFF959595), wordSpacing: 5, fontSize: 14, ), textAlign: TextAlign.center, )
                        ),
                      ),
                      VerticalDivider(indent: 20, endIndent: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyFollowerList())).then((value) => getData);
                          },
                          child: Text('팔로워 ${profileInfo.info.followCnt}', style: TextStyle(color: Color(0xFF959595), wordSpacing: 5, fontSize: 14, ), textAlign: TextAlign.center )
                        ),
                      ),
                  ],)
                )
              ],
            ),),
        ],),
      ),
    );
  }

  int iFeedPageNo = 1;
  JFeedList feedList;
  bool bFeedMoreData = false; //로딩아이콘 표시할때사용..
  bool bImage = false;

  //피드 데이터
  Future getFeedData() async {
    final uri = Uri.parse(commonUri + '/V1/Feed/FeedList.json');
    try{
      // if(mounted)
      //   setState(() {
      //     bLoading = true;
      //     bNetworkErr = false;
      //   });

      iFeedPageNo = 1;

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchTargetUserId' : user.userId.toString(),
        'searchPageNo' : iFeedPageNo.toString(),  //페이지 번호. 기본:1
        'searchPageSize' : '10',  //페이지 크기. 기본:10
        'searchPosLat' : '0.0', //위치정보 (위도)
        'searchPosLng' : '0.0', //위치정보 (경도)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JFeedList _feedList;
      if(response.statusCode == 200){
        _feedList =JFeedList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          feedList = _feedList;
          // bLoading = false;
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

  Future getFeedMoreData() async {
    final uri = Uri.parse(commonUri + '/V1/Feed/FeedList.json');
    try{
      if(mounted)
        setState(() {
          bFeedMoreData = true;    
        });

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchTargetUserId' :  user.userId.toString(),
        'searchPageNo' : (++iFeedPageNo).toString(),  //페이지 번호. 기본:1
        'searchPageSize' : '10',  //페이지 크기. 기본:10
        'searchPosLat' : '0.0', //위치정보 (위도)
        'searchPosLng' : '0.0', //위치정보 (경도)
      };
      
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JFeedList _feedList;
      if(response.statusCode == 200){
        _feedList = JFeedList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
        if(mounted)
          setState(() {
            bFeedMoreData = false;   
          });
      }
        
      if(mounted)
        setState(() {
          feedList.list.addAll(_feedList.list);
          bFeedMoreData = false;
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
          bFeedMoreData = false;   
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

//피드리스트
  myFeedList(String key){
    if(feedList.resultCode == 'FAIL')
      return NoData('등록한 피드가 없습니다.');
    else
      return RefreshIndicator(
        color: const Color(0xFF469BA7),
        onRefresh: getData,
        child: NotificationListener<UserScrollNotification>( 
          child: ListView.builder (
            physics: AlwaysScrollableScrollPhysics(),
            key: PageStorageKey(key),
            itemBuilder: (BuildContext context, int index){
              if(index == feedList.list.length)
                return Center(
                  child: CircularProgressIndicator(),
                  widthFactor: 0.5,
                  heightFactor: 2,
                );
              else
                return FeedUnit(
                  key: UniqueKey(),
                  feedListUnit: feedList.list[index], 
                  onDelete: (){
                    setState(() {
                      feedList.list.removeAt(index);
                    });
                  },
                );
              },
            itemCount: bFeedMoreData? feedList.list.length + 1 : feedList.list.length
          ),
          onNotification: (scrollNotification){
            if(scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && !bFeedMoreData){
              getFeedMoreData();
            }
            return false;
          },
        ),
      );
  }

  int iReviewPageNo = 1;
  JMyReviewList reviewList;
  bool bReviewMoreData = false; //로딩아이콘 표시할때사용..
  
  //초기 데이터 가져오기
  Future getReviewData() async {
    final uri = Uri.parse(commonUri + '/V1/Review/MypageReviewList.json');
    try{
      // if(mounted)
      //   setState(() {
      //     bNetworkErr = false;
      //     bLoading = true;
      //   });

      iReviewPageNo = 1;
      var params = {
        'user_auth_id' : user.userAuthId,
        'searchTargetUserId' :  user.userId.toString(),          //사용자 ID (본인 리뷰시)
        'searchOrder' : 'NEW', //타입 - NEW : 최신 - HIGH : 높은순 - LOW : 낮은순
        'searchImageFlag' : bImage? 'Y' : 'N', //사진리뷰 여부 (Y/N)
        'searchPageNo' : iReviewPageNo.toString(), //마지막 리뷰 seq
        'searchPageSize' : '10',  //페이지 크기 (기본 : 10)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JMyReviewList _reviewList;
      if(response.statusCode == 200){
        _reviewList =JMyReviewList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          // bLoading = false; 
        });
    } on TimeoutException catch(_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        if(mounted)
          setState(() {
            bNetworkErr = true;
          });
    } catch(_){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
    }
  }
  
  Future getReviewMoreData() async {
    final uri = Uri.parse(commonUri + '/V1/Review/MypageReviewList.json');
    try{
      if(mounted)
        setState(() {
          bReviewMoreData = true;
        });

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchTargetUserId' :  user.userId.toString(),          //사용자 ID (본인 리뷰시)
        'searchOrder' : 'NEW', //타입 - NEW : 최신 - HIGH : 높은순 - LOW : 낮은순
        'searchImageFlag' : bImage? 'Y' : 'N', //사진리뷰 여부 (Y/N)
        'searchPageNo' : (++iReviewPageNo).toString(), //마지막 리뷰 seq
        'searchPageSize' : '10',  //페이지 크기 (기본 : 10)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JMyReviewList _reviewList;
      if(response.statusCode == 200){
        _reviewList =JMyReviewList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        if(mounted)
          setState(() {
            bReviewMoreData = false;   
          });
      }
      if(mounted)
        setState(() {
          reviewList.info.list.addAll(_reviewList.info.list);
          bReviewMoreData = false;    
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
          bReviewMoreData = false;   
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

  Future deleteReview(String seq) async{
    final uri = Uri.parse(commonUri + '/V1/Review/DeleteReview.json');
    try{
      var params = {
        'user_auth_id' :user.userAuthId,
        'seq' : seq
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      Navigator.pop(context); //로딩끝

      JResponse _response;
      if(response.statusCode == 200){
        _response =JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        return _response.resultCode;
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
    }
    on TimeoutException catch(_) {
        Navigator.pop(context); //로딩끝
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
    return null;
  }

//리뷰리스트
  myReviewList(String key){
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

    Widget imageSlider(List<JMyReviewListInfoListUnitImageUnit> imageList){
      List<String> list = [];
      imageList.forEach((element) {
        list.add(element.imageUrl); 
      });
      return ImageUrlSlider(list);
    }

    if(reviewList.resultCode == 'FAIL')
      return NoData('등록한 리뷰가 없습니다.');
    else
    return NotificationListener<UserScrollNotification>(
      onNotification: (scrollNotification){
        if(scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent && !bReviewMoreData) {
          getReviewMoreData();
        }
        return false;
      },
      child: ListView.builder(
        key: PageStorageKey(key),
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index){
          if(index == reviewList.info.list.length)
            return Center(
              child: CircularProgressIndicator(),
              widthFactor: 0.5,
              heightFactor: 2,
            );
          else
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6), width: 10))
              ),
              child: Card(
                elevation: 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(reviewList.info.list[index].name, style: Theme.of(context).textTheme.headline3, ),
                                  Row(
                                    children: [
                                      scoreStar(reviewList.info.list[index].score),
                                      SizedBox(width: 10,),
                                      Text(reviewList.info.list[index].elapsedTime.toString(), style: Theme.of(context).textTheme.caption )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            itemBuilder: (context){
                              return [
                                PopupMenuItem(
                                  textStyle: Theme.of(context).textTheme.bodyText1,
                                  height: 35,
                                  value: '삭제하기',
                                  child: Text('삭제하기'),
                                )
                              ];
                            },
                            onSelected: (value){
                              if(value == '삭제하기'){
                                showDialog(
                                  context: context, 
                                  builder: (context) => OkCancelDialog(
                                    text: '리뷰를 삭제하시겠습니까?', 
                                    onOk: (){
                                      deleteReview(reviewList.info.list[index].seq).then(
                                        (resultCode) {
                                          if (resultCode != null) {
                                            if (resultCode == 'SUCC'){
                                              setState(() {
                                                reviewList.info.list.removeAt(index);
                                              });
                                          }
                                        }
                                      });
                                    }
                                  )
                                );
                              }
                            },
                            icon:Icon(Icons.more_vert),
                          )
                        ],
                      ),
                    ),
                    if(reviewList.info.list[index].reviewImageList.length > 0)
                      imageSlider(reviewList.info.list[index].reviewImageList),
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: Text(reviewList.info.list[index].content),
                    )
                  ],
                ),
              ),
            );
        },
        itemCount: bReviewMoreData? reviewList.info.list.length + 1 : reviewList.info.list.length
      )
    );
  }
}

//피드 낱개
class FeedUnit extends StatefulWidget {
  final JFeedListUnit feedListUnit;
  final Function onDelete;
  FeedUnit({
    Key key, 
    @required this.feedListUnit, 
    @required this.onDelete
    }) : super(key: key);

  @override
  _FeedUnitState createState() => _FeedUnitState();
}

class _FeedUnitState extends State<FeedUnit>{
  String sLikeFlag;
  int iLikeCnt ;
  String sReplyCnt;

  @override
  void initState() {
    super.initState();
    sLikeFlag = widget.feedListUnit.likeFlag.toString();
    iLikeCnt = int.tryParse(widget.feedListUnit.likeCnt.toString());
    sReplyCnt = widget.feedListUnit.commentCnt.toString();
  }

  Future deleteFeed() async {
    final uri = Uri.parse(commonUri + '/V1/Feed/DeleteFeed.json');
    try{
      showDialog(context: context,barrierDismissible: false,  builder: (_)  => LoadingDialog());

      var params = {
        'user_auth_id' : user.userAuthId,
        'feed_id' : widget.feedListUnit.feedId.toString(), // FEED ID / COMMENT ID / REPLY ID
      };
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      
      Navigator.pop(context); //로딩끝

      JResponse _response;
      if(response.statusCode == 200){
        _response =JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        return _response.resultCode;
      }
      else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
    }
    on TimeoutException catch(_) {
        Navigator.pop(context); //로딩끝
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6), width: 10))
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: ClipOval(
                    child: (widget.feedListUnit.profileImageUrl!= null)? 
                    Image.network(widget.feedListUnit.profileImageUrl, width:40, height:40, fit: BoxFit.cover,
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
                      Text(widget.feedListUnit.name, style: Theme.of(context).textTheme.headline3,),
                      Text('${widget.feedListUnit.elapsedTime}', style: Theme.of(context).textTheme.caption ),
                    ],
                  )
                ),
                PopupMenuButton(
                  itemBuilder: (context){
                    return [
                      PopupMenuItem(
                        textStyle: Theme.of(context).textTheme.bodyText1,
                        height: 35,
                        value: '삭제하기',
                        child: Text('삭제하기'),
                      )
                    ];
                  },
                  onSelected: (value){
                    if(value == '삭제하기'){
                      showDialog(
                        context: context, 
                        builder: (context) => OkCancelDialog(
                          text: '피드를 삭제하시겠습니까?', 
                          onOk: (){
                            deleteFeed().then((resultCode) {
                              if(resultCode!=null){
                                if(resultCode=='SUCC') {
                                  widget.onDelete();
                                }
                                else{ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(milliseconds: 1500),
                                    content: Text('오류가 발생했습니다.'))
                                  );
                                }
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(milliseconds: 1500),
                                    content: Text('오류가 발생했습니다.'))
                                  );
                              }
                              Navigator.pop(context);
                            });
                        },)
                      );
                    }
                  },
                  icon:Icon(Icons.more_vert),
                  )
              ],
            ),
          ),
          if(widget.feedListUnit.feedImageList.length > 0)
            imageSlider(widget.feedListUnit.feedImageList),
          Container(
            constraints: BoxConstraints(
              minHeight: 70,
              minWidth: double.infinity
              ),
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextConvertHashTag(text: widget.feedListUnit.content , feed: widget.feedListUnit, clickable: true),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          MaterialButton(
                            child: Row(
                              children: [
                                sLikeFlag == 'Y'? SvgPicture.asset('assets/like_o.svg') : SvgPicture.asset('assets/like_x.svg'),
                                SizedBox(width: 5,),
                              Text('좋아요 $iLikeCnt', style:  Theme.of(context).textTheme.bodyText2,),
                              ],
                            ), 
                            onPressed: (){
                              setState(() {
                                if(sLikeFlag == 'Y')
                                  { 
                                    sLikeFlag = 'N';
                                    iLikeCnt --;
                                    like(sLikeFlag).then((value) => 
                                    {
                                      if(value != null)
                                        iLikeCnt = int.parse(value)
                                    });
                                  }
                                else
                                  {
                                    sLikeFlag = 'Y';
                                    iLikeCnt ++;
                                    like(sLikeFlag).then((value) => 
                                    {
                                      if(value != null)
                                        iLikeCnt = int.parse(value)
                                    });
                                  }
                              });
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minWidth: 0,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                          ),
                          SizedBox(width: 15,),
                          MaterialButton(
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/comment.svg', ),
                                SizedBox(width: 5,),
                                Text(' 댓글 $sReplyCnt', style: Theme.of(context).textTheme.bodyText2,),
                              ],
                            ) , 
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FeedComment(feed: widget.feedListUnit, onDelete: widget.onDelete,)));
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minWidth: 0,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: SvgPicture.asset('assets/share.svg') , 
                        onPressed: () async{
                          var dynamicLink = await getDynamicLink(widget.feedListUnit.feedId.toString());
                          Share.share(dynamicLink.toString());
                        },
                      )
                    ],
                  ),
              ],
            ),
          ),
      ],),
    );
  }

  Widget imageSlider(List<JFeedListUnitFeedImage> imageList){
    List<String> list = [];
    imageList.forEach((element) {
      list.add(element.imageUrl); 
    });
    return ImageUrlSlider(list);
  }

  Future like(String sFlag) async{
    final uri = Uri.parse(commonUri + '/V1/Like/RegisterLike.json');
    try{
      var params = {
        'user_auth_id' : user.userAuthId,
        'flag' : sFlag, //"Y" : 등록 / "N" : 취소
        'type' : 'FEED', //타입 (FEED / COMMENT/ REPLY)
        'id' : widget.feedListUnit.feedId.toString(), // FEED ID / COMMENT ID / REPLY ID
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(Duration(seconds: 3));

      JRegisterLike _registerLike;
      if(response.statusCode == 200){
        _registerLike =JRegisterLike.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        return _registerLike.info.cnt;
      }
      else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
        return null;
      }
    }
    on TimeoutException catch(_){
        Navigator.pop(context); //로딩끝
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
    return null;
  }
}