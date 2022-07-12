import 'dart:async';
import 'dart:convert';
import 'package:craits/Home_Feed/feed_comment.dart';
import 'package:craits/Home_Feed/textConvertHashtag.dart';
import 'package:craits/_JClass/registerLike.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/okCancelDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:craits/_JClass/feedList.dart';
import 'package:craits/MyWidget/imageSliderUrl.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/MyWidget/followDialog.dart';
import 'package:craits/Common/com.dart';
import 'package:share/share.dart';
//피드 탭

class FeedSearch extends StatefulWidget {
  FeedSearch({Key key, this.searchKeyword}) : super(key: key);
  final String searchKeyword;

  @override
  FeedSearchState createState() => FeedSearchState();
}

class FeedSearchState extends State<FeedSearch> {
  final uri = Uri.parse(commonUri+ '/V1/Feed/FeedList.json');
  JFeedList feedList;
  int count = 0;
  ScrollController scrollController;
  int iSearchPageNo = 1;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  bool bLoading = true;
  bool bNetworkErr = false;
  String searchKeyword;

  @override
  void initState() {
    searchKeyword = widget.searchKeyword;
    getData();
    scrollController = ScrollController()
    ..addListener(() {
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent && !bMoreData){
        getMoreData();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchKeyword' : searchKeyword,
        'searchPageNo' : iSearchPageNo.toString(),  //페이지 번호. 기본:1
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
          duration: const Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      }

      if(mounted)
        setState(() {
          feedList = _feedList;
          if(feedList != null && feedList.list!= null)
            count = feedList.list.length;
        });
        
      if(mounted)
        setState(() {
          feedList = _feedList;
          bLoading = false;
      });
    } on TimeoutException catch(_){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
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
          duration: const Duration(milliseconds: 1500),
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
        'searchTargetUserId' : ' ',
        'searchKeyword' : searchKeyword,
        'searchPageNo' : (++iSearchPageNo).toString(),  //페이지 번호. 기본:1
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
            duration: const Duration(milliseconds: 1500),
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
          count = feedList.list.length;
          bMoreData = false;    
        });
    } 
    on TimeoutException catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
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
          duration: const Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      (searchKeyword!= null && searchKeyword.trim().length > 0)?
      Column(
        children: [
          Expanded(
            flex: 1,
            child:
              bLoading?
               bNetworkErr?
                  Center(
                    child:Container(
                      height: MediaQuery.of(context).size.height - 250,
                      child: NetworkErr(onRetry:getData)
                    ))
                  : Center(
                    child: CircularProgressIndicator())
               : RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  onRefresh: getData,
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
      )
      : Container(),
    );
  }

  // 피드 리스트뷰
  ListView feedListview(){
    return ListView.separated(
    physics: AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemBuilder:(context, index){
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
      separatorBuilder: (context, index){
        return Divider(thickness: 10, color: Color(0xFFF2F4F6), height: 10,);
      }, 
      itemCount: bMoreData? feedList.list.length + 1 : feedList.list.length
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
  String sReplyCnt;

  @override
  void initState() {
    sLikeFlag = widget.feedListUnit.likeFlag.toString();
    iLikeCnt = int.tryParse(widget.feedListUnit.likeCnt.toString());
    sReplyCnt = widget.feedListUnit.commentCnt.toString();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
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
                    Text('${widget.feedListUnit.regDt}', style: Theme.of(context).textTheme.caption ),
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
        if(widget.feedListUnit.feedImageList!= null && widget.feedListUnit.feedImageList.length > 0)
          imageSlider(widget.feedListUnit.feedImageList),
        Container(
          constraints: BoxConstraints(
            minHeight: 70,
            minWidth: double.infinity
            ),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextConvertHashTag(text: widget.feedListUnit.content , feed: widget.feedListUnit, clickable: false),
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
                              if(sLikeFlag == 'Y'){ 
                                sLikeFlag = 'N';
                                iLikeCnt --;
                                like(sLikeFlag).then((value) {
                                  if(value != null)
                                    setState(() {
                                      iLikeCnt = int.parse(value.toString());
                                    });
                                });
                              }
                              else{
                                sLikeFlag = 'Y';
                                iLikeCnt ++;
                                like(sLikeFlag).then((value) {
                                  if(value != null)
                                    setState(() {
                                      iLikeCnt = int.parse(value.toString());
                                    });
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
    ],);
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
          duration: const Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
    }
    on TimeoutException catch(_) {
        Navigator.pop(context); //로딩끝
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
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
          duration: const Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
    }
    on TimeoutException catch(_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
    return null;
  }
}

