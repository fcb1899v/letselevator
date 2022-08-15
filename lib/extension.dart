import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constant.dart';

extension StringExt on String {

  ///Common
  void debugPrint() {
    if (kDebugMode) print(this);
  }

  void pushPage(BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(this, (_) => false);

  void playAudio() {
    debugPrint();
    AudioCache().play(this);
  }

  String ttsLang() =>
      (this != "en") ? this: "en";

  Future<void> speakText(BuildContext context) async {
    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage(Localizations.localeOf(context).languageCode.ttsLang());
    flutterTts.setSpeechRate((Platform.isAndroid) ? 0.55: 0.5);
    debugPrint();
    await flutterTts.speak(this);
  }
}


extension ContextExt on BuildContext {

  ///Common
  double width() => MediaQuery.of(this).size.width;
  double height() => MediaQuery.of(this).size.height;
  String lang() => Localizations.localeOf(this).languageCode;

  ///LETS ELEVATOR
  String rooftop() => AppLocalizations.of(this)!.rooftop;
  String ground() => AppLocalizations.of(this)!.ground;
  String basement() => AppLocalizations.of(this)!.basement;
  String floor(String number) => AppLocalizations.of(this)!.floor(number);
  String platform() => AppLocalizations.of(this)!.platform;
  String dog() => AppLocalizations.of(this)!.dog;
  String spa() => AppLocalizations.of(this)!.spa;
  String vip() => AppLocalizations.of(this)!.vip;
  String parking() => AppLocalizations.of(this)!.parking;
  String paradise() => AppLocalizations.of(this)!.paradise;
  String openDoor() => AppLocalizations.of(this)!.openDoor;

  ///1000 Buttons
  String newRecord() => AppLocalizations.of(this)!.newRecord;
  String best() => AppLocalizations.of(this)!.best;
  String start() => AppLocalizations.of(this)!.start;
  String challenge() => AppLocalizations.of(this)!.challenge;

  ///Menu
  String menu() => AppLocalizations.of(this)!.menu;
  String back() => AppLocalizations.of(this)!.back;
  String normalMode() => AppLocalizations.of(this)!.normalMode;
  String buttonsMode() => AppLocalizations.of(this)!.buttonsMode;
  String buttons() => AppLocalizations.of(this)!.aboutButtons;
  String shimax() => AppLocalizations.of(this)!.aboutShimax;
  String letsElevator() => AppLocalizations.of(this)!.aboutLetsElevator;
  String onlineShop() => AppLocalizations.of(this)!.officialOnlineShop;
  String modeChangeLabel(bool flag) => (flag) ?
    AppLocalizations.of(this)!.reproButtons:
    AppLocalizations.of(this)!.elevatorMode;
  String elevatorLink() => (lang() == "ja") ? landingPageJa: landingPageEn;
  String shopLink() => (lang() == "ja") ? onlineShopJa: onlineShopEn;
  String shimaxLink() => (lang() == "ja") ? shimaxPage: timeoutArticle;
  String articleLink() => (lang() == "ja") ? fnnArticle: twitterPage;
}

extension IntExt on int {

  ///Floor Sound
  // this is counter
  String basement(BuildContext context) =>
      (this < 0) ? AppLocalizations.of(context)!.basement: "";

  String soundPlace(BuildContext context, int max, bool isShimada) =>
      (!isShimada) ? "":
      (this == 3) ? context.platform():
      (this == 7) ? context.dog():
      (this == 14) ? context.spa():
      (this == 154) ? context.vip():
      (this == -2) ? context.parking():
      (this == max) ? context.paradise():
      "";

  String soundFloor(BuildContext context) =>
      (this == max) ? context.rooftop():
      (this == 0) ? context.ground():
      (context.lang() == "en") ? context.floor("${enRankNumber()}${basement(context)}"):
      context.floor("${basement(context)}${abs()}");

