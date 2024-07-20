import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'extension.dart';

class AdInterstitialWidget extends HookWidget {
  const AdInterstitialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final adLoaded = useState(false);
    final adFailedLoading = useState(false);
    final interstitialAd = useState<InterstitialAd?>(null);
    final numAttemptLoad = useState(0);

    // バナー広告ID
    String interstitialUnitId() =>
        (!kDebugMode && Platform.isIOS) ? dotenv.get("IOS_INTERSTITIAL_UNIT_ID"):
        (!kDebugMode && Platform.isAndroid) ? dotenv.get("ANDROID_INTERSTITIAL_UNIT_ID"):
        (Platform.isIOS) ? dotenv.get("IOS_INTERSTITIAL_TEST_ID"):
        dotenv.get("ANDROID_INTERSTITIAL_UNIT_ID");

    Future<void> createInterstitialAd() async {
      InterstitialAd.load(
        adUnitId: interstitialUnitId(),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
        // 広告が正常にロードされたとき
          onAdLoaded: (InterstitialAd ad) async {
            'ad loaded'.debugPrint();
            interstitialAd.value = ad;
            numAttemptLoad.value = 0;

            if (interstitialAd.value == null) {
              'Warning: attempt to show interstitial before loaded.'.debugPrint();
              return;
            }
            interstitialAd.value!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (InterstitialAd ad) {
                "ad on AdShowedFullscreen".debugPrint();
              },
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                "ad Disposed".debugPrint();
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                '$ad OnAdFailed $error'.debugPrint();
                ad.dispose();
                createInterstitialAd();
              },
            );
            // インタースティシャル広告の表示
            await interstitialAd.value!.show();
            interstitialAd.value = null;
          },
          // 広告のロードが失敗したとき
          onAdFailedToLoad: (LoadAdError error) {
            interstitialAd.value = null;
            numAttemptLoad.value++;
            if (numAttemptLoad.value <= 2) {
              // 再度広告をロード
              createInterstitialAd();
            }
          },
        ),
      );
    }

    useEffect(() {
      return () {
        interstitialAd.value?.dispose(); // アンマウント時に広告を破棄する
      };
    }, []);

    return SizedBox(
      width: context.admobWidth(),
      height: context.admobHeight(),
      // child: (adLoaded.value) ? AdWidget(ad: interstitialAd.value!): null,
    );
  }
}