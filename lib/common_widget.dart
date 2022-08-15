import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'extension.dart';
import 'constant.dart';

Future<void> initPlugin() async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await Future.delayed(const Duration(milliseconds: 200));
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

BoxDecoration metalDecoration() =>
    const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: metalSort,
        colors: metalColor,
      )
    );

Widget menuLogo(BuildContext context) =>
    SizedBox(
      width: context.width().menuTitleWidth(),
      child: Image.asset(appLogo),
    );

Text menuTitle(BuildContext context) =>
    Text(context.menu(),
      style: TextStyle(
        color: blackColor,
        fontSize: context.width().menuTitleFontSize(),
        fontWeight: FontWeight.bold,
        fontFamily: menuFont,
      ),
    );

Text menuText(BuildContext context, String label) =>
    Text(" $label",
      style: TextStyle(
        color: blackColor,
        fontSize: context.width().menuListFontSize(),
        fontWeight: FontWeight.bold,
        fontFamily: menuFont,
        decoration: TextDecoration.underline,
      )
    );

Icon menuIcon(BuildContext context, IconData icon) =>
    Icon(icon,
      size: context.width().menuListIconSize(),
      color: lampColor,
    );

TextButton linkButton(BuildContext context, IconData icon, String label, String link) =>
    TextButton.icon(
      label:menuText(context, label),
      icon: menuIcon(context, icon),
      onPressed: () async => launchUrl(Uri.parse(link)),
    );

TextButton linkLetsElevator(BuildContext context) =>
    TextButton.icon(
      label:menuText(context, context.letsElevator()),
      icon: menuIcon(context, CupertinoIcons.app),
      onPressed: () async => launchUrl(Uri.parse(context.elevatorLink())),
    );

TextButton linkOnlineShop(BuildContext context) =>
    TextButton.icon(
      label:menuText(context, context.onlineShop()),
      icon: menuIcon(context, CupertinoIcons.cart),
      onPressed: () async => launchUrl(Uri.parse(context.shopLink())),
    );

TextButton linkShimax(BuildContext context) =>
    TextButton.icon(
      label:menuText(context, context.shimax()),
      icon: menuIcon(context, CupertinoIcons.info),
      onPressed: () async => launchUrl(Uri.parse(context.shimaxLink())),
    );

TextButton link1000Buttons(BuildContext context) =>
    TextButton.icon(
      label:menuText(context, context.buttons()),
      icon: menuIcon(context, CupertinoIcons.info),
      onPressed: () async => launchUrl(Uri.parse(context.articleLink())),
    );

TextButton changePageButton(BuildContext context, bool flag) =>
    TextButton.icon(
      label:menuText(context, context.modeChangeLabel(flag)),
      icon: menuIcon(context, CupertinoIcons.arrow_2_circlepath),
      onPressed: () async {
        changePageSound.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        (flag ? "/r": "/h").pushPage(context);
      },
    );

Widget snsButton(BuildContext context, String logo, String link) =>
    SizedBox(
      width: context.height().menuSnsLogoSize(),
      height: context.height().menuSnsLogoSize(),
      child: IconButton(
        icon: SvgPicture.asset(logo, color: lampColor),
        onPressed: () async => launchUrl(Uri.parse(link))
      ),
    );

Widget overLay(BuildContext context) =>
    Container(
      width: context.width(),
      height: context.height(),
      color: transpWhiteColor,
    );

Widget adMobBannerWidget(BuildContext context, BannerAd myBanner) =>
    SizedBox(
      width: context.width().admobWidth(),
      height: context.height().admobHeight(),
      child: AdWidget(ad: myBanner),
    );

// 階数の表示
Widget displayArrowNumber(double width, double height, bool isShimada, String arrow, String number) =>
    Container(
      padding: EdgeInsets.only(top: height.displayPadding()),
      width: width.displayWidth(),
      height: height.displayHeight(),
      color: darkBlackColor,
      child: Stack(alignment: Alignment.center, children: [
        Image(
          color: blackColor,
          height: height.shimadaLogoHeight(),
          image: AssetImage(isShimada.shimadaLogo()),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(),
          SizedBox(
            width: height.displayArrowWidth(),
            height: height.displayArrowHeight(),
            child: Image.asset(arrow),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: height.displayNumberWidth(),
            height: height.displayNumberHeight(),
            child: Text(number,
              style: TextStyle(
                color: lampColor,
                fontSize: height.displayNumberFontSize(),
                fontWeight: FontWeight.normal,
                fontFamily: numberFont,
              ),
            ),
          ),
          const Spacer(),
        ]),
      ]),
    );