  String enRankNumber() =>
      (abs() % 10 == 1 && abs() ~/ 10 != 1) ? "${abs()}st ":
      (abs() % 10 == 2 && abs() ~/ 10 != 1) ? "${abs()}nd ":
      (abs() % 10 == 3 && abs() ~/ 10 != 1) ? "${abs()}rd ":
      "${abs()}th ";

  String openingSound(BuildContext context, int max, bool isShimada) =>
      "${soundFloor(context)}${soundPlace(context, max, isShimada)}${context.openDoor()}";

  ///Display
  // this is counter
  String displayNumber(int max) =>
      (this == max) ? "R":
      (this == 0) ? "G":
      (this < 0) ? "B${abs()}":
      "$this";

  String arrowImage(bool isMoving, int nextFloor) =>
      (isMoving && this < nextFloor) ? upArrow:
      (isMoving && this > nextFloor) ? downArrow:
      transpImage;

  ///Speed
  //this is i
  int elevatorSpeed(int count, int nextFloor) {
    int l = (this - nextFloor).abs();
    return (count < 2 || l < 2) ? 2000:
    (count < 5 || l < 5) ? 1000:
    (count < 10 || l < 10) ? 500:
    (count < 20 || l < 20) ? 250: 100;
  }

  ///Button
  //this is i
  String numberBackground(bool isShimada, bool isSelected, int max) =>
      (!isShimada) ? ((isSelected) ? pressedCircle: circleButton):
      (this == max) ? "$assets1000${isSelected ? "pR.png": "R.png"}":
      (this > 0) ? "$assets1000${isSelected ? "p${this}.png": "${this}.png"}":
      "$assets1000${(isSelected) ? "pB${abs()}.png": "B${abs()}.png"}";

  //this is i
  String buttonNumber(int max, bool isShimada) =>
      (isShimada) ? "":
      (this == max) ? "R":
      (this == 0) ? "G":
      (this < 0) ? "B${abs()}":
      "$this";

  //this is i and counter.
  bool isSelected(List<bool> isAboveSelectedList, List<bool> isUnderSelectedList) =>
      (this > 0) ? isAboveSelectedList[this]: isUnderSelectedList[this * (-1)];

  //this is counter.
  void clearUpperFloor(List<bool> isAboveSelectedList, List<bool> isUnderSelectedList, int max) {
    for (int j = max; j > this - 1; j--) {
      if (j > 0) isAboveSelectedList[j] = false;
      if (j < 0) isUnderSelectedList[j * (-1)] = false;
    }
  }

  //this is counter.
  void clearLowerFloor(List<bool> isAboveSelectedList, List<bool> isUnderSelectedList, int min) {
    for (int j = min; j < this + 1; j++) {
      if (j > 0) isAboveSelectedList[j] = false;
      if (j < 0) isUnderSelectedList[j * (-1)] = false;
    }
  }

  //this is counter.
  List<int> upFromToNumber(int nextFloor) {
    List<int> floorList = [];
    for (int i = this + 1; i < nextFloor + 1; i++) {
      floorList.add(i);
    }
    return floorList;
  }

  //this is counter
  List<int> downFromToNumber(int nextFloor) {
    List<int> floorList = [];
    for (int i = this - 1; i > nextFloor - 1; i--) {
      floorList.add(i);
    }
    return floorList;
  }

  // this is counter
  int upNextFloor(List<bool> isAboveSelectedList, List<bool> isUnderSelectedList, int min, int max) {
    int nextFloor = max;
    for (int k = this + 1; k < max + 1; k++) {
      bool isSelected = k.isSelected(isAboveSelectedList, isUnderSelectedList);
      if (k < nextFloor && isSelected) nextFloor = k;
    }
    if (nextFloor == max) {
      bool isMaxSelected = max.isSelected(isAboveSelectedList, isUnderSelectedList);
      if (isMaxSelected) {
        nextFloor = max;
      } else {
        nextFloor = min;
        bool isMinSelected = min.isSelected(isAboveSelectedList, isUnderSelectedList);
        for (int k = min; k < this; k++) {
          bool isSelected = k.isSelected(isAboveSelectedList, isUnderSelectedList);
          if (k > nextFloor && isSelected) nextFloor = k;
        }
        if (isMinSelected) nextFloor = min;
      }
    }
    bool allFalse = true;
    for (int k = 0; k < isAboveSelectedList.length; k++) {
      if (isAboveSelectedList[k]) allFalse = false;
    }
    for (int k = 0; k < isUnderSelectedList.length; k++) {
      if (isUnderSelectedList[k]) allFalse = false;
    }
    if (allFalse) nextFloor = this;
    return nextFloor;
  }

