import 'package:flutter/material.dart';
import 'extension.dart';

BoxDecoration backgroundDecoration() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: [0.1, 0.4, 0.7, 0.9],
      colors: [Colors.white38, Colors.white70, Colors.white54, Colors.white38]
    )
  );
}

Widget imageButtonView(String link) {
  return FittedBox(
      fit: BoxFit.fitHeight,
      child: Container(width: 40, height: 40,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(link),
          fit: BoxFit.fitWidth,
        ),
      ),
    ),
  );
}

ButtonStyle imageButtonStyle(Color color) {
  return ButtonStyle(
    minimumSize: MaterialStateProperty.all<Size>(const Size(80, 80)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        side: BorderSide(color: color, width: 4.0),
        borderRadius: BorderRadius.circular(10.0),
      )
    ),
    overlayColor: MaterialStateProperty.all<Color>(color.withOpacity(0.5)),
    backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
  );
}

ButtonStyle numberButtonStyle(int i, List<bool> isAboveSelectedList, List<bool> isUnderSelectedList) {
  bool isSelected = i.isSelected(isAboveSelectedList, isUnderSelectedList);
  return ButtonStyle(
    minimumSize: MaterialStateProperty.all<Size>(const Size(80, 80)),
    shape: MaterialStateProperty.all<CircleBorder>(
      CircleBorder(
        side: BorderSide(
          color: isSelected.onOffColor(),
          width: 4,
          style: BorderStyle.solid,
        ),
      ),
    ),
    backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
  );
}

Widget numberText(int i, int max, List<bool> isAboveSelectedList, List<bool> isUnderSelectedList) {
  bool isSelected = i.isSelected(isAboveSelectedList, isUnderSelectedList);
  return FittedBox(
    fit: BoxFit.fitHeight,
    child: Text(i.buttonNumber(max),
      style: TextStyle(
        color: isSelected.onOffColor(),
        fontSize: 20,
        fontWeight: FontWeight.normal,
      ),
      textScaleFactor: 1.0,
    ),
  );
}

Widget displayArrow(int counter, int nextFloor, bool isMoving) {
  if (counter == nextFloor || !isMoving) {
    return const SizedBox(width: 120, height: 60,);
  } else {
    return Container(width: 120, height: 60,
      decoration: BoxDecoration(
        image: DecorationImage(
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
  return Container(width: 180,
    padding: const EdgeInsets.only(top: 5),
    child: Text(counter.displayNumber(max),
      textAlign: TextAlign.end,
      style: const TextStyle(
        color: Color.fromRGBO(255, 177, 110, 1),
        fontSize: 100,
        fontWeight: FontWeight.normal,
        fontFamily: "teleIndicators",
      ),
      textScaleFactor: 1.0,
    ),
  );
}

Widget displayNumberView(BuildContext context, int counter, int nextFloor, int max, bool isMoving) {
  final Size display = MediaQuery.of(context).size;
  return Container(
    width: display.width.displayWidth(),
    height: display.height.displayHeight(),
    decoration: const BoxDecoration(
      color: Colors.black,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        displayNumber(context, counter, max),
        displayArrow(counter, nextFloor, isMoving)
      ],
    )
  );
}

