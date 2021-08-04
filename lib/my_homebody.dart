import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'common_widget.dart';
import 'extension.dart';
import 'admob.dart';

class MyHomeBody extends StatefulWidget {
  const MyHomeBody({Key? key}) : super(key: key);
  @override
  State<MyHomeBody> createState() => _MyHomeBodyState();
}

class _MyHomeBodyState extends State<MyHomeBody> {

  final int min = -4;
  final int max = 163;
  final int openTime = 10;
  final int waitTime = 3;
  late String lang;
  late int counter;
  late int nextFloor;
  late bool isMoving;
  late bool isBeforeMove;
  late bool isOpenDoor;
  late bool isOpenPressed;
  late bool isClosePressed;
  late bool isCallPressed;
  late List<bool> isAboveSelectedList;
  late List<bool> isUnderSelectedList;
  late BannerAd myBanner;

  @override
  void initState() {
    super.initState();
    setState(() {
      counter = 1;
      nextFloor = counter;
      isMoving = false;
      isBeforeMove = false;
      isOpenDoor = true;
      isOpenPressed = true;
      isClosePressed = true;
      isCallPressed = true;
      isAboveSelectedList = List.generate(max + 1, (_) => false);
      isUnderSelectedList = List.generate(min * (-1) + 1, (_) => false);
      myBanner = AdmobService().getBannerAd();
    });
    AppLocalizations.of(context)!.openDoor.speakText(context);
  }

  _openingDoor() async {
    if (!isMoving && isBeforeMove && !isOpenDoor) {
      AppLocalizations.of(context)!.openDoor.speakText(context);
      setState(() {
        isMoving = false;
        isBeforeMove = false;
        isOpenDoor = true;
      });
    }
  }

  _closingDoor() async {
    if (!isMoving && !isBeforeMove && isOpenDoor) {
      AppLocalizations.of(context)!.closeDoor.speakText(context);
      setState(() {
        isMoving = false;
        isBeforeMove = true;
        isOpenDoor = false;
      });
      await Future.delayed(Duration(seconds: waitTime)).then((_) {
        if (!isMoving && isBeforeMove && !isOpenDoor) {
          (counter < nextFloor) ? _counterUp():
          (counter > nextFloor) ? _counterDown():
          AppLocalizations.of(context)!.pushNumber.speakText(context);
        }
      });
    }
  }

  _counterUp() async {
    AppLocalizations.of(context)!.upFloor.speakText(context);
    int count = 0;
    await Future.delayed(Duration(seconds: waitTime)).then((_) {
      setState(() {
        isMoving = true;
        isBeforeMove = false;
        isOpenDoor = false;
      });
      Future.forEach(counter.upFromToNumber(nextFloor), (int i) async {
        await Future.delayed(Duration(milliseconds: i.elevatorSpeed(count, nextFloor))).then((_) async {
          count++;
          if (isMoving && counter < nextFloor && nextFloor <  max + 1) setState(() => counter++);
          if (counter == 0) setState(() => counter++);
          if (isMoving && (counter == nextFloor || counter == max)) {
            counter.arriveFloor(context, max).speakText(context);
            setState(() {
              isMoving = false;
              isBeforeMove = false;
              isOpenDoor = true;
              counter.clearLowerFloor(isAboveSelectedList, isUnderSelectedList, min);
              nextFloor = counter.upNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
            });
            print("Next Floor: $nextFloor");
          }
        });
      });
    });
  }

  _counterDown() async {
    AppLocalizations.of(context)!.downFloor.speakText(context);
    int count = 0;
    await Future.delayed(Duration(seconds: waitTime)).then((_) {
      setState(() {
        isMoving = true;
        isBeforeMove = false;
        isOpenDoor = false;
      });
      Future.forEach(counter.downFromToNumber(nextFloor), (int i) async {
        await Future.delayed(Duration(milliseconds: i.elevatorSpeed(count, nextFloor))).then((_) async {
          count++;
          if (isMoving && min - 1 < nextFloor && nextFloor < counter) setState(() => counter--);
          if (counter == 0) setState(() => counter--);
          if (isMoving && (counter == nextFloor || counter == min)) {
            counter.arriveFloor(context, max).speakText(context);
            setState(() {
              isMoving = false;
              isBeforeMove = false;
              isOpenDoor = true;
              counter.clearUpperFloor(isAboveSelectedList, isUnderSelectedList, max);
              nextFloor = counter.downNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
            });
            print("Next Floor: $nextFloor");
          }
        });
      });
    });
  }

