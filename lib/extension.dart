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

  void playAudio(AudioPlayer audioPlayer, bool isSoundOn) async {
    if (isSoundOn) {
      debugPrint();
      await audioPlayer.stop();
      await AudioPlayer().play(AssetSource(this));
    }
  }

  String ttsLang() =>
      (this != "en") ? this: "en";

  Future<void> speakText(FlutterTts flutterTts, bool isSoundOn) async {
    if (isSoundOn) {
      debugPrint();
      await flutterTts.speak(this);
    }
  }
}

extension ContextExt on BuildContext {

  ///Common
  double width() => MediaQuery.of(this).size.width;
  double height() => MediaQuery.of(this).size.height;
  String lang() => Localizations.localeOf(this).languageCode;

  ///LETS ELEVATOR
  String thisApp() => AppLocalizations.of(this)!.thisApp;
  String rooftop() => AppLocalizations.of(this)!.rooftop;
  String ground() => AppLocalizations.of(this)!.ground;
  String openDoor() => AppLocalizations.of(this)!.openDoor;
  String closeDoor() => AppLocalizations.of(this)!.closeDoor;
  String emergency() => AppLocalizations.of(this)!.emergency;
  String pushNumber() => AppLocalizations.of(this)!.pushNumber;
  String return1st() => AppLocalizations.of(this)!.return1st;
  String upFloor() => AppLocalizations.of(this)!.upFloor;
  String downFloor() => AppLocalizations.of(this)!.downFloor;
  String notStop() => AppLocalizations.of(this)!.notStop;
  String basement(int counter) => (counter < 0) ? AppLocalizations.of(this)!.basement: "";
  String floor(String number) => AppLocalizations.of(this)!.floor(number);
  String platform() => AppLocalizations.of(this)!.platform;
  String dog() => AppLocalizations.of(this)!.dog;
  String spa() => AppLocalizations.of(this)!.spa;
  String vip() => AppLocalizations.of(this)!.vip;
  String parking() => AppLocalizations.of(this)!.parking;
  String paradise() => AppLocalizations.of(this)!.paradise;
  String soundPlace(int counter, bool isShimada) =>
      (!isShimada) ? "":
      (counter == 3) ? platform():
      (counter == 7) ? dog():
      (counter == 14) ? spa():
      (counter == 154) ? vip():
      (counter == -2) ? parking():
      (counter == max) ? paradise():
      "";
  String soundFloor(int counter) =>
      (counter == max) ? rooftop():
      (counter == 0) ? ground():
      (lang() == "en") ? floor("${counter.enRankNumber()}${basement(counter)}"):
      floor("${basement(counter)}${counter.abs()}");
  String openingSound(int counter, bool isShimada) =>
      "${soundFloor(counter)}${soundPlace(counter, isShimada)}${openDoor()}";

  ///1000 Buttons
  String newRecord() => AppLocalizations.of(this)!.newRecord;
  String best() => AppLocalizations.of(this)!.best;
  String start() => AppLocalizations.of(this)!.start;
  String challenge() => AppLocalizations.of(this)!.challenge;
  String yourScore() => AppLocalizations.of(this)!.yourScore;

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

  ///Responsible
  double responsible() => (height() < 1000) ? height(): 1000;
  double widthResponsible() => (width() < 600) ? width(): 600;
  double widthResponsible2() => (width() < 1000) ? width(): 1000;

  ///Display
  double displayHeight() => responsible() * displayHeightRate;
  double displayWidth() => widthResponsible();
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

  ///Admob
  double admobHeight() => (height() < 600) ? 50: (height() < 1000) ? 50 + (height() - 600) / 8: 100;
  double admobWidth() => width() - 100;

  ///Settings
  double menuTitleWidth() => widthResponsible() * menuTitleWidthRate;
  double menuTitleFontSize() => widthResponsible() * menuTitleFontSizeRate;
  double menuListFontSize() => widthResponsible() * menuListFontSizeRate;
  double menuListIconSize() => widthResponsible() * menuListIconSizeRate;
  double menuTitleMargin() => responsible() * menuTitleMarginRate;
  double menuTitleMenuMargin() => responsible() * menuTitleMenuMarginRate;
  double menuListMargin() => responsible() * menuListMarginRate;
  double menuSnsLogoSize() => responsible() * menuSnsLogoSizeRate;

