import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  late String lang;
  late int counter;
  late int nextFloor;
  late bool stopFlag;
  late List<bool> isAboveSelectedList;
  late List<bool> isUnderSelectedList;

  @override
  void initState() {
    super.initState();
    setState(() {
      counter = 1;
      nextFloor = counter;
      stopFlag = true;
      isAboveSelectedList = List.generate(max + 1, (_) => false);
      isUnderSelectedList = List.generate(min * (-1) + 1, (_) => false);
    });
  }

  _counterUp() async {
    int count = 0;
    await Future.forEach(counter.upFromToNumber(nextFloor), (int i) async {
      if (!stopFlag) {
        await Future.delayed(Duration(milliseconds: i.waitTime(count, nextFloor))).then((_) {
          count++;
          setState(() {
            counter++;
            if (counter == 0) counter++;
            if (counter == nextFloor) {
              counter.openSound(context, max).speakText(context);
              counter.clearLowerFloor(isAboveSelectedList, isUnderSelectedList, min);
              nextFloor = counter.upNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
              stopFlag = true;
              print("Next Floor: $nextFloor");
            }
          });
        });
      }
    });
  }

  _counterDown() async {
    int count = 0;
    await Future.forEach(counter.downFromToNumber(nextFloor), (int i) async {
      if (!stopFlag) {
        await Future.delayed(Duration(milliseconds: i.waitTime(count, nextFloor))).then((_) {
          count++;
          setState(() {
            counter--;
            if (counter == 0) counter--;
            if (counter == nextFloor) {
              counter.closeSound(context, max).speakText(context);
              counter.clearUpperFloor(isAboveSelectedList, isUnderSelectedList, max);
              nextFloor = counter.downNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
              stopFlag = true;
              print("Next Floor: $nextFloor");
            }
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size display = MediaQuery.of(context).size;
    return Container(
      height: display.height,
      width: display.width,
      padding: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.1, 0.4, 0.7, 0.9],
          colors: [Colors.white38, Colors.white70, Colors.white54, Colors.white38]
        )
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                SizedBox(height: display.height.panelMargin()),
                displayNumberView(context, counter, nextFloor, max, stopFlag),
                SizedBox(height: display.height.panelMargin()),
                operationButtons(),
                floorButtons([14, 69, 154, max], [true, true, true, true]),
                floorButtons([5, 6, 7, 8], [true, false, true, true]),
                floorButtons([1, 2, 3, 4], [true, true, true, true]),
                floorButtons([-1, -2, -3, -4], [true, true, true, false]),
              ]
            )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: adMobWidget(context),
          ),
        ],
        fit: StackFit.expand,
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
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        child: numberText(i ,max, isAboveSelectedList, isUnderSelectedList),
        style: numberButtonStyle(i, isAboveSelectedList, isUnderSelectedList),
        //ボタン選択をする
        onPressed: () {
          if (i != 0) {
            if (!selectFlag) {
              AppLocalizations.of(context)!.notStop.speakText(context);
            } else if (stopFlag && i == counter) {
              AppLocalizations.of(context)!.pushNumber.speakText(context);
            } else if (!i.isSelected(isAboveSelectedList, isUnderSelectedList)){
              setState(() {
                i.trueSelected(isAboveSelectedList, isUnderSelectedList);
                if (counter < i && i < nextFloor) nextFloor = i;
                if (counter > i && i > nextFloor) nextFloor = i;
                if (i.onlyTrue(isAboveSelectedList, isUnderSelectedList)) nextFloor = i;
                print("Next Floor: $nextFloor");
              });
            }
          }
        },
        //ボタン選択を解除する
        onLongPress: () {
          if (stopFlag && i.isSelected(isAboveSelectedList, isUnderSelectedList)) {
            setState(() {
              i.falseSelected(isAboveSelectedList, isUnderSelectedList);
              if (counter < nextFloor) {
                nextFloor = counter.upNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
              }
              if (counter > nextFloor) {
                nextFloor = counter.downNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
              }
              print("Next Floor: $nextFloor");
            });
          }
        }
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
      child: ElevatedButton(
        child: imageButtonView("images/open.png"),
        onPressed: () {
          if (stopFlag) {
            AppLocalizations.of(context)!.openDoor.speakText(context);
          }
        },
        style: imageButtonStyle(Colors.greenAccent),
      ),
    );
  }

  Widget closeButton() {
    return Container(width: 80, height: 80,
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        child: imageButtonView("images/close.png"),
        onPressed: () {
          if (stopFlag) {
            if (counter == nextFloor) {
              AppLocalizations.of(context)!.pushNumber.speakText(context);
            } else if (counter < nextFloor) {
              setState(() => stopFlag = false);
              AppLocalizations.of(context)!.upFloor.closeDoorSound(context).speakText(context);
              Future.delayed(const Duration(seconds: 3)).then((_) => _counterUp());
            } else {
              setState(() => stopFlag = false);
              AppLocalizations.of(context)!.downFloor.closeDoorSound(context).speakText(context);
              Future.delayed(const Duration(seconds: 3)).then((_) => _counterDown());
            }
          }
        },
        style: imageButtonStyle(Colors.white),
      ),
    );
  }

  Widget alertButton() {
    return Container(width: 80, height: 80,
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        child: imageButtonView("images/phone.png"),
        onPressed: () {print("Height: ${MediaQuery.of(context).size.height}");},
        onLongPress: () => "audios/phone.mp3".startAudio(),
        style: imageButtonStyle(Colors.yellow),
      ),
    );
  }
}