  //行き先階ボタンの選択を解除する
  _floorCanceled(int i) {
    if (i.isSelected(isAboveSelectedList, isUnderSelectedList)) {
      if (!isMoving || i != nextFloor) {
        "audios/popi.mp3".startAudio();
        setState(() {
          i.falseSelected(isAboveSelectedList, isUnderSelectedList);
          if (i == nextFloor) {
            nextFloor = (counter < nextFloor) ?
              counter.upNextFloor(isAboveSelectedList, isUnderSelectedList, min, max) :
              counter.downNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
          }
        });
        print("Next Floor: $nextFloor");
      }
    }
  }

  //行き先階ボタンを選択する
  _floorSelected (int i, bool selectFlag) async {
    if (i == counter) {
      if (!isMoving && i == nextFloor) {
        AppLocalizations.of(context)!.pushNumber.speakText(context);
      }
    } else if (!selectFlag) {
      //止まらない階の場合のメッセージ
      AppLocalizations.of(context)!.notStop.speakText(context);
    } else if (!i.isSelected(isAboveSelectedList, isUnderSelectedList)){
      "audios/pon.mp3".startAudio();
      setState(() {
        i.trueSelected(isAboveSelectedList, isUnderSelectedList);
        if (counter < i && i < nextFloor) nextFloor = i;
        if (counter > i && i > nextFloor) nextFloor = i;
        if (i.onlyTrue(isAboveSelectedList, isUnderSelectedList)) nextFloor = i;
      });
      print("Next Floor: $nextFloor");
      if (!isMoving && isBeforeMove && !isOpenDoor) {
        (counter < nextFloor) ? _counterUp(): _counterDown();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size display = MediaQuery.of(context).size;
    return Container(
      height: display.height,
      width: display.width.displayWidth(),
      padding: const EdgeInsets.only(top: 30),
      decoration: backgroundDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: display.height.displayTopMargin()),
          displayNumberView(context, counter, nextFloor, max, isMoving),
          const Spacer(),
          operationButtons(),
          SizedBox(height: display.height.buttonMargin()),
          floorButtons([14, 69, 154, max], [true, true, true, true]),
          floorButtons([5, 6, 7, 8], [true, false, true, true]),
          floorButtons([1, 2, 3, 4], [true, true, true, true]),
          floorButtons([-1, -2, -3, -4], [true, true, false, true]),
          const Spacer(),
          adMobWidget(context, myBanner),
        ],
      ),
    );
  }

  Widget floorButtons(List<int> n, List<bool> nFlag) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          floorButton(n[0], nFlag[0]),
          floorButton(n[1], nFlag[1]),
          floorButton(n[2], nFlag[2]),
          floorButton(n[3], nFlag[3]),
        ]
    );
  }

  Widget floorButton(int i, bool selectFlag) {
    return Container(width: 80, height: 80,
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        style: numberButtonStyle(i, isAboveSelectedList, isUnderSelectedList),
        child: GestureDetector(
          child: numberText(i ,max, isAboveSelectedList, isUnderSelectedList),
          onLongPress: () => _floorCanceled(i),
          onDoubleTap: () => _floorCanceled(i),
        ),
        //ボタン選択をする
        onPressed: () => _floorSelected(i, selectFlag),
      ),
    );
  }

  Widget operationButtons() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          openButton(),
          closeButton(),
          const SizedBox(width: 80),
          alertButton(),
        ]
    );
  }

  Widget openButton() {
    return Container(width: 80, height: 80,
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        child: ElevatedButton(
          style: imageButtonStyle(Colors.greenAccent),
          child: imageButtonView(
            (isOpenPressed) ? "images/open.png": "images/pressedOpen.png"
          ),
          onPressed: () async {
            setState(() => isOpenPressed = true);
            _openingDoor();
          },
        ),
        onTapDown: (_) => setState(() => isOpenPressed = false),
      ),
    );
  }

  Widget closeButton() {
    return Container(width: 80, height: 80,
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        child: ElevatedButton(
          style: imageButtonStyle(Colors.white),
          child: imageButtonView(
            (isClosePressed) ? "images/close.png": "images/pressedClose.png"
          ),
          onPressed: () {
            setState(() => isClosePressed = true);
            _closingDoor();
          },
        ),
        onTapDown: (_) => setState(() => isClosePressed = false),
      )
    );
  }

  Widget alertButton() {
    return Container(width: 80, height: 80,
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        child: ElevatedButton(
          style: imageButtonStyle(Colors.yellow),
          child: imageButtonView(
            (isCallPressed) ? "images/phone.png": "images/pressedPhone.png"
          ),
          onPressed: () => setState(() => isCallPressed = true),
          onLongPress: () {
            setState(() => isCallPressed = true);
            "audios/call.mp3".startAudio();
          },
        ),
        onTapDown: (_) => setState(() => isCallPressed = false),
        onLongPressDown: (_) => setState(() => isCallPressed = false),
      ),
    );
  }
}