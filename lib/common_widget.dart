import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
// import 'package:games_services/games_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'extension.dart';
import 'constant.dart';

/// App Tracking Transparency
Future<void> initPlugin(BuildContext context) async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined && context.mounted) {
    await showCupertinoDialog(context: context, builder: (context) => CupertinoAlertDialog(
      title: Text(context.letsElevator()),
      content: Text(context.thisApp()),
      actions: [
        CupertinoDialogAction(
          child: const Text('OK', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ));
    await Future.delayed(const Duration(milliseconds: 200));
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

///メニュー画面
//アプリロゴ
Widget menuLogo(BuildContext context) => SizedBox(
  width: context.menuTitleWidth(),
  child: Image.asset(appLogo),
);

//メニュータイトル
Text menuTitle(BuildContext context) => Text(
  context.menu(),
  style: TextStyle(
    color: blackColor,
    fontSize: context.menuTitleFontSize(),
    fontWeight: FontWeight.bold,
    fontFamily: menuFont,
  ),
);

//メニューのリンクボタンの表示
Widget linkIconText(BuildContext context, String label, IconData icon) =>
    FittedBox(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.menuListMargin()),
        child: Row(children: [
          Icon(icon,
            size: context.menuListIconSize(),
            color: lampColor,
          ),
          Text(" $label",
            style: TextStyle(
              color: blackColor,
              fontSize: context.menuListFontSize(),
              fontWeight: FontWeight.bold,
              fontFamily: menuFont,
              decoration: TextDecoration.underline,
            )
          ),
        ]),
      ),
    );

//メニューのリンクボタン
Widget linkIconTextButton(BuildContext context, String label, IconData icon, String link) =>
    GestureDetector(
      child: linkIconText(context, label, icon),
      onTap: () {
        changePageSound.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        launchUrl(Uri.parse(link));
      },
    );

//再現！1000のボタン⇄エレベーターモードのモードチェンジ
Widget changePageButton(BuildContext context, bool flag) =>
    GestureDetector(
      child: linkIconText(context, context.modeChangeLabel(flag), CupertinoIcons.arrow_2_circlepath),
      onTap: () {
        changePageSound.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        (flag ? "/r": "/h").pushPage(context);
        // GamesServices.signIn(shouldEnableSavedGame: true);
      },
    );

//SNSボタン
Widget snsButton(BuildContext context, String logo, String link) => SizedBox(
  width: context.menuSnsLogoSize(),
  height: context.menuSnsLogoSize(),
  child: IconButton(
    icon: SvgPicture.asset(logo, color: lampColor),
    onPressed: () {
      changePageSound.playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      launchUrl(Uri.parse(link));
    },
  ),
);

//メニュー画面の背景
Widget overLay(BuildContext context) => Container(
  width: context.width(),
  height: context.height(),
  color: transpWhiteColor,
);

///AdMob
//バナー
Widget adMobBannerWidget(BuildContext context, BannerAd myBanner) => SizedBox(
  width: context.admobWidth(),
  height: context.admobHeight(),
  child: AdWidget(ad: myBanner),
);

///エレベーターモード
//Background
BoxDecoration metalDecoration() => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: metalSort,
      colors: metalColor,
    )
);

