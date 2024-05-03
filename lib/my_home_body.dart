import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'admob_banner.dart';
import 'common_function.dart';
import 'extension.dart';
import 'constant.dart';
import 'main.dart';
import 'my_menu.dart';

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final counter = useState(1);
    final nextFloor = useState(1);
    final isMoving = useState(false);
    final isEmergency = useState(false);
    final isShimada = ref.watch(isShimadaProvider);
    final isMenu = ref.watch(isMenuProvider);
    final isDoorState = useState(closedState); //[opened, closed, opening, closing]
    final isPressedOperationButtons = useState([false, false, false]);  //open, close, alert
    final isAboveSelectedList = useState(List.generate(max + 1, (_) => false));
    final isUnderSelectedList = useState(List.generate(min * (-1) + 1, (_) => false));
    final isSoundOn = useState(true);
    final FlutterTts flutterTts = FlutterTts();
    final AudioPlayer audioPlayer = AudioPlayer();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (Platform.isIOS || Platform.isMacOS) await initPlugin(context);
        await flutterTts.setSharedInstance(true);
        await flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
          ]
        );
        await flutterTts.setVolume(1);
        await flutterTts.setLanguage(context.ttsLang());
        await flutterTts.setVoice({
          "name": context.voiceName(Platform.isAndroid),
          "locale": context.ttsVoice()}
        );
        context.voiceName(Platform.isAndroid).debugPrint();
        await flutterTts.setSpeechRate(0.5);
        await audioPlayer.setReleaseMode(ReleaseMode.loop);
        await audioPlayer.setVolume(0.5);
        context.pushNumber().speakText(flutterTts, isSoundOn.value);
      });
      return null;
    }, []);

    useEffect(() {
      var observer = LifecycleEventHandler(
        resumeCallBack: () async {
          if (isSoundOn.value) {
            await audioPlayer.resume();
          }
        },
        suspendingCallBack: () async {
          if (isSoundOn.value) {
            await audioPlayer.pause();
          }
        },
      );
      WidgetsBinding.instance.addObserver(observer);
      // コンポーネントのクリーンアップ時の処理
      return () {
        audioPlayer.dispose();
        WidgetsBinding.instance.removeObserver(observer);
      };
    }, []);

    /// 上の階へ行く
    counterUp() async {
      context.upFloor().speakText(flutterTts, isSoundOn.value);
      int count = 0;
      isMoving.value = true;
      if (isDoorState.value != closedState) isDoorState.value = closedState;
      await Future.delayed(const Duration(seconds: waitTime)).then((_) {
        Future.forEach(counter.value.upFromToNumber(nextFloor.value), (int i) async {
          await Future.delayed(Duration(milliseconds: i.elevatorSpeed(count, nextFloor.value))).then((_) async {
            if (isMoving.value) count++;
            if (isMoving.value && counter.value < nextFloor.value && nextFloor.value < max + 1) counter.value = counter.value + 1;
            if (counter.value == 0) counter.value = 1;
            if (isMoving.value && (counter.value == nextFloor.value || counter.value == max)) {
              context.openingSound(counter.value, isShimada).speakText(flutterTts, isSoundOn.value);
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
      context.downFloor().speakText(flutterTts, isSoundOn.value);
      int count = 0;
      isMoving.value = true;
      if (isDoorState.value != closedState) isDoorState.value = closedState;
      await Future.delayed(const Duration(seconds: waitTime)).then((_) {
        Future.forEach(counter.value.downFromToNumber(nextFloor.value), (int i) async {
          await Future.delayed(Duration(milliseconds: i.elevatorSpeed(count, nextFloor.value))).then((_) async {
            if (isMoving.value) count++;
            if (isMoving.value && min - 1 < nextFloor.value && nextFloor.value < counter.value) counter.value = counter.value - 1;
            if (counter.value == 0) counter.value = -1;
            if (isMoving.value && (counter.value == nextFloor.value || counter.value == min)) {
              context.openingSound(counter.value, isShimada).speakText(flutterTts, isSoundOn.value);
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
      if (!isMoving.value && !isEmergency.value && isDoorState.value != closedState && isDoorState.value != closingState) {
        isDoorState.value = closingState;
        "isDoorState: ${isDoorState.value}".debugPrint();
        await context.closeDoor().speakText(flutterTts, isSoundOn.value);
        await Future.delayed(const Duration(seconds: waitTime)).then((_) {
          if (!isMoving.value && !isEmergency.value && isDoorState.value == closingState) {
            isDoorState.value = closedState;
            "isDoorState: ${isDoorState.value}".debugPrint();
            (counter.value < nextFloor.value) ? counterUp() :
            (counter.value > nextFloor.value) ? counterDown() :
            context.pushNumber().speakText(flutterTts, isSoundOn.value);
          }
        });
      }
    }

    ///Pressed open button action
    pressedOpenAction(bool isOn) async {
      isPressedOperationButtons.value = [isOn, false, false];
      if (isOn) {
        selectButton.playAudio(audioPlayer, isSoundOn.value);
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        if (!isMoving.value && !isEmergency.value && isDoorState.value != openedState && isDoorState.value != openingState) {
          Future.delayed(const Duration(milliseconds: flashTime)).then((_) async {
            if (!isMoving.value && !isEmergency.value  && isDoorState.value != openedState && isDoorState.value != openingState) {
              context.openDoor().speakText(flutterTts, isSoundOn.value);
              isDoorState.value = openingState;
              "isDoorState: ${isDoorState.value}".debugPrint();
              await Future.delayed(const Duration(seconds: waitTime)).then((_) {
                if (!isMoving.value && !isEmergency.value && isDoorState.value == openingState) {
                  isDoorState.value = openedState;
                  "isDoorState: ${isDoorState.value}".debugPrint();
                }
              });
            }
          });
        }
      }
    }

    ///Pressed close button action
    pressedCloseAction(bool isOn) async {
      isPressedOperationButtons.value = [false, isOn, false];
      if (isOn) {
        selectButton.playAudio(audioPlayer, isSoundOn.value);
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        if (!isMoving.value && !isEmergency.value && isDoorState.value != closedState && isDoorState.value != closingState) {
          Future.delayed(const Duration(milliseconds: flashTime)).then((_) => doorsClosing());
        }
      }
    }

    ///Long pressed alert button action
    pressedAlertAction(bool isOn, isLongPressed) async {
      isPressedOperationButtons.value = [false, false, isOn];
      if (isOn) {
        selectButton.playAudio(audioPlayer, isSoundOn.value);
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        if (isLongPressed) {
          if (isMoving.value) isEmergency.value = true;
          if (isEmergency.value && isMoving.value) {
            callSound.playAudio(audioPlayer, isSoundOn.value);
            await Future.delayed(const Duration(seconds: waitTime)).then((_) {
              context.emergency().speakText(flutterTts, isSoundOn.value);
              nextFloor.value = counter.value;
              isMoving.value = false;
              isEmergency.value = true;
              counter.value.clearLowerFloor(
                  isAboveSelectedList.value, isUnderSelectedList.value);
              counter.value.clearUpperFloor(
                  isAboveSelectedList.value, isUnderSelectedList.value);
            });
            await Future.delayed(const Duration(seconds: openTime)).then((
                _) async {
              context.return1st().speakText(flutterTts, isSoundOn.value);
            });
            await Future.delayed(const Duration(seconds: waitTime * 2)).then((
                _) async {
              if (counter.value != 1) {
                nextFloor.value = 1;
                "$nextString${nextFloor.value}".debugPrint();
                (counter.value < nextFloor.value) ? counterUp() : counterDown();
              } else {
                context.openDoor().speakText(flutterTts, isSoundOn.value);
                isDoorState.value = openingState;
                "isDoorState: ${isDoorState.value}".debugPrint();
              }
            });
          }
        }
      }
    }

    ///Button action list
    List<dynamic> pressedButtonAction(bool isOn, isLongPressed) => [
      (isOn && isLongPressed) ? () => pressedOpenAction(isOn): (_) => pressedOpenAction(isOn),
      (isOn && isLongPressed) ? () => pressedCloseAction(isOn): (_) => pressedCloseAction(isOn),
      (isOn && isLongPressed) ? () => pressedAlertAction(isOn, isLongPressed): (_) => pressedAlertAction(isOn, isLongPressed),
    ];

    ///行き先階ボタンを選択する
    floorSelected(int i, bool selectFlag) async {
      if (!isEmergency.value) {
        if (i == counter.value) {
          if (!isMoving.value && i == nextFloor.value) context.pushNumber().speakText(flutterTts, isSoundOn.value);
        } else if (!selectFlag) {
          //止まらない階の場合のメッセージ
          context.notStop().speakText(flutterTts, isSoundOn.value);
        } else if (!i.isSelected(isAboveSelectedList.value, isUnderSelectedList.value)) {
          selectButton.playAudio(audioPlayer, isSoundOn.value);
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
              context.pushNumber().speakText(flutterTts, isSoundOn.value);
            }
          });
        }
      }
    }

    ///Deselect floor button
    floorCanceled(int i) async {
      if (i.isSelected(isAboveSelectedList.value, isUnderSelectedList.value) && i != nextFloor.value) {
        cancelButton.playAudio(audioPlayer, isSoundOn.value);
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

    ///Menu button action
    pressedMenu() async {
      selectButton.playAudio(audioPlayer, isSoundOn.value);
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      ref.read(isMenuProvider.notifier).state = true;
    }

    ///Action after changing door state
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

    return Scaffold(
      backgroundColor: grayColor,
      body: Center(child:
        Stack(children: [
          Center(child:
            Container(
              alignment: Alignment.center,
              width: context.displayWidth(),
              height: context.height(),
              ///Metal Decoration
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: metalSort,
                  colors: metalColor,
                )
              ),
              child: Column(children: [
                const Spacer(flex: 3),
                Container(
                  width: context.displayWidth(),
                  height: context.displayHeight(),
                  color: darkBlackColor,
                  child: Stack(alignment: Alignment.center,
                    children: [
                      ///Shimada Logo
                      Image(image: AssetImage(isShimada.shimadaLogo()),
                        height: context.shimadaLogoHeight(),
                        color: blackColor,
                      ),
                      Row(children: [
                        const Spacer(),
                        ///Arrow
                        Container(
                          padding: EdgeInsets.only(top: context.displayArrowPadding()),
                          width: context.displayArrowWidth(),
                          height: context.displayArrowHeight(),
                          child: Image.asset(counter.value.arrowImage(isMoving.value, nextFloor.value))
                        ),
                        ///Floor number
                        Container(
                          alignment: Alignment.topRight,
                          width: context.displayNumberWidth(),
                          height: context.displayNumberHeight(),
                          child: useMemoized(() => HookBuilder(
                            builder: (context) => Text(counter.value.displayNumber(),
                              style: TextStyle(
                                color: lampColor,
                                fontSize: context.displayNumberFontSize(),
                                fontWeight: FontWeight.normal,
                                fontFamily: numberFont,
                              ),
                            ),
                          ), [counter.value]),
                        ),
                        const Spacer(),
                      ])
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                ///Operation Buttons (Open, Close, Alert)
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [...List.generate(3, (i) => GestureDetector(
                    onTapDown: pressedButtonAction(true, false)[i],
                    onTapUp: pressedButtonAction(false, false)[i],
                    onLongPress: pressedButtonAction(true, true)[i],
                    onLongPressEnd: pressedButtonAction(false, true)[i],
                    child: Container(
                      width: context.operationButtonSize() + 2 * context.buttonBorderWidth(),
                      height: context.operationButtonSize() + 2 * context.buttonBorderWidth(),
                      decoration: BoxDecoration(
                        color: transpColor,
                        shape: (isShimada && i == 2) ? BoxShape.circle: BoxShape.rectangle,
                        borderRadius: (isShimada && i == 2) ? null: BorderRadius.circular(context.buttonBorderRadius()),
                        border: Border.all(
                          color: (i == 2) ? yellowColor: (i == 0) ? greenColor: whiteColor,
                          width: context.buttonBorderWidth(),
                        ),
                      ),
                      child: Image.asset(isShimada.operateBackGround(isPressedOperationButtons.value)[i]),
                    )))..insert(1, SizedBox(width: context.buttonMargin()))
                    ..insert(3, SizedBox(width: context.operationButtonSize() + 2 * context.buttonMargin()))
                  ],
                ),
                const Spacer(flex: 1),
                ///Floor Buttons
                Column(children: floorNumbers.asMap().entries.map((row) =>
                  Column(children: [
                    SizedBox(height: context.buttonMargin()),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: row.value.asMap().entries.map((floor) => Row(children: [
                        SizedBox(width: context.buttonMargin()),
                        GestureDetector(
                          child: SizedBox(
                            width: context.floorButtonSize(),
                            height: context.floorButtonSize(),
                            child: Stack(alignment: Alignment.center,
                              children: [
                                Image.asset(floor.value.numberBackground(isShimada, floor.value.isSelected(isAboveSelectedList.value, isUnderSelectedList.value))),
                                Text(floor.value.buttonNumber(isShimada),
                                  style: TextStyle(
                                    color: (floor.value.isSelected(isAboveSelectedList.value, isUnderSelectedList.value)) ? lampColor: whiteColor,
                                    fontSize: context.buttonNumberFontSize(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () => floorSelected(floor.value, isFloors[row.key][floor.key]),
                          onLongPress: () => floorCanceled(floor.value),
                          onDoubleTap: () => floorCanceled(floor.value),
                        ),
                        if (floor.key == row.value.length - 1) SizedBox(width: context.buttonMargin()),
                      ])).toList(),
                    ),
                    if (row.key == floorNumbers.length - 1) SizedBox(height: context.buttonMargin()),
                  ])
                ).toList()),
                const Spacer(flex: 1),
                Row(children: [
                  const Spacer(),
                  ///Admob Banner
                  const AdBannerWidget(),
                  const Spacer(flex: 1),
                  ///Menu Button
                  GestureDetector(
                    onTap: () => pressedMenu(),
                    child: SizedBox(
                      width: context.operationButtonSize(),
                      height: context.operationButtonSize(),
                      child: Image.asset(isMenu.buttonChanBackGround()),
                    ),
                  ),
                  const Spacer(flex: 1),
                ]),
              ]),
            ),
          ),
          ///Menu
          if (isMenu) const MyMenuPage(isHome: true),
        ]),
      ),
    );
  }
}