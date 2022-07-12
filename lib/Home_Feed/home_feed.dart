import 'dart:async';
import 'dart:convert';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:craits/MyWidget/imageBannerSlider.dart';
import 'package:craits/_JClass/bannerList.dart';
import 'package:craits/_JClass/registerLike.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/okCancelDialog.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:craits/_JClass/feedList.dart';
import 'package:craits/MyWidget/imageSliderUrl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';
import 'textConvertHashtag.dart';
import 'feed_comment.dart';
import 'uploadFeed.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/MyWidget/followDialog.dart';
import 'package:craits/Common/com.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:io';
import 'package:craits/Home_Chart/photoSend.dart';
import 'package:url_launcher/url_launcher.dart';

//피드 탭
class HomeMyFeed extends StatefulWidget {
  @override
  _HomeMyFeedState createState() => _HomeMyFeedState();
}

class _HomeMyFeedState extends State<HomeMyFeed> with AutomaticKeepAliveClientMixin<HomeMyFeed>{
  bool get wantKeepAlive => true;
  final uri = Uri.parse(commonUri+ '/V1/Feed/FeedList.json');
  JFeedList feedList;
  JBannerList bannerList;
  ScrollController scrollController;
  int iSearchPageNo = 1;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  bool bLoading = true;
  bool bNetworkErr = false;

