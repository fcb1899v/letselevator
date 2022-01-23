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
  final List<List<bool>> isEnableButtonsList = List.generate(
      99, (i) => List.generate(11, (j) => j.ableButtonFlag(i))
  );
  final int vibTime = 100;
  final int vibAmp = 128;

  final String realTitleImage = "assets/images/common/title1000Buttons.jpg";
  final String buttonImage = "assets/images/common/button.png";
  final String ponAudio = "audios/pon.mp3";
  final String teteteAudio = "audios/tetete.mp3";

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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        height: height,
        width: width,
        decoration: metalDecoration(),
        child: Column(
          children: <Widget>[
            const Spacer(flex: 3),
            titleButtonsView(height),
            const Spacer(flex: 1),
            buttonsView(height),
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
    );
  }

  Widget titleButtonsView(double height) {
    return SizedBox(
      height: height.title1000Height(),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Image(image: AssetImage(realTitleImage)),
        ]
      ),
    );
  }

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

  Widget eachButton(int i, int j, double height) {
    return Container(
      width: height.buttonWidth(i, j),
      height: height.buttonHeight(),
      padding: EdgeInsets.all(height.paddingSize()),
      alignment: Alignment.center,
      child: ElevatedButton(
        style: transparentButtonStyle(),
        child: Image(
          image: AssetImage(
            isSelectedButtonsList.buttonBackground(i, j, isEnableButtonsList)
          ),
        ),
        onPressed: () {
          if (isEnableButtonsList[i][j]) _buttonSelected(i, j);
        },
      ),
    );
  }

  Widget largeSizeButton(int i, int j, double hR, double vR, double height) {
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

  //ボタンを選択または解除する
  _buttonSelected(int i, int j) async {
    ponAudio.playAudio();
    Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
    setState(() {
      isSelectedButtonsList[i][j] = isSelectedButtonsList[i][j].reverse();
    });
  }

  Widget shimadaSpeedDial(double width) {
    return SizedBox(width: 50, height: 50,
      child: Stack(
        children: [
          Image(image: AssetImage(buttonImage)),
          SpeedDial(
            backgroundColor: Colors.transparent,
            overlayColor: const Color.fromRGBO(56, 54, 53, 1),
            spaceBetweenChildren: 20,
            children: [
              speedDialChildChangePage(width),
              speedDialChildToLink(width,
                CupertinoIcons.info,
                AppLocalizations.of(context)!.buttons,
                Localizations.localeOf(context).languageCode.articleLink(),
              ),
              speedDialChildToLink(width,
                CupertinoIcons.info,
                AppLocalizations.of(context)!.shimada,
                Localizations.localeOf(context).languageCode.shimadaLink(),
              ),
              speedDialChildToLink(width,
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
        AdmobService().createInterstitialAd();
      },
    );
  }
}