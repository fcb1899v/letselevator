import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'common_function.dart';
import 'main.dart';
import 'my_menu.dart';
import 'extension.dart';
import 'constant.dart';
import 'admob_banner.dart';

class ManyButtonsPage extends HookConsumerWidget {
  const ManyButtonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final isSelectedButtonsList = useState(panelMax.listListAllFalse(rowMax, columnMax));
    final isDarkBack = useState(false);
    final isBeforeCount = useState(false);
    final isChallengeStart = useState(false);
    final isChallengeFinish = useState(false);
    final isSoundOn = useState(true);

    final beforeCount = useState(0);
    final counter = useState(0);
    final currentSeconds = useState(0);
    final bestScore = useState(0);

    final isMenu = ref.watch(isMenuProvider);
    final AudioPlayer audioPlayer = AudioPlayer();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        isSelectedButtonsList.value = panelMax.listListAllFalse(rowMax, columnMax);
        await audioPlayer.setReleaseMode(ReleaseMode.loop);
        await audioPlayer.setVolume(0.5);
        await gamesSignIn();
        bestScore.value = await getBestScore();
        final timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
          if (currentSeconds.value < 1 && isChallengeStart.value) {
            isDarkBack.value = true;
            isChallengeStart.value = false;
            isChallengeFinish.value = true;
            bestScore.value = (counter.value > bestScore.value) ? counter.value: bestScore.value;
            if (counter.value >= bestScore.value) bestScoreSound.playAudio(audioPlayer, isSoundOn.value);
            if (!isTest) bestScore.value.setSharedPrefInt(bestScoreKey);
            if (!isTest) gamesSubmitScore(bestScore.value);
            "Your Score: ${counter.value}".debugPrint();
            "Best score: ${bestScore.value}".debugPrint();
            timer.cancel;
          } else if (isChallengeStart.value) {
            currentSeconds.value = currentSeconds.value - 1;
            if (currentSeconds.value < 4) countdown.playAudio(audioPlayer, isSoundOn.value);
            if (currentSeconds.value == 0) countdownFinish.playAudio(audioPlayer, isSoundOn.value);
          }
        });
        timer.cancel;
      });
      return null;
    }, const []);

    //ボタンを選択する
    buttonSelected(int p, i, j) async {
      if (!isSelectedButtonsList.value[p][i][j] && !p.isTranspButton(i, j)) {
        if (!isChallengeStart.value) {
          selectButton.playAudio(audioPlayer, isSoundOn.value);
          Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        }
        counter.value = counter.value + 1;
        isSelectedButtonsList.value[p][i][j] = true;
      }
    }

    //ボタンを解除する
    buttonDeSelected(int p, i, j) async {
      if (isSelectedButtonsList.value[p][i][j] && !p.isTranspButton(i, j)) {
        if (!isChallengeStart.value) {
          cancelButton.playAudio(audioPlayer, isSoundOn.value);
          Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        }
        counter.value = counter.value - 1;
        isSelectedButtonsList.value[p][i][j] = false;
      }
    }

    //30秒チャレンジスタート前のカウントダウン表示
    beforeCountdown(int i) {
      countdown.playAudio(audioPlayer, isSoundOn.value);
      isBeforeCount.value = true;
      beforeCount.value = i;
    }

    //30秒チャレンジスタート前のカウントダウン表示終了
    finishBeforeCountdown() {
      countdownFinish.playAudio(audioPlayer, isSoundOn.value);
      isDarkBack.value= false;
      isChallengeStart.value = true;
      currentSeconds.value = 30;
    }

    // 30秒チャレンジスタート
    challengeStart() async {
      counter.value = 0;
      isSelectedButtonsList.value = panelMax.listListAllFalse(rowMax, columnMax);
      isDarkBack.value = true;
      beforeCountdown(3);
      await Future.delayed(const Duration(milliseconds: 500)).then((_) async => isBeforeCount.value = false);
      await Future.delayed(const Duration(milliseconds: 500)).then((_) async => beforeCountdown(2));
      await Future.delayed(const Duration(milliseconds: 500)).then((_) async => isBeforeCount.value = false);
      await Future.delayed(const Duration(milliseconds: 500)).then((_) async => beforeCountdown(1));
      await Future.delayed(const Duration(milliseconds: 500)).then((_) async => isBeforeCount.value = false);
      await Future.delayed(const Duration(milliseconds: 500)).then((_) async => finishBeforeCountdown());
    }

    // 30秒チャレンジのストップ
    challengeStop() {
      counter.value = 0;
      isSelectedButtonsList.value = panelMax.listListAllFalse(rowMax, columnMax);
      isChallengeStart.value = false;
      currentSeconds.value = 0;
    }

    // 完全再現1000のボタンに戻る
    back1000Buttons() {
      isDarkBack.value = false;
      isChallengeFinish.value = false;
      // インタースティシャル広告
      // if (bestScore != counter && counter % 2 == 1) {
      //   AdmobService().createInterstitialAd();
      // }
    }

    //　メニューボタンを押した時の操作
    pressedMenu() async {
      selectButton.playAudio(audioPlayer, isSoundOn.value);
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      ref.read(isMenuProvider.notifier).state = true;
    }

    ///Normal size button
    Widget normalButton(int p, i, j) => GestureDetector(
      child: Container(
        width: context.buttonWidth(p, i, j),
        height: context.buttonHeight(),
        padding: EdgeInsets.all(context.buttonsPadding()),
        alignment: Alignment.center,
        child: Image.asset(isSelectedButtonsList.value.buttonImage(p, i, j)),
      ),
      onTap: () => buttonSelected(p, i, j),
      onLongPress: () => buttonDeSelected(p, i, j),
      onDoubleTap: () => buttonDeSelected(p, i, j),
    );

    ///Large size button
    Widget largeSizeButton(int p, i, j, double hR, double vR) => GestureDetector(
      child: Container(
        width: context.largeButtonWidth(hR),
        height: context.largeButtonHeight(vR),
        padding: EdgeInsets.all(context.buttonsPadding()),
        alignment: Alignment.center,
        child: Image.asset(isSelectedButtonsList.value.buttonImage(p, i, j)),
      ),
      onTap: () => buttonSelected(p, i, j),
      onLongPress: () => buttonDeSelected(p, i, j),
      onDoubleTap: () => buttonDeSelected(p, i, j),
    );

    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        width: context.width(),
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
        child: Stack(children: [
          Column(children: [
            const Spacer(flex: 3),
            Row(children: [
              const Spacer(flex: 1),
              /// 1000のボタンのロゴ
              GestureDetector(
                onTap: () async => await gamesShowLeaderboard(),
                child: Container(
                  width: context.logo1000ButtonsWidth(),
                  padding: EdgeInsets.all(context.logo1000ButtonsPadding()),
                  child: Image.asset(realTitleImage),
                ),
              ),
              const Spacer(flex: 1),
              ///Challenge start button & Countdown
              GestureDetector(
                onTap: () => (isChallengeStart.value) ? challengeStop(): challengeStart(),
                child: Container(
                  alignment: Alignment.center,
                  width: context.challengeStartButtonWidth(),
                  height: context.challengeStartButtonHeight(),
                  padding: EdgeInsets.only(
                    top: (isChallengeStart.value) ? 0: context.countdownPaddingTop(),
                    left: (isChallengeStart.value) ? context.countdownPaddingLeft(): 0,
                ),
                  decoration: BoxDecoration(
                    color: currentSeconds.value.startButtonColor(isChallengeStart.value),
                    borderRadius: BorderRadius.circular(context.startCornerRadius()),
                    border: Border.all(color: whiteColor, width: context.startBorderWidth()),
                  ),
                  ///Countdown
                  child: (isChallengeStart.value) ? Text(currentSeconds.value.countDownNumber(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: whiteColor,
                      fontFamily: numberFont,
                      fontSize: context.countdownFontSize(),
                    ),
                  ///Challenge start button
                  ): Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.challenge(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.challengeButtonFontSize(),
                          fontWeight: FontWeight.bold,
                          color: whiteColor,
                        ),
                      ),
                      Text(context.start(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.challengeStartFontSize(),
                          fontWeight: FontWeight.bold,
                          color: whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 1),
              ///Button counter
              Container(
                width: context.countDisplayWidth(),
                height: context.countDisplayHeight(),
                color: darkBlackColor,
                padding: EdgeInsets.only(
                  top: context.countDisplayPaddingTop(),
                  left: context.countDisplayPaddingLeft(),
                  right: context.countDisplayPaddingRight(),
                ),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(counter.value.countNumber(),
                    style: const TextStyle(
                      color: lampColor,
                      fontFamily: numberFont,
                      fontSize: 100,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ]),
            const Spacer(flex: 1),
            ///Buttons Panel
            SingleChildScrollView(
              controller: ScrollController(),
              scrollDirection: Axis.horizontal,
              child: InteractiveViewer(
                child: Row(children: [
                  for(int p = 0; p < panelMax; p++) ... {
                    Stack(children: [
                      ///Normal buttons
                      Column(children: List.generate(columnMax, (j) => Row(
                        children: List.generate(rowMax - rowMinus[p][j], (i) => normalButton(p, i, j)),
                      ))),
                      ///Large circle button @ panel 2
                      if (p == 1) Row(children: [
                        SizedBox(width: 1.9 * context.defaultButtonLength()),
                        Column(children: [
                          SizedBox(height: 5.9 * context.defaultButtonLength()),
                          largeSizeButton(1, 2, 6, 2.2, 2.2),
                        ]),
                      ]),
                      ///Long rectangle buttons @ panel 3
                      if (p == 3) Row(children: [
                        SizedBox(width: 9 * context.defaultButtonLength()),
                        Column(children: [
                          SizedBox(height: 2 * context.defaultButtonLength()),
                          largeSizeButton(3, 7, 2, 1.0, 1.5),
                          largeSizeButton(3, 9, 4, 1.0, 1.5),
                        ]),
                      ]),
                      ///Large circle buttons @ panel 4
                      if (p == 4) Row(children: [
                        SizedBox(width: 6.1 * context.defaultButtonLength()),
                        Column(children: [
                          SizedBox(height: 5.8 * context.defaultButtonLength()),
                          Row(children: [
                            largeSizeButton(4, 6, 6, 1.4, 1.4),
                            largeSizeButton(4, 7, 6, 1.4, 1.4),
                          ]),
                        ]),
                      ]),
                      ///Large up buttons @ panel 4
                      if (p == 4) Row(children: [
                        SizedBox(width: 5.35 * context.defaultButtonLength()),
                        Column(children: [
                          SizedBox(height: 1.85 * context.defaultButtonLength()),
                          largeSizeButton(4, 5, 2, 1.3, 1.3),
                        ]),
                      ]),
                      ///Large down buttons @ panel 4
                      if (p == 4) Row(children: [
                        SizedBox(width: 1.35 * context.defaultButtonLength()),
                        Column(children: [
                          SizedBox(height: 4.85 * context.defaultButtonLength()),
                          largeSizeButton(4, 1, 5, 1.3, 1.3),
                        ]),
                      ]),
                    ]),
                    ///Panel Divider
                    if (p != panelMax - 1) Container(
                      width: 1,
                      height: context.dividerHeight(),
                      margin: EdgeInsets.symmetric(horizontal: context.dividerMargin()),
                      color: blackColor,
                    ),
                  },
                ]),
              ),
            ),
            const Spacer(flex: 1),
            Row(children: [
              const Spacer(),
              const AdBannerWidget(),
              const Spacer(flex: 1),
              /// Menu Button
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
          ///Countdown before 30s challenge start
          if (isDarkBack.value) Container(
            width: context.width(),
            height: context.height(),
            color: transpBlackColor,
            child: Stack(alignment: Alignment.center,
              children: [
                ///Countdown
                if (isBeforeCount.value) SizedBox(
                  width: context.beforeCountdownCircleSize(),
                  height: context.beforeCountdownCircleSize(),
                  child: const FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Image(image: AssetImage(circleButton)),
                  ),
                ),
                if (isBeforeCount.value) Text("${beforeCount.value}",
                  style: GoogleFonts.roboto(
                  color: whiteColor,
                  fontSize: context.beforeCountdownNumberSize(),
                  fontWeight: FontWeight.bold,
                  ),
                ),
                ///Challenge result
                if (isChallengeFinish.value) Column(children: [
                  const Spacer(flex: 5),
                  ///Challenge result title
                  Text(context.yourScore(),
                    style: TextStyle(
                      color: whiteColor,
                      fontWeight: context.lang() == "en" ? FontWeight.normal: FontWeight.bold,
                      fontSize: context.scoreTitleFontSize(),
                      fontFamily: "teleIndicators",
                    ),
                  ),
                  const Spacer(flex: 1),
                  ///Challenge result score
                  Text(counter.value.countNumber(),
                    style: TextStyle(
                      color: lampColor,
                      fontFamily: "teleIndicators",
                      fontSize: context.yourScoreFontSize(),
                    ),
                  ),
                  const Spacer(flex: 1),
                  ///Challenge best score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.best(),
                        style: TextStyle(
                          color: whiteColor,
                          fontWeight: context.lang() == "en" ? FontWeight.normal: FontWeight.bold,
                          fontSize: context.bestFontSize(),
                          fontFamily: "teleIndicators",
                        ),
                      ),
                      Text(":",
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: context.bestScoreFontSize(),
                          fontFamily: "teleIndicators",
                        ),
                      ),
                      Text(bestScore.value.countNumber(),
                        style: TextStyle(
                          color: lampColor,
                          fontSize: context.bestScoreFontSize(),
                          fontFamily: "teleIndicators",
                        ),
                      ),
                    ]
                  ),
                  const Spacer(flex: 2),
                  Row(children: [
                    const Spacer(flex: 1),
                    ///Ranking button
                    GestureDetector(
                      onTap: () async => await gamesShowLeaderboard(),
                      child: Container(
                        alignment: Alignment.center,
                        width: context.backButtonWidth(),
                        height: context.backButtonHeight(),
                        decoration: BoxDecoration(
                          color: lampColor,
                          borderRadius: BorderRadius.circular(context.backButtonBorderRadius()),
                        ),
                        child: Text(context.ranking(),
                          style: TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.bold,
                            fontSize: context.backButtonFontSize(),
                            fontFamily: "teleIndicators",
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    ///Back button
                    GestureDetector(
                      onTap: () => back1000Buttons(),
                      child: Container(
                        alignment: Alignment.center,
                        width: context.backButtonWidth(),
                        height: context.backButtonHeight(),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(context.backButtonBorderRadius()),
                        ),
                        child: Text(context.back(),
                          style: TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.bold,
                            fontSize: context.backButtonFontSize(),
                            fontFamily: "teleIndicators",
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                  ]),
                  const Spacer(flex: 5),
                ])
              ]
            ),
          ),
          if (isMenu) const MyMenuPage(isHome: false)
        ]),
      ),
    );
  }
}