  @override
  void initState() {
    init();
    scrollController = ScrollController()
    ..addListener(() {
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent && !bMoreData){
        getMoreData();
      }
    });
    super.initState();
  }

  Future init() async{
    if(mounted)
      setState(() {
        bLoading = true;
        bNetworkErr = false;
      });

      if (mounted)
    await getBannerList();
    
      if (mounted)
    await getData();
    
    if (mounted && !bNetworkErr)
      setState(() {
        bLoading = false;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
    
  //초기 데이터 가져오기
  Future getData() async {
    try {
      iSearchPageNo = 1;

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchPageNo' : iSearchPageNo.toString(),  //페이지 번호. 기본:1
        'searchPageSize' : '10',  //페이지 크기. 기본:10
        'searchPosLat' : dCurLat.toString(), //위치정보 (위도)
        'searchPosLng' : dCurLong.toString(), //위치정보 (경도)
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
            bNetworkErr = true;
          });
        return;
      }
      if (mounted)
        setState(() {
          feedList = _feedList;
          // bLoading = false;
      });
    } on TimeoutException catch(_){
      
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        if (mounted)
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

  Future getBannerList() async{
    try {
      final uri = Uri.parse(commonUri+ '/V1/Board/BannerList.json'); 
      var params = {
        'user_auth_id' : user.userAuthId,
      };
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      
      JBannerList _bannerList;
      if(response.statusCode == 200){
        _bannerList = JBannerList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
      if (mounted)
        setState(() {
          bannerList = _bannerList;
          // bLoading = false;
      });
    } on TimeoutException catch(_){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        if (mounted)
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

  Future getMoreData() async {
    try {
      if(mounted)
        setState(() {
          bMoreData = true;    
        });
      var params = {
        'user_auth_id' : user.userAuthId,
        'searchPageNo' : (++iSearchPageNo).toString(),  //페이지 번호. 기본:1
        'searchPageSize' : '10',  //페이지 크기. 기본:10
        'searchPosLat' : dCurLat.toString(), //위치정보 (위도)
        'searchPosLng' : dCurLong.toString(), //위치정보 (경도)
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
            bMoreData = false;   
          });
      }
      if(mounted)
        setState(() {
          feedList.list.addAll(_feedList.list);
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
    } catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton:  floating(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child:
              bLoading?
                bNetworkErr?
                  Center(
                    child:Container(
                      height: MediaQuery.of(context).size.height - 250,
                      child: NetworkErr(onRetry: init)
                    ))
                  : Center(
                      child: CircularProgressIndicator())
              : RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: init,
                child: (feedList.resultCode == 'FAIL')
                ? ListView(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height - 250,
                      child: NoData("피드가 없습니다."),
                    ),
                  ],
                )
                : feedListview(), 
              )
          ),
        ],
      ),
    );
  }
  
  // 피드 리스트뷰
  CustomScrollView feedListview(){
    return CustomScrollView(
    physics: AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      slivers:[
        //배너 이미지 슬라이더
        SliverToBoxAdapter(
          child: Container(
            child: ImageBannerSlider(bannerList.list),
          ),
        ),
        //위치표시 
        SliverToBoxAdapter(
          child: Container(
            height: 30,
            color: Theme.of(context).backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async{
                    final uri = Uri.parse(commonUri+ '/V1/Push/TestPush.json'); 
                    var params = {
                      'user_auth_id' : user.userAuthId,
                      'searchNotiType' : 'PKFREE', //FOLLOW CMT LIKE TAKE DONE EFFECT
                      'searchTitle' : '댓글알림',
                      'searchBody' : '댓글...',
                      'searchName' : '이은빈',  //복용자, 닉네임
                      'searchId' : '273',       //링크 ID
                      'searchAlarmDt' : '2021-09-27 14:30:59', //복용 일시
                      'searchResultId' : '15', //결과 ID
                    };
                    await Future.delayed(Duration(seconds: 5));
                    final newUri = uri.replace(queryParameters: params);
                    http.get(newUri).timeout(timeoutDuration);
                  }, 
                  child: Text('푸시알람보내기')),
                SvgPicture.asset('assets/location.svg', width: 11,),
                SizedBox(width: 5,),
                Text(sLocation, style: Theme.of(context).textTheme.caption,),
                SizedBox(width: 5,),
              ]
            ),
          ),
        ),
        //피드리스트
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index){
            if(index == feedList.list.length)
              return Center(
                child: CircularProgressIndicator(),
                heightFactor: 2,
              );
            else{
              if(feedList.list[index].feedType == 'FEED'){
                return FeedUnit(
                  key: UniqueKey(),
                  feedListUnit: feedList.list[index], 
                  onDelete: (){
                    setState(() {
                      feedList.list.removeAt(index);
                    });
                  },
                );
              }
              else{
                return AdUnit(
                  feedListUnit: feedList.list[index], 
                );
              }
            }
          },
          childCount: bMoreData? feedList.list.length + 1 : feedList.list.length,)
        )
      ]
    );
  } 

  //floating버튼 
  SpeedDial floating(){
    File _image;
    final picker = ImagePicker();
    Future getImage(ImageSource _source, BuildContext context) async {
      try{
        final pickedFile = await picker.getImage(source: _source);
        setState(() {
          if (pickedFile != null) {
            _image = File(pickedFile.path);
            Navigator.push(context, MaterialPageRoute(builder: (context) => Photo(_image, (){ getData(); } )));
          } else {
            print('No image selected.');
          }
        });
      } on PlatformException catch (error) {
        print(error);
      // Handle err
      } catch (error) {
      // other types of Exceptions
        print(error);
      }
    }
    
    return SpeedDial( //Speed dial menu
      icon: Icons.add_sharp, //icon on Floating action button
      foregroundColor: Colors.white,
      activeIcon: Icons.close, //icon when menu is expanded on button
      spacing: 10,
      activeChild: FloatingActionButton(backgroundColor: Colors.white, child: SvgPicture.asset('assets/close.svg'), onPressed: (){},),
      visible: true,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.6,
      elevation: 1.0,
      buttonSize: 54.0,
      childPadding: EdgeInsets.symmetric(vertical: 5),
      childrenButtonSize: 60.0,
      childMargin : const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      children: [
        SpeedDialChild( //speed dial child
          child: SvgPicture.asset('assets/write.svg',),
          backgroundColor: Theme.of(context).primaryColor,
          labelWidget: Text('피드글쓰기', style: TextStyle(color: Colors.white, fontSize: 14.0),),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> UploadFeed(onRefresh: getData,)));
          },
        ),
        SpeedDialChild(
          child: SvgPicture.asset('assets/camera.svg'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          labelWidget: Text('진료기록쓰기', style: TextStyle(color: Colors.white, fontSize: 14.0),),
          onTap: (){
            showAdaptiveActionSheet(
            context: context,
            actions: <BottomSheetAction>[
              BottomSheetAction(
                title: Text('사진 찍기', style: Theme.of(context).textTheme.headline4,),
                onPressed: (){
                  //카메라 실행
                  getImage(ImageSource.camera, context);
                  Navigator.of(context).pop();
                },
              ),
                BottomSheetAction(
                title: Text('사진 보관함', style: Theme.of(context).textTheme.headline4,),
                onPressed: (){
                  //저장소
                  getImage(ImageSource.gallery, context);
                  Navigator.of(context).pop();
                },
              ),
            ],
            cancelAction: CancelAction(
              title: Text('취소', style: Theme.of(context).textTheme.headline4,))
          );
          },
        ),
      ],
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

class _FeedUnitState extends State<FeedUnit> {
  String sLikeFlag;
  int iLikeCnt ;

