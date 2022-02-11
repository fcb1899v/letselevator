import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vibration/vibration.dart';
import 'my_home_extension.dart';
import 'common_widget.dart';
import 'common_extension.dart';
import 'constant.dart';
import 'admob.dart';
import 'my_home_widget.dart';

class MyHomeBody extends StatefulWidget {
  const MyHomeBody({Key? key}) : super(key: key);
  @override
  State<MyHomeBody> createState() => _MyHomeBodyState();
}

class _MyHomeBodyState extends State<MyHomeBody> {

  late String lang;
  late int counter;
  late int nextFloor;
  late bool isMoving;
  late bool isEmergency;
  late bool isShimada;
  late List<bool> isDoorState;          //[opened, closed, opening, closing]
  late List<bool> isPressedButton;      //[open, close, call]
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

  @override
  void didChangeDependencies() {
    "call didChangeDependencies".debugPrint();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(oldWidget) {
    "call didUpdateWidget".debugPrint();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    "call deactivate".debugPrint();
    super.deactivate();
  }

  @override
  void dispose() {
    "call dispose".debugPrint();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Container(
          height: height,
          width: width.displayWidth(),
          padding: const EdgeInsets.only(top: 30),
          decoration: metalDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(flex: 1),
              displayArrowNumber(width, height),
              const Spacer(flex: 1),
              SizedBox(height: height.displayMargin()),
              operationButtons(height),
              SizedBox(height: height.displayMargin()),
              SizedBox(height: height.buttonMargin()),
              floorButtons(floors1, isFloors1, height),
              SizedBox(height: height.buttonMargin()),
              floorButtons(floors2, isFloors2, height),
              SizedBox(height: height.buttonMargin()),
              floorButtons(floors3, isFloors3, height),
              SizedBox(height: height.buttonMargin()),
              floorButtons(floors4, isFloors4, height),
              const Spacer(flex: 1),
              Row(
                children: [
                  const Spacer(),
                  adMobBannerWidget(width, height, myBanner),
                  const Spacer(),
                  shimadaSpeedDial(width),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _openingDoor() async {
    if (!isMoving && !isEmergency && (isDoorState == closedState || isDoorState == closingState)) {
      setState(() => isDoorState = openingState);
      await AppLocalizations.of(context)!.openDoor.speakText(context);
      await Future.delayed(const Duration(seconds: waitTime)).then((_) async {
        if (!isMoving && !isEmergency && isDoorState == openingState) {
          setState(() => isDoorState = openedState);
          await Future.delayed(const Duration(seconds: openTime)).then((_) async{
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
      setState(() => isDoorState = closingState);
      await AppLocalizations.of(context)!.closeDoor.speakText(context);
      await Future.delayed(const Duration(seconds: waitTime)).then((_) {
        if (!isMoving && !isEmergency && isDoorState == closingState) {
          setState(() => isDoorState = closedState);
          (counter < nextFloor) ? _counterUp():
          (counter > nextFloor) ? _counterDown():
          AppLocalizations.of(context)!.pushNumber.speakText(context);
        }
      });
    }
  }

  _alertSelected() async {
    callSound.playAudio();
    Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
    if (isMoving) setState(() => isEmergency = true);
    if(isEmergency && isMoving) {
      await Future.delayed(const Duration(seconds: waitTime)).then((_) {
        AppLocalizations.of(context)!.emergency.speakText(context);
        setState(() {
          nextFloor = counter;
          isMoving = false;
          isEmergency = true;
          counter.clearLowerFloor(isAboveSelectedList, isUnderSelectedList, min);
          counter.clearUpperFloor(isAboveSelectedList, isUnderSelectedList, max);
        });
      });
      if (counter != 1) {
        await Future.delayed(const Duration(seconds: openTime)).then((_) async {
          AppLocalizations.of(context)!.return1st.speakText(context);
        });
        await Future.delayed(const Duration(seconds: waitTime * 2)).then((_) async {
          setState(() => nextFloor = 1);
          (counter < nextFloor) ? _counterUp() : _counterDown();
        });
      }
    }
  }

  _counterUp() async {
    AppLocalizations.of(context)!.upFloor.speakText(context);
    int count = 0;
    setState(() => isMoving = true);
    await Future.delayed(const Duration(seconds: waitTime)).then((_) {
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
              "$nextString$nextFloor".debugPrint();
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
    await Future.delayed(const Duration(seconds: waitTime)).then((_) {
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
              "$nextString$nextFloor".debugPrint();
            });
          }
        });
      });
    });
  }

  //行き先階ボタンの選択を解除する
  _floorCanceled(int i) async {
    if (i.isSelected(isAboveSelectedList, isUnderSelectedList) && i != nextFloor) {
      cancelButton.playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      setState(() {
        i.falseSelected(isAboveSelectedList, isUnderSelectedList);
        if (i == nextFloor) {
          nextFloor = (counter < nextFloor) ?
          counter.upNextFloor(isAboveSelectedList, isUnderSelectedList, min, max):
          counter.downNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
        }
      });
      "$nextString$nextFloor".debugPrint();
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
        selectButton.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        setState(() {
          i.trueSelected(isAboveSelectedList, isUnderSelectedList);
          if (counter < i && i < nextFloor) nextFloor = i;
          if (counter > i && i > nextFloor) nextFloor = i;
          if (i.onlyTrue(isAboveSelectedList, isUnderSelectedList)) nextFloor = i;
        });
        "$nextString$nextFloor".debugPrint();
        await Future.delayed(const Duration(seconds: waitTime)).then((_) {
          if (!isMoving && !isEmergency && isDoorState == closedState) {
            (counter < nextFloor) ? _counterUp() : _counterDown();
          }
        });
      }
    }
  }

  Widget floorButtons(List<int> n, List<bool> nFlag, double height) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      floorButton(n[0], nFlag[0], height),
      SizedBox(width: height.buttonMargin()),
      floorButton(n[1], nFlag[1], height),
      SizedBox(width: height.buttonMargin()),
      floorButton(n[2], nFlag[2], height),
      SizedBox(width: height.buttonMargin()),
      floorButton(n[3], nFlag[3], height),
    ],
  );

  Widget floorButton(int i, bool selectFlag, double height) {
    bool isSelected = i.isSelected(isAboveSelectedList, isUnderSelectedList);
    return GestureDetector(
      child: ElevatedButton(
        style: transparentButtonStyle(),
        child: SizedBox(
          width: height.buttonSize(),
          height: height.buttonSize(),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              buttonBackGround(height.buttonSize(), i.numberBackground(isShimada, isSelected, max)),
              buttonNumberText(height, i.buttonNumber(max, isShimada), isSelected)
            ],
          ),
        ),
        //ボタン選択をする
        onPressed: () => _floorSelected(i, selectFlag),
      ),
      onLongPress: () => _floorCanceled(i),
      onDoubleTap: () => _floorCanceled(i),
    );
  }

