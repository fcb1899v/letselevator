import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:games_services/games_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'common_widget.dart';
import 'extension.dart';
import 'constant.dart';
import 'admob_banner.dart';

class ManyButtonsPage extends HookConsumerWidget {
  const ManyButtonsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final width = context.width();
    final height = context.height();
    final lang = context.lang();

    final isSelectedButtonsList = useState(panelMax.listListAllFalse(rowMax, columnMax));
    final isDarkBack = useState(false);
    final isBeforeCount = useState(false);
    final isChallengeStart = useState(false);
    final isChallengeFinish = useState(false);
    final isMenu = useState(false);
    final beforeCount = useState(0);
    final counter = useState(0);
    final currentSeconds = useState(0);
    final bestScore = useState(0);
    final isSoundOn = useState(true);
    final AudioPlayer audioPlayer = AudioPlayer();

    // ベストスコアの取得
    // getBestScore() async {
      // await GamesServices.getPlayerScore(
      //   androidLeaderboardID: lBID30Sec,
      //   iOSLeaderboardID: lBID30Sec,
      // ) ?? prefs.getInt('bestScore') ?? 0
    // }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        isSelectedButtonsList.value = panelMax.listListAllTrue(rowMax, columnMax);
        await audioPlayer.setReleaseMode(ReleaseMode.loop);
        await audioPlayer.setVolume(0.5);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        bestScore.value = prefs.getInt('bestScore') ?? 0;
        final timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
          if (currentSeconds.value < 1 && isChallengeStart.value) {
            if (counter.value >= bestScore.value) bestScoreSound.playAudio(audioPlayer, isSoundOn.value);
            counter.value.saveBestScore(bestScore.value);
            isChallengeStart.value = false;
            isDarkBack.value = true;
            isChallengeFinish.value = true;
            timer.cancel;
          } else if (isChallengeStart.value) {
            currentSeconds.value = currentSeconds.value - 1;
            if (currentSeconds.value < 4) countdown.playAudio(audioPlayer, isSoundOn.value);
            if (currentSeconds.value == 0) countdownFinish.playAudio(audioPlayer, isSoundOn.value);
          }
        });
        timer.cancel;
        isSelectedButtonsList.value = panelMax.listListAllFalse(rowMax, columnMax);
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
      // timer.cancel();
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
      // if (counter.value.setBestScore(bestScore) > bestScore) {
      //   GamesServices.submitScore(score: Score(
      //     androidLeaderboardID: lBID30Sec,
      //     iOSLeaderboardID: lBID30Sec,
      //     value: counter.setBestScore(bestScore)
      //   ));
      //   GamesServices.showLeaderboards(
      //     androidLeaderboardID: lBID30Sec,
      //     iOSLeaderboardID: lBID30Sec,
      //   );
      // }
      "Your Score: ${counter.value}".debugPrint();
      "Best score: ${bestScore.value}".debugPrint();
      isDarkBack.value = false;
      isChallengeFinish.value = false;
      bestScore.value = counter.value.setBestScore(bestScore.value);
      //インタースティシャル広告
      // if (bestScore != counter && counter % 2 == 1) {
      //   AdmobService().createInterstitialAd();
      // }
    }

    //　メニュー画面
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
            linkIconTextButton(context, context.letsElevator(), context.elevatorLink(), CupertinoIcons.app, audioPlayer, isSoundOn.value),
            //オンラインショップのリンク
            if (lang == "ja") linkIconTextButton(context, context.onlineShop(), context.shopLink(), CupertinoIcons.cart, audioPlayer, isSoundOn.value),
            //島田電機製作所のリンク
            linkIconTextButton(context, context.shimax(), context.shimaxLink(), CupertinoIcons.info, audioPlayer, isSoundOn.value),
            //1000のボタン紹介のリンク
            linkIconTextButton(context, context.buttons(), context.articleLink(), CupertinoIcons.info, audioPlayer, isSoundOn.value),
            //再現！1000のボタン⇄エレベーターモードのモードチェンジ
            changePageButton(context, audioPlayer, false, isSoundOn.value),
          ]
        ),
      ),
      const Spacer(flex: 2),
      Row(children: [
        const Spacer(flex: 3),
        if (lang == "ja") snsButton(context, twitterLogo, elevatorTwitter, audioPlayer, isSoundOn.value),
        const Spacer(flex: 1),
        snsButton(context, youtubeLogo, elevatorYoutube, audioPlayer, isSoundOn.value),
        const Spacer(flex: 1),
        if (lang == "ja") snsButton(context, instagramLogo, elevatorInstagram, audioPlayer, isSoundOn.value),
        const Spacer(flex: 3),
      ]),
      const Spacer(flex: 2),
      SizedBox(height: context.admobHeight()),
    ]);

    // 通常サイズのボタン
    Widget normalButton(int p, i, j) => GestureDetector(
      child: normalButtonImage(context, p, i, j, isSelectedButtonsList.value.buttonImage(p, i, j)),
      onTap: () => buttonSelected(p, i, j),
      onLongPress: () => buttonDeSelected(p, i, j),
      onDoubleTap: () => buttonDeSelected(p, i, j),
    );

    // 大サイズボタン
    Widget largeSizeButton(int p, i, j, double hR, double vR) => GestureDetector(
      child: largeButtonImage(context, hR, vR, isSelectedButtonsList.value.buttonImage(p, i, j)),
      onTap: () => buttonSelected(p, i, j),
      onLongPress: () => buttonDeSelected(p, i, j),
      onDoubleTap: () => buttonDeSelected(p, i, j),
    );

    // panel 2 丸特大ボタン
    Widget largeSizeButtonWidget() => Row(children: [
      SizedBox(width: 1.9 * context.defaultButtonLength()),
      Column(children: [
        SizedBox(height: 5.9 * context.defaultButtonLength()),
        largeSizeButton(1, 2, 6, 2.2, 2.2),
      ]),
    ]);

    // panel 3 縦長2連ボタン
    Widget longSizeButtonWidget() => Row(children: [
      SizedBox(width: 9 * context.defaultButtonLength()),
      Column(children: [
        SizedBox(height: 2 * context.defaultButtonLength()),
        largeSizeButton(3, 7, 2, 1.0, 1.5),
        largeSizeButton(3, 9, 4, 1.0, 1.5),
      ]),
    ]);

    // panel 4 丸大2連ボタン
    Widget doubleLargeButtonWidget() => Row(children: [
      SizedBox(width: 6.1 * context.defaultButtonLength()),
      Column(children: [
        SizedBox(height: 5.8 * context.defaultButtonLength()),
        Row(children: [
          largeSizeButton(4, 6, 6, 1.4, 1.4),
          largeSizeButton(4, 7, 6, 1.4, 1.4),
        ]),
      ]),
    ]);

    // panel 4 上大ボタン
    Widget upLargeButtonWidget() => Row(children: [
      SizedBox(width: 5.35 * context.defaultButtonLength()),
      Column(children: [
        SizedBox(height: 1.85 * context.defaultButtonLength()),
        largeSizeButton(4, 5, 2, 1.3, 1.3),
      ]),
    ]);

    // panel 4 下大ボタン
    Widget downLargeButtonWidget() => Row(children: [
      SizedBox(width: 1.35 * context.defaultButtonLength()),
      Column(children: [
        SizedBox(height: 4.85 * context.defaultButtonLength()),
        largeSizeButton(4, 1, 5, 1.3, 1.3),
      ]),
    ]);

    // 30秒チャレンジ開始前のカウントダウン表示
    Widget beforeCountDown() => Stack(alignment: Alignment.center,
      children: [
        SizedBox(width: width, height: height),
        beforeCountdownBackground(context),
        beforeCountdownNumber(context, beforeCount.value),
      ]
    );

    // 30秒チャレンジ後の結果画面
    Widget finishChallenge() => Stack(alignment: Alignment.center,
      children: [
        SizedBox(width: width, height: height,),
        Column(children: [
          const Spacer(flex: 3),
          finishChallengeText(context.yourScore(), 32),
          const SizedBox(height: 50),
          finishChallengeScore(counter.value),
          const SizedBox(height: 50),
          finishChallengeText(bestScore.value.finishBestScore(context, counter.value), 24),
          const Spacer(flex: 1),
          ///　完全再現1000のボタンに戻るボタン
          GestureDetector(child: return1000Buttons(context),
            onTap: () => back1000Buttons(),
          ),
          const Spacer(flex: 3),
        ]),
      ]
    );

    /// 1000個のボタンの表示
    Widget buttonsPanel(int p) {
      List<Widget> listColumn = [];
      for(int j = 0; j < columnMax; j++) {
        List<Widget> listRow = [];
        for(int i = 0; i < rowMax - rowMinus[p][j]; i++) {
          listRow.add(normalButton(p, i, j));
        }
        listColumn.add(Row(children: listRow,));
      }
      return Stack(children: [
        Column(children: listColumn),
        if (p == 1) largeSizeButtonWidget(),
        if (p == 3) longSizeButtonWidget(),
        if (p == 4) doubleLargeButtonWidget(),
        if (p == 4) upLargeButtonWidget(),
        if (p == 4) downLargeButtonWidget(),
      ]);
    }

    Widget buttonsView() => SingleChildScrollView(
      controller: ScrollController(),
      scrollDirection: Axis.horizontal,
      child: InteractiveViewer(
        child: Row(children: [
          for(int p = 0; p < panelMax - 1; p++) ... {
            buttonsPanel(p),
            panelDivider(context),
          },
          buttonsPanel(panelMax - 1),
        ]),
      )
    );

    ///
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(width: width, height: height,
        decoration: metalDecoration(),
        child: Stack(children: [
          Column(children: [
            const Spacer(flex: 3),
            Row(children: [
              const Spacer(flex: 1),
              real1000ButtonsLogo(context),
              const Spacer(flex: 1),
              /// 30秒チャレンジのスタートボタン
              GestureDetector(
                onTap: () => (isChallengeStart.value) ? challengeStop(): challengeStart(),
                child: challengeStartText(context, currentSeconds.value, isChallengeStart.value),
              ),
              const Spacer(flex: 1),
              countDisplay(context, counter.value),
              const Spacer(flex: 1),
            ]),
            const Spacer(flex: 1),
            buttonsView(),
            const Spacer(flex: 1),
            SizedBox(height: context.admobHeight())
          ]),
          if (isDarkBack.value) darkBackground(context),
          if (isBeforeCount.value) beforeCountDown(),
          if (isChallengeFinish.value) finishChallenge(),
          if (isMenu.value) overLay(context),
          if (isMenu.value) menuList(),
          Column(children: [
            const Spacer(),
            Row(children: [
              const Spacer(),
              const AdBannerWidget(),
              const Spacer(),
              ///　メニューボタン
              GestureDetector(
                onTap: () {
                  selectButton.playAudio(audioPlayer, isSoundOn.value);
                  isMenu.value = !isMenu.value;
                },
                child: imageButton(context, isMenu.value.buttonChanBackGround())
              ),
              const Spacer(),
            ]),
          ])
        ]),
      ),
    );
  }
}