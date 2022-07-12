import 'package:carousel_slider/carousel_slider.dart';
import 'package:craits/MyWidget/imageViewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageUrlSlider extends StatefulWidget {
  final List<String> urlList;
  ImageUrlSlider(this.urlList);

  @override
  _ImageUrlSliderState createState() => _ImageUrlSliderState();
}

class _ImageUrlSliderState extends State<ImageUrlSlider> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      Container(
        child: CarouselSlider.builder(
          itemCount: widget.urlList.length,
          itemBuilder: (context, imageindex, realIdx) {
            return InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => NetworkImagesViewer(urlList: widget.urlList, index: imageindex,)));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Center(
                  child: widget.urlList[imageindex] != null
                    ? Image.network(
                        widget.urlList[imageindex],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) =>
                          (loadingProgress == null) ? child : CircularProgressIndicator(),
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
              viewportFraction: (widget.urlList.length > 1) ? 0.9 : 1,
              aspectRatio: 1.5,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }),
        ),
      ),
      if (widget.urlList.length > 1)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.urlList.map((url) {
            int index = widget.urlList.indexOf(url);
            return Container(
              width: 6.0,
              height: 6.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == index
                    ? Theme.of(context).primaryColor.withOpacity(0.8)
                    : Color.fromRGBO(0, 0, 0, 0.2),
              ),
            );
          }).toList(),
        ),
    ]);
  }
}
