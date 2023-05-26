import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'common_widget.dart';
import 'extension.dart';
import 'constant.dart';
import 'admob.dart';

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final height = context.height();
    final lang = context.lang();
    final BannerAd myBanner = AdmobService().getBannerAd();

    final counter = useState(1);
    final nextFloor = useState(1);
    final isMoving = useState(false);
    final isEmergency = useState(false);
    final isShimada = useState(false);
    final isMenu = useState(false);
    final isDoorState = useState(closedState); //[opened, closed, opening, closing]
    final isPressedOpenButton = useState(false);
    final isPressedCloseButton = useState(false);
    final isPressedPhoneButton = useState(false);
    final isAboveSelectedList = useState(List.generate(max + 1, (_) => false));
    final isUnderSelectedList = useState(List.generate(min * (-1) + 1, (_) => false));

    /// 上の階へ行く
    counterUp() async {
      context.upFloor().speakText(lang);
      int count = 0;
      isMoving.value = true;
      await Future.delayed(const Duration(seconds: waitTime)).then((_) {
        Future.forEach(counter.value.upFromToNumber(nextFloor.value), (int i) async {
          await Future.delayed(Duration(milliseconds: i.elevatorSpeed(count, nextFloor.value))).then((_) async {
            count++;
            if (isMoving.value && counter.value < nextFloor.value && nextFloor.value < max + 1) counter.value = counter.value + 1;
            if (counter.value == 0) counter.value = 1;
            if (isMoving.value && (counter.value == nextFloor.value || counter.value == max)) {
              context.openingSound(counter.value, isShimada.value).speakText(lang);
              counter.value.clearLowerFloor(isAboveSelectedList.value, isUnderSelectedList.value);
              nextFloor.value = counter.value.upNextFloor(isAboveSelectedList.value, isUnderSelectedList.value);
              isMoving.value = false;
              isEmergency.value = false;
              isDoorState.value = openingState;
              "isDoorState: ${isDoorState.value}".debugPrint();
              "$nextString${nextFloor.value}".debugPrint();
            }
          });
        });
      });
    }

    /// 下の階へ行く
    counterDown() async {
      context.downFloor().speakText(lang);
      int count = 0;
      isMoving.value = true;
      await Future.delayed(const Duration(seconds: waitTime)).then((_) {
        Future.forEach(counter.value.downFromToNumber(nextFloor.value), (int i) async {
          await Future.delayed(Duration(milliseconds: i.elevatorSpeed(count, nextFloor.value))).then((_) async {
            count++;
            if (isMoving.value && min - 1 < nextFloor.value && nextFloor.value < counter.value) counter.value = counter.value - 1;
            if (counter.value == 0) counter.value = -1;
            if (isMoving.value && (counter.value == nextFloor.value || counter.value == min)) {
              context.openingSound(counter.value, isShimada.value).speakText(lang);
              counter.value.clearUpperFloor(isAboveSelectedList.value, isUnderSelectedList.value);
              nextFloor.value = counter.value.downNextFloor(isAboveSelectedList.value, isUnderSelectedList.value);
              isMoving.value = false;
              isEmergency.value = false;
              isDoorState.value = openingState;
              "isDoorState: ${isDoorState.value}".debugPrint();
              "$nextString${nextFloor.value}".debugPrint();
            }
          });
        });
      });
    }

    /// ドアを閉じる
    doorsClosing() async {
      if (!isMoving.value && !isEmergency.value && (isDoorState.value == openedState || isDoorState.value == openingState)) {
        isDoorState.value = closingState;
        "isDoorState: ${isDoorState.value}".debugPrint();
        await context.closeDoor().speakText(lang);
        await Future.delayed(const Duration(seconds: waitTime)).then((_) {
          if (!isMoving.value && !isEmergency.value && isDoorState.value == closingState) {
            isDoorState.value = closedState;
            "isDoorState: ${isDoorState.value}".debugPrint();
            (counter.value < nextFloor.value) ? counterUp() :
            (counter.value > nextFloor.value) ? counterDown() :
            context.pushNumber().speakText(lang);
          }
        });
      }
    }

    /// 開くボタンを押した時の動作
    pressedOpen() {
      isPressedOpenButton.value = true;
      selectButton.playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      Future.delayed(const Duration(milliseconds: flashTime)).then((_) {
        if (!isMoving.value && !isEmergency.value && (isDoorState.value == closedState || isDoorState.value == closingState)) {
          context.openDoor().speakText(lang);
          isDoorState.value = openingState;
          "isDoorState: ${isDoorState.value}".debugPrint();
        }
      });
    }

    /// 閉じるボタンを押した時の動作
    pressedClose() {
      isPressedCloseButton.value = true;
      selectButton.playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      Future.delayed(const Duration(milliseconds: flashTime)).then((_) {
        if (!isMoving.value && !isEmergency.value && (isDoorState.value == openedState || isDoorState.value == openingState)) {
          doorsClosing();
        }
      });
    }

    ///緊急電話ボタンを押した時の動作
    pressedAlert() async {
      isPressedPhoneButton.value = true;
      selectButton.playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
    }

    ///緊急電話ボタンを長押しした時の動作
    longPressedAlert() async {
      if (isMoving.value) isEmergency.value = true;
      if (isEmergency.value && isMoving.value) {
        callSound.playAudio();
        await Future.delayed(const Duration(seconds: waitTime)).then((_) {
          context.emergency().speakText(lang);
          nextFloor.value = counter.value;
          isMoving.value = false;
          isEmergency.value = true;
          counter.value.clearLowerFloor(isAboveSelectedList.value, isUnderSelectedList.value);
          counter.value.clearUpperFloor(isAboveSelectedList.value, isUnderSelectedList.value);
        });
        await Future.delayed(const Duration(seconds: openTime)).then((_) async {
          context.return1st().speakText(lang);
        });
        await Future.delayed(const Duration(seconds: waitTime * 2)).then((_) async {
          if (counter.value != 1) {
            nextFloor.value = 1;
            "$nextString${nextFloor.value}".debugPrint();
            (counter.value < nextFloor.value) ? counterUp() : counterDown();
          } else {
            context.openDoor().speakText(lang);
            isDoorState.value = openingState;
            "isDoorState: ${isDoorState.value}".debugPrint();
          }
        });
      }
    }

    ///行き先階ボタンを選択する
    floorSelected(int i, bool selectFlag) async {
      if (!isEmergency.value) {
        if (i == counter.value) {
          if (!isMoving.value && i == nextFloor.value) context.pushNumber().speakText(lang);
        } else if (!selectFlag) {
          //止まらない階の場合のメッセージ
          context.notStop().speakText(lang);
        } else if (!i.isSelected(isAboveSelectedList.value, isUnderSelectedList.value)) {
          selectButton.playAudio();
          Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
          i.trueSelected(isAboveSelectedList.value, isUnderSelectedList.value);
          if (counter.value < i && i < nextFloor.value) nextFloor.value = i;
          if (counter.value > i && i > nextFloor.value) nextFloor.value = i;
          if (i.onlyTrue(isAboveSelectedList.value, isUnderSelectedList.value)) nextFloor.value = i;
          "$nextString${nextFloor.value}".debugPrint();
          await Future.delayed(const Duration(seconds: waitTime)).then((_) async {
            if (!isMoving.value && !isEmergency.value && isDoorState.value == closedState) {
              (counter.value < nextFloor.value) ? counterUp() :
              (counter.value > nextFloor.value) ? counterDown() :
              context.pushNumber().speakText(lang);
            }
          });
        }
      }
    }

    ///行き先階ボタンの選択を解除する
    floorCanceled(int i) async {
      if (i.isSelected(isAboveSelectedList.value, isUnderSelectedList.value) && i != nextFloor.value) {
        cancelButton.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        i.falseSelected(isAboveSelectedList.value, isUnderSelectedList.value);
        if (i == nextFloor.value) {
          nextFloor.value = (counter.value < nextFloor.value) ?
          counter.value.upNextFloor(isAboveSelectedList.value, isUnderSelectedList.value) :
          counter.value.downNextFloor(isAboveSelectedList.value, isUnderSelectedList.value);
        }
        "$nextString${nextFloor.value}".debugPrint();
      }
    }

    ///　メニューボタンを押した時の操作
    pressedMenu() async {
      selectButton.playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      isMenu.value = isMenu.value.reverse();
    }

    /// アプリ開始後の動作を指定
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        context.pushNumber().speakText(lang);
      });
      return null;
    }, const []);

    /// ドアの開閉後の動作を指定
    useEffect(() {
      if (isDoorState.value == openingState) {
        Future.delayed(const Duration(seconds: waitTime)).then((_) {
          isDoorState.value = openedState;
          "isDoorState: ${isDoorState.value}".debugPrint();
          if (!isMoving.value && !isEmergency.value && isDoorState.value == openedState) {
            Future.delayed(const Duration(seconds: openTime)).then((_) async {
              doorsClosing();
            });
          }
        });
      } else if (isDoorState.value == closingState) {
        doorsClosing();
      }
      return null;
    }, [isDoorState.value]);

    /// 行き先階ボタン
    Widget floorButton(int i, bool selectFlag) => GestureDetector(
      child: floorButtonImage(context, i, isShimada.value, i.isSelected(isAboveSelectedList.value, isUnderSelectedList.value)),
      onTap: () => floorSelected(i, selectFlag),
      onLongPress: () => floorCanceled(i),
      onDoubleTap: () => floorCanceled(i),
    );

    Widget floorButtons(List<int> n, List<bool> nFlag) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        floorButton(n[0], nFlag[0]),
        SizedBox(width: context.buttonMargin()),
        floorButton(n[1], nFlag[1]),
        SizedBox(width: context.buttonMargin()),
        floorButton(n[2], nFlag[2]),
        SizedBox(width: context.buttonMargin()),
        floorButton(n[3], nFlag[3]),
      ]
    );

    ///　メニュー画面
    Widget menuList() => Column(children: [
      const Spacer(flex: 3),
      menuLogo(context),
      const Spacer(flex: 2),
      menuTitle(context),
      const Spacer(flex: 1),
      Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //レッツ・エレベーターのリンク
            linkIconTextButton(context, context.letsElevator(), CupertinoIcons.app, context.elevatorLink()),
            //オンラインショップのリンク
            if (lang == "ja") linkIconTextButton(context, context.onlineShop(), CupertinoIcons.cart, context.shopLink()),
            //島田電機製作所のリンク
            linkIconTextButton(context, context.shimax(), CupertinoIcons.info, context.shimaxLink()),
            //1000のボタン紹介のリンク
            linkIconTextButton(context, context.buttons(), CupertinoIcons.info, context.articleLink()),
            //再現！1000のボタン⇄エレベーターモードのモードチェンジ
            changePageButton(context, true),
            //1000のボタンモードへ変更
            GestureDetector(
              child: linkIconText(context, isShimada.value.changeModeLabel(context), CupertinoIcons.arrow_2_circlepath),
              onTap: () {
                changeModeSound.playAudio();
                Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
                isShimada.value = isShimada.value.reverse();
                isMenu.value = isMenu.value.reverse();
              },
            ),
          ]
        ),
      ),
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
      SizedBox(height: context.admobHeight())
    ]);

    return Scaffold(
      backgroundColor: grayColor,
      body: Center(child:
        Stack(children: [
          Center(child:
            Container(
              alignment: Alignment.center,
              width: context.displayWidth(),
              height: height,
              decoration: metalDecoration(),
              child: Column(children: [
                const Spacer(flex: 1),
                SizedBox(height: context.displayMargin()),
                displayArrowNumber(context, isShimada.value, counter.value.arrowImage(isMoving.value, nextFloor.value), counter.value.displayNumber()),
                SizedBox(height: context.displayMargin()),
                const Spacer(flex: 1),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ///<開くボタン>
                    GestureDetector(
                      onTapDown: (_) => pressedOpen(),
                      onTapUp: (_) => isPressedOpenButton.value = false,
                      onTapCancel: () => isPressedOpenButton.value = false,
                      child: operationImage(context, "open", isShimada.value, isPressedOpenButton.value),
                    ),
                    SizedBox(width: context.buttonMargin()),
                    ///<閉じるボタン>
                    GestureDetector(
                      onTapDown: (_) => pressedClose(),
                      onTapUp: (_) => isPressedCloseButton.value = false,
                      onTapCancel: () => isPressedCloseButton.value = false,
                      child: operationImage(context, "close", isShimada.value, isPressedCloseButton.value),
                    ),
                    SizedBox(width: context.floorButtonSize() + 2 * context.buttonMargin()),
                    ///<緊急ボタン>
                    GestureDetector(
                      onTapDown: (_) => pressedAlert(),
                      onTapUp: (_) => isPressedPhoneButton.value = false,
                      onTapCancel: () => isPressedPhoneButton.value = false,
                      onLongPress: () => longPressedAlert(),
                      onLongPressEnd: (_) => isPressedPhoneButton.value = false,
                      child: operationImage(context, "alert", isShimada.value, isPressedPhoneButton.value),
                    )
                  ]
                ),
                const Spacer(flex: 1),
                SizedBox(height: context.buttonMargin()),
                floorButtons(floors1, isFloors1),
                SizedBox(height: context.buttonMargin()),
                floorButtons(floors2, isFloors2),
                SizedBox(height: context.buttonMargin()),
                floorButtons(floors3, isFloors3),
                SizedBox(height: context.buttonMargin()),
                floorButtons(floors4, isFloors4),
                SizedBox(height: context.buttonMargin()),
                const Spacer(flex: 3),
                SizedBox(height: context.admobHeight())
              ]),
            ),
          ),
          if (isMenu.value) overLay(context),
          if (isMenu.value) menuList(),
          Column(children: [
            const Spacer(),
            Row(children: [
              const Spacer(),
              adMobBannerWidget(context, myBanner),
              const Spacer(flex: 1),
              ///　メニューボタン
              GestureDetector(
                onTap: () => pressedMenu(),
                child: imageButton(context, isMenu.value.buttonChanBackGround())
              ),
              const Spacer(flex: 1),
            ]),
          ]),
        ]),
      ),
    );
  }
}