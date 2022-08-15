import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'common_widget.dart';
import 'extension.dart';
import 'constant.dart';
import 'admob.dart';

class ManyButtonsBody extends StatefulWidget {
  const ManyButtonsBody({Key? key}) : super(key: key);
  @override
  State<ManyButtonsBody> createState() => _ManyButtonsBodyState();
}

class _ManyButtonsBodyState extends State<ManyButtonsBody> {

  final List<List<bool>> isEnableButtonsList = List.generate(
    rowMax, (i) => List.generate(columnMax, (j) => j.ableButtonFlag(i))
  );

  late double width;
  late double height;
  late String lang;
  late List<List<bool>> _isSelectedButtonsList;
  late BannerAd _myBanner;
  late bool _isDarkBack;
  late bool _isBeforeCount;
  late bool _isChallengeStart;
  late bool _isChallengeFinish;
  late bool _isMenu;
  late int _beforeCount;
  late int _counter;
  late int _currentSeconds;
  late Timer _timer;
  late int _bestScore;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
    setState(() {
      _isSelectedButtonsList = columnMax.listListAllFalse(rowMax);
      _myBanner = AdmobService().getBannerAd();
      _isDarkBack = false;
      _isBeforeCount = false;
      _isChallengeStart = false;
      _isChallengeFinish = false;
      _isMenu = false;
      _beforeCount = 0;
      _timer = countTimer();
      _counter = 0;
      _currentSeconds = 0;
      _bestScore = 0;
    });
    getBestScore();
    _timer.cancel();
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
    _myBanner.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(width: width, height: height,
        decoration: metalDecoration(),
        child: Stack(children: [
          Column(children: [
            const Spacer(flex: 3),
            Row(children: [
              const Spacer(flex: 1), real1000ButtonsLogo(width),
              const Spacer(flex: 1), startButtonView(),
              const Spacer(flex: 2), countDisplay(width, _counter),
              const Spacer(flex: 1),
            ]),
            const Spacer(flex: 1), buttonsView(),
            const Spacer(flex: 1),
            SizedBox(height: height.admobHeight())
          ]),
          if (_isDarkBack) darkBackground(width, height),
          if (_isBeforeCount) beforeCountdown(width, height, _beforeCount),
          if (_isChallengeFinish) finishChallenge(),
          if (_isMenu) overLay(context),
          if (_isMenu) menuList(),
          Column(children: [
            const Spacer(),
            Row(children: [
              const Spacer(), adMobBannerWidget(context, _myBanner),
              const Spacer(), menuButton(),
              const Spacer(),
            ]),
          ])
        ]),
      ),
    );
  }

  //　メニューボタン
  Widget menuButton() =>
      SizedBox(
        width: height.operationButtonSize(),
        height: height.operationButtonSize(),
        child: ElevatedButton(
          style: transparentButtonStyle(),
          child: Image.asset(true.buttonChanBackGround()),
          onPressed: () => setState(() => _isMenu = !_isMenu),
        )
      );

  //　メニュー画面
  Widget menuList() =>
      Column(children: [
        const Spacer(flex: 4),
        menuLogo(context),
        const Spacer(flex: 2),
        menuTitle(context),
        const Spacer(flex: 1),
        // SizedBox(height: context.height().menuTitleMargin()),
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
            changePageButton(context, false),
            SizedBox(height: context.height().menuListMargin()),
          ]
        )),
        const Spacer(flex: 2),
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

  // 1000個のボタンの表示
  Widget buttonsView() {

    List<Widget> _listColumn = [];

    for(int j = 0; j < columnMax; j++) {
      List<Widget> _listRow = [];
      for(int i = 0; i < rowMax - wideList[j]; i++) {
        _listRow.add(normalButton(i, j));
      }
      _listColumn.add(Row(children: _listRow,));
    }

    return SingleChildScrollView(
      controller: ScrollController(),
      scrollDirection: Axis.horizontal,
      child: Stack(children: [
        Column(children: _listColumn),
        // 以下大型ボタン
        largeSizeButtonWidget(),
        longSizeButtonWidget(),
        doubleLargeButtonWidget(),
        upLargeButtonWidget(),
        downLargeButtonWidget(),
      ]),
    );
  }

  // 通常サイズのボタン
  Widget normalButton(int i, int j) =>
      GestureDetector(
        child: normalButtonImage(i, j, height, _isSelectedButtonsList.buttonBackground(i, j, isEnableButtonsList)),
        onTap: () => _buttonSelected(i, j),
        onLongPress: () => _buttonDeSelected(i, j),
        onDoubleTap: () => _buttonDeSelected(i, j),
      );

  // 大サイズボタン
  Widget largeSizeButton(int i, int j, double hR, double vR) =>
      GestureDetector(
        child: largeButtonImage(hR, vR, height, _isSelectedButtonsList.buttonImage(i, j)),
        onTap: () => _buttonSelected(i, j),
        onLongPress: () => _buttonDeSelected(i, j),
        onDoubleTap: () => _buttonDeSelected(i, j),
      );

  // 2倍の大きさのボタン
  Widget largeSizeButtonWidget() =>
      Row(children: [
        SizedBox(width: 12.9 * height.defaultButtonLength()),
        Column(children: [
          SizedBox(height: 5.9 * height.defaultButtonLength()),
          largeSizeButton(13, 6, 2.2, 2.2),
        ]),
      ]);

  // 縦長2連ボタン
  Widget longSizeButtonWidget() =>
      Row(children: [
        SizedBox(width: 41 * height.defaultButtonLength()),
        Column(children: [
          SizedBox(height: 2 * height.defaultButtonLength()),
          largeSizeButton(36, 2, 1.0, 1.5),
          largeSizeButton(41, 4, 1.0, 1.5),
        ]),
      ]);

  // 丸大2連ボタン
  Widget doubleLargeButtonWidget() =>
      Row(children: [
        SizedBox(width: 50.1 * height.defaultButtonLength()),
        Column(children: [
          SizedBox(height: 5.8 * height.defaultButtonLength()),
          Row(children: [
            largeSizeButton(47, 6, 1.4, 1.4),
            largeSizeButton(48, 6, 1.4, 1.4),
          ]),
        ]),
      ]);

  // 上大ボタン
  Widget upLargeButtonWidget() =>
      Row(children: [
        SizedBox(width: 48.35 * height.defaultButtonLength()),
        Column(children: [
          SizedBox(height: 1.85 * height.defaultButtonLength()),
          largeSizeButton(43, 2, 1.3, 1.3),
        ]),
      ]);

  // 上大ボタン
  Widget downLargeButtonWidget() =>
      Row(children: [
        SizedBox(width: 45.35 * height.defaultButtonLength()),
        Column(children: [
          SizedBox(height: 4.85 * height.defaultButtonLength()),
          largeSizeButton(45, 5, 1.3, 1.3),
        ]),
      ]);

  // 30秒チャレンジのスタートボタンの表示
  Widget startButtonView() =>
      TextButton(
        style: challengeStartStyle(width, _currentSeconds, _isChallengeStart),
        onPressed: () => (_isChallengeStart) ? _challengeStop(): _challengeStart(),
        child: challengeStartText(context, width, _currentSeconds, _isChallengeStart),
      );

  // 30秒チャレンジ後の結果画面
  Widget finishChallenge() =>
      Stack(alignment: Alignment.center, children: [
        SizedBox(width: width, height: height,),
        Column(children: [
          const Spacer(flex: 3),
          finishChallengeText(AppLocalizations.of(context)!.yourScore, 32),
          const SizedBox(height: 50),
          finishChallengeScore(_counter),
          const SizedBox(height: 50),
          finishChallengeText(_bestScore.finishBestScore(context, _counter), 24),
          const Spacer(flex: 1),
          backButton(),
          const Spacer(flex: 3),
        ]),
      ]);

  //　完全再現1000のボタンに戻るボタン
  Widget backButton() =>
      ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(whiteColor)),
        child: return1000Buttons(context),
        onPressed: () => _back1000Buttons(),
      );


  /// <setStateに関する関数>

  //ボタンを選択する
  _buttonSelected(int i, int j) async {
    if (!_isSelectedButtonsList[i][j] && isEnableButtonsList[i][j]) {
      if (!_isChallengeStart) {
        selectButton.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      }
      setState(() {
        _counter++;
        _isSelectedButtonsList[i][j] = true;
      });
    }
  }

  //ボタンを解除する
  _buttonDeSelected(int i, int j) async {
    if (_isSelectedButtonsList[i][j] && isEnableButtonsList[i][j]) {
      if (!_isChallengeStart) {
        cancelButton.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      }
      setState(() {
        _counter--;
        _isSelectedButtonsList[i][j] = false;
      });
    }
  }

  // 30秒チャレンジスタート
  _challengeStart() async {
    _startBeforeCountdown();
    _beforeCountdown(3);
    await Future.delayed(const Duration(milliseconds: 500))
        .then((_) async => setState(() => _isBeforeCount = false));
    await Future.delayed(const Duration(milliseconds: 500))
        .then((_) async => _beforeCountdown(2));
    await Future.delayed(const Duration(milliseconds: 500))
        .then((_) async => setState(() => _isBeforeCount = false));
    await Future.delayed(const Duration(milliseconds: 500))
        .then((_) async => _beforeCountdown(1));
    await Future.delayed(const Duration(milliseconds: 500))
        .then((_) async => setState(() => _isBeforeCount = false));
    await Future.delayed(const Duration(milliseconds: 500))
        .then((_) async => _finishBeforeCountdown());
  }

  //30秒チャレンジスタート前のカウントダウン表示の準備
  _startBeforeCountdown() {
    setState(() {
      _counter = 0;
      _isSelectedButtonsList = columnMax.listListAllFalse(rowMax);
      _isDarkBack = true;
    });
  }

  //30秒チャレンジスタート前のカウントダウン表示
  _beforeCountdown(int i) {
    countdown.playAudio();
    setState(() {
      _isBeforeCount = true;
      _beforeCount = i;
    });
  }

  // カウントダウンタイマー
  Timer countTimer() {
    return Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        if (_currentSeconds < 1) {
          if (_counter >= _bestScore) bestScoreSound.playAudio();
          _challengeFinish();
        } else {
          setState(() => _currentSeconds = _currentSeconds - 1);
          if (_currentSeconds < 4) countdown.playAudio();
          if (_currentSeconds == 0) countdownFinish.playAudio();
        }
      },
    );
  }

  //30秒チャレンジスタート前のカウントダウン表示終了
  _finishBeforeCountdown() {
    countdownFinish.playAudio();
    setState(() {
      _isDarkBack = false;
      _isChallengeStart = true;
      _currentSeconds = 30;
    });
    _timer.cancel();
    _timer = countTimer();
  }

  // 30秒チャレンジのストップ
  _challengeStop() {
    setState(() {
      _counter = 0;
      _isSelectedButtonsList = columnMax.listListAllFalse(rowMax);
      _isChallengeStart = false;
      _currentSeconds = 0;
    });
    _timer.cancel();
  }

  // 30秒チャレンジの終了
  _challengeFinish() {
    _counter.saveBestScore(_bestScore);
    setState(() {
      _isChallengeStart = false;
      _isDarkBack = true;
      _isChallengeFinish = true;
    });
    _timer.cancel();
  }

  // ベストスコアの取得
  void getBestScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _bestScore = prefs.getInt('bestScore') ?? 0);
  }

  // 完全再現1000のボタンに戻る
  _back1000Buttons() {
    setState(() {
      "Your Score: $_counter".debugPrint();
      "Best score: $_bestScore".debugPrint();
      _isDarkBack = false;
      _isChallengeFinish = false;
      _bestScore = _counter.setBestScore(_bestScore);

      //インタースティシャル広告
      // if (_bestScore != _counter && _counter % 2 == 1) {
      //   AdmobService().createInterstitialAd();
      // }
    });
  }
}