  Widget operationButtons(double height) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      openButton(height),
      SizedBox(width: height.buttonMargin()),
      closeButton(height),
      SizedBox(width: height.buttonMargin()),
      SizedBox(width: height.buttonSize()),
      SizedBox(width: height.buttonMargin()),
      alertButton(height),
    ]
  );

  Widget openButton(double height) => GestureDetector(
    child: ElevatedButton(
      style: rectangleButtonStyle(greenColor),
      child: openButtonImage(height, isShimada, isPressedButton[0]),
      onPressed: () {
        setState(() => isPressedButton[0] = true);
        selectButton.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        _openingDoor();
      },
      onLongPress: () {
        setState(() => isPressedButton[0] = true);
        selectButton.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        _openingDoor();
      },
    ),
    onTapDown: (_) async => setState(() => isPressedButton[0] = false),
    onLongPressDown: (_) async => setState(() => isPressedButton[0] = false),
  );

  Widget closeButton(double height) => GestureDetector(
    child: ElevatedButton(
      style: rectangleButtonStyle(whiteColor),
      child: closeButtonImage(height, isShimada, isPressedButton[1]),
      onPressed: () {
        setState(() => isPressedButton[1] = true);
        selectButton.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        _closingDoor();
      },
      onLongPress: () {
        setState(() => isPressedButton[1] = true);
        selectButton.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        _closingDoor();
      },
    ),
    onTapDown: (_) async => setState(() => isPressedButton[1] = false),
    onLongPressDown: (_) async => setState(() => isPressedButton[1] = false),
  );

  Widget alertButton(double height) => GestureDetector(
    child: ElevatedButton(
      style: isShimada ? circleButtonStyle(yellowColor): rectangleButtonStyle(yellowColor),
      child: alertButtonImage(height, isShimada, isPressedButton[2]),
      onPressed: () async => setState(() => isPressedButton[2] = true),
      onLongPress: () {
        setState(() => isPressedButton[2] = true);
        if (isMoving) setState(() => isEmergency = true);
        _alertSelected();
      },
    ),
    onTapDown: (_) async => setState(() => isPressedButton[2] = false),
    onLongPressDown: (_) async => setState(() => isPressedButton[2] = false),
  );

  Widget displayArrowNumber(double width, double height) => Container(
    width: width.displayWidth(),
    height: height.displayHeight(),
    color: darkBlackColor,
    child: Stack(
      alignment: Alignment.center,
      children: [
        shimadaLogoImage(isShimada),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            displayArrow(counter.arrowImage(isMoving, nextFloor)),
            displayNumber(counter.displayNumber(max)),
            const Spacer(),
          ],
        ),
      ],
    ),
  );

  Widget shimadaSpeedDial(double width) => SizedBox(
    width: 50,
    height: 50,
    child: Stack(
      children: [
        Image(image: AssetImage(isShimada.buttonChanBackGround())),
        SpeedDial(
          backgroundColor: transpColor,
          overlayColor: blackColor,
          spaceBetweenChildren: 20,
          children: [
            changeMode(width),
            changePage(width),
            info1000Buttons(context, width),
            infoShimada(context, width),
            infoLetsElevator(context, width),
          ],
        ),
      ],
    ),
  );

  SpeedDialChild changeMode(double width) => SpeedDialChild(
    child: const Icon(CupertinoIcons.arrow_2_circlepath, size: 50,),
    label: isShimada.changeModeLabel(context),
    labelStyle: speedDialTextStyle(width),
    labelBackgroundColor: whiteColor,
    foregroundColor: whiteColor,
    backgroundColor: transpColor,
    onTap: () async {
      changeModeSound.playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      setState(() => isShimada = isShimada.reverse());
    },
  );

  SpeedDialChild changePage(double width) => SpeedDialChild(
    child: const Icon(CupertinoIcons.arrow_2_circlepath, size: 50,),
    label: AppLocalizations.of(context)!.reproButtons,
    labelStyle: speedDialTextStyle(width),
    labelBackgroundColor: whiteColor,
    foregroundColor: whiteColor,
    backgroundColor: transpColor,
    onTap: () async {
      changePageSound.playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      "/r".pushPage(context);
    },
  );
}