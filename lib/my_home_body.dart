import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vibration/vibration.dart';
import 'common_widget.dart';
import 'extension.dart';
import 'constant.dart';
import 'admob.dart';

class MyHomeBody extends StatefulWidget {
  const MyHomeBody({Key? key}) : super(key: key);
  @override
  State<MyHomeBody> createState() => _MyHomeBodyState();
}

class _MyHomeBodyState extends State<MyHomeBody> {

  late double width;
  late double height;
  late String lang;

  late int counter;
  late int nextFloor;
  late bool isMoving;
  late bool isEmergency;
  late bool isShimada;
  late bool isMenu;
  late List<bool> isDoorState;          //[opened, closed, opening, closing]
  late List<bool> isPressedButton;      //[open, close, call]
  late List<bool> isAboveSelectedList;
  late List<bool> isUnderSelectedList;
  late BannerAd myBanner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
    setState(() {
      counter = 1;
      nextFloor = counter;
      isMoving = false;
      isEmergency = false;
      isShimada = false;
      isMenu = false;
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
    setState((){
      width = context.width();
      height = context.height();
      lang = context.lang();
    });
    "width: $width, height: $height, lang: $lang".debugPrint();
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
    myBanner.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        backgroundColor: Colors.grey,
        body: Center(
          child: Stack(children: [
            Center(child:
              Container(
                alignment: Alignment.center,
                width: width.displayWidth(),
                height: height,
                decoration: metalDecoration(),
                child: Column(children: [
                  const Spacer(flex: 1),
                  SizedBox(height: height.displayMargin()),
                  displayArrowNumber(width, height, isShimada,
                    counter.arrowImage(isMoving, nextFloor),
                    counter.displayNumber(max)
                  ),
                  SizedBox(height: height.displayMargin()),
                  const Spacer(flex: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      openButton(),
                      SizedBox(width: height.buttonMargin()),
                      closeButton(),
                      SizedBox(width: height.floorButtonSize() + 2 * height.buttonMargin()),
                      alertButton(),
                    ]
                  ),
                  const Spacer(flex: 1),
                  SizedBox(height: height.buttonMargin()),
                  floorButtons(floors1, isFloors1),
                  SizedBox(height: height.buttonMargin()),
                  floorButtons(floors2, isFloors2),
                  SizedBox(height: height.buttonMargin()),
                  floorButtons(floors3, isFloors3),
                  SizedBox(height: height.buttonMargin()),
                  floorButtons(floors4, isFloors4),
                  SizedBox(height: height.buttonMargin()),
                  const Spacer(flex: 3),
                  SizedBox(height: height.admobHeight())
                ]),
              ),
            ),
            if (isMenu) overLay(context),
            if (isMenu) menuList(),
            Column(children: [
              const Spacer(),
              Row(children: [
                const Spacer(),
                adMobBannerWidget(context, myBanner),
                const Spacer(flex: 1),
                menuButton(),
                const Spacer(flex: 1),
              ]),
            ]),
          ]),
        ),
      );

  ///<子Widget>
  // 開くボタン
  Widget openButton() =>
      GestureDetector(
        child: ElevatedButton(
          style: operationButtonStyle(height, greenColor, false),
          child: operationButtonImage("open", height, isShimada, isPressedButton[0]),
          onPressed: () => _pressedOpen(),
          onLongPress: () => _pressedOpen(),
        ),
        onTapDown: (_) async => setState(() => isPressedButton[0] = false),
        onLongPressDown: (_) async => setState(() => isPressedButton[0] = false),
      );

  // 閉じるボタン
  Widget closeButton() =>
      GestureDetector(
        child: ElevatedButton(
          style: operationButtonStyle(height, whiteColor, false),
          child: operationButtonImage("close", height, isShimada, isPressedButton[1]),
          onPressed: () => _pressedClose(),
          onLongPress: () => _pressedClose(),
        ),
        onTapDown: (_) async => setState(() => isPressedButton[1] = false),
        onLongPressDown: (_) async => setState(() => isPressedButton[1] = false),
      );

  // 緊急電話ボタン
  Widget alertButton() =>
      GestureDetector(
        child: ElevatedButton(
          style: operationButtonStyle(height, yellowColor, isShimada),
          child: operationButtonImage("alert", height, isShimada, isPressedButton[2]),
          onPressed: () async => setState(() => isPressedButton[2] = true),
          onLongPress: () => _pressedAlert(),
        ),
        onTapDown: (_) async => setState(() => isPressedButton[2] = false),
        onLongPressDown: (_) async => setState(() => isPressedButton[2] = false),
      );