  ///1000 Buttons
  double logo1000ButtonsWidth() => widthResponsible2() * logo1000ButtonsWidthRate;
  double logo1000ButtonsPadding() => widthResponsible2() * logo1000ButtonsPaddingRate;
  double challengeStartButtonWidth() => widthResponsible2() * startButtonWidthRate;
  double challengeStartButtonHeight() => widthResponsible2() * startButtonHeightRate;
  double challengeStartPaddingTop() => widthResponsible2() * startButtonPaddingTopRate;
  double challengeStartPaddingLeft() => widthResponsible2() * startButtonPaddingLeftRate;
  double challengeStartPaddingRight() => widthResponsible2() * startButtonPaddingRightRate;
  double challengeStartPaddingBottom() => widthResponsible2() * startButtonPaddingBottomRate;
  double countdownPaddingTop() => widthResponsible2() * countdownPaddingTopRate;
  double countdownPaddingLeft() => widthResponsible2() * countdownPaddingLeftRate;
  double countdownPaddingRight() => widthResponsible2() * countdownPaddingRightRate;
  double countdownPaddingBottom() => widthResponsible2() * countdownPaddingBottomRate;
  double challengeStartButtonPaddingTop(isChallengeStart) =>
      isChallengeStart ? countdownPaddingTop(): challengeStartPaddingTop();
  double challengeStartButtonPaddingLeft(isChallengeStart) =>
      isChallengeStart ? countdownPaddingLeft(): challengeStartPaddingLeft();
  double challengeStartButtonPaddingRight(isChallengeStart) =>
      isChallengeStart ? countdownPaddingRight(): challengeStartPaddingRight();
  double challengeStartButtonPaddingBottom(isChallengeStart) =>
      isChallengeStart ? countdownPaddingBottom(): challengeStartPaddingBottom();
  double countDisplayWidth() => widthResponsible2() * countDisplayWidthRate;
  double countDisplayHeight() => widthResponsible2() * countDisplayHeightRate;
  double countDisplayPaddingTop() => widthResponsible2() * countDisplayPaddingTopRate;
  double countDisplayPaddingLeft() => widthResponsible2() * countDisplayPaddingLeftRate;
  double countDisplayPaddingRight() => widthResponsible2() * countDisplayPaddingRightRate;

  double defaultButtonLength() => 0.07 * height() - 2;
  double buttonWidth(int p, i, j) => p.buttonWidthFactor(i, j) * defaultButtonLength();
  double buttonHeight() => defaultButtonLength();
  double largeButtonWidth(double ratio) => ratio * defaultButtonLength();
  double largeButtonHeight(double ratio) => ratio * defaultButtonLength();
  double longButtonHeight() => 3 * defaultButtonLength();
  double buttonsPadding() => (height() < 1100) ? 0.014 * height() - 3: 12.4 + 0.038 * (height() - 1100);
  double startBorderWidth() => (width() < 800) ? width() / 400: 2.0;
  double startCornerRadius() => (width() < 800) ? width() / 80: 10.0;
}

extension IntExt on int {

  ///Floor Sound
  String enRankNumber() =>
      (abs() % 10 == 1 && abs() ~/ 10 != 1) ? "${abs()}st ":
      (abs() % 10 == 2 && abs() ~/ 10 != 1) ? "${abs()}nd ":
      (abs() % 10 == 3 && abs() ~/ 10 != 1) ? "${abs()}rd ":
      "${abs()}th ";

  ///Display
  // this is counter
  String displayNumber() =>
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
  String numberBackground(bool isShimada, isSelected) =>
      (!isShimada) ? ((isSelected) ? pressedCircle: circleButton):
      (this == max) ? "$assets1000${isSelected ? "pR.png": "R.png"}":
      (this > 0) ? "$assets1000${isSelected ? "p$this.png": "$this.png"}":
      "$assets1000${(isSelected) ? "pB${abs()}.png": "B${abs()}.png"}";

