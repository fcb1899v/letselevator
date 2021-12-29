import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'my_home_extension.dart';

BoxDecoration metalDecoration() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: [0.1, 0.3, 0.4, 0.7, 0.9],
      colors: [Colors.black12, Colors.white24, Colors.white54, Colors.white10, Colors.black12],
    )
  );
}

Widget rectangleButton(BuildContext context, Color color, String imageFile) {
  final buttonSize = MediaQuery.of(context).size.height.buttonSize();
  return SizedBox(width: buttonSize, height: buttonSize,
    child: ElevatedButton(
      style: rectangleButtonStyle(color),
      child: Image(image: AssetImage(imageFile)),
      onPressed: () {},
    ),
  );
}

ButtonStyle rectangleButtonStyle(Color color) {
  return ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
      const EdgeInsets.all(4)
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        side: BorderSide(color: color, width: 5.0),
        borderRadius: BorderRadius.circular(10.0),
      )
    ),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    shadowColor: MaterialStateProperty.all(Colors.transparent),
    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(56, 54, 53, 1)),
  );
}

Widget circleButton(BuildContext context, Color color, String imageFile) {
  final buttonSize = MediaQuery.of(context).size.height.buttonSize();
  return Container(width: buttonSize, height: buttonSize,
    padding: const EdgeInsets.all(10),
    child: ElevatedButton(
      style: circleButtonStyle(color),
      child: Image(image: AssetImage(imageFile)),
      onPressed: () {},
    ),
  );
}

ButtonStyle circleButtonStyle(Color color) {
  return ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.all(5)
    ),
    shape: MaterialStateProperty.all<CircleBorder>(
      CircleBorder(
        side: BorderSide(color: color, width: 5.0),
      ),
    ),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    shadowColor: MaterialStateProperty.all(Colors.transparent),
    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(56, 54, 53, 1)),
  );
}

ButtonStyle transparentButtonStyle() {
  return ButtonStyle(
    padding: MaterialStateProperty.all(EdgeInsets.zero),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    shadowColor: MaterialStateProperty.all(Colors.transparent),
    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
  );
}

Widget numberButton(BuildContext context, int i, int max, bool isShimada,
  List<bool> isAboveSelectedList, List<bool> isUnderSelectedList,
) {
  final buttonSize = MediaQuery.of(context).size.height.buttonSize();
  bool isSelected = i.isSelected(isAboveSelectedList, isUnderSelectedList);
  return Stack(
    alignment: Alignment.center,
    children: <Widget>[
      SizedBox(width: buttonSize, height: buttonSize,
        child: Image(
          image: AssetImage(i.numberBackground(isShimada, isSelected, max)),
        ),
      ),
      Text(i.buttonNumber(max, isShimada),
        style: TextStyle(
          color: isSelected.onOffColor(),
          fontSize: MediaQuery.of(context).size.height.numberFontSize(),
          fontWeight: FontWeight.bold,
        ),
        textScaleFactor: 1.0,
      ),
    ],
  );
}

Widget displayArrow(int counter, int nextFloor, bool isMoving) {
  if (counter == nextFloor || !isMoving) {
    return const SizedBox(width: 60, height: 60,);
  } else {
    return Container(width: 60, height: 60,
      decoration: BoxDecoration(
        image: DecorationImage(
          alignment: Alignment.centerLeft,
          image: AssetImage(
            (counter < nextFloor) ? "images/up.png": "images/down.png",
          ),
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}

Widget displayNumber(BuildContext context, int counter, int max) {
  return SizedBox(width: 150, height: 60,
    child: Text(counter.displayNumber(max),
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: Color.fromRGBO(247, 178, 73, 1),
        fontSize: 100,
        fontWeight: FontWeight.normal,
        fontFamily: "teleIndicators",
      ),
      textScaleFactor: 1.0,
    ),
  );
}

Widget displayArrowNumber(BuildContext context, int counter, int nextFloor, int max, bool isMoving, bool isShimada) {
  return Container(
    width: MediaQuery.of(context).size.width.displayWidth(),
    height: MediaQuery.of(context).size.height.displayHeight(),
    decoration: const BoxDecoration(
      color: Colors.black,
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        if (isShimada) const Image(height: 80,
          image: AssetImage("images/1000ButtonsMode/shimada.png"),
          color: Color.fromRGBO(56, 54, 53, 0.8),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            displayArrow(counter, nextFloor, isMoving),
            displayNumber(context, counter, max),
            const Spacer(),
          ],
        ),
      ],
    ),
  );
}

TextStyle speedDialTextStyle(BuildContext context) =>
    TextStyle(
      color: const Color.fromRGBO(56, 54, 53, 1),
      fontWeight: FontWeight.bold,
      fontSize: MediaQuery.of(context).size.width.speedDialFontSize(),
    );

SpeedDialChild speedDialChildToLink(BuildContext context, IconData iconData, String label, String link) {
  return SpeedDialChild(
    child: Icon(iconData, size: 50,),
    label: label,
    labelStyle: speedDialTextStyle(context),
    labelBackgroundColor: Colors.white,
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
    onTap: () async {
      launch(link);
    }
  );
}

Widget adMobBannerWidget(BuildContext context, BannerAd myBanner) {
  return SizedBox(
    width: MediaQuery.of(context).size.width.admobWidth(),
    height: MediaQuery.of(context).size.height.admobHeight(),
    child: AdWidget(ad: myBanner),
  );
}

