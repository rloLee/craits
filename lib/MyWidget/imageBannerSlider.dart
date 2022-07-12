import 'package:carousel_slider/carousel_slider.dart';
import 'package:craits/_JClass/bannerList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageBannerSlider extends StatefulWidget {
  final List<JBannerListUnit> bannerList;
  ImageBannerSlider(this.bannerList);

  @override
  _ImageBannerSliderState createState() => _ImageBannerSliderState();
}

class _ImageBannerSliderState extends State<ImageBannerSlider> {
  CarouselController controller;
  int _current = 0;


  @override
  void initState() {
    controller = CarouselController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: CarouselSlider.builder(
            carouselController: controller,
            itemCount: widget.bannerList.length,
            itemBuilder: (context, imageindex, realIdx) {
              return InkWell(
                onTap: (){
                  //인터넷 URL 링크 연결
                  _launchInBrowser(widget.bannerList[imageindex].urlLink);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Center(
                    child: widget.bannerList[imageindex] != null? 
                      Image.network(
                        widget.bannerList[imageindex].imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        filterQuality: FilterQuality.low,
                        scale: 0.2,
                        loadingBuilder: (context, child, loadingProgress) =>
                          (loadingProgress == null) ?
                          child : CircularProgressIndicator(),
                        errorBuilder: (context, exception, stackTrace) {
                          return SvgPicture.asset('assets/noImage.svg', width: double.infinity,
                              fit: BoxFit.fitWidth);
                        },
                      )
                      : SvgPicture.asset(
                          'assets/noImage.svg',
                          fit: BoxFit.fitWidth,
                        )),
                ),
              );
            },
            options: CarouselOptions(
              autoPlay: false,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              viewportFraction: 1,
              aspectRatio: 2,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
          ),
        ),
        if(_current > 0)
          Positioned(
            top: 60,
            left: 30,
            bottom: 60,
            child: InkWell(
              onTap: (){
                controller.previousPage();
              },
              child: Icon(Icons.chevron_left, color: const Color(0xFF333333), size: 30,)
            ),
          ),
        if(_current < widget.bannerList.length - 1)
          Positioned(
            top: 60,
            right: 30,
            bottom: 60,
            child: InkWell(
              onTap: (){
                controller.nextPage();
              },
              child: Icon(Icons.chevron_right, color: const Color(0xFF333333), size: 30,)
            ),
          ),
      ],
    );
  }
}

Future<void> _launchUniversalLinkIos(String url) async {
  if (await canLaunch(url)) {
    final bool nativeAppLaunchSucceeded = await launch(
      url,
      forceSafariVC: false,
      universalLinksOnly: true,
    );
    if (!nativeAppLaunchSucceeded) {
      await launch(
        url,
        forceSafariVC: true,
      );
    }
  }
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