import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';

extension IntExt on int {

  String soundNumber(BuildContext context, int max) {
    String lang = Localizations.localeOf(context).languageCode;
    String rooftop = AppLocalizations.of(context)!.rooftop;
    String floor = AppLocalizations.of(context)!.floor;
    String chika = AppLocalizations.of(context)!.chika;
    String basement = AppLocalizations.of(context)!.basement;
    if (this == max) {
      return rooftop;
    } else if (lang == "ja" && this > 0) {
       return "$this $floor";
    } else if (lang == "ja" && this < 0) {
      return "$chika ${(-1) * this} $floor";
    } else if (this > 0) {
      if (this % 10 == 1 && this ~/ 10 != 1) {
        return "${this}st $floor";
      } else if (this % 10 == 2 && this ~/ 10 != 1) {
        return "${this}nd $floor";
      } else if (this % 10 == 3 && this ~/ 10 != 1) {
        return "${this}rd $floor";
      } else {
        return "${this}th $floor";
      }
    } else {
      if (this % 10 == 1 && this ~/ 10 != -1) {
        return "$chika${(-1) * this}st $basement $floor";
      } else if (this % 10 == 2 && this ~/ 10 != -1) {
        return "$chika${(-1) * this}nd $basement $floor";
      } else if (this % 10 == 3 && this ~/ 10 != -1) {
        return "$chika${(-1) * this}rd $basement $floor";
      } else {
        return "$chika${(-1) * this}th $basement $floor";
      }
    }
  }

  String openSound(BuildContext context, int max) {
    return soundNumber(context, max) + AppLocalizations.of(context)!.openDoor;
  }

  String closeSound(BuildContext context, int max) {
    return soundNumber(context, max) + AppLocalizations.of(context)!.closeDoor;
  }

  String buttonNumber(int max) {
    String num = "$this";
    if (this < 0) num = "B${this * (-1)}";
    if (this == max) num = "R";
    return num;
  }

  String displayNumber(int max) {
    String num = "$this";
    if (this < 10 && this > 0) num = " $this";
    if (this < 0) num = "B${this * (-1)}";
    if (this == max) num = " R";
    return num;
  }

  int waitTime(int count, int nextFloor) {
    int l = (this - nextFloor).abs();
    if (count < 5 || l < 5) {
      return 1000;
    } else if (count < 10 || l < 10) {
      return 500;
    } else if (count < 20 || l < 20) {
      return 250;
    } else {
      return 100;
    }
  }

  //this is i and counter.
  bool isSelected(List<bool> isAboveSelectedList, List<bool> isUnderSelectedList) {
    return (this > 0) ? isAboveSelectedList[this]: isUnderSelectedList[this * (-1)];
  }

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
    await flutterTts.stop();
    flutterTts.setLanguage(
        Localizations.localeOf(context).languageCode
    );
    flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(this);
  }

  Future<void> startAudio() async {
    FlutterTts flutterTts = FlutterTts();
    AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
    await flutterTts.stop();
    await assetsAudioPlayer.open(Audio(this),);
  }

  String closeDoorSound(BuildContext context) {
    return this + AppLocalizations.of(context)!.closeDoor;
  }
}

extension DoubleExt on double {

  double panelMargin() {
    if (this < 680) {
      return 20;
    } else if (this < 1080) {
      return 20 + (this - 680) / 4;
    } else {
      return 120;
    }
  }
}