import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

extension StringExt on String {

  void debugPrint() {
    if (kDebugMode) {
      print(this);
    }
  }

  void pushPage(BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(this, (_) => false);

  Future<void> speakText(BuildContext context) async {
    final thisLang = Localizations.localeOf(context).languageCode;
    final lang = (thisLang == "ja") ? "ja": (thisLang == "ko") ? "ko": "en";
    final speed = (Platform.isAndroid) ? 0.55: 0.5;
    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage(lang);
    flutterTts.setSpeechRate(speed);
    debugPrint();
    await flutterTts.speak(this);
  }

  void playAudio() {
    debugPrint();
    AudioCache().play(this);
  }

  String elevatorLink() =>
      (this == "ja") ?
      "https://nakajimamasao-appstudio.web.app/ja/letselevator.html":
      "https://nakajimamasao-appstudio.web.app/letselevator.html";

  String shimadaLink() =>
      (this == "ja") ?
      "https://www.shimada.cc/":
      "https://www.timeout.com/tokyo/things-to-do/shimada-electric-manufacturing-company";

  String articleLink() =>
      (this == "ja") ?
      "https://www.fnn.jp/articles/-/257115":
      "https://twitter.com/shimax_hachioji/status/1450698944393007107";
}

extension BoolExt on bool {

  String changeModeLabel(BuildContext context) =>
      (this) ? AppLocalizations.of(context)!.normalMode:
      AppLocalizations.of(context)!.buttonsMode;

  bool reverse() =>
      (this) ? false: true;
}