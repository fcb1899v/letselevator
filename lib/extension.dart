import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

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
            (lang == "ja" && this > 0) ? "${this}$floor":
            (lang == "ja" && this < 0) ? "$chika${abs()}$floor":
            (this > 0) ? "${rankNumber()}$floor":
            "${rankNumber()}$basement$floor";
  }

  String rankNumber() =>
      (abs() % 10 == 1 && abs() ~/ 10 != 1) ? "${abs()}st ":
      (abs() % 10 == 2 && abs() ~/ 10 != 1) ? "${abs()}nd ":
      (abs() % 10 == 3 && abs() ~/ 10 != 1) ? "${abs()}rd ":
      "${abs()}th ";

  String buttonNumber(int max) =>
      (this == max) ? "R":
      (this == 100) ? "百":
      (this == 0) ? "G":
      (this < 0) ? "B${abs()}": "$this";

  String displayNumber(int max) =>
      (this == max) ? " R":
      (this == 0) ? " G":
      (this < 0) ? "B${abs()}":
      (this < 10) ? " $this": "$this";

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

extension StringExt on String {

  Future<void> speakText(BuildContext context) async {
    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage(Localizations.localeOf(context).languageCode);
    flutterTts.setSpeechRate(0.5);
    await flutterTts.stop();
    await flutterTts.speak(this);
  }

  Future<void> startAudio() async {
    AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
    await assetsAudioPlayer.open(Audio(this),);
  }
}

extension DoubleExt on double {

  double displayTopMargin() =>
      (this < 680) ? 0:
      (this < 1280) ? (this - 680) / 4: 150;

  double displayHeight() =>
      (this < 680) ? 120:
      (this < 1280) ? 120 + (this - 680) / 10: 180;

  double displayWidth() =>
      (this > 440) ? 440: this;

  double buttonMargin() =>
      (this < 680) ? 10:
      (this < 1280) ? 10 + (this - 680) / 10: 70;
}

extension BoolExt on bool {

  Color onOffColor() =>
      (!this) ? Colors.white : const Color.fromRGBO(255, 177, 110, 1);
      // Temperature = 3000 K = FFB16E
      // Red = 255 = FF
      // Green = 99.47080 * Ln(30) - 161.11957 = 177 = B1
      // Blue = 138.51773 * Ln(30-10) - 305.04480 = 110 = 6E
}


