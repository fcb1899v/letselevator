import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common_extension.dart';
import 'constant.dart';

const String bestScoreKey = "bestScore";

extension IntExt on int {

  bool ableButtonFlag(int i) =>
      (i == 36 && this == 2) ? false:
      (i == 42 && this == 4) ? false:
      (i == 13 && this == 7) ? false:
      true;

  double buttonWidthFactor(int i) =>
      (i == 16 && this == 1) ? 3:
      (i == 60 && this == 1) ? 2:
      (i == 70 && this == 1) ? 2:
      (i == 86 && this == 1) ? 4:
      (i == 5 && this == 2) ? 3:
      (i == 24 && this == 2) ? 3:
      (i == 30 && this == 2) ? 3:
      (i == 42 && this == 2) ? 2:
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

  String countNumber() {
    return (this > 999) ? "$this":
    (this > 99) ? "0$this":
    (this > 9) ? "00$this":
    "000$this";
  }

  String bestScore(BuildContext context) =>
      "${AppLocalizations.of(context)!.best}${countNumber()}";

  String finishBestScore(BuildContext context, int counter) =>
      (counter > this) ? AppLocalizations.of(context)!.newRecord: bestScore(context);


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
      (!isCountStart) ? AppLocalizations.of(context)!.start:
      (this > 9) ? "$this": "0$this";

  Color startButtonColor(bool isCountStart) =>
      (this == 0 && isCountStart) ? redColor:
      (!isCountStart || this % 2 == 1) ? blackColor:
      (this < 10) ? yellowColor:
      greenColor;

  List<List<bool>> listListAllTrue(int rowMax) => List.generate(
      rowMax, (_) => List.generate(this, (_) => true));

  List<List<bool>> listListAllFalse(int rowMax) => List.generate(
      rowMax, (_) => List.generate(this, (_) => false));
}


extension DoubleExt on double {

  double startWidth() =>
      (this < 900) ? this / 6: 150.0;

  double startHeight() =>
      (this < 800) ? this / 8: 100.0;

  double startPadding() =>
      (this < 900) ? this / 60: 15;

  double startBorderWidth() =>
      (this < 800) ? this / 400: 2.0;

  double startCornerRadius() =>
      (this < 800) ? this / 80: 10.0;

  double defaultButtonLength() =>
      0.07 * this - 2;

  double buttonWidth(int i, int j) =>
      j.buttonWidthFactor(i) * defaultButtonLength();

  double buttonHeight() =>
      defaultButtonLength();

  double largeButtonWidth(double ratio) =>
      ratio * defaultButtonLength();

  double largeButtonHeight(double ratio) =>
      ratio * defaultButtonLength();

  double longButtonHeight() =>
      3 * defaultButtonLength();

  double paddingSize() =>
      (this < 1100) ? 0.014 * this - 3: 12.4 + 0.038 * (this - 1100);
}

extension ListListBoolExt on List<List<bool>> {

  String buttonImage(int i, int j) => (this[i][j]) ?
      "${assetsRealOn}xp${(7 * i - 13 * j) % 36 + 1}.png":
      "${assetsRealOff}x${(7 * i - 13 * j) % 36 + 1}.png";
      //(this[i][j]) ? "${assetsRealOn}p${i}_$j.png": "${assetsRealOff}${i}_$j.png";

  String buttonBackground(int i, int j, List<List<bool>> isAbleButtonsList) =>
      (!isAbleButtonsList[i][j]) ?
        "${assetsCommon}transparent.png":
        buttonImage(i, j);

  int countTrue(int rowMax, int columnMax) {
    int counter = 0;
    for (int i = 0; i < rowMax; i++) {
      for (int j = 0; j < columnMax; j++) {
        if (this[i][j] == true) counter++;
      }
    }
    "counter: $counter".debugPrint();
    return counter;
  }
}