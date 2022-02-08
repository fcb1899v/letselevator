import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'constant.dart';

extension IntExt on int {

  String soundFloor(BuildContext context, int max, bool isShimada) {

    String lang = Localizations.localeOf(context).languageCode;
    String basement = (this < 0) ? AppLocalizations.of(context)!.basement: "";

    String enRankNumber =
      (abs() % 10 == 1 && abs() ~/ 10 != 1) ? "${abs()}st ":
      (abs() % 10 == 2 && abs() ~/ 10 != 1) ? "${abs()}nd ":
      (abs() % 10 == 3 && abs() ~/ 10 != 1) ? "${abs()}rd ":
      "${abs()}th ";

    String soundPlace = (!isShimada) ? "":
      (this == 3) ? AppLocalizations.of(context)!.platform:
      (this == 7) ? AppLocalizations.of(context)!.dog:
      (this == 14) ? AppLocalizations.of(context)!.spa:
      (this == 154) ? AppLocalizations.of(context)!.vip:
      (this == -2) ? AppLocalizations.of(context)!.parking:
      (this == max) ? AppLocalizations.of(context)!.paradise: "";

    return "${
      (this == max) ? AppLocalizations.of(context)!.rooftop:
      (this == 0) ? AppLocalizations.of(context)!.ground:
      AppLocalizations.of(context)!.floor(
        (lang == "en") ? "$enRankNumber$basement": "$basement${abs()}"
      )
    }$soundPlace";
  }

  String numberBackground(bool isShimada, bool isSelected, int max) =>
      (!isShimada) ? "$assetsNormal${isSelected ? "pressedCircle.png": "circle.png"}":
      (this == max) ? "$assets1000${isSelected ? "pR.png": "R.png"}":
      (this > 0) ? "$assets1000${isSelected ? "p${this}.png": "${this}.png"}":
      "$assets1000${(isSelected) ? "pB${abs()}.png": "B${abs()}.png"}";

  String buttonNumber(int max, bool isShimada) =>
      (isShimada) ? "":
      (this == max) ? "R":
      (this == 0) ? "G":
      (this < 0) ? "B${abs()}":
      "$this";

  String displayNumber(int max) =>
      (this == max) ? "R":
      (this == 0) ? "G":
      (this < 0) ? "B${abs()}":
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

  String arrowImage(bool isMoving, int nextFloor) =>
      "$assetsCommon${
        (isMoving && this < nextFloor) ? "up.png":
        (isMoving && this > nextFloor) ? "down.png":
        "transparent.png"
      }";

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
      (this < 200) ? 8:
      (this < 250) ? 10:
      (this < 300) ? 12:
      (this < 370) ? 14: 16;
}

extension BoolExt on bool {

  //this -> isShimada
  String buttonChanBackGround() =>
      "$assetsCommon${(this) ? "pButton.png": "button.png"}";

  String shimadaLogo() =>
      "$assetsCommon${(this) ? "shimada.png": "transparent.png"}";

  String openBackGround(bool isPressed) => (this) ?
      "$assets1000${(isPressed) ? "sOpen.png": "sPressedOpen.png"}":
      "$assetsNormal${(isPressed) ? "open.png": "pressedOpen.png"}";

  String closeBackGround(bool isPressed) => (this) ?
      "$assets1000${(isPressed) ? "sClose.png": "sPressedClose.png"}":
      "$assetsNormal${(isPressed) ? "close.png": "pressedClose.png"}";

  String phoneBackGround(bool isPressed) => (this) ?
      "$assets1000${(isPressed) ? "sPhone.png": "sPressedPhone.png"}":
      "$assetsNormal${(isPressed) ? "phone.png": "pressedPhone.png"}";

  int announceTime() =>
      (this) ? 4: 3;
}

