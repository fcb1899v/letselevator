import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

const String landingPageJa = "https://nakajimamasao-appstudio.web.app/ja/letselevator.html";
const String landingPageEn = "https://nakajimamasao-appstudio.web.app/letselevator.html";
const String shimadaPage = "https://www.shimada.cc/";
const String timeoutArticle = "https://www.timeout.com/tokyo/things-to-do/shimada-electric-manufacturing-company";
const String fnnArticle = "https://www.fnn.jp/articles/-/257115";
const String twitterPage = "https://twitter.com/shimax_hachioji/status/1450698944393007107";

extension StringExt on String {

  void debugPrint() {
    if (kDebugMode) print(this);
  }

  void pushPage(BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(this, (_) => false);

  void playAudio() {
    debugPrint();
    AudioCache().play(this);
  }

  String ttsLang() =>
      (this != "en") ? this: "en";

  Future<void> speakText(BuildContext context) async {
    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage(Localizations.localeOf(context).languageCode.ttsLang());
    flutterTts.setSpeechRate((Platform.isAndroid) ? 0.55: 0.5);
    debugPrint();
    await flutterTts.speak(this);
  }

  String elevatorLink() =>
      (this == "ja") ? landingPageJa: landingPageEn;
  String shimadaLink() =>
      (this == "ja") ? shimadaPage: timeoutArticle;
  String articleLink() =>
      (this == "ja") ? fnnArticle: twitterPage;
}

extension BoolExt on bool {

  String changeModeLabel(BuildContext context) => (this) ?
      AppLocalizations.of(context)!.normalMode:
      AppLocalizations.of(context)!.buttonsMode;

  bool reverse() => (this) ? false: true;
}