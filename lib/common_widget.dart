import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:letselevator/common_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constant.dart';
import 'my_home_extension.dart';

BoxDecoration metalDecoration() =>
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: metalSort,
        colors: metalColor,
      )
    );

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

SpeedDialChild info1000Buttons(BuildContext context, double width) =>
    speedDialChildToLink(width,
      CupertinoIcons.info,
      AppLocalizations.of(context)!.buttons,
      Localizations.localeOf(context).languageCode.articleLink(),
    );

SpeedDialChild infoShimada(BuildContext context, double width) =>
    speedDialChildToLink(width,
      CupertinoIcons.info,
      AppLocalizations.of(context)!.shimada,
      Localizations.localeOf(context).languageCode.shimadaLink(),
    );

SpeedDialChild infoLetsElevator(BuildContext context, double width) =>
    speedDialChildToLink(width,
      CupertinoIcons.app,
      AppLocalizations.of(context)!.letsElevator,
      Localizations.localeOf(context).languageCode.elevatorLink(),
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