  // 行き先階ボタン
  Widget floorButtons(List<int> n, List<bool> nFlag) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        floorButton(n[0], nFlag[0]),
        SizedBox(width: height.buttonMargin()),
        floorButton(n[1], nFlag[1]),
        SizedBox(width: height.buttonMargin()),
        floorButton(n[2], nFlag[2]),
        SizedBox(width: height.buttonMargin()),
        floorButton(n[3], nFlag[3]),
      ]);

  Widget floorButton(int i, bool selectFlag) =>
      GestureDetector(
        child: ElevatedButton(
          style: transparentButtonStyle(),
          child: floorButtonImage(height, i, isShimada, i.isSelected(isAboveSelectedList, isUnderSelectedList)),
          onPressed: () => _floorSelected(i, selectFlag),
        ),
        onLongPress: () => _floorCanceled(i),
        onDoubleTap: () => _floorCanceled(i),
      );

  //　メニューボタン
  Widget menuButton() =>
      SizedBox(
        width: height.operationButtonSize(),
        height: height.operationButtonSize(),
        child: ElevatedButton(
          style: transparentButtonStyle(),
          child: Image.asset(isShimada.buttonChanBackGround()),
          onPressed: () => setState(() => isMenu = !isMenu),
        )
      );

  //　メニュー画面
  Widget menuList() =>
      Column(children: [
        const Spacer(flex: 3),
        menuLogo(context),
        const Spacer(flex: 2),
        menuTitle(context),
        const Spacer(flex: 1),
        Center(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            linkLetsElevator(context),
            SizedBox(height: context.height().menuListMargin()),
            if (context.lang() == "ja") linkOnlineShop(context),
            if (context.lang() == "ja") SizedBox(height: context.height().menuListMargin()),
            linkShimax(context),
            SizedBox(height: context.height().menuListMargin()),
            link1000Buttons(context),
            SizedBox(height: context.height().menuListMargin()),
            changePageButton(context, true),
            SizedBox(height: context.height().menuListMargin()),
            changeModeButton(),
          ]
        )),
        const Spacer(flex: 1),
        Row(children: [
          const Spacer(flex: 3),
          if (lang == "ja") snsButton(context, twitterLogo, elevatorTwitter),
          const Spacer(flex: 1),
          snsButton(context, youtubeLogo, elevatorYoutube),
          const Spacer(flex: 1),
          if (lang == "ja") snsButton(context, instagramLogo, elevatorInstagram),
          const Spacer(flex: 3),
        ]),
        const Spacer(flex: 2),
        SizedBox(height: height.admobHeight())
      ]);

  //1000のボタンモードへ変更するSpeedDialChild
  TextButton changeModeButton() =>
      TextButton.icon(
        label: menuText(context, isShimada.changeModeLabel(context)),
        icon: menuIcon(context, CupertinoIcons.arrow_2_circlepath),
        onPressed: () async {
          changeModeSound.playAudio();
          Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
          setState(() {
            isShimada = isShimada.reverse();
            isMenu = isMenu.reverse();
          });
        },
      );

  /// <setStateに関する関数>
  // 開くボタンを押した時の動作
  _pressedOpen() async {
    setState(() => isPressedButton[0] = true);
    selectButton.playAudio();
    Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
    if (!isMoving && !isEmergency && (isDoorState == closedState || isDoorState == closingState)) {
      setState(() => isDoorState = openingState);
      await AppLocalizations.of(context)!.openDoor.speakText(context);
      await Future.delayed(const Duration(seconds: waitTime)).then((_) async {
        _doorsOpening();
      });
    }
  }

  // ドアを開く
  _doorsOpening() async {
    if (!isMoving && !isEmergency && isDoorState == openingState) {
      setState(() => isDoorState = openedState);
      await Future.delayed(const Duration(seconds: openTime)).then((_) async{
        if (!isMoving && !isEmergency && isDoorState == openedState) {
          _doorsClosing();
        }
      });
    }
  }

  // 閉じるボタンを押した時の動作
  _pressedClose() {
    setState(() => isPressedButton[1] = true);
    selectButton.playAudio();
    Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
    _doorsClosing();
  }

  //ドアを閉じる
  _doorsClosing() async {
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

  //緊急電話ボタンを押した時の動作
  _pressedAlert() async {
    setState(() => isPressedButton[2] = true);
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

  // 上の階へ行く
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
            counter.openingSound(context, max, isShimada).speakText(context);
            setState(() {
              counter.clearLowerFloor(isAboveSelectedList, isUnderSelectedList, min);
              nextFloor = counter.upNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
              isMoving = false;
              isEmergency = false;
              isDoorState = openingState;
            });
            "$nextString$nextFloor".debugPrint();
            await _doorsOpening();
          }
        });
      });
    });
  }

  // 下の階へ行く
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
            counter.openingSound(context, max, isShimada).speakText(context);
            setState(() {
              counter.clearUpperFloor(isAboveSelectedList, isUnderSelectedList, max);
              nextFloor = counter.downNextFloor(isAboveSelectedList, isUnderSelectedList, min, max);
              isMoving = false;
              isEmergency = false;
              isDoorState = openingState;
            });
            "$nextString$nextFloor".debugPrint();
            await _doorsOpening();
          }
        });
      });
    });
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

}