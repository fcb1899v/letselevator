extension IntExt on int {

  bool ableButtonFlag(int i) =>
      (i == 36 && this == 2) ? false:
      (i == 42 && this == 3) ? false:
      (i == 42 && this == 4) ? false:
      (i == 13 && this == 6) ? false:
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
}

extension DoubleExt on double {

  double title1000Height() =>
      (this < 800) ? 60 * this / 800: 60;

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

  String buttonImage(int i, int j) =>
      (this[i][j]) ? "images/1000ButtonsOn/xp${(7 * i - 13 * j) % 36 + 1}.png":
                     "images/1000ButtonsOff/x${(7 * i - 13 * j) % 36 + 1}.png";
      //(this[i][j]) ? "images/p${i}_$j.png": "images/${i}_$j.png";

  String buttonBackground(int i, int j, List<List<bool>> isAbleButtonsList) =>
      (!isAbleButtonsList[i][j]) ? "images/transparent.png": buttonImage(i, j);

}