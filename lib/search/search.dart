import 'dart:async';
import 'dart:convert';
import 'package:craits/search/search_medicine.dart';
import 'package:craits/search/search_pharmacy.dart';
import 'package:http/http.dart' as http;
import 'package:craits/Common/com.dart';
import 'package:craits/Home_Feed/feed_comment.dart';
import 'package:craits/Home_Feed/textConvertHashtag.dart';
import 'package:craits/_JClass/feedList.dart';
import 'package:craits/_JClass/registerLike.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyWidget/imageSliderUrl.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/MyWidget/okCancelDialog.dart';
import 'package:craits/MyWidget/followDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share/share.dart';
import 'search_hospital.dart';
import 'search_feed.dart';

GlobalKey<HospitalSearchState> globalHospitalKey = GlobalKey();
GlobalKey<PharmacySearchState> globalPharmacylKey = GlobalKey();
GlobalKey<MedicineSearchState> globalMedicinelKey = GlobalKey();
GlobalKey<FeedSearchState> globalFeedKey = GlobalKey();

class Search extends StatefulWidget {
  final String hashTagText ;
  Search({this.hashTagText});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with TickerProviderStateMixin{
  String searchKeyword;
  TabController tabController;
  // int tabIndex = 0;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    tabController =TabController(length: 4, vsync: this);
    if(widget.hashTagText != null) {
      searchController.text = widget.hashTagText;
      searchKeyword = searchController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: SvgPicture.asset('assets/arrowLeft.svg'),
              onPressed:(){
                Navigator.pop(context);
              },
            ),
            bottom: TabBar(
              controller: tabController,
              indicatorWeight: 3,
              tabs: <Widget>[
                Tab(text:'피드',),
                Tab(text:'병원'),
                Tab(text:'약국'),
                Tab(text:'약'),
              ],
            ),
            titleSpacing: 10,
            title: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    child: TextField(
                      cursorColor: Theme.of(context).primaryColor,
                      controller: searchController,
                      style: Theme.of(context).textTheme.bodyText1,
                      decoration: InputDecoration(
                        contentPadding:EdgeInsets.fromLTRB(10, 10, 10, 0), 
                        filled: true,
                        fillColor: Color(0xFFF3F3F3),
                        hintText:'통합검색',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                      ),
                      
                      onEditingComplete: (){
                        FocusScope.of(context).unfocus();
                        setState(() {
                          searchKeyword = searchController.text;
                          if(tabController.index == 0){
                            globalFeedKey.currentState.searchKeyword = searchKeyword;
                            globalFeedKey.currentState.getData();
                          }
                          else if (tabController.index == 1){
                            globalHospitalKey.currentState.searchKeyword = searchKeyword;
                            globalHospitalKey.currentState.getData();
                          }
                          else if (tabController.index == 2){
                            globalPharmacylKey.currentState.searchKeyword = searchKeyword;
                            globalPharmacylKey.currentState.getData();
                          }
                          else if (tabController.index == 3){
                            globalMedicinelKey.currentState.searchKeyword = searchKeyword;
                            globalMedicinelKey.currentState.getData();
                          }
                        });

                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Builder(builder: (context){
              return MaterialButton(
                minWidth: 0,
                child: SvgPicture.asset('assets/search.svg', fit: BoxFit.none,),
                onPressed: (){
                  FocusScope.of(context).unfocus();
                  setState(() {
                    searchKeyword = searchController.text;
                    if(tabController.index == 0){
                      globalFeedKey.currentState.searchKeyword = searchKeyword;
                      globalFeedKey.currentState.getData();
                    }
                    else if (tabController.index == 1){
                      globalHospitalKey.currentState.searchKeyword = searchKeyword;
                      globalHospitalKey.currentState.getData();
                    }
                    else if (tabController.index == 2){
                      globalPharmacylKey.currentState.searchKeyword = searchKeyword;
                      globalPharmacylKey.currentState.getData();
                    }
                    else if (tabController.index == 3){
                      globalMedicinelKey.currentState.searchKeyword = searchKeyword;
                      globalMedicinelKey.currentState.getData();
                    }
                  });
                });
              },)
            ],
            centerTitle: true,
            iconTheme:IconThemeData(color:Colors.black),
            backgroundColor: Colors.white,
            elevation: 1.0,
          ),
          body:TabBarView(
            controller: tabController,
            children: <Widget>[
              FeedSearch(key: globalFeedKey,searchKeyword: searchKeyword),      
              HospitalSearch(key: globalHospitalKey,searchKeyword: searchKeyword),
              PharmacySearch(key: globalPharmacylKey,searchKeyword: searchKeyword),
              MedicineSearch(key: globalMedicinelKey,searchKeyword: searchKeyword),
            ],
          ),
        ),
      ),
    );
  }
}

//피드 낱개
class FeedUnit extends StatefulWidget {
  final JFeedListUnit feedListUnit;
  final Function onDelete;
  FeedUnit({this.feedListUnit, this.onDelete});

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
                              if(sLikeFlag == 'Y') { 
                                sLikeFlag = 'N';
                                iLikeCnt --;
                                like(sLikeFlag).then((value) {
                                  if(value != null)
                                    setState(() {
                                      iLikeCnt = int.parse(value.toString());
                                    });
                                });
                              }
                              else {
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