  @override
  void initState() {
    sLikeFlag = widget.feedListUnit.likeFlag.toString();
    iLikeCnt = int.tryParse(widget.feedListUnit.likeCnt.toString());
    initDynamicLinks();
    super.initState();
  }
  
  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;
          if (deepLink != null) {
            if(deepLink.path == '/feed'){
              var feedId = deepLink.queryParameters['code'];
              Navigator.push(context, MaterialPageRoute(builder: (context) => FeedComment(
                feedId : feedId,
                onDelete: (){
                },
              )));
            }
          }
        },
        onError: (OnLinkErrorException e) async {
          print(e.message);
        }
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).backgroundColor, width: 10))
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
                    Image.network(widget.feedListUnit.profileImageUrl, width:40, height:40, fit: BoxFit.cover , 
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
                      Row(
                        children: [
                          Text(widget.feedListUnit.name, style: Theme.of(context).textTheme.headline3,),
                          SizedBox(width: 10,),
                          if(widget.feedListUnit.feedUserId != user.userId)
                          widget.feedListUnit.followFlag == 'Y'
                            ? GestureDetector(
                              onTap: (){
                                showDialog(context: context, builder: (context) => FollowDialog(widget.feedListUnit.feedUserId.toString(), widget.feedListUnit.name, 'N')).then(
                                  (value) => {
                                    if(value == 'SUCC'){
                                      setState(() {
                                        widget.feedListUnit.followFlag = 'N';
                                      })
                                    }
                                  }
                                );
                              },
                              child: Text( '팔로잉', style: Theme.of(context).textTheme.subtitle2,)
                            )
                            :
                            GestureDetector(
                              onTap: (){
                                showDialog(context: context, builder: (context) => FollowDialog(widget.feedListUnit.feedUserId.toString(), widget.feedListUnit.name, 'Y')).then(
                                  (value) => {
                                    if(value == 'SUCC'){
                                      setState(() {
                                        widget.feedListUnit.followFlag = 'Y';
                                      })
                                    }
                                  }
                                );
                              },
                              child: Text( '팔로우', style: Theme.of(context).textTheme.subtitle1,)
                            )
                        ],
                      ),
                      Text('${widget.feedListUnit.elapsedTime}', style: Theme.of(context).textTheme.caption ),
                    ],
                  )
                ),
                PopupMenuButton(
                  itemBuilder: (context){
                    return [
                      if(widget.feedListUnit.feedUserId == user.userId)
                        PopupMenuItem(
                          textStyle: Theme.of(context).textTheme.bodyText1,
                          height: 35,
                          value: '삭제하기',
                          child: Text('삭제하기'),
                        ),
                      PopupMenuItem(
                        textStyle: Theme.of(context).textTheme.bodyText1,
                        height: 35,
                        value: '신고하기',
                        child: Text('신고하기'),
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
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                    else if (value == '신고하기'){
                      showDialog(
                        context: context, 
                        builder: (context) => OkCancelDialog(
                          text: '이 피드를 신고하시겠습니까?', 
                          onOk: (){
                          },
                        )
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
            child: TextConvertHashTag(text: widget.feedListUnit.content , feed: widget.feedListUnit, clickable: true, onDelete: widget.onDelete,),
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
                                if(sLikeFlag == 'Y') { 
                                  sLikeFlag = 'N';
                                  iLikeCnt --;
                                  like(sLikeFlag).then((value) => 
                                  {
                                    if(value != null)
                                      setState(() {
                                        iLikeCnt = int.parse(value.toString());
                                      })
                                  });
                                }
                                else{
                                  sLikeFlag = 'Y';
                                  iLikeCnt ++;
                                  like(sLikeFlag).then((value) => 
                                  {
                                    if(value != null)
                                      setState(() {
                                        iLikeCnt = int.parse(value.toString());
                                      })
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
                                Text(' 댓글 ${widget.feedListUnit.commentCnt.toString()}', style: Theme.of(context).textTheme.bodyText2,),
                              ],
                            ) , 
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FeedComment(
                                feed: widget.feedListUnit,
                                onDelete: (){
                                  widget.onDelete();
                                },
                              )));
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

  Widget imageSlider(List<JFeedListUnitFeedImage> imageList){
    List<String> list = [];
    imageList.forEach((element) {
      list.add(element.imageUrl); 
    });
    return ImageUrlSlider(list);
  }

  Future like(String sFlag) async {
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
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      return null;
    }
  }
}

//광고 낱개
class AdUnit extends StatefulWidget {
  final JFeedListUnit feedListUnit;
  AdUnit({
    Key key,
    @required this.feedListUnit, 
    }) : super(key: key);

  @override
  _AdUnitState createState() => _AdUnitState();
}

class _AdUnitState extends State<AdUnit> {
  @override
  void initState() {
    super.initState();
  }
  
  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    }
}
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).backgroundColor, width: 10))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Color(0xFFF3F3F3),
            width: double.infinity,
            child: Text('광고(AD)', style: Theme.of(context).textTheme.caption,),
          ),
          Container(
            child: InkWell(
              onTap: (){
                //인터넷 URL 링크 연결
                _launchInBrowser(widget.feedListUnit.adUrlLink);
              },
              child:Image.network(widget.feedListUnit.adImageUrl,fit: BoxFit.fitWidth , 
              errorBuilder: (context, exception, stackTrace){
                return Image.asset('assets/noProfile.png',  fit: BoxFit.fitWidth);
              },) 
            ),
          ),
          Container(
            color: Color(0xFFF3F3F3),
            constraints: BoxConstraints(
              minHeight: 70,
              ),
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(widget.feedListUnit.adUrlLink, style: Theme.of(context).textTheme.subtitle2,),
                Text(widget.feedListUnit.adTitle, style: Theme.of(context).textTheme.headline2,),
                Text(widget.feedListUnit.adContent, style: Theme.of(context).textTheme.subtitle2,),
              ],
            ),
          ),
      ],),
    );
  }
}

