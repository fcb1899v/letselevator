import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vibration/vibration.dart';
import 'common_widget.dart';
import 'many_buttons_extension.dart';
import 'common_extension.dart';
import 'admob.dart';

class ManyButtonsBody extends StatefulWidget {
  const ManyButtonsBody({Key? key}) : super(key: key);
  @override
  State<ManyButtonsBody> createState() => _ManyButtonsBodyState();
}

class _ManyButtonsBodyState extends State<ManyButtonsBody> {

  final int rowMax = 99;
  final int columnMax = 11;
  final List<int> wideList = [0, 7, 7, 4, 0, 3, 7, 1, 6, 3, 1];
  final List<List<bool>> isAbleButtonsList = List.generate(
      99, (i) => List.generate(11, (j) => j.ableButtonFlag(i))
  );
  final int vibTime = 100;
  final int vibAmp = 128;
  final _controllerX = ScrollController();
  late List<List<bool>> isSelectedButtonsList;
  late BannerAd myBanner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => initPlugin());
    setState(() {
      isSelectedButtonsList = List.generate(
        rowMax, (_) => List.generate(columnMax, (_) => false)
      );
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
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: metalDecoration(),
        child: Column(
          children: <Widget>[
            const Spacer(flex: 3),
            titleButtonsView(),
            const Spacer(flex: 1),
            buttonsView(),
            const Spacer(flex: 1),
            Row(
              children: [
                const Spacer(),
                adMobBannerWidget(context, myBanner),
                const Spacer(),
                shimadaSpeedDial(),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget titleButtonsView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height.title1000Height(),
      child: Row(
        children: const [
          SizedBox(width: 20),
          Image(image: AssetImage("images/title1000Buttons.jpg")),
        ]
      )
    );
  }

  Widget buttonsView() {
    List<Widget> _listColumn = [];
    for(int j = 0; j < columnMax; j++) {
      List<Widget> _listRow = [];
      for(int i = 0; i < rowMax - wideList[j]; i++) {
        _listRow.add(eachButton(i, j));
      }
      _listColumn.add(Row(children: _listRow,));
    }
    return SingleChildScrollView(
      controller: _controllerX,
      scrollDirection: Axis.horizontal,
      child: Stack(
        children: [
          Column(children: _listColumn,),
          largeButtonsList(),
        ],
      )
    );
  }

  Widget largeButtonsList() {
    final height = MediaQuery.of(context).size.height;
    return Row(
      children: [
        SizedBox(width: 13 * height.defaultButtonLength()),
        doubleSizeButton(),
        SizedBox(width: 27 * height.defaultButtonLength()),
        longSizeButton(),
        SizedBox(width: 56 * height.defaultButtonLength()),
      ],
    );
  }

  Widget eachButton(int i, int j) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: height.buttonWidth(i, j),
      height: height.buttonHeight(),
      padding: EdgeInsets.all(height.paddingSize()),
      alignment: Alignment.center,
      child: ElevatedButton(
        style: transparentButtonStyle(),
        child: Image(
          image: AssetImage(
            isSelectedButtonsList.buttonBackground(i, j, isAbleButtonsList)
          ),
        ),
        onPressed: () {
          if (isAbleButtonsList[i][j]) _buttonSelected(i, j);
        },
      ),
    );
  }

  Widget largeSizeButton(int i, int j, double hR, double vR) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: height.largeButtonWidth(hR),
      height: height.largeButtonHeight(vR),
      padding: EdgeInsets.all(height.paddingSize()),
      alignment: Alignment.center,
      child: ElevatedButton(
        style: transparentButtonStyle(),
        child: Image(
          image: AssetImage(
            isSelectedButtonsList.buttonImage(i, j)
          ),
        ),
        onPressed: () => _buttonSelected(i, j),
      ),
    );
  }

  Widget doubleSizeButton() {
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(height: 6 * height.defaultButtonLength()),
        largeSizeButton(13, 6, 2.0, 2.0),
        SizedBox(height: 3 * height.defaultButtonLength()),
      ]
    );
  }

  Widget longSizeButton() {
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(height: 2 * height.defaultButtonLength()),
        largeSizeButton(42, 3, 1.0, 3.0),
        SizedBox(height: 6 * height.defaultButtonLength()),
      ]
    );
  }

  //ボタンを選択または解除する
  _buttonSelected(int i, int j) async {
    //"pon.mp3".playAudio();
    Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
    setState(() {
      isSelectedButtonsList[i][j] = isSelectedButtonsList[i][j].reverse();
    });
  }

  Widget shimadaSpeedDial() {
    return SizedBox(width: 50, height: 50,
      child: Stack(
        children: [
          const Image(image: AssetImage("images/button.png")),
          SpeedDial(
            backgroundColor: Colors.transparent,
            overlayColor: const Color.fromRGBO(56, 54, 53, 1),
            spaceBetweenChildren: 20,
            children: [
              speedDialChildChangePage(),
              speedDialChildToLink(context,
                CupertinoIcons.info,
                AppLocalizations.of(context)!.buttons,
                Localizations.localeOf(context).languageCode.articleLink(),
              ),
              speedDialChildToLink(context,
                CupertinoIcons.info,
                AppLocalizations.of(context)!.shimada,
                Localizations.localeOf(context).languageCode.shimadaLink(),
              ),
              speedDialChildToLink(context,
                CupertinoIcons.app,
                AppLocalizations.of(context)!.letsElevator,
                Localizations.localeOf(context).languageCode.elevatorLink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SpeedDialChild speedDialChildChangePage() {
    return SpeedDialChild(
      child: const Icon(CupertinoIcons.arrow_2_circlepath, size: 50,),
      label: AppLocalizations.of(context)!.elevatorMode,
      labelStyle: speedDialTextStyle(context),
      labelBackgroundColor: Colors.white,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      onTap: () async {
        "tetete.mp3".playAudio();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        "/h".pushPage(context);
        AdmobService().createInterstitialAd();
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