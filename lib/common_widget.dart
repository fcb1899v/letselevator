import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'my_home_extension.dart';

const blackColor = Color.fromRGBO(56, 54, 53, 1);
const metalColor1 = Colors.black12;
const metalColor2 = Colors.white24;
const metalColor3 = Colors.white54;
const metalColor4 = Colors.white10;
const metalColor5 = Colors.black12;
const transpColor = Colors.transparent;

BoxDecoration metalDecoration() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: [0.1, 0.3, 0.4, 0.7, 0.9],
      colors: [metalColor1, metalColor2, metalColor3, metalColor4, metalColor5],
    )
  );
}

ButtonStyle rectangleButtonStyle(Color color) {
  return ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
      const EdgeInsets.all(4)
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        side: BorderSide(color: color, width: 5.0),
        borderRadius: BorderRadius.circular(10.0),
      )
    ),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: MaterialStateProperty.all<Color>(transpColor),
    foregroundColor: MaterialStateProperty.all<Color>(transpColor),
    shadowColor: MaterialStateProperty.all(transpColor),
    backgroundColor: MaterialStateProperty.all<Color>(blackColor),
  );
}

ButtonStyle circleButtonStyle(Color color) {
  return ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.all(5)
    ),
    shape: MaterialStateProperty.all<CircleBorder>(
      CircleBorder(side: BorderSide(color: color, width: 5.0)),
    ),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: MaterialStateProperty.all<Color>(transpColor),
    foregroundColor: MaterialStateProperty.all<Color>(transpColor),
    shadowColor: MaterialStateProperty.all(transpColor),
    backgroundColor: MaterialStateProperty.all<Color>(blackColor),
  );
}

ButtonStyle transparentButtonStyle() {
  return ButtonStyle(
    padding: MaterialStateProperty.all(EdgeInsets.zero),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: MaterialStateProperty.all<Color>(transpColor),
    foregroundColor: MaterialStateProperty.all<Color>(transpColor),
    shadowColor: MaterialStateProperty.all(transpColor),
    backgroundColor: MaterialStateProperty.all<Color>(transpColor),
  );
}

TextStyle speedDialTextStyle(double width) =>
    TextStyle(
      color: blackColor,
      fontWeight: FontWeight.bold,
      fontSize: width.speedDialFontSize(),
    );

SpeedDialChild speedDialChildToLink(double width, IconData iconData, String label, String link) =>
    SpeedDialChild(
      child: Icon(iconData, size: 50),
      label: label,
      labelStyle: speedDialTextStyle(width),
      labelBackgroundColor: Colors.white,
      foregroundColor: Colors.white,
      backgroundColor: transpColor,
      onTap: () async => launch(link),
    );


Widget adMobBannerWidget(double width, double height, BannerAd myBanner) =>
    SizedBox(
      width: width.admobWidth(),
      height: height.admobHeight(),
      child: AdWidget(ad: myBanner),
    );

Future<void> initPlugin() async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await Future.delayed(const Duration(milliseconds: 200));
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

