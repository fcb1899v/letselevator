import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

extension IntExt on int {

  String soundNumber(BuildContext context, int max) {
    String lang = Localizations.localeOf(context).languageCode;
    String ground = AppLocalizations.of(context)!.ground;
    String rooftop = AppLocalizations.of(context)!.rooftop;
    String floor = AppLocalizations.of(context)!.floor;
    String chika = AppLocalizations.of(context)!.chika;
    String basement = AppLocalizations.of(context)!.basement;

    return  (this == max) ? rooftop:
            (this == 0) ? ground:
            ((lang == "ja" || lang == "ko") && this > 0) ? "${this}$floor":
            ((lang == "ja" || lang == "ko") && this < 0) ? "$chika${abs()}$floor":
            (this > 0) ? "${rankNumber()}$floor":
            "${rankNumber()}$basement$floor";
  }

  String soundPlace(BuildContext context, int max) {
    String home = AppLocalizations.of(context)!.platform;
    String dog = AppLocalizations.of(context)!.dog;
    String spa = AppLocalizations.of(context)!.spa;
    String vip = AppLocalizations.of(context)!.vip;
    String parking = AppLocalizations.of(context)!.parking;
    String paradise = AppLocalizations.of(context)!.paradise;

    return (this == 3) ? home:
      (this == 7) ? dog:
      (this == 14) ? spa:
      (this == 154) ? vip:
      (this == -2) ? parking:
      (this == max) ? paradise: "";
  }

  String soundFloor(BuildContext context, int max, bool isShimada) =>
      (isShimada) ? soundNumber(context, max) + soundPlace(context, max):
                    soundNumber(context, max);

  String rankNumber() =>
      (abs() % 10 == 1 && abs() ~/ 10 != 1) ? "${abs()}st ":
      (abs() % 10 == 2 && abs() ~/ 10 != 1) ? "${abs()}nd ":
      (abs() % 10 == 3 && abs() ~/ 10 != 1) ? "${abs()}rd ":
      "${abs()}th ";

  String numberBackground(bool isShimada, bool isSelected, int max) =>
      (!isShimada && isSelected) ? "images/normalMode/pressedCircle.png":
      (!isShimada) ? "images/normalMode/circle.png":
      (isShimada && isSelected && this == max) ? "images/1000ButtonsMode/pR.png":
      (isShimada && this == max) ? "images/1000ButtonsMode/R.png":
      (isShimada && isSelected && this < 0) ? "images/1000ButtonsMode/pB${abs()}.png":
      (isShimada && this < 0) ? "images/1000ButtonsMode/B${abs()}.png":
      (isShimada && isSelected) ? "images/1000ButtonsMode/p${this}.png":
      "images/1000ButtonsMode/${this}.png";

  String buttonNumber(int max, bool isShimada) =>
      (isShimada) ? "":
      (this == max) ? "R":
      (this == 0) ? "G":
      (this < 0) ? "B${abs()}":
      "$this";

  String displayNumber(int max) =>
      (this == max) ? " R":
      (this == 0) ? " G":
      (this < 0) ? "B${abs()}":
      (this < 10) ? " $this":
      "$this";

  int elevatorSpeed(int count, int nextFloor) {
    int l = (this - nextFloor).abs();
    return (count < 2 || l < 2) ? 2000:
           (count < 5 || l < 5) ? 1000:
           (count < 10 || l < 10) ? 500:
           (count < 20 || l < 20) ? 250: 100;
  }

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
}

extension DoubleExt on double {

  double displayHeight() =>
      (this < 480) ? 100:
      (this < 1280) ? 100 + (this - 480) / 10: 180;

  double displayWidth() =>
      (this > 500) ? 500: this;

  double displayMargin() =>
      (this < 680) ? 10:
      (this < 1280) ? 10 + (this - 680) / 10: 70;

  double buttonSize() =>
      (this < 680) ? 80 * this / 680: 80;

  double buttonPadding() =>
      (this < 680) ? 10 * this / 680: 10;

  double numberFontSize() =>
      (this < 680) ? 18: 20;

  double admobHeight() =>
      (this < 680) ? 50:
      (this < 1180) ? 50 + (this - 680) / 10: 100;

  double admobWidth() =>
      displayWidth() - 100;

  double speedDialFontSize() =>
      (this < 370) ? 14: 18;
}

extension BoolExt on bool {

  Color onOffColor() =>
      (!this) ? Colors.white : const Color.fromRGBO(247, 178, 73, 1);

      //＜島田電機の電球色＞
      // 島田電機の電球色 → F7B249
      // Red = F7 = 247
      // Green = B2 = 178
      // Blue = 49 = 73

      //＜色温度から算出する電球色＞
      // Temperature = 3000 K → FFB16E
      // Red = 255 = FF
      // Green = 99.47080 * Ln(30) - 161.11957 = 177 = B1
      // Blue = 138.51773 * Ln(30-10) - 305.04480 = 110 = 6E

  //isShimada
  String buttonChanBackGround() =>
      (!this) ? "images/button.png": "images/pButton.png";
  int announceTime() =>
      (this && Platform.isAndroid) ? 4: (Platform.isAndroid) ? 3: 0;

  //isButtonPressed
  String openBackGround(bool isShimada) =>
      (isShimada && !this) ? "images/1000ButtonsMode/sPressedOpen.png":
      (isShimada) ? "images/1000ButtonsMode/sOpen.png":
      (!isShimada && !this) ? "images/normalMode/pressedOpen.png":
      "images/normalMode/open.png";

  String closeBackGround(bool isShimada) =>
      (isShimada && !this) ? "images/1000ButtonsMode/sPressedClose.png":
      (isShimada) ? "images/1000ButtonsMode/sClose.png":
      (!isShimada && !this) ? "images/normalMode/pressedClose.png":
      "images/normalMode/close.png";

  String phoneBackGround(bool isShimada) =>
      (isShimada && !this) ? "images/1000ButtonsMode/sPressedPhone.png":
      (isShimada) ? "images/1000ButtonsMode/sPhone.png":
      (!isShimada && !this) ? "images/normalMode/pressedPhone.png":
      "images/normalMode/phone.png";

}