  //this is i
  String buttonNumber(bool isShimada) =>
      (isShimada) ? "":
      (this == max) ? "R":
      (this == 0) ? "G":
      (this < 0) ? "B${abs()}":
      "$this";

  //this is i and counter.
  bool isSelected(List<bool> isAboveSelectedList, isUnderSelectedList) =>
      (this > 0) ? isAboveSelectedList[this]: isUnderSelectedList[this * (-1)];

  //this is counter.
  void clearUpperFloor(List<bool> isAboveSelectedList, isUnderSelectedList) {
    for (int j = max; j > this - 1; j--) {
      if (j > 0) isAboveSelectedList[j] = false;
      if (j < 0) isUnderSelectedList[j * (-1)] = false;
    }
  }

  //this is counter.
  void clearLowerFloor(List<bool> isAboveSelectedList, isUnderSelectedList) {
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
  int upNextFloor(List<bool> isAboveSelectedList, isUnderSelectedList) {
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
  int downNextFloor(List<bool> isAboveSelectedList, isUnderSelectedList) {
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
  void trueSelected(List<bool> isAboveSelectedList, isUnderSelectedList) {
    if (this > 0) isAboveSelectedList[this] = true;
    if (this < 0) isUnderSelectedList[this * (-1)] = true;
  }

  //this is i.
  void falseSelected(List<bool> isAboveSelectedList, isUnderSelectedList) {
    if (this > 0) isAboveSelectedList[this] = false;
    if (this < 0) isUnderSelectedList[this * (-1)] = false;
  }

  //this is i
  bool onlyTrue(List<bool> isAboveSelectedList, isUnderSelectedList) {
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
  bool isTranspButton(int i, j) =>
      //panel 2
      (this == 1 && i == 2 && j == 7) ? true:
      //panel 4
      (this == 3 && i == 9 && j == 3) ? true:
      false;

  bool isNotHaveButton(int i, j) =>
      // panel 1
      (this == 0 && i == 0 && j == 2) ? true:
      (this == 0 && i == 0 && j == 4) ? true:
      (this == 0 && i == 0 && j == 10) ? true:
      (this == 0 && i == 1 && j == 1) ? true:
      (this == 0 && i == 1 && j == 2) ? true:
      (this == 0 && i == 1 && j == 9) ? true:
      (this == 0 && i == 1 && j == 10) ? true:
      (this == 0 && i == 2 && j == 6) ? true:
      (this == 0 && i == 2 && j == 9) ? true:
      (this == 0 && i == 2 && j == 10) ? true:
      (this == 0 && i == 5 && j == 4) ? true:
      (this == 0 && i == 5 && j == 5) ? true:
      (this == 0 && i == 6 && j == 5) ? true:
      (this == 0 && i == 7 && j == 3) ? true:
      (this == 0 && i == 7 && j == 8) ? true:
      (this == 0 && i == 8 && j == 7) ? true:
      (this == 0 && i == 8 && j == 9) ? true:
      (this == 0 && i == 9 && j == 5) ? true:
      (this == 0 && i == 10 && j == 1) ? true:
      // panel 2
      (this == 1 && i == 0 && j == 0) ? true:
      (this == 1 && i == 0 && j == 3) ? true:
      (this == 1 && i == 0 && j == 4) ? true:
      (this == 1 && i == 0 && j == 6) ? true:
      (this == 1 && i == 1 && j == 0) ? true:
      (this == 1 && i == 1 && j == 9) ? true:
      (this == 1 && i == 2 && j == 2) ? true:
      (this == 1 && i == 3 && j == 2) ? true:
      (this == 1 && i == 7 && j == 1) ? true:
      (this == 1 && i == 7 && j == 4) ? true:
      (this == 1 && i == 8 && j == 1) ? true:
      (this == 1 && i == 8 && j == 3) ? true:
      (this == 1 && i == 8 && j == 4) ? true:
      (this == 1 && i == 8 && j == 7) ? true:
      // panel 3
      (this == 2 && i == 0 && j == 0) ? true:
      (this == 2 && i == 1 && j == 7) ? true:
      (this == 2 && i == 1 && j == 8) ? true:
      (this == 2 && i == 1 && j == 9) ? true:
      (this == 2 && i == 2 && j == 6) ? true:
      (this == 2 && i == 3 && j == 0) ? true:
      (this == 2 && i == 4 && j == 5) ? true:
      (this == 2 && i == 4 && j == 6) ? true:
      (this == 2 && i == 5 && j == 10) ? true:
      (this == 2 && i == 7 && j == 9) ? true:
      (this == 2 && i == 8 && j == 7) ? true:
      (this == 2 && i == 9 && j == 5) ? true:
      (this == 2 && i == 10 && j == 1) ? true:
      (this == 2 && i == 10 && j == 4) ? true:
      // panel 4
      (this == 3 && i == 0 && j == 5) ? true:
      (this == 3 && i == 1 && j == 4) ? true:
      (this == 3 && i == 1 && j == 5) ? true:
      (this == 3 && i == 1 && j == 8) ? true:
      (this == 3 && i == 2 && j == 10) ? true:
      (this == 3 && i == 3 && j == 2) ? true:
      (this == 3 && i == 3 && j == 3) ? true:
      (this == 3 && i == 6 && j == 5) ? true:
      (this == 3 && i == 7 && j == 3) ? true:
      (this == 3 && i == 7 && j == 6) ? true:
      (this == 3 && i == 7 && j == 10) ? true:
      (this == 3 && i == 8 && j == 2) ? true:
      (this == 3 && i == 8 && j == 4) ? true:
      (this == 3 && i == 10 && j == 4) ? true:
      (this == 3 && i == 10 && j == 5) ? true:
      // panel 5
      (this == 4 && i == 0 && j == 3) ? true:
      (this == 4 && i == 0 && j == 5) ? true:
      (this == 4 && i == 0 && j == 6) ? true:
      (this == 4 && i == 0 && j == 8) ? true:
      (this == 4 && i == 0 && j == 9) ? true:
      (this == 4 && i == 1 && j == 8) ? true:
      (this == 4 && i == 2 && j == 6) ? true:
      (this == 4 && i == 3 && j == 1) ? true:
      (this == 4 && i == 3 && j == 4) ? true:
      (this == 4 && i == 3 && j == 9) ? true:
      (this == 4 && i == 5 && j == 8) ? true:
      (this == 4 && i == 6 && j == 1) ? true:
      (this == 4 && i == 6 && j == 9) ? true:
      (this == 4 && i == 7 && j == 7) ? true:
      (this == 4 && i == 8 && j == 7) ? true:
      (this == 4 && i == 8 && j == 9) ? true:
      (this == 4 && i == 9 && j == 7) ? true:
      (this == 4 && i == 9 && j == 8) ? true:
      (this == 4 && i == 10 && j == 3) ? true:
      (this == 4 && i == 10 && j == 8) ? true:
      // panel 6
      (this == 5 && i == 0 && j == 7) ? true:
      (this == 5 && i == 1 && j == 6) ? true:
      (this == 5 && i == 1 && j == 9) ? true:
      (this == 5 && i == 2 && j == 5) ? true:
      (this == 5 && i == 3 && j == 0) ? true:
      (this == 5 && i == 3 && j == 4) ? true:
      (this == 5 && i == 3 && j == 5) ? true:
      (this == 5 && i == 4 && j == 0) ? true:
      (this == 5 && i == 4 && j == 3) ? true:
      (this == 5 && i == 4 && j == 5) ? true:
      (this == 5 && i == 4 && j == 7) ? true:
      (this == 5 && i == 5 && j == 2) ? true:
      (this == 5 && i == 5 && j == 4) ? true:
      (this == 5 && i == 5 && j == 8) ? true:
      (this == 5 && i == 6 && j == 1) ? true:
      (this == 5 && i == 6 && j == 4) ? true:
      (this == 5 && i == 6 && j == 9) ? true:
      (this == 5 && i == 7 && j == 6) ? true:
      (this == 5 && i == 8 && j == 0) ? true:
      (this == 5 && i == 8 && j == 3) ? true:
      (this == 5 && i == 8 && j == 7) ? true:
      (this == 5 && i == 8 && j == 9) ? true:
      (this == 5 && i == 9 && j == 1) ? true:
      (this == 5 && i == 9 && j == 2) ? true:
      (this == 5 && i == 9 && j == 7) ? true:
      (this == 5 && i == 9 && j == 10) ? true:
      (this == 5 && i == 10 && j == 7) ? true:
      // panel 7
      (this == 6 && i == 0 && j == 2) ? true:
      (this == 6 && i == 1 && j == 9) ? true:
      (this == 6 && i == 2 && j == 1) ? true:
      (this == 6 && i == 2 && j == 2) ? true:
      (this == 6 && i == 2 && j == 10) ? true:
      (this == 6 && i == 3 && j == 2) ? true:
      (this == 6 && i == 3 && j == 6) ? true:
      (this == 6 && i == 3 && j == 7) ? true:
      (this == 6 && i == 4 && j == 1) ? true:
      (this == 6 && i == 6 && j == 8) ? true:
      (this == 6 && i == 7 && j == 10) ? true:
      (this == 6 && i == 10 && j == 0) ? true:
      // panel 8
      (this == 7 && i == 1 && j == 3) ? true:
      (this == 7 && i == 2 && j == 6) ? true:
      (this == 7 && i == 2 && j == 8) ? true:
      (this == 7 && i == 3 && j == 3) ? true:
      (this == 7 && i == 5 && j == 0) ? true:
      (this == 7 && i == 5 && j == 7) ? true:
      (this == 7 && i == 7 && j == 2) ? true:
      (this == 7 && i == 7 && j == 7) ? true:
      (this == 7 && i == 7 && j == 10) ? true:
      (this == 7 && i == 8 && j == 0) ? true:
      (this == 7 && i == 8 && j == 7) ? true:
      (this == 7 && i == 9 && j == 4) ? true:
      (this == 7 && i == 10 && j == 2) ? true:
      (this == 7 && i == 10 && j == 4) ? true:
      // panel 8
      (this == 8 && i == 0 && j == 4) ? true:
      (this == 8 && i == 0 && j == 9) ? true:
      (this == 8 && i == 1 && j == 1) ? true:
      (this == 8 && i == 1 && j == 2) ? true:
      (this == 8 && i == 2 && j == 3) ? true:
      (this == 8 && i == 2 && j == 9) ? true:
      (this == 8 && i == 3 && j == 4) ? true:
      (this == 8 && i == 3 && j == 5) ? true:
      (this == 8 && i == 3 && j == 7) ? true:
      (this == 8 && i == 3 && j == 8) ? true:
      (this == 8 && i == 5 && j == 3) ? true:
      (this == 8 && i == 5 && j == 4) ? true:
      (this == 8 && i == 5 && j == 6) ? true:
      (this == 8 && i == 5 && j == 8) ? true:
      (this == 8 && i == 6 && j == 7) ? true:
      (this == 8 && i == 6 && j == 10) ? true:
      (this == 8 && i == 7 && j == 9) ? true:
      (this == 8 && i == 8 && j == 2) ? true:
      (this == 8 && i == 8 && j == 8) ? true:
      (this == 8 && i == 9 && j == 5) ? true:
      (this == 8 && i == 10 && j == 8) ? true:
      // Other
      false;


  double buttonWidthFactor(int i, j) =>
      //panel 1
      (this == 0 && i == 1 && j == 8) ? 3:
      (this == 0 && i == 5 && j == 2) ? 3:
      (this == 0 && i == 8 && j == 10) ? 2:
      //panel 2
      (this == 1 && i == 2 && j == 6) ? 2:
      (this == 1 && i == 2 && j == 7) ? 2:
      (this == 1 && i == 5 && j == 1) ? 3:
      (this == 1 && i == 7 && j == 9) ? 3:
      //panel 3
      (this == 2 && i == 4 && j == 2) ? 1.5:
      (this == 2 && i == 5 && j == 2) ? 1.5:
      (this == 2 && i == 6 && j == 6) ? 3:
      //panel 4
      (this == 3 && i == 2 && j == 2) ? 3:
      //panel 5
      (this == 4 && i == 1 && j == 5) ? 2:
      (this == 4 && i == 1 && j == 9) ? 2:
      (this == 4 && i == 5 && j == 2) ? 2:
      (this == 4 && i == 6 && j == 6) ? 1.5:
      (this == 4 && i == 7 && j == 6) ? 1.5:
      //panel 6
      (this == 5 && i == 3 && j == 8) ? 3:
      (this == 5 && i == 7 && j == 1) ? 2:
      //panel 7
      (this == 6 && i == 3 && j == 3) ? 3:
      (this == 6 && i == 7 && j == 1) ? 2:
      (this == 6 && i == 7 && j == 8) ? 3:
      //panel 8
      (this == 7 && i == 6 && j == 5) ? 3:
      //panel 9
      (this == 8 && i == 1 && j == 6) ? 4:
      (this == 8 && i == 2 && j == 1) ? 4:
      (this == 8 && i == 7 && j == 3) ? 3:
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

  String countDownNumber() =>
      (this > 9) ? "$this": "0$this";

  Color startButtonColor(bool isCountStart) =>
      (this == 0 && isCountStart) ? redColor:
      (!isCountStart || this % 2 == 1) ? blackColor:
      (this < 10) ? yellowColor:
      greenColor;

  List<List<List<bool>>> listListAllFalse(int rowMax, int columnMax) =>
      List.generate(this, (_) => List.generate(rowMax, (_) => List.generate(columnMax, (_) => false)));

  List<List<List<bool>>> listListAllTrue(int rowMax, int columnMax) =>
      List.generate(this, (_) => List.generate(rowMax, (_) => List.generate(columnMax, (_) => true)));
}

extension BoolExt on bool {

  ///This is isShimada
  String buttonChanBackGround() => (this) ? pressedButtonChan: buttonChan;
  String shimadaLogo() => (this) ? shimadaImage: transpImage;

  String openBackGround(bool isPressed) => (this) ?
      ((isPressed) ? pressedShimadaOpen: shimadaOpen):
      ((isPressed) ? pressedOpenButton: openButton);

  String closeBackGround(bool isPressed) => (this) ?
      ((isPressed) ? pressedShimadaClose: shimadaClose):
      ((isPressed) ? pressedCloseButton: closeButton);

  String phoneBackGround(bool isPressed) => (this) ?
      ((isPressed) ? pressedShimadaAlert: shimadaAlert):
      ((isPressed) ? pressedAlertButton: alertButton);

  String operateBackGround(String operate, bool isPressed) =>
      (operate == "alert") ? phoneBackGround(isPressed):
      (operate == "open") ? openBackGround(isPressed):
      closeBackGround(isPressed);

  String changeModeLabel(BuildContext context) =>
      (this) ? context.normalMode(): context.buttonsMode();

  int announceTime() => (this) ? 4: 3;

  bool reverse() => (this) ? false: true;
}

extension ListListListBoolExt on List<List<List<bool>>> {

  String buttonImage(int p, i, j) =>
      // Large Buttons => Transparent
      (p.isTranspButton(i, j)) ? transpImage:
      // not have Buttons => Random
      (p.isNotHaveButton(i, j) && this[p][i][j]) ? "${assetsRealOn}xp${(19 * i + 13 * j) % 184 + 1}.png":
      (p.isNotHaveButton(i, j)) ? "${assetsRealOff}x${(19 * i + 13 * j) % 184 + 1}.png":
      // Other Buttons
      (this[p][i][j]) ? "${assetsReal1000On}p${p + 1}/p${p + 1}_${i + 1}_${j + 1}.png":
      "$assetsReal1000Off${p + 1}/${p + 1}_${i + 1}_${j + 1}.png";
}