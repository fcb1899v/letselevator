import 'package:flutter/material.dart';
import 'my_home_extension.dart';
import 'constant.dart';

Image shimadaLogoImage(bool isShimada) => Image(
  height: 80,
  image: AssetImage(isShimada.shimadaLogo()),
  color: blackColor,
);

Widget displayArrow(String image) => Container(
  width: 60,
  height: 60,
  decoration: BoxDecoration(
    image: DecorationImage(
      alignment: Alignment.centerLeft,
      image: AssetImage(image),
      fit: BoxFit.fitHeight,
    ),
  ),
);

Widget displayNumber(String number) => SizedBox(
  width: 150,
  height: 60,
  child: Text(number,
    textAlign: TextAlign.right,
    style: const TextStyle(
      color: lampColor,
      fontSize: 100,
      fontWeight: FontWeight.normal,
      fontFamily: numberFont,
    ),
    textScaleFactor: 1.0,
  ),
);

Text buttonNumberText(double height, String number, bool isSelected) =>
    Text(number,
      style: TextStyle(
        color: (isSelected) ? lampColor: whiteColor,
        fontSize: height.numberFontSize(),
        fontWeight: FontWeight.bold,
      ),
      textScaleFactor: 1.0,
    );

Widget buttonBackGround(double height, String image) =>
    SizedBox(
      width: height,
      height: height,
      child: Image(image: AssetImage(image)),
    );

Widget openButtonImage(double height, bool isShimada, bool isPressedButton) =>
    buttonBackGround(
      height.operationButtonSize(),
      isShimada.openBackGround(isPressedButton),
    );

Widget closeButtonImage(double height, bool isShimada, bool isPressedButton) =>
    buttonBackGround(
      height.operationButtonSize(),
      isShimada.closeBackGround(isPressedButton),
    );

Widget alertButtonImage(double height, bool isShimada, bool isPressedButton) =>
    buttonBackGround(
      height.operationButtonSize(),
      isShimada.phoneBackGround(isPressedButton)
    );

RoundedRectangleBorder rectangleShape(Color color) =>
    RoundedRectangleBorder(
      side: BorderSide(color: color, width: 5.0),
      borderRadius: BorderRadius.circular(10.0),
    );

ButtonStyle rectangleButtonStyle(Color color) {
  return ButtonStyle(
    shape: MaterialStateProperty.all(rectangleShape(color)),
    padding: MaterialStateProperty.all(const EdgeInsets.all(4)),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: MaterialStateProperty.all(transpColor),
    foregroundColor: MaterialStateProperty.all(transpColor),
    shadowColor: MaterialStateProperty.all(transpColor),
    backgroundColor: MaterialStateProperty.all(blackColor),
  );
}

CircleBorder circleShape(Color color) =>
    CircleBorder(
      side: BorderSide(color: color, width: 5.0),
    );

ButtonStyle circleButtonStyle(Color color) {
  return ButtonStyle(
    shape: MaterialStateProperty.all(circleShape(color)),
    padding: MaterialStateProperty.all(const EdgeInsets.all(4)),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: MaterialStateProperty.all(transpColor),
    foregroundColor: MaterialStateProperty.all(transpColor),
    shadowColor: MaterialStateProperty.all(transpColor),
    backgroundColor: MaterialStateProperty.all(blackColor),
  );
}

ButtonStyle transparentButtonStyle() {
  return ButtonStyle(
    shape: MaterialStateProperty.all(null),
    padding: MaterialStateProperty.all(EdgeInsets.zero),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: MaterialStateProperty.all(transpColor),
    foregroundColor: MaterialStateProperty.all(transpColor),
    shadowColor: MaterialStateProperty.all(transpColor),
    backgroundColor: MaterialStateProperty.all(transpColor),
  );
}

