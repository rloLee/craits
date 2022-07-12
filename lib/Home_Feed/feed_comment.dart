import 'dart:async';
import 'dart:convert';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/okCancelDialog.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/feedList.dart';
import 'package:craits/_JClass/commentList.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:craits/MyWidget/imageSliderUrl.dart';
import 'package:http/http.dart' as http;
import 'package:craits/MyWidget/followDialog.dart';
import 'package:craits/_JClass/registerLike.dart';
import 'textConvertHashtag.dart';
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/loadingDialog.dart';

class FeedComment extends StatefulWidget {
  final JFeedListUnit feed;
  final String feedId;
  final Function onDelete;
  FeedComment({this.feed, @required this.onDelete, this.feedId});

  @override
  _FeedCommentState createState() => _FeedCommentState();
}

class _FeedCommentState extends State<FeedComment> {
  final TextEditingController commentController = TextEditingController();
  final TextEditingController replyController = TextEditingController();

  JFeedListUnit feed;
  JCommentList commentList;
  bool bLoading = true;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  int iSearchPageNo = 1;
  bool bReplying = false;
  String replyingCommentId;
  String replyingName;
  FocusNode myFocusNode;
  bool bNetworkErr = false;

  @override
  void initState() {
    myFocusNode = FocusNode();
    init();
    // scrollController = ScrollController()
    //   ..addListener(() {
    //     if (scrollController.position.pixels ==
    //           scrollController.position.maxScrollExtent &&
    //         !bMoreData) {
    //       getMoreData();
    //     }
    //   });
    super.initState();
  }