  // this is counter
  int downNextFloor(List<bool> isAboveSelectedList, List<bool> isUnderSelectedList, int min, int max) {
    int nextFloor = min;
    for (int k = min; k < this; k++) {
      bool isSelected = k.isSelected(isAboveSelectedList, isUnderSelectedList);
      if (k > nextFloor && isSelected) nextFloor = k;
    }
    if (nextFloor == min) {
      bool isMinSelected = min.isSelected(isAboveSelectedList, isUnderSelectedList);
      if (isMinSelected) {
        nextFloor = min;
      } else {
        nextFloor = max;
        bool isMaxSelected = max.isSelected(isAboveSelectedList, isUnderSelectedList);
        for (int k = max; k > this; k--) {
          bool isSelected = k.isSelected(isAboveSelectedList, isUnderSelectedList);
          if (k < nextFloor && isSelected) nextFloor = k;
        }
        if (isMaxSelected) nextFloor = max;
      }
    }
    bool allFalse = true;
    for (int k = 0; k < isAboveSelectedList.length; k++) {
      if (isAboveSelectedList[k]) allFalse = false;
    }
    for (int k = 0; k < isUnderSelectedList.length; k++) {
      if (isUnderSelectedList[k]) allFalse = false;
    }
    if (allFalse) nextFloor = this;
    return nextFloor;
  }

  //this is i.
  void trueSelected(List<bool> isAboveSelectedList, List<bool> isUnderSelectedList) {
    if (this > 0) isAboveSelectedList[this] = true;
    if (this < 0) isUnderSelectedList[this * (-1)] = true;
  }

  //this is i.
  void falseSelected(List<bool> isAboveSelectedList, List<bool> isUnderSelectedList) {
    if (this > 0) isAboveSelectedList[this] = false;
    if (this < 0) isUnderSelectedList[this * (-1)] = false;
  }

  //this is i
  bool onlyTrue(List<bool> isAboveSelectedList, List<bool> isUnderSelectedList) {
    bool listFlag = false;
    if (isSelected(isAboveSelectedList, isUnderSelectedList)) listFlag = true;
    if (this > 0) {
      for (int k = 0; k < isAboveSelectedList.length; k++) {
        if (k != this && isAboveSelectedList[k]) listFlag = false;
      }
      for (int k = 0; k < isUnderSelectedList.length; k++) {
        if (isUnderSelectedList[k]) listFlag = false;
      }
    }
    if (this < 0) {
      for (int k = 0; k < isUnderSelectedList.length; k++) {
        if (k != this * (-1) && isUnderSelectedList[k]) listFlag = false;
      }
      for (int k = 0; k < isAboveSelectedList.length; k++) {
        if (isAboveSelectedList[k]) listFlag = false;
      }
    }
    return listFlag;
  }

  ///1000 Buttons
  bool ableButtonFlag(int i) =>
      ((i == 41 && this == 3) || (i == 13 && this == 7)) ? false: true;

