import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'many_buttons_extension.dart';
import 'constant.dart';

// 通常ボタンの画像
Widget normalButtonImage(int i, int j, double height, String image) =>
    Container(
      width: height.buttonWidth(i, j),
      height: height.buttonHeight(),
      padding: EdgeInsets.all(height.paddingSize()),
      alignment: Alignment.center,
      child: Image(image: AssetImage(image)),
    );

// 大サイズボタンの画像
Widget largeButtonImage(double hR, double vR, double height, String image) =>
    Container(
      width: height.largeButtonWidth(hR),
      height: height.largeButtonHeight(vR),
      padding: EdgeInsets.all(height.paddingSize()),
      alignment: Alignment.center,
      child: Image(image: AssetImage(image)),
    );

// 1000のボタンのロゴ
Widget real1000ButtonsLogo(double width) =>
    Container(
      height: width.startHeight(),
      padding: EdgeInsets.all(width.startPadding() * 0.5),
      child: const Image(image: AssetImage(realTitleImage)),
    );

// 30秒チャレンジスタートボタンおよびカウントダウンの表示
Widget challengeStartText(BuildContext context, double width, int number, bool flag) =>
    Container(
      width: width.startWidth(),
      height: width.startHeight(),
      padding: EdgeInsets.only(
        top: width.startPadding() * (flag ? 1.1: 0.4),
        left: width.startPadding() * (flag ? 2: 1),
        right: width.startPadding() * (flag ? 1.5: 1),
        bottom: width.startPadding() * (flag ? 0.5: 0),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!flag) challengeTitleText(AppLocalizations.of(context)!.challenge),
          startAndCountdownText(number.startButtonText(context, flag), flag),
        ],
      ),
    );

// 30秒チャレンジスタートボタンの表示
Widget challengeTitleText(String title) =>
    FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(title,
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
      width: width.startHeight() * 2.2,
      height: width.startHeight(),
      color: darkBlackColor,
      padding: EdgeInsets.only(
        top: width.startHeight() * 0.11,
        left: width.startHeight() * 0.20,
        right: width.startHeight() * 0.12,
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
Text return1000Buttons(String text) =>
    Text(text,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );

