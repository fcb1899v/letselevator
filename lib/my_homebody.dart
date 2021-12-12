import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vibration/vibration.dart';
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
  final int vibTime = 200;
  final int vibAmp = 128;

  final List<bool> openedState = [true, false, false, false];
  final List<bool> closedState = [false, true, false, false];
  final List<bool> openingState = [false, false, true, false];
  final List<bool> closingState = [false, false, false, true];

  final List<bool> noPressed = [false, false, false];
  final List<bool> pressedOpen = [true, false, false];
  final List<bool> pressedClose = [false, true, false];
  final List<bool> pressedCall = [false, false, true];
  final List<bool> allPressed = [true, true, true];

  late String lang;
  late int counter;
  late int nextFloor;
  late bool isMoving;
  late bool isEmergency;
  late bool isShimada;
  late List<bool> isDoorState; //[opened, closed, opening, closing]
  late List<bool> isPressedButton; //[open, close, call]
  late List<bool> isAboveSelectedList;
  late List<bool> isUnderSelectedList;
  late BannerAd myBanner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => initPlugin());
    setState(() {
      counter = 1;
      nextFloor = counter;
      isMoving = false;
      isEmergency = false;
      isShimada = false;
      isDoorState = closedState;
      isPressedButton = allPressed;
      isAboveSelectedList = List.generate(max + 1, (_) => false);
      isUnderSelectedList = List.generate(min * (-1) + 1, (_) => false);
      myBanner = AdmobService().getBannerAd();
    });
  }

  _openingDoor() async {
    if (!isMoving && !isEmergency && (isDoorState == closedState || isDoorState == closingState)) {
      "pon.mp3".playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      setState(() => isDoorState = openingState);
      await AppLocalizations.of(context)!.openDoor.speakText(context);
      await Future.delayed(Duration(seconds: waitTime)).then((_) async {
        if (!isMoving && !isEmergency && isDoorState == openingState) {
          setState(() => isDoorState = openedState);
          await Future.delayed(Duration(seconds: openTime)).then((_) async{
            if (!isMoving && !isEmergency && isDoorState == openedState) {
              _closingDoor();
            }
          });
        }
      });
    }
  }

  _closingDoor() async {
    if (!isMoving && !isEmergency && (isDoorState == openedState || isDoorState == openingState)) {
      "pon.mp3".playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      setState(() => isDoorState = closingState);
      await AppLocalizations.of(context)!.closeDoor.speakText(context);
      await Future.delayed(Duration(seconds: waitTime)).then((_) {
        if (!isMoving && !isEmergency && isDoorState == closingState) {
          setState(() => isDoorState = closedState);
          (counter < nextFloor) ? _counterUp():
          (counter > nextFloor) ? _counterDown():
          AppLocalizations.of(context)!.pushNumber.speakText(context);
        }
      });
    }
  }

  _alertSelected() {
    "call.mp3".playAudio();
    Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
    if(isEmergency && isMoving) {
      Future.delayed(Duration(seconds: waitTime)).then((_) {
        AppLocalizations.of(context)!.emergency.speakText(context);
        setState(() {
          nextFloor = counter;
          isMoving = false;
          isEmergency = true;
          counter.clearLowerFloor(isAboveSelectedList, isUnderSelectedList, min);
          counter.clearUpperFloor(isAboveSelectedList, isUnderSelectedList, max);
        });
        if (counter != 1) {
          Future.delayed(Duration(seconds: openTime)).then((_) async {
            AppLocalizations.of(context)!.return1st.speakText(context);
            await Future.delayed(Duration(seconds: waitTime * 2)).then((_) {
              setState(() => nextFloor = 1);
              (counter < nextFloor) ? _counterUp() : _counterDown();
            });
          });
        }
      });
    }
  }

  _counterUp() async {
    AppLocalizations.of(context)!.upFloor.speakText(context);
    int count = 0;
    setState(() => isMoving = true);
    await Future.delayed(Duration(seconds: waitTime)).then((_) {
      Future.forEach(counter.upFromToNumber(nextFloor), (int i) async {
        await Future.delayed(Duration(milliseconds: i.elevatorSpeed(count, nextFloor))).then((_) async {
          count++;
          if (isMoving && counter < nextFloor && nextFloor <  max + 1) setState(() => counter++);
          if (counter == 0) setState(() => counter++);
          if (isMoving && (counter == nextFloor || counter == max)) {
            counter.soundFloor(context, max, isShimada).speakText(context);
            setState(() {
              counter.clearLowerFloor(isAboveSelectedList, isUnderSelectedList, min);
              nextFloor = counter.upNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
            });
            await Future.delayed(Duration(seconds: isShimada.announceTime())).then((_) {
              setState(() {
                isMoving = false;
                isEmergency = false;
              });
              _openingDoor();
              print("Next Floor: $nextFloor");
            });
          }
        });
      });
    });
  }

  _counterDown() async {
    AppLocalizations.of(context)!.downFloor.speakText(context);
    int count = 0;
    setState(() => isMoving = true);
    await Future.delayed(Duration(seconds: waitTime)).then((_) {
      Future.forEach(counter.downFromToNumber(nextFloor), (int i) async {
        await Future.delayed(Duration(milliseconds: i.elevatorSpeed(count, nextFloor))).then((_) async {
          count++;
          if (isMoving && min - 1 < nextFloor && nextFloor < counter) setState(() => counter--);
          if (counter == 0) setState(() => counter--);
          if (isMoving && (counter == nextFloor || counter == min)) {
            counter.soundFloor(context, max, isShimada).speakText(context);
            setState(() {
              counter.clearUpperFloor(isAboveSelectedList, isUnderSelectedList, max);
              nextFloor = counter.downNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
            });
            await Future.delayed(Duration(seconds: isShimada.announceTime())).then((_) {
              setState(() {
                isMoving = false;
                isEmergency = false;
              });
              _openingDoor();
              print("Next Floor: $nextFloor");
            });
          }
        });
      });
    });
  }

  //行き先階ボタンの選択を解除する
  _floorCanceled(int i) async {
    if (i.isSelected(isAboveSelectedList, isUnderSelectedList) && i != nextFloor) {
      "popi.mp3".playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      setState(() {
        i.falseSelected(isAboveSelectedList, isUnderSelectedList);
        if (i == nextFloor) {
          nextFloor = (counter < nextFloor) ?
          counter.upNextFloor(isAboveSelectedList, isUnderSelectedList, min, max):
          counter.downNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
        }
      });
      print("Next Floor: $nextFloor");
    }
  }

  //行き先階ボタンを選択する
  _floorSelected (int i, bool selectFlag) async {
    if(!isEmergency) {
      if (i == counter) {
        if (!isMoving && i == nextFloor) {
          AppLocalizations.of(context)!.pushNumber.speakText(context);
        }
      } else if (!selectFlag) {
        //止まらない階の場合のメッセージ
        AppLocalizations.of(context)!.notStop.speakText(context);
      } else if (!i.isSelected(isAboveSelectedList, isUnderSelectedList)){
        "pon.mp3".playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        setState(() {
          i.trueSelected(isAboveSelectedList, isUnderSelectedList);
          if (counter < i && i < nextFloor) nextFloor = i;
          if (counter > i && i > nextFloor) nextFloor = i;
          if (i.onlyTrue(isAboveSelectedList, isUnderSelectedList)) nextFloor = i;
        });
        print("Next Floor: $nextFloor");
        await Future.delayed(Duration(seconds: waitTime)).then((_) {
          if (!isMoving && !isEmergency && isDoorState == closedState) {
            (counter < nextFloor) ? _counterUp() : _counterDown();
          }
        });
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
      decoration: metalDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          displayArrowNumberView(context, counter, nextFloor, max, isMoving, isShimada),
          const Spacer(),
          operationButtons(),
          SizedBox(height: display.height.buttonMargin()),
          floorButtons([14, 100, 154, max], [true, true, true, true]),
          floorButtons([5, 6, 7, 8], [false, true, true, true]),
          floorButtons([1, 2, 3, 4], [true, true, true, true]),
          floorButtons([-1, -2, -3, -4], [true, true, true, true]),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              adMobWidget(context, myBanner),
              const Spacer(),
              shimadaSpeedDial(),
              const Spacer(),
            ],
          ),
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
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        numberButton(i, max, isShimada, isAboveSelectedList, isUnderSelectedList),
        Container(width: 80, height: 80,
          padding: EdgeInsets.all(isShimada ? 5: 0),
          child: ElevatedButton(
            style: transparentButtonStyle(),
            child: GestureDetector(
              onLongPress: () => _floorCanceled(i),
              onDoubleTap: () =>_floorCanceled(i),
            ),
            //ボタン選択をする
            onPressed: () => _floorSelected(i, selectFlag),
          ),
        ),
      ],
    );
  }

  Widget operationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        openButton(),
        const SizedBox(width: 20),
        closeButton(),
        const SizedBox(width: 100),
        alertButton(),
      ]
    );
  }

  Widget openButton() {
    return SizedBox(width: 60, height: 60,
      child: GestureDetector(
        child: ElevatedButton(
          style: rectangleButtonStyle(const Color.fromRGBO(105, 184, 0, 1)),
          child: Image(
            image: AssetImage(isPressedButton[0].openBackGround(isShimada)),
          ),
          onPressed: () {
            setState(() => isPressedButton[0] = true);
            _openingDoor();
          },
          onLongPress: () {
            setState(() => isPressedButton[0] = true);
            _openingDoor();
          },
        ),
        onTapDown: (_) async => setState(() => isPressedButton[0] = false),
        onLongPressDown: (_) async => setState(() => isPressedButton[0] = false),
      ),
    );
  }

  Widget closeButton() {
    return SizedBox(width: 60, height: 60,
      child: GestureDetector(
        child: ElevatedButton(
          style: rectangleButtonStyle(Colors.white),
          child: Image(
            image: AssetImage(isPressedButton[1].closeBackGround(isShimada)),
          ),
          onPressed: () {
            setState(() => isPressedButton[1] = true);
            _closingDoor();
          },
          onLongPress: () {
            setState(() => isPressedButton[1] = true);
            _closingDoor();
          },
        ),
        onTapDown: (_) async => setState(() => isPressedButton[1] = false),
        onLongPressDown: (_) async => setState(() => isPressedButton[1] = false),
      )
    );
  }

  Widget alertButton() {
    return SizedBox(width: 60, height: 60,
      child: GestureDetector(
        child: ElevatedButton(
          style: isShimada ? circleButtonStyle(const Color.fromRGBO(255, 234, 0, 1)):
                             rectangleButtonStyle(const Color.fromRGBO(255, 234, 0, 1)),
          child: Image(
            image: AssetImage(isPressedButton[2].phoneBackGround(isShimada))
          ),
          onPressed: () async => setState(() => isPressedButton[2] = true),
          onLongPress: () {
            setState(() => isPressedButton[2] = true);
            if (isMoving) setState(() => isEmergency = true);
            _alertSelected();
          },
        ),
        onTapDown: (_) async => setState(() => isPressedButton[2] = false),
        onLongPressDown: (_) async => setState(() => isPressedButton[2] = false),
      ),
    );
  }

  Widget shimadaSpeedDial() {
    return SizedBox(width: 50, height: 50,
      child: Stack(
        children: [
          Image(
            image: AssetImage(isShimada.buttonChanBackGround()),
          ),
          SpeedDial(
            backgroundColor: Colors.transparent,
            overlayColor: const Color.fromRGBO(56, 54, 53, 1),
            spaceBetweenChildren: 20,
            children: [
              speedDialChild(true, CupertinoIcons.arrow_2_circlepath,
                isShimada.changeModeLabel(context),
                "",
              ),
              speedDialChild(false, CupertinoIcons.info,
                AppLocalizations.of(context)!.buttons,
                Localizations.localeOf(context).languageCode.twitterLink(),
              ),
              speedDialChild(false, CupertinoIcons.info,
                AppLocalizations.of(context)!.shimada,
                Localizations.localeOf(context).languageCode.articleLink(),
              ),
              speedDialChild(false, CupertinoIcons.app,
                AppLocalizations.of(context)!.letsElevator,
                Localizations.localeOf(context).languageCode.elevatorLink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SpeedDialChild speedDialChild(bool flag, IconData iconData, String label, String link) {
    return SpeedDialChild(
      child: Icon(iconData, size: 50,),
      label: label,
      labelStyle: speedDialTextStyle(),
      labelBackgroundColor: Colors.white,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      onTap: () async {
        if (flag) {
          "tetete.mp3".playAudio();
          Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
          setState(() => isShimada = isShimada.reverse());
        } else {
          "piron.mp3".playAudio();
          launch(link);
        }
      },
    );
  }

  Future<void> initPlugin() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
}