  Future init() async{
    if(widget.feed != null) {
      feed = widget.feed;
    }
    else {
      await getFeedData();
    }
    await getCommentData();
  }
  //피드 가져오기
  Future getFeedData() async {
    final uri = Uri.parse(commonUri + '/V1/Feed/FeedInfo.json');
    try {
      if(mounted)
        setState(() {
          bLoading = true;
          bNetworkErr = false;
        });

      var params = {
        'user_auth_id': user.userAuthId,
        'searchFeedId': widget.feedId.toString(), //피드 id
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JFeedInfo _feedInfo;
      if (response.statusCode == 200) {
        _feedInfo = JFeedInfo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
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
          feed = _feedInfo.info;
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
    catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  //댓글 가져오기
  Future getCommentData() async {
  final uri = Uri.parse(commonUri + '/V1/Feed/CommentList.json');
    try {
      if(mounted)
        setState(() {
          bLoading = true;
          bNetworkErr = false;
        });
      iSearchPageNo = 1;

      var params = {
        'user_auth_id': user.userAuthId,
        'searchFeedId': feed.feedId.toString(), //피드 id
        'searchPageNo': iSearchPageNo.toString(), //페이지 번호. 기본:1
        'searchPageSize': '200', //페이지 크기. 기본:10
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JCommentList _commentList;
      if (response.statusCode == 200) {
        _commentList =
            JCommentList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
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
          commentList = _commentList;
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
    catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  // Future getMoreCommentData() async {
  // final uri = Uri.parse(commonUri + '/V1/Feed/CommentList.json');
  //   try {
  //     setState(() {
  //       bMoreData = true;
  //     });

  //     var params = {
  //       'user_auth_id': user.userAuthId,
  //       'searchFeedId': feed.feedId.toString(), //피드 id
  //       'searchPageNo': (++iSearchPageNo).toString(), //페이지 번호. 기본:1
  //       'searchPageSize': '10', 
  //     };

  //     final newUri = uri.replace(queryParameters: params);
  //     http.Response response = await http.get(newUri);

  //     JCommentList _commentList;
  //     if (response.statusCode == 200) {
  //       _commentList =
  //           JCommentList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  //     } 
  //     else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           duration: Duration(milliseconds: 1500),
  //           content: Text('네트워크 오류가 발생했습니다.'))
  //         );
  //       }
  //       setState(() {
  //         commentList.list.addAll(_commentList.list);
  //         bMoreData = false;
  //       });
  //   } catch (_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         duration: Duration(milliseconds: 1500),
  //         content: Text('네트워크 오류가 발생했습니다.'))
  //       );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '피드',
          style: Theme.of(context).textTheme.headline5,
        ),
        centerTitle: true,
        elevation: 1.0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: 
          bLoading?  
            bNetworkErr?
              Center(
                child:Container(
                    height: MediaQuery.of(context).size.height - 250,
                    child: NetworkErr(onRetry:getCommentData)
                  ))
              : Center(
                child: CircularProgressIndicator(
                ))
          :Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  onRefresh: getCommentData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    // controller: scrollController,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: ClipOval(
                                  child: (feed.profileImageUrl != null)
                                      ? Image.network(
                                          feed.profileImageUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, exception, stackTrace) {
                                            return Image.asset(
                                                'assets/noProfile.png',
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover);
                                          },
                                        )
                                      : Image.asset('assets/noProfile.png',
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        feed.name,
                                        style:
                                            Theme.of(context).textTheme.headline3,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      if (feed.feedUserId != user.userId)
                                        feed.followFlag == 'Y'
                                            ? RichText(
                                                text: TextSpan(
                                                    text: '팔로잉',
                                                    style: Theme.of(context).textTheme.subtitle2,
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () { 
                                                            showDialog(
                                                                context: context,
                                                                builder: (context) =>
                                                                    FollowDialog(
                                                                        feed.feedUserId.toString(),
                                                                        feed.name,'N')).then(
                                                                (value) => {
                                                                      if (value !=null){
                                                                        setState(() {
                                                                          feed.followFlag = value;
                                                                        })}
                                                                    });
                                                          }))
                                            : RichText(
                                                text: TextSpan(
                                                    text: '팔로우',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle1,
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {
                                                            showDialog(
                                                                context: context,
                                                                builder: (context) =>
                                                                    FollowDialog(
                                                                        feed.feedUserId.toString(),
                                                                        feed.name,
                                                                        'Y')).then(
                                                                (value) => {
                                                                      if (value != null){
                                                                          setState(() {
                                                                            feed.followFlag = value;
                                                                          })
                                                                        }
                                                                    });
                                                          }))
                                    ],
                                  ),
                                  Text('${feed.elapsedTime}',
                                      style: Theme.of(context).textTheme.caption),
                                ],
                              )),
                              PopupMenuButton(
                                itemBuilder: (context) {
                                  return [
                                    if (feed.feedUserId == user.userId )
                                      PopupMenuItem(
                                        textStyle:
                                            Theme.of(context).textTheme.bodyText1,
                                        height: 35,
                                        value: '삭제하기',
                                        child: Text('삭제하기'),
                                      ),
                                    PopupMenuItem(
                                      textStyle:
                                          Theme.of(context).textTheme.bodyText1,
                                      height: 35,
                                      value: '신고하기',
                                      child: Text('신고하기'),
                                    )
                                  ];
                                },
                                onSelected: (value) {
                                  if (value == '삭제하기') {
                                    showDialog(
                                        context: context,
                                        builder: (context) => OkCancelDialog(
                                              text: '피드를 삭제하시겠습니까?',
                                              onOk: () {
                                                deleteFeed().then((resultCode) {
                                                  if (resultCode != null) {
                                                    if (resultCode == 'SUCC') {
                                                      if (widget.onDelete != null)
                                                        widget.onDelete();
                                                      Navigator.of(context).pop();
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          duration: Duration(milliseconds: 1500),
                                                          content: Text('오류가 발생했습니다.'))
                                                        );
                                                    }
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        duration: Duration(milliseconds: 1500),
                                                        content: Text('오류가 발생했습니다.'))
                                                      );
                                                  }
                                                  Navigator.pop(context);
                                                });
                                              },
                                            ));
                                  } else if (value == '신고하기') {
                                    showDialog(
                                        context: context,
                                        builder: (context) => OkCancelDialog(
                                              text: '이 피드를 신고하시겠습니까?',
                                              onOk: () {},
                                            ));
                                  }
                                },
                                icon: Icon(Icons.more_vert),
                              )
                            ],
                          ),
                        ),
                        if (feed.feedImageList.length > 0)
                          imageSlider(feed.feedImageList),
                        Container(
                          constraints: BoxConstraints(
                              minHeight: 70, minWidth: double.infinity),
                          width: double.infinity,
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: TextConvertHashTag(
                              text: feed.content,
                              feed: feed,
                              clickable: false),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Column(
                            children: [
                              Divider(),
                            ],
                          ),
                        ),
                        comment()
                      ],
                    ),
                  ),
                ),
              ),
              bReplying
                ? replyRegister(replyingCommentId, replyingName)
                : commentRegister()
            ],
          ),
      ),
    );
  }

  Future deleteFeed() async {
    final uri = Uri.parse(commonUri + '/V1/Feed/DeleteFeed.json');
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => LoadingDialog());

      var params = {
        'user_auth_id': user.userAuthId,
        'feed_id':
            feed.feedId.toString(), // FEED ID / COMMENT ID / REPLY ID
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      Navigator.pop(context); //로딩끝

      JResponse _response;
      if (response.statusCode == 200) {
        _response =
            JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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

  //답글 등록 창
  Container replyRegister(String replyingCommentId, String replyingName) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 30,
              width: double.infinity,
              color: const Color(0xFFF3F3F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('@$replyingName',
                      style: Theme.of(context).textTheme.bodyText2),
                  GestureDetector(
                    child: SvgPicture.asset(
                      'assets/close.svg',
                      height: 20,
                    ),
                    onTap: () {
                      setState(() {
                        replyController.clear();
                        bReplying = false;
                        replyingCommentId = null;
                        replyingName = null;
                      });
                    },
                  )
                ],
              )),
          Divider(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: TextField(
              focusNode: myFocusNode,
              cursorColor: Theme.of(context).primaryColor,
              controller: replyController,
              style: Theme.of(context).textTheme.bodyText1,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              minLines: 1,
              maxLength: 200,
              // keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  prefixStyle: Theme.of(context).textTheme.subtitle1,
                  prefixText: '@$replyingName ',
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  filled: true,
                  fillColor: Color(0xFFF3F3F3),
                  hintText: '댓글을 입력해 주세요.',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  suffixIcon: TextButton(
                      onPressed: () {
                        //등록버튼
                        registerReply(replyingCommentId,
                              '@$replyingName ' + replyController.text)
                            .then((resultCode) => {
                              if (resultCode == 'SUCC')
                                {
                                  bReplying = false,
                                  replyingCommentId = null,
                                  replyingName = null,
                                  // getRefreshData(),
                                  replyController.clear(),
                                  FocusScope.of(context).requestFocus(FocusNode()),
                                  getCommentData()
                                }
                              else{
                              }
                            });
                      },
                      child: Text('등록'))),
            ),
          ),
        ],
      ),
    );
  }

  //댓글 등록 창
  Container commentRegister() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(),
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: TextField(
              controller: commentController,
              style: Theme.of(context).textTheme.bodyText1,
              cursorColor: Theme.of(context).primaryColor,
              keyboardType: TextInputType.multiline,
              maxLength: 200,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                filled: true,
                fillColor: const Color(0xFFF3F3F3),
                hintText: '댓글을 입력해 주세요.',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                suffixIcon: TextButton(
                  onPressed: () {
                    registerComment(feed.feedId.toString(), commentController.text)
                      .then((resultCode){
                        if (resultCode == 'SUCC') {
                          commentController.clear();
                          FocusScope.of(context).requestFocus(FocusNode());
                          getCommentData();
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(milliseconds: 1500),
                              content: Text('오류가 발생했습니다.'))
                          );
                        }
                      });
                  },
                  child: Text('등록'))),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageSlider(List<JFeedListUnitFeedImage> imageList) {
    List<String> list = [];
    imageList.forEach((element) {
      list.add(element.imageUrl);
    });
    return ImageUrlSlider(list);
  }

  ListView comment() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          if (index == commentList.list.length)
            return Center(
              child: CircularProgressIndicator(
              ),
              widthFactor: 0.5,
              heightFactor: 2,
            );
          else
            return CommentUnit(
              commentListUnit: commentList.list[index],
              onReply: (id, name) {
                setState(() {
                  FocusScope.of(context).requestFocus(myFocusNode);
                  commentController.clear();
                  bReplying = true;
                  replyingCommentId = id.toString();
                  replyingName = name.toString();
                });
              },
              onDelete: () {
                setState(() {
                  commentList.list.removeAt(index);
                });
              },
            );
        },
        itemCount:
            bMoreData ? commentList.list.length + 1 : commentList.list.length);
  }

  //댓글 등록하기
  Future registerComment(String feedId, String content) async {
    final uri = Uri.parse(commonUri + '/V1/Feed/RegisterComment.json');
    try {
      var params = {
        'user_auth_id': user.userAuthId,
        'feed_id': feedId.toString(),
        'content': content
      };
      showDialog(context: context, builder: (context) => LoadingDialog()); //로딩

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      Navigator.pop(context); //로딩끝

      JResponse _response;
      if (response.statusCode == 200) {
        _response =
            JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        return _response.resultCode;
      } 
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
      }
    } on TimeoutException catch(_) {
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

  //답글 등록하기
  Future registerReply(String commentId, String content) async {
    final uri = Uri.parse(commonUri + '/V1/Feed/RegisterReply.json');
    try {
      var params = {
        'user_auth_id': user.userAuthId,
        'comment_id': commentId.toString(),
        'content': content
      };
      showDialog(context: context, builder: (context) => LoadingDialog()); //로딩

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      Navigator.pop(context); //로딩끝

      JResponse _response;
      if (response.statusCode == 200) {
        _response = JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_response.resultCode == 'FAIL')
            showDialog(context: context, builder: (context) => OkDialog(text: _response.resultMsg, onOk: (){}));
        return _response.resultCode;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
      }
    } on TimeoutException catch(_) {
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

class CommentUnit extends StatefulWidget {
  final JCommentListUnit commentListUnit;
  final Function(String commentId, String name) onReply;
  final Function onDelete;
  CommentUnit(
      {@required this.commentListUnit,
      @required this.onReply,
      @required this.onDelete});

  @override
  _CommentUnitState createState() => _CommentUnitState();
}

class _CommentUnitState extends State<CommentUnit> {
  String sLikeFlag;

  @override
  void initState() {
    super.initState();
    sLikeFlag = widget.commentListUnit.likeFlag;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(right: 15),
            child: ClipOval(
              child: (widget.commentListUnit.profileImageUrl != null)
                  ? Image.network(
                      widget.commentListUnit.profileImageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, exception, stackTrace) {
                        return Image.asset('assets/noProfile.png',
                            width: 40, height: 40, fit: BoxFit.cover);
                      },
                    )
                  : Image.asset('assets/noProfile.png',
                      width: 40, height: 40, fit: BoxFit.cover),
            ),
          ),
          Expanded(
            child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.commentListUnit.name,
                          style: TextStyle(
                            color: const Color(0xFF232323),
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                        ),
                        Text(
                          widget.commentListUnit.content,
                          style: TextStyle(
                            color: Color(0xFF232323),
                            fontSize: 13,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.commentListUnit.elapsedTime,
                              style: TextStyle(
                                color: Color(0xFF8B8B8B),
                                fontSize: 11,
                              ),
                            ),
                            MaterialButton(
                              child: sLikeFlag == 'Y'
                                  ? SvgPicture.asset('assets/likeSmall_o.svg')
                                  : SvgPicture.asset('assets/likeSmall_x.svg'),
                              onPressed: () {
                                //좋아요처리
                                setState(() {
                                  if (sLikeFlag == 'Y') {
                                    sLikeFlag = 'N';
                                    like(sLikeFlag);
                                    // iLikeCnt --;
                                    // like(sLikeFlag).then((value) =>
                                    // {
                                    //   if(value != null)
                                    //     iLikeCnt = int.parse(value)
                                    // });
                                  } else {
                                    sLikeFlag = 'Y';
                                    like(sLikeFlag);
                                    // iLikeCnt ++;
                                    // like(sLikeFlag).then((value) =>
                                    // {
                                    //   if(value != null)
                                    //     iLikeCnt = int.parse(value)
                                    // });
                                  }
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              minWidth: 30,
                              height: 20,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            MaterialButton(
                              child:
                                  SvgPicture.asset('assets/commentSmall.svg'),
                              onPressed: () {
                                widget.onReply(
                                    widget.commentListUnit.id.toString(),
                                    widget.commentListUnit.name.toString());
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              minWidth: 30,
                              height: 20,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        if (widget.commentListUnit.commentUserId == user.userId)
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
                    onSelected: (value) {
                      if (value == '삭제하기') {
                        showDialog(
                            context: context,
                            builder: (context) => OkCancelDialog(
                                  text: '댓글을 삭제하시겠습니까?',
                                  onOk: () {
                                    deleteComment().then((resultCode) {
                                      if (resultCode != null) {
                                        if (resultCode == 'SUCC') {
                                          widget.onDelete();
                                        } 
                                        else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              duration: Duration(milliseconds: 1500),
                                              content: Text('오류가 발생했습니다.'))
                                            );
                                        }
                                      } 
                                      else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            duration: Duration(milliseconds: 1500),
                                            content: Text('오류가 발생했습니다.'))
                                          );
                                      }
                                      Navigator.pop(context);
                                    });
                                  },
                                ));
                      } else if (value == '신고하기') {
                        showDialog(
                            context: context,
                            builder: (context) => OkCancelDialog(
                                  text: '이 피드를 신고하시겠습니까?',
                                  onOk: () {},
                                ));
                      }
                    },
                    icon: SvgPicture.asset('assets/more_vert.svg'),
                  )
                ],
              ),
              if (widget.commentListUnit.replyList != null &&
                  widget.commentListUnit.replyList.length > 0)
                commentReply()
            ],
          )),
        ],
      ),
    );
  }

  Future deleteComment() async {
    final uri = Uri.parse(commonUri + '/V1/Feed/DeleteComment.json');
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => LoadingDialog());
          
      var params = {
        'user_auth_id': user.userAuthId,
        'comment_id': widget.commentListUnit.id
            .toString(), // FEED ID / COMMENT ID / REPLY ID
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      Navigator.pop(context); //로딩끝

      JResponse _response;
      if (response.statusCode == 200) {
        _response =
            JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        return _response.resultCode;
      } else {
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

  ListView commentReply() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return CommentRelplyUnit(
            replyUnit: widget.commentListUnit.replyList[index],
            commentUnit: widget.commentListUnit,
            onReply: widget.onReply,
            onDelete: () {
              widget.commentListUnit.replyList.removeAt(index);
            },
          );
        },
        itemCount: widget.commentListUnit.replyList.length);
  }

  //댓글에 좋아요
  Future like(String sFlag) async {
    final uri = Uri.parse(commonUri + '/V1/Like/RegisterLike.json');
    try {
      var params = {
        'user_auth_id': user.userAuthId,
        'flag': sFlag, //"Y" : 등록 / "N" : 취소
        'type': 'COMMENT', //타입 (FEED / COMMENT/ REPLY)
        'id': widget.commentListUnit.id
            .toString(), // FEED ID / COMMENT ID / REPLY ID
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(Duration(seconds: 3));

      JRegisterLike _registerLike;
      if (response.statusCode == 200) {
        _registerLike =
            JRegisterLike.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        return _registerLike.info.cnt;
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
}

class CommentRelplyUnit extends StatefulWidget {
  final JCommentListUnit commentUnit;
  final JCommentListUnitReplyListUnit replyUnit;
  final Function(String commentId, String name) onReply;
  final Function onDelete;

  CommentRelplyUnit({
    @required this.commentUnit,
    @required this.replyUnit,
    @required this.onReply,
    @required this.onDelete,
  });

  @override
  _CommentRelplyUnitState createState() => _CommentRelplyUnitState();
}

class _CommentRelplyUnitState extends State<CommentRelplyUnit> {
  String sLikeFlag;

  @override
  void initState() {
    super.initState();
    sLikeFlag = widget.replyUnit.likeFlag;
  }

  //답글에 좋아요
  Future like(String sFlag) async {
    final uri = Uri.parse(commonUri + '/V1/Like/RegisterLike.json');
    try {
      var params = {
        'user_auth_id': user.userAuthId,
        'flag': sFlag, //"Y" : 등록 / "N" : 취소
        'type': 'REPLY', //타입 (FEED / COMMENT/ REPLY)
        'id': widget.replyUnit.id.toString(), // FEED ID / COMMENT ID / REPLY ID
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(Duration(seconds: 3));

      JRegisterLike _registerLike;
      if (response.statusCode == 200) {
        _registerLike =
            JRegisterLike.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        return _registerLike.info.cnt;
      } 
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: EdgeInsets.only(right: 15),
            child: ClipOval(
              child: (widget.replyUnit.profileImageUrl != null)
                  ? Image.network(
                      widget.replyUnit.profileImageUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, exception, stackTrace) {
                        return Image.asset('assets/noProfile.png',
                            width: 40, height: 40, fit: BoxFit.cover);
                      },
                    )
                  : Image.asset('assets/noProfile.png',
                      width: 32, height: 32, fit: BoxFit.cover),
            ),
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.replyUnit.name,
                style: TextStyle(
                    color: Color(0xFF232323),
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              TextConvertUserTag(widget.replyUnit.content),
              // Text(widget.replyUnit.content, style: TextStyle(color: Color(0xFF232323), fontSize: 12, ),),
              Row(
                children: [
                  Text(
                    widget.replyUnit.elapsedTime,
                    style: TextStyle(
                      color: Color(0xFF8B8B8B),
                      fontSize: 10,
                    ),
                  ),
                  MaterialButton(
                    child: sLikeFlag == 'Y'
                        ? SvgPicture.asset('assets/likeSmall_o.svg')
                        : SvgPicture.asset('assets/likeSmall_x.svg'),
                    onPressed: () {
                      //좋아요처리
                      setState(() {
                        if (sLikeFlag == 'Y') {
                          sLikeFlag = 'N';
                          like(sLikeFlag);
                          // iLikeCnt --;
                          // like(sLikeFlag).then((value) =>
                          // {
                          //   if(value != null)
                          //     iLikeCnt = int.parse(value)
                          // });
                        } else {
                          sLikeFlag = 'Y';
                          like(sLikeFlag);
                          // iLikeCnt ++;
                          // like(sLikeFlag).then((value) =>
                          // {
                          //   if(value != null)
                          //     iLikeCnt = int.parse(value)
                          // });
                        }
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minWidth: 30,
                    height: 20,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  MaterialButton(
                    child: SvgPicture.asset('assets/commentSmall.svg'),
                    onPressed: () {
                      widget.onReply(widget.commentUnit.id.toString(),
                          widget.replyUnit.name);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minWidth: 30,
                    height: 20,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ],
              ),
            ],
          )),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                if (widget.replyUnit.repliyUserId == user.userId)
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
            onSelected: (value) {
              if (value == '삭제하기') {
                showDialog(
                    context: context,
                    builder: (context) => OkCancelDialog(
                          text: '댓글을 삭제하시겠습니까?',
                          onOk: () {
                            deleteReply().then((resultCode) {
                              if (resultCode != null) {
                                if (resultCode == 'SUCC') {
                                  widget.onDelete();
                                } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(milliseconds: 1500),
                                        content: Text('오류가 발생했습니다.'))
                                      );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(milliseconds: 1500),
                                    content: Text('오류가 발생했습니다.'))
                                  );
                              }
                              Navigator.pop(context);
                            });
                          },
                        ));
              } 
              else if (value == '신고하기') {
                showDialog(
                  context: context,
                  builder: (context) => OkCancelDialog(
                        text: '이 피드를 신고하시겠습니까?',
                        onOk: () {},
                      ));
              }
            },
            icon: SvgPicture.asset('assets/more_vert.svg'),
          )
        ],
      ),
    );
  }

  Future deleteReply() async {
    final uri = Uri.parse(commonUri + '/V1/Feed/DeleteReply.json');
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => LoadingDialog());
      var params = {
        'user_auth_id': user.userAuthId,
        'reply_id':
            widget.replyUnit.id.toString(), // FEED ID / COMMENT ID / REPLY ID
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      Navigator.pop(context); //로딩끝

      JResponse _response;
      if (response.statusCode == 200) {
        _response =
            JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        return _response.resultCode;
      } else {
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
}

class TextConvertUserTag extends StatelessWidget {
  TextConvertUserTag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> textSpans = [];
    final RegExp regex = RegExp(r"\@[a-zA-Zㄱ-ㅎ가-힣0-9]+");
    Match match = regex.firstMatch(text);
    if (match != null) {
      textSpans.add(TextSpan(
          text: match.group(0), style: Theme.of(context).textTheme.button));
      textSpans.add(TextSpan(
          text: text.substring(match.end, text.length),
          style: TextStyle(
            color: Color(0xFF232323),
            fontSize: 12,
          )));
    } else {
      textSpans.add(TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 14.0,
            color: Color(0xFF262626),
          )));
    }
    return Text.rich(TextSpan(
      children: textSpans,
    ));
  }
}