  double buttonWidthFactor(int i) =>
      (i == 16 && this == 1) ? 3:
      (i == 60 && this == 1) ? 2:
      (i == 70 && this == 1) ? 2:
      (i == 86 && this == 1) ? 4:
      (i == 5 && this == 2) ? 3:
      (i == 24 && this == 2) ? 1.5:
      (i == 25 && this == 2) ? 1.5:
      (i == 31 && this == 2) ? 3:
      (i == 43 && this == 2) ? 2:
      (i == 69 && this == 3) ? 3:
      (i == 93 && this == 3) ? 3:
      (i == 45 && this == 5) ? 2:
      (i == 82 && this == 5) ? 3:
      (i == 13 && this == 6) ? 2:
      (i == 27 && this == 6) ? 3:
      (i == 47 && this == 6) ? 1.5:
      (i == 48 && this == 6) ? 1.5:
      (i == 85 && this == 6) ? 4:
      (i == 13 && this == 7) ? 2:
      (i == 1 && this == 8) ? 3:
      (i == 56 && this == 8) ? 3:
      (i == 70 && this == 8) ? 3:
      (i == 18 && this == 9) ? 3:
      (i == 43 && this == 9) ? 2:
      (i == 8 && this == 10) ? 2:
      1;

  String countNumber() =>
      (this > 999) ? "$this":
      (this > 99) ? "0$this":
      (this > 9) ? "00$this":
      "000$this";

  String finishBestScore(BuildContext context, int counter) =>
      (counter > this) ? context.newRecord(): context.best() + countNumber();

  void saveBestScore(int bestScore) async {
    if (this > bestScore) setSharedPrefInt(bestScoreKey);
  }

  int setBestScore(int bestScore) =>
      (this > bestScore) ? this: bestScore;

  Future<void> setSharedPrefInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, this);
  }

  String startButtonText(BuildContext context, bool isCountStart) =>
      (!isCountStart) ? context.start():
      (this > 9) ? "$this":
      "0$this";

  Color startButtonColor(bool isCountStart) =>
      (this == 0 && isCountStart) ? redColor:
      (!isCountStart || this % 2 == 1) ? blackColor:
      (this < 10) ? yellowColor:
      greenColor;

  List<List<bool>> listListAllFalse(int rowMax) =>
      List.generate(rowMax, (_) => List.generate(this, (_) => false));

}


extension DoubleExt on double {

  ///Responsible
  double responsible() => (this < 1000) ? this: 1000;
  double menuResponsible() => (this < 600) ? this: 600;

  ///Display
  double displayHeight() => responsible() * displayHeightRate;
  double displayWidth() => (this < 600) ? this: 600;
  double displayNumberHeight() => responsible() * displayNumberHeightRate;
  double displayNumberWidth() => responsible() * displayNumberWidthRate;
  double displayArrowHeight() => responsible() * displayArrowHeightRate;
  double displayArrowWidth() => responsible() * displayArrowWidthRate;
  double displayNumberFontSize() => responsible() * displayFontSizeRate;
  double displayPadding() => responsible() * displayPaddingRate;
  double displayMargin() => responsible() * displayMarginRate;
  double shimadaLogoHeight() => responsible() * shimadaLogoHeightRate;

  ///Button
  double floorButtonSize() => responsible() * floorButtonSizeRate;
  double operationButtonSize() =>  responsible() * operationButtonSizeRate;
  double operationButtonPadding() =>  responsible() * operationButtonPaddingRate;
  double buttonNumberFontSize() => responsible() * buttonNumberFontSizeRate;
  double buttonMargin() => responsible() * buttonMarginRate;
  double buttonBorderWidth() => responsible() * buttonBorderWidthRate;
  double buttonBorderRadius() => responsible() * buttonBorderRadiusRate;
  double speedDialFontSize() => ((this < 680) ? this: 680) * speedDialFontSizeRate;
  double speedDialMargin() => responsible() * speedDialMarginRate;

  ///Admob
  double admobHeight() => (this < 680) ? 50: (this < 1180) ? 50 + (this - 680) / 10: 100;
  double admobWidth() => responsible() - 100;

