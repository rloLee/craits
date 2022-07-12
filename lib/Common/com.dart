import 'package:craits/_JClass/login.dart';
import 'package:craits/_JClass/profileInfo.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

// final String commonUri = 'http://192.168.0.200:8080/CRATIS';
// final String commonUri = 'http://121.180.79.180:8181/CRATIS';
final String commonUri = 'http://craits.com:8080/CRATIS';

String naverClientId = 'k4mo4exrnb';
String naverClientSecretId = 'FVpXCStwvhgjPBJzxP5S4a5XfvKglUDKpHXjq12Y';
JLoginInfo user;
JProfileInfoDetail profile;

double dCurLat = 37.563600; //현재위도
double dCurLong = 126.962370; //현재경도
String sLocation = '';
String sSigungu = '';
String sSido = '';
String sSearchLocation;
String sSearchSigungu;
String sSearchSido;

Duration timeoutDuration = Duration(seconds: 15);

Future<Uri> getDynamicLink(String feedId) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://craits.page.link',
      link: Uri.parse('https://craits.page.link/feed?code=$feedId'),
      androidParameters: AndroidParameters(
        packageName: 'com.dw.craits',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.dawool.craits',
        minimumVersion: '1.0',
        appStoreId: '', //TODO: APPSTORE ID
      ));

  final ShortDynamicLink shortLink = await parameters.buildShortLink();
  Uri url = shortLink.shortUrl;
  return url;
}

String medicineType(String code) {
  String rtnType = '';
  switch (code) {
    case 'DUP':
      rtnType = '중복처방';
      break;
    case 'WRONG':
      rtnType = '오처방';
      break;
    case 'ALTER':
      rtnType = '대체의약품';
      break;
    default:
      rtnType = '';
      break;
  }
  return rtnType;
}

String medicineTypes(String typeCode) {
  List<String> typeCodeList = typeCode.split(',');
  List<String> typeValueList = [];
  String rtnType = '';

  typeCodeList.forEach((code) {
    String value = '';
    switch (code) {
      case 'DUP':
        rtnType = '중복처방';
        break;
      case 'WRONG':
        rtnType = '오처방';
        break;
      case 'DUR':
        rtnType = '주의사항';
        break;
      default:
        value = '';
        break;
    }
    typeValueList.add(value);
  });

  String rtn = typeValueList.join(',');
  return rtn;
}

String medicineDurs(String durCode) {
  List<String> durCodeList = durCode.split(',');
  List<String> durValueList = [];

  durCodeList.forEach((code) {
    String value = '';
    switch (code) {
      case 'USE':
        value = '병용금기';
        break;
      case 'AGE':
        value = '특정연령대금기';
        break;
      case 'PREGNANT':
        value = '임부금기';
        break;
      case 'EFFECT':
        value = '효능군중복주의';
        break;
      case 'VOLUME':
        value = '용량주의';
        break;
      case 'PERIOD':
        value = '투여기간주의';
        break;
      case 'OLDER':
        value = '노인주의';
        break;
      default:
        value = '';
        break;
    }
    durValueList.add(value);
  });

  String rtn = durValueList.join(',');
  return rtn;
}
