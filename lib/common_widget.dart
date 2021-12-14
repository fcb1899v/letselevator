import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';
import 'extension.dart';

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

Widget numberButton(int i, int max, bool isShimada,
  List<bool> isAboveSelectedList, List<bool> isUnderSelectedList,
) {
  bool isSelected = i.isSelected(isAboveSelectedList, isUnderSelectedList);
  return Container(width: 80, height: 80,
    padding: const EdgeInsets.all(10.0),
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        numberButtonView(i, max, isSelected, isShimada),
        numberTextView(i, max, isSelected, isShimada),
      ],
    ),
  );
}

Widget numberButtonView(int i, int max, bool isSelected, bool isShimada){
  return SizedBox(width: 60, height: 60,
    child: Image(
      image: AssetImage(i.numberBackground(isShimada, isSelected, max)),
    ),
  );
}

Widget numberTextView(int i, int max, bool isSelected, bool isShimada){
  return Text(i.buttonNumber(max, isShimada),
    style: TextStyle(
      color: isSelected.onOffColor(),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    textScaleFactor: 1.0,
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

Widget displayArrowNumber(BuildContext context, int counter, int max, int nextFloor, bool isMoving, bool isShimada) {
  return Stack(
    alignment: Alignment.center,
    children: [
      if (isShimada) const Image(height: 80,
        image: AssetImage("images/shimada.png"),
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
  );
}

Widget displayArrowNumberView(BuildContext context, int counter, int nextFloor, int max, bool isMoving, bool isShimada) {
  final Size display = MediaQuery.of(context).size;
  return Container(
    width: display.width.displayWidth(),
    height: display.height.displayHeight(),
    decoration: const BoxDecoration(
      color: Colors.black,
    ),
    child: displayArrowNumber(context, counter, max, nextFloor, isMoving, isShimada),
  );
}

TextStyle speedDialTextStyle() =>
  const TextStyle(
    color: Color.fromRGBO(56, 54, 53, 1),
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

SpeedDialChild speedDialChildToLink(IconData iconData, String label, String link) {
  return SpeedDialChild(
    child: Icon(iconData, size: 50,),
    label: label,
    labelStyle: speedDialTextStyle(),
    labelBackgroundColor: Colors.white,
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
    onTap: () async {
      "piron.mp3".playAudio();
      launch(link);
    }
  );
}