  ///Settings
  double menuTitleWidth() => menuResponsible() * menuTitleWidthRate;
  double menuTitleFontSize() => menuResponsible() * menuTitleFontSizeRate;
  double menuListFontSize() => menuResponsible() * menuListFontSizeRate;
  double menuListIconSize() => menuResponsible() * menuListIconSizeRate;
  double menuTitleMargin() => responsible() * menuTitleMarginRate;
  double menuTitleMenuMargin() => responsible() * menuTitleMenuMarginRate;
  double menuListMargin() => responsible() * menuListMarginRate;
  double menuSnsLogoSize() => responsible() * menuSnsLogoSizeRate;

  ///1000 Buttons
  double startButtonWidth() => responsible() * startButtonWidthRate;
  double startButtonHeight() => responsible() * startButtonHeightRate;
  double startButtonPadding() => responsible() * startButtonPaddingRate;
  double logo1000ButtonsPadding() => startButtonPadding() * 0.5;

  double startPadding() => (this < 900) ? this / 60: 15;
  double startBorderWidth() => (this < 800) ? this / 400: 2.0;
  double startCornerRadius() => (this < 800) ? this / 80: 10.0;
  double defaultButtonLength() => 0.07 * this - 2;

  double buttonWidth(int i, int j) => j.buttonWidthFactor(i) * defaultButtonLength();
  double buttonHeight() => defaultButtonLength();
  double largeButtonWidth(double ratio) => ratio * defaultButtonLength();
  double largeButtonHeight(double ratio) => ratio * defaultButtonLength();
  double longButtonHeight() => 3 * defaultButtonLength();
  double paddingSize() => (this < 1100) ? 0.014 * this - 3: 12.4 + 0.038 * (this - 1100);

}

extension BoolExt on bool {

  ///This is isShimada
  String buttonChanBackGround() => (this) ? pressedButtonChan: buttonChan;
  String shimadaLogo() => (this) ? shimadaImage: transpImage;

  String openBackGround(bool isPressed) => (this) ?
      ((isPressed) ? shimadaOpen: pressedShimadaOpen):
      ((isPressed) ? openButton: pressedOpenButton);

  String closeBackGround(bool isPressed) => (this) ?
      ((isPressed) ? shimadaClose: pressedShimadaClose):
      ((isPressed) ? closeButton: pressedCloseButton);

  String phoneBackGround(bool isPressed) => (this) ?
      ((isPressed) ? shimadaAlert: pressedShimadaAlert):
      ((isPressed) ? alertButton: pressedAlertButton);

  int announceTime() => (this) ? 4: 3;

  ///Speed Dial
  String changeModeLabel(BuildContext context) =>
      (this) ? context.normalMode(): context.buttonsMode();

  bool reverse() => (this) ? false: true;

}

extension ListListBoolExt on List<List<bool>> {