// 階数の表示
Widget displayArrowNumber(BuildContext context, bool isShimada, String arrow, String number) => Container(
  padding: EdgeInsets.only(top: context.displayPadding()),
  width: context.displayWidth(),
  height: context.displayHeight(),
  color: darkBlackColor,
  child: Stack(alignment: Alignment.center,
    children: [
      shimadaLogoImage(context, isShimada),
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          //　矢印
          SizedBox(
            width: context.displayArrowWidth(),
            height: context.displayArrowHeight(),
            child: Image.asset(arrow),
          ),
          //　数字
          Container(
            alignment: Alignment.centerRight,
            width: context.displayNumberWidth(),
            height: context.displayNumberHeight(),
            child: Text(number,
              style: TextStyle(
                color: lampColor,
                fontSize: context.displayNumberFontSize(),
                fontWeight: FontWeight.normal,
                fontFamily: numberFont,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    ],
  ),
);

Image shimadaLogoImage(BuildContext context, bool isShimada) => Image(
  color: blackColor,
  height: context.shimadaLogoHeight(),
  image: AssetImage(isShimada.shimadaLogo()),
);

Widget floorButtonImage(BuildContext context, int i, bool isShimada, bool isSelected,) =>
    SizedBox(
      width: context.floorButtonSize(),
      height: context.floorButtonSize(),
      child: Stack(alignment: Alignment.center,
        children: [
          Image.asset(i.numberBackground(isShimada, isSelected)),
          Text(i.buttonNumber(isShimada),
            style: TextStyle(
              color: (isSelected) ? lampColor: whiteColor,
              fontSize: context.buttonNumberFontSize(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

Widget imageButton(BuildContext context, String image) =>
    SizedBox(
      width: context.operationButtonSize(),
      height: context.operationButtonSize(),
      child: Image.asset(image),
    );

Widget operationImage(BuildContext context, String operate, bool isShimada, bool isPressed) => Stack(
  alignment: Alignment.center,
  children: [
    imageButton(context, isShimada.operateBackGround(operate, isPressed)),
    Container(
      width: context.operationButtonSize() + context.buttonBorderWidth(),
      height: context.operationButtonSize() + context.buttonBorderWidth(),
      decoration: BoxDecoration(
        color: transpColor,
        shape: (isShimada && operate == "alert") ? BoxShape.circle: BoxShape.rectangle,
        borderRadius: (isShimada && operate == "alert") ? null: BorderRadius.circular(context.buttonBorderRadius()),
        border: Border.all(
          color: (operate == "alert") ? yellowColor: (operate == "open") ? greenColor: whiteColor,
          width: context.buttonBorderWidth(),
        ),
      ),
    )
  ]
);


///再現！1000のボタン
Widget buttonImage(String image, double buttonWidth, double buttonHeight, double buttonPadding) => Container(
  width: buttonWidth,
  height: buttonHeight,
  padding: EdgeInsets.all(buttonPadding),
  alignment: Alignment.center,
  child: Image.asset(image),
);

// 通常ボタンの画像
Widget normalButtonImage(BuildContext context, int p, i, j, String image) => buttonImage(
  image,
  context.buttonWidth(p, i, j),
  context.buttonHeight(),
  context.buttonsPadding(),
);

// 大サイズボタンの画像
Widget largeButtonImage(BuildContext context, double hR, double vR, String image) => buttonImage(
  image,
  context.largeButtonWidth(hR),
  context.largeButtonHeight(vR),
  context.buttonsPadding(),
);

// 1000のボタンのロゴ
Widget real1000ButtonsLogo(BuildContext context) => Container(
  width: context.logo1000ButtonsWidth(),
  padding: EdgeInsets.all(context.logo1000ButtonsPadding()),
  child: Image.asset(realTitleImage),
);

// 30秒チャレンジスタートボタンの表示
Widget challengeStartText(BuildContext context, int number, bool isChallengeStart) => Container(
  width: context.challengeStartButtonWidth(),
  height: context.challengeStartButtonHeight(),
  padding: EdgeInsets.only(
    top: context.challengeStartButtonPaddingTop(isChallengeStart),
    left: context.challengeStartButtonPaddingLeft(isChallengeStart),
    right: context.challengeStartButtonPaddingRight(isChallengeStart),
    bottom: context.challengeStartButtonPaddingBottom(isChallengeStart),
  ),
  decoration: BoxDecoration(
    color: number.startButtonColor(isChallengeStart),
    borderRadius: BorderRadius.circular(context.startCornerRadius()),
    border: Border.all(color: whiteColor, width: context.startBorderWidth()),
  ),
  child: (isChallengeStart) ? countdownText(number): Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      challengeText(context.challenge()),
      if (context.lang() != "ko") challengeText(context.start()),
    ],
  ),
);


Widget panelDivider(BuildContext context) => Row(children: [
  const SizedBox(width: 10),
  Container(
    color: blackColor,
    width: 1,
    height: context.height() * dividerHeightRate
  ),
  const SizedBox(width: 10),
]);

Widget challengeText(String text) => FittedBox(
  fit: BoxFit.fitWidth,
  child: Text(text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 100,
      fontWeight: FontWeight.bold,
      color: whiteColor,
    ),
  ),
);

// 30秒カウントダウンの表示
Widget countdownText(int number) => FittedBox(
  fit: BoxFit.fitHeight,
  child: Text(number.countDownNumber(),
    style: const TextStyle(
      fontFamily: numberFont,
      fontSize: 100,
      fontWeight: FontWeight.normal,
      color: whiteColor,
    ),
  ),
);

// 押したボタンの数を表示
Widget countDisplay(BuildContext context, int counter) => Container(
  width: context.countDisplayWidth(),
  height: context.countDisplayHeight(),
  color: darkBlackColor,
  padding: EdgeInsets.only(
    top: context.countDisplayPaddingTop(),
    left: context.countDisplayPaddingLeft(),
    right: context.countDisplayPaddingRight(),
  ),
  child: FittedBox(
    fit: BoxFit.fitWidth,
    child: Text(counter.countNumber(),
      style: const TextStyle(
        color: lampColor,
        fontFamily: numberFont,
        fontSize: 100,
      ),
    ),
  ),
);

// 30秒チャレンジ開始前および終了後の暗い透明背景の表示
Widget darkBackground(BuildContext context) => Container(
  width: context.width(),
  height: context.height(),
  color: transpBlackColor,
  alignment: Alignment.center,
  child: null,
);

Widget beforeCountdownBackground(BuildContext context) => SizedBox(
  width: context.width() * 0.4,
  height: context.width() * 0.4,
  child: const FittedBox(
    fit: BoxFit.fitWidth,
    child: Image(image: AssetImage(circleButton)),
  ),
);

Text beforeCountdownNumber(BuildContext context, int i) => Text(
  "$i",
  style: GoogleFonts.roboto(
    color: whiteColor,
    fontSize: context.width() * 0.2,
    fontWeight: FontWeight.bold,
  ),
);

//　30秒チャレンジ終了画面のテキスト
Text finishChallengeText(String text, double fontSize) => Text(
  text,
  style: TextStyle(
    color: whiteColor,
    fontWeight: FontWeight.bold,
    fontSize: fontSize,
  )
);

//　30秒チャレンジ終了画面のスコア表示のテキスト
Text finishChallengeScore(int counter) => Text(
  counter.countNumber(),
  style: const TextStyle(
    color: lampColor,
    fontFamily: "teleIndicators",
    fontSize: 120,
  ),
);

//　戻るボタンの表示
Widget return1000Buttons(BuildContext context) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
  decoration: BoxDecoration(
    color: whiteColor,
    borderRadius: BorderRadius.circular(5),
  ),
  child: Text(
    context.back(),
    style: const TextStyle(
      color: blackColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  ),
);

