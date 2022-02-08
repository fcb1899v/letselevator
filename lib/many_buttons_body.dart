import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'common_extension.dart';
import 'common_widget.dart';
import 'many_buttons_extension.dart';
import 'many_buttons_widget.dart';
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

  late List<List<bool>> _isSelectedButtonsList;
  late BannerAd _myBanner;
  late bool _isDarkBack;
  late bool _isBeforeCount;
  late bool _isCountStart;
  late bool _isCountFinish;
  late int _beforeCount;
  late int _counter;
  late int _currentSeconds;
  late Timer _timer;
  late int _bestScore;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => initPlugin());
    setState(() {
      _isSelectedButtonsList = columnMax.listListAllFalse(rowMax);
      _myBanner = AdmobService().getBannerAd();
      _isDarkBack = false;
      _isBeforeCount = false;
      _isCountStart = false;
      _isCountFinish = false;
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
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        height: height,
        width: width,
        decoration: metalDecoration(),
        child: Stack(children: [
          Column(children: [
            const Spacer(flex: 3),
            Row(children: [
              const Spacer(flex: 1),
              real1000ButtonsTitle(context, width, realTitleImage),
              const Spacer(flex: 1),
              startButtonView(width),
              const Spacer(flex: 2),
              countDisplay(width, _counter),
              const Spacer(flex: 1),
            ]),
            const Spacer(flex: 1),
            buttonsView(height),
            const Spacer(flex: 1),
            Row(children: [
              const Spacer(),
              adMobBannerWidget(width, height, _myBanner),
              const Spacer(),
              shimadaSpeedDial(width),
              const Spacer(),
            ]),
          ]),
          if (_isDarkBack) darkBackground(width, height),
          if (_isBeforeCount) countNumber(width, height, _beforeCount),
          if (_isCountFinish) finishChallenge(width, height),
        ]),
      ),
    );
  }

  // ベストスコアの取得
  void getBestScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _bestScore = prefs.getInt('bestScore') ?? 0);
  }

  // カウントダウンタイマー
  Timer countTimer() {
    return Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        (_currentSeconds < 1) ? _challengeFinish():
          setState(() => _currentSeconds = _currentSeconds - 1);
      },
    );
  }

  // 30秒チャレンジスタート
  _challengeStart() async {
    setState(() {
      _counter = 0;
      _isSelectedButtonsList = columnMax.listListAllFalse(rowMax);
      _isDarkBack = true;
      _isBeforeCount = true;
      _beforeCount = 3;
    });
    await Future.delayed(const Duration(milliseconds: 500)).then((_) async {
      setState(() => _isBeforeCount = false);
    });
    await Future.delayed(const Duration(milliseconds: 500)).then((_) async {
      setState(() {
        _isBeforeCount = true;
        _beforeCount = 2;
      });
    });
    await Future.delayed(const Duration(milliseconds: 500)).then((_) async {
      setState(() => _isBeforeCount = false);
    });
    await Future.delayed(const Duration(milliseconds: 500)).then((_) async {
      setState(() {
        _isBeforeCount = true;
        _beforeCount = 1;
      });
    });
    await Future.delayed(const Duration(milliseconds: 500)).then((_) async {
      setState(() => _isBeforeCount = false);
    });
    await Future.delayed(const Duration(milliseconds: 500)).then((_) async {
      setState(() {
        _isDarkBack = false;
        _isCountStart = true;
        _currentSeconds = 30;
      });
      _timer.cancel();
      _timer = countTimer();
    });
  }

  // 30秒チャレンジストップ
  _challengeStop() {
    setState(() {
      _counter = 0;
      _isSelectedButtonsList = columnMax.listListAllFalse(rowMax);
      _isCountStart = false;
      _currentSeconds = 0;
    });
    _timer.cancel();
  }

  // 30秒チャレンジ終了
  _challengeFinish() {
    _counter.saveBestScore(_bestScore);
    setState(() {
      _isCountStart = false;
      _isDarkBack = true;
      _isCountFinish = true;
    });
    _timer.cancel();
  }

  // ボタンの効果音
  _playButtonAudio() {
    if (!_isCountStart) {
      ponAudio.playAudio();
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
    }
  }

  //ボタンを選択する
  _buttonSelected(int i, int j) async {
    if (!_isSelectedButtonsList[i][j] && isEnableButtonsList[i][j]) {
      _playButtonAudio();
      setState(() {
        _counter++;
        _isSelectedButtonsList[i][j] = true;
      });
    }
  }

  //ボタンを解除する
  _buttonDeSelected(int i, int j) async {
    if (_isSelectedButtonsList[i][j] && isEnableButtonsList[i][j]) {
      _playButtonAudio();
      setState(() {
        _counter--;
        _isSelectedButtonsList[i][j] = false;
      });
    }
  }

  //
  _back1000Buttons() {
    setState(() {
      "Your Score: $_counter".debugPrint();
      "Best score: $_bestScore".debugPrint();
      _isDarkBack = false;
      _isCountFinish = false;
      _bestScore = _counter.setBestScore(_bestScore);
      if (_bestScore != _counter && _counter % 2 == 1) {
        AdmobService().createInterstitialAd();
      }
    });
  }

  // 30秒チャレンジのスタートボタン
  Widget startButtonView(double width) =>
      TextButton(
        style: challengeStartStyle(width, _currentSeconds, _isCountStart),
        onPressed: () => (_isCountStart) ? _challengeStop(): _challengeStart(),
        child: challengeStartText(context, width, _currentSeconds, _isCountStart),
      );

  // 薄黒い透明背景を表示
  Widget darkBackground(double width, double height) =>
      Container(
        width: width,
        height: height,
        color: transpBlackColor,
        alignment: Alignment.center,
        child: null,
      );

  // 30秒チャレンジ開始前のカウントダウン
  Widget finishChallenge(double width, double height) =>
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: width,
            height: height,
          ),
          Column(
            children: [
              const Spacer(flex: 3),
              finishChallengeText(AppLocalizations.of(context)!.yourScore, 32),
              const SizedBox(height: 50),
              finishChallengeScore(_counter),
              const SizedBox(height: 50),
              finishChallengeText(_bestScore.finishBestScore(context, _counter), 24),
              const Spacer(flex: 1),
              backButton(),
              const Spacer(flex: 3),
            ],
          )
        ]
      );
  
  Widget buttonsView(double height) {
    List<Widget> _listColumn = [];
    for(int j = 0; j < columnMax; j++) {
      List<Widget> _listRow = [];
      for(int i = 0; i < rowMax - wideList[j]; i++) {
        _listRow.add(eachButton(i, j, height));
      }
      _listColumn.add(Row(children: _listRow,));
    }
    return SingleChildScrollView(
      controller: ScrollController(),
      scrollDirection: Axis.horizontal,
      child: Stack(
        children: [
          Column(children: _listColumn,),
          largeButtonsList(height),
        ],
      )
    );
  }

  Widget largeButtonsList(double height) {
    return Row(
      children: [
        SizedBox(width: 13 * height.defaultButtonLength()),
        doubleSizeButton(height),
        SizedBox(width: 27 * height.defaultButtonLength()),
        longSizeButton(height),
        SizedBox(width: 56 * height.defaultButtonLength()),
      ],
    );
  }

  Widget backButton() =>
    ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(whiteColor),
      ),
      onPressed: () => _back1000Buttons(),
      child: return1000Buttons(AppLocalizations.of(context)!.back),
    );


  Widget eachButton(int i, int j, double height) {
    return GestureDetector(
      onTap: () => _buttonSelected(i, j),
      onLongPress: () => _buttonDeSelected(i, j),
      onDoubleTap: () => _buttonDeSelected(i, j),
      child: eachButtonImage(i, j, height,
        _isSelectedButtonsList.buttonBackground(i, j, isEnableButtonsList)
      )
    );
  }

  Widget largeSizeButton(int i, int j, double hR, double vR, double height) {
    return GestureDetector(
      onTap: () => _buttonSelected(i, j),
      onLongPress: () => _buttonDeSelected(i, j),
      onDoubleTap: () => _buttonDeSelected(i, j),
      child: largeButtonImage(hR, vR, height,
        _isSelectedButtonsList.buttonImage(i, j)
      )
    );
  }

  Widget doubleSizeButton(double height) {
    return Column(
      children: [
        SizedBox(height: 6 * height.defaultButtonLength()),
        largeSizeButton(13, 6, 2.0, 2.0, height),
        SizedBox(height: 3 * height.defaultButtonLength()),
      ]
    );
  }

  Widget longSizeButton(double height) {
    return Column(
      children: [
        SizedBox(height: 2 * height.defaultButtonLength()),
        largeSizeButton(42, 3, 1.0, 3.0, height),
        SizedBox(height: 6 * height.defaultButtonLength()),
      ]
    );
  }

  Widget shimadaSpeedDial(double width) {
    return SizedBox(width: 50, height: 50,
      child: Stack(children: [
        const Image(image: AssetImage(buttonImage)),
        SpeedDial(
          backgroundColor: Colors.transparent,
          overlayColor: const Color.fromRGBO(56, 54, 53, 1),
          spaceBetweenChildren: 20,
          children: [
            speedDialChildChangePage(width),
            info1000Buttons(context, width),
            infoShimada(context, width),
            infoLetsElevator(context, width),
          ],
        ),
      ]),
    );
  }

  SpeedDialChild speedDialChildChangePage(double width) {
    return SpeedDialChild(
      child: const Icon(CupertinoIcons.arrow_2_circlepath, size: 50,),
      label: AppLocalizations.of(context)!.elevatorMode,
      labelStyle: speedDialTextStyle(width),
      labelBackgroundColor: Colors.white,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      onTap: () async {
        teteteAudio.playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        "/h".pushPage(context);
      },
    );
  }
}