  String buttonImage(int i, int j) =>
      //横長ボタン
      (i == 16 && j == 1 && this[i][j]) ? "${assetsRealOn}lp2.png":
      (i == 16 && j == 1) ? "${assetsRealOff}l2.png":
      (i == 60 && j == 1 && this[i][j]) ? "${assetsRealOn}lp18.png":
      (i == 60 && j == 1) ? "${assetsRealOff}l18.png":
      (i == 70 && j == 1 && this[i][j]) ? "${assetsRealOn}lp10.png":
      (i == 70 && j == 1) ? "${assetsRealOff}l10.png":
      (i == 86 && j == 1 && this[i][j]) ? "${assetsRealOn}lp2.png":
      (i == 86 && j == 1) ? "${assetsRealOff}l2.png":
      (i == 5 && j == 2 && this[i][j]) ? "${assetsRealOn}lp7.png":
      (i == 5 && j == 2) ? "${assetsRealOff}l7.png":
      (i == 24 && j == 2 && this[i][j]) ? "${assetsRealOn}lp13.png":
      (i == 24 && j == 2) ? "${assetsRealOff}l13.png":
      (i == 25 && j == 2 && this[i][j]) ? "${assetsRealOn}lp14.png":
      (i == 25 && j == 2) ? "${assetsRealOff}l14.png":
      (i == 31 && j == 2 && this[i][j]) ? "${assetsRealOn}lp6.png":
      (i == 31 && j == 2) ? "${assetsRealOff}l6.png":
      (i == 43 && j == 2 && this[i][j]) ? "${assetsRealOn}lp16.png":
      (i == 43 && j == 2) ? "${assetsRealOff}l16.png":
      (i == 69 && j == 3 && this[i][j]) ? "${assetsRealOn}lp7.png":
      (i == 69 && j == 3) ? "${assetsRealOff}l7.png":
      (i == 93 && j == 3 && this[i][j]) ? "${assetsRealOn}lp7.png":
      (i == 93 && j == 3) ? "${assetsRealOff}l7.png":
      (i == 45 && j == 5 && this[i][j]) ? "${assetsRealOn}lp15.png":
      (i == 45 && j == 5) ? "${assetsRealOff}l15.png":
      (i == 82 && j == 5 && this[i][j]) ? "${assetsRealOn}lp9.png":
      (i == 82 && j == 5) ? "${assetsRealOff}l9.png":
      (i == 27 && j == 6 && this[i][j]) ? "${assetsRealOn}lp5.png":
      (i == 27 && j == 6) ? "${assetsRealOff}l5.png":
      (i == 47 && j == 6 && this[i][j]) ? "${assetsRealOn}lp12.png":
      (i == 47 && j == 6) ? "${assetsRealOff}l12.png":
      (i == 48 && j == 6 && this[i][j]) ? "${assetsRealOn}lp11.png":
      (i == 48 && j == 6) ? "${assetsRealOff}l11.png":
      (i == 85 && j == 6 && this[i][j]) ? "${assetsRealOn}lp8.png":
      (i == 85 && j == 6) ? "${assetsRealOff}l8.png":
      (i == 1 && j == 8 && this[i][j]) ? "${assetsRealOn}lp1.png":
      (i == 1 && j == 8) ? "${assetsRealOff}l1.png":
      (i == 56 && j == 8 && this[i][j]) ? "${assetsRealOn}lp4.png":
      (i == 56 && j == 8) ? "${assetsRealOff}l4.png":
      (i == 70 && j == 8 && this[i][j]) ? "${assetsRealOn}lp3.png":
      (i == 70 && j == 8) ? "${assetsRealOff}l3.png":
      (i == 18 && j == 9 && this[i][j]) ? "${assetsRealOn}lp8.png":
      (i == 18 && j == 9) ? "${assetsRealOff}l8.png":
      (i == 43 && j == 9 && this[i][j]) ? "${assetsRealOn}lp17.png":
      (i == 43 && j == 9) ? "${assetsRealOff}l17.png":
      (i == 8 && j == 10 && this[i][j]) ? "${assetsRealOn}lp10.png":
      (i == 8 && j == 10) ? "${assetsRealOff}l10.png":
      //大サイズボタン
      (i == 13 && j == 6 && this[i][j]) ? "${assetsRealOn}lp19.png":
      (i == 13 && j == 6) ? "${assetsRealOff}l19.png":
      //縦長ボタン
      (i == 36 && j == 2 && this[i][j]) ? "${assetsRealOn}lp20.png":
      (i == 36 && j == 2) ? "${assetsRealOff}l20.png":
      (i == 41 && j == 4 && this[i][j]) ? "${assetsRealOn}lp20.png":
      (i == 41 && j == 4) ? "${assetsRealOff}l20.png":
      //その他のボタン
      (this[i][j]) ? "${assetsRealOn}xp${(79 * i + 19 * j) % 184 + 1}.png":
      "${assetsRealOff}x${(79 * i + 19 * j) % 184 + 1}.png";
      //(this[i][j]) ? "${assetsRealOn}p${i}_$j.png": "${assetsRealOff}${i}_$j.png";

  String buttonBackground(int i, int j, List<List<bool>> isAbleButtonsList) =>
      (!isAbleButtonsList[i][j]) ? transpImage: buttonImage(i, j);
}