Widget floorButtonImage(double height, int i, bool isShimada, bool isSelected,) =>
    SizedBox(
      width: height.floorButtonSize(),
      height: height.floorButtonSize(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(i.numberBackground(isShimada, isSelected, max)),
          Text(i.buttonNumber(max, isShimada),
            style: TextStyle(
              color: (isSelected) ? lampColor: whiteColor,
              fontSize: height.buttonNumberFontSize(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

Widget operationButtonImage(String operation, double height, bool isShimada, bool isPressedButton) =>
    SizedBox(
      width: height.operationButtonSize(),
      height: height.operationButtonSize(),
      child: Image.asset(
        (operation == "open") ? isShimada.openBackGround(isPressedButton):
        (operation == "close") ? isShimada.closeBackGround(isPressedButton):
        isShimada.phoneBackGround(isPressedButton)
      ),
    );

ButtonStyle operationButtonStyle(double height, Color color, bool isCircle) =>
    ButtonStyle(
      shape: MaterialStateProperty.all(
        isCircle ? CircleBorder(
          side: BorderSide(color: color, width: height.buttonBorderWidth())
        ): RoundedRectangleBorder(
          side: BorderSide(color: color, width: height.buttonBorderWidth()),
          borderRadius: BorderRadius.circular(height.buttonBorderRadius()),
        ),
      ),
      padding: MaterialStateProperty.all(
        EdgeInsets.all(height.operationButtonPadding())
      ),
      minimumSize: MaterialStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

ButtonStyle transparentButtonStyle() {
  return ButtonStyle(
    shape: MaterialStateProperty.all(null),
    padding: MaterialStateProperty.all(EdgeInsets.zero),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: MaterialStateProperty.all(transpColor),
    foregroundColor: MaterialStateProperty.all(transpColor),
    shadowColor: MaterialStateProperty.all(transpColor),
    backgroundColor: MaterialStateProperty.all(transpColor),
  );
}

///1000 Buttons
// 通常ボタンの画像
Widget buttonImage(double buttonWidth, double buttonHeight, double buttonPadding, String image) =>
    Container(
      width: buttonWidth,
      height: buttonHeight,
      padding: EdgeInsets.all(buttonPadding),
      alignment: Alignment.center,
      child: Image.asset(image),
    );

Widget normalButtonImage(int i, int j, double height, String image) =>
    buttonImage(height.buttonWidth(i, j), height.buttonHeight(), height.paddingSize(), image);

// 大サイズボタンの画像
Widget largeButtonImage(double hR, double vR, double height, String image) =>
    buttonImage(height.largeButtonWidth(hR), height.largeButtonHeight(vR), height.paddingSize(), image);

// 1000のボタンのロゴ
Widget real1000ButtonsLogo(double width) =>
    Container(
      height: width.startButtonHeight(),
      padding: EdgeInsets.all(width.logo1000ButtonsPadding()),
      child: Image.asset(realTitleImage),
    );

// 30秒チャレンジスタートボタンおよびカウントダウンの表示
Widget challengeStartText(BuildContext context, double width, int number, bool flag) =>
    Container(
      width: width.startButtonWidth(),
      height: width.startButtonHeight(),
      padding: EdgeInsets.only(
        top: width.startButtonPadding() * (flag ? 1.1: 0.4),
        left: width.startButtonPadding() * (flag ? 2: 1),
        right: width.startButtonPadding() * (flag ? 1.5: 1),
        bottom: width.startButtonPadding() * (flag ? 0.5: 0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!flag) challengeTitleText(context),
          startAndCountdownText(number.startButtonText(context, flag), flag),
        ],
      ),
    );

// 30秒チャレンジスタートボタンの表示
Widget challengeTitleText(BuildContext context) =>
    FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(context.challenge(),
        style: const TextStyle(
          fontSize: 100,
          fontWeight: FontWeight.bold,
          color: whiteColor,
        ),
      ),
    );

// 30秒カウントダウンの表示
Widget startAndCountdownText(String text, bool flag) =>
    FittedBox(
      fit: BoxFit.fitHeight,
      child: Text(text,
        style: TextStyle(
          fontFamily: (flag) ? numberFont: null,
          fontSize: 80,
          fontWeight: (flag) ? FontWeight.normal: FontWeight.bold,
          color: whiteColor,
        ),
      ),
    );

// 30秒チャレンジスタートボタンの形状
ButtonStyle challengeStartStyle(double width, int number, bool flag) =>
    ButtonStyle(
      backgroundColor: MaterialStateProperty.all(number.startButtonColor(flag)),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
        side: BorderSide(color: whiteColor, width: width.startBorderWidth()),
        borderRadius: BorderRadius.circular(width.startCornerRadius()),
      )),
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      minimumSize: MaterialStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

// 押したボタンの数を表示
Widget countDisplay(double width, int counter) =>
    Container(
      width: width.startButtonHeight() * 2.2,
      height: width.startButtonHeight(),
      color: darkBlackColor,
      padding: EdgeInsets.only(
        top: width.startButtonHeight() * 0.11,
        left: width.startButtonHeight() * 0.20,
        right: width.startButtonHeight() * 0.12,
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(counter.countNumber(),
          style: const TextStyle(
            color: lampColor,
            fontFamily: numberFont,
            fontSize: 50,
          ),
        ),
      ),
    );

// 30秒チャレンジ開始前および終了後の暗い透明背景の表示
Widget darkBackground(double width, double height) =>
    Container(
      width: width,
      height: height,
      color: transpBlackColor,
      alignment: Alignment.center,
      child: null,
    );

// 30秒チャレンジ開始前のカウントダウン表示
Widget beforeCountdown(double width, double height, int i) =>
    Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(width: width, height: height),
          beforeCountdownBackground(width),
          beforeCountdownNumber(width, i),
        ]
    );

Widget beforeCountdownBackground(double width) =>
    SizedBox(
      width: width * 0.4,
      height: width * 0.4,
      child: const FittedBox(
        fit: BoxFit.fitWidth,
        child: Image(image: AssetImage(circleButton)),
      ),
    );

Text beforeCountdownNumber(double width, int i) =>
    Text("$i",
      style: GoogleFonts.roboto(
        color: whiteColor,
        fontSize: width * 0.2,
        fontWeight: FontWeight.bold,
      ),
    );

//　30秒チャレンジ終了画面のテキスト
Text finishChallengeText(String text, double fontSize) =>
    Text(text,
        style: TextStyle(
          color: whiteColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        )
    );

//　30秒チャレンジ終了画面のスコア表示のテキスト
Text finishChallengeScore(int counter) =>
    Text(counter.countNumber(),
      style: const TextStyle(
        color: lampColor,
        fontFamily: "teleIndicators",
        fontSize: 120,
      ),
    );

//　戻るボタンのテキスト
Text return1000Buttons(BuildContext context) =>
    Text(context.back(),
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );

