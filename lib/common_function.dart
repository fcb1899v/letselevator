import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:games_services/games_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'extension.dart';
import 'main.dart';

/// App Tracking Transparency
Future<void> initPlugin(BuildContext context) async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined && context.mounted) {
    await showCupertinoDialog(context: context, builder: (context) => CupertinoAlertDialog(
      title: Text(context.letsElevator()),
      content: Text(context.thisApp()),
      actions: [
        CupertinoDialogAction(
          child: const Text('OK', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ));
    await Future.delayed(const Duration(milliseconds: 200));
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

///LifecycleEventHandler
class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({required this.resumeCallBack, required this.suspendingCallBack});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        resumeCallBack();
        break;
      case AppLifecycleState.paused:
        suspendingCallBack();
        break;
      default:
        break;
    }
  }
}

///Signing in to Game Services
gamesSignIn() async {
  try {
    await GamesServices.signIn();
    final isSignedIn = await GamesServices.isSignedIn;
    'Success to sign in to game services: $isSignedIn'.debugPrint();
  } catch (e) {
    'Fail to sign in to game services: $e'.debugPrint();
  }
}

///Submitting games score
gamesSubmitScore(int value) async {
  if (!(await GamesServices.isSignedIn)) await gamesSignIn();
  if (await GamesServices.isSignedIn) {
    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: dotenv.get("ANDROID_LEADERBOARD_ID"),
          iOSLeaderboardID: dotenv.get("IOS_LEADERBOARD_ID"),
          value: value,
        ),
      );
      "Success submitting leaderboard: $value".debugPrint();
    } catch (e) {
      'Error submitting score: $e'.debugPrint();
    }
  }
}

///Showing games leaderboards
gamesShowLeaderboard() async {
  if (!(await GamesServices.isSignedIn)) await gamesSignIn();
  if (await GamesServices.isSignedIn) {
    try {
      await GamesServices.showLeaderboards(
        androidLeaderboardID: dotenv.get("ANDROID_LEADERBOARD_ID"),
        iOSLeaderboardID: dotenv.get("IOS_LEADERBOARD_ID")
      );
      "Success showing leaderboard".debugPrint();
    } catch (e) {
      'Error showing leaderboards: $e'.debugPrint();
    }
  }
}

///Get best score games leaderboards
Future<int> getBestScore() async {
  int gamesBestScore;
  if (!(await GamesServices.isSignedIn)) await gamesSignIn();
  if (await GamesServices.isSignedIn) {
    try {
      gamesBestScore = await GamesServices.getPlayerScore(
        androidLeaderboardID: dotenv.get("ANDROID_LEADERBOARD_ID"),
        iOSLeaderboardID: dotenv.get("IOS_LEADERBOARD_ID"),
      ) ?? 0;
      "gamesBestScore: $gamesBestScore".debugPrint();
    } catch(e) {
      "gamesBestScore: 0: Fail to get".debugPrint();
      gamesBestScore = 0;
    }
  } else {
    "gamesBestScore: 0: Can't sign in".debugPrint();
    gamesBestScore = 0;
  }
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final prefBestScore = prefs.getInt('bestScore') ?? 0;
  "prefBestScore: $prefBestScore".debugPrint();
  if (prefBestScore >= gamesBestScore) {
    if (!isTest && gamesBestScore != 0) gamesSubmitScore(prefBestScore);
    "bestScore: $prefBestScore".debugPrint();
    return prefBestScore;
  } else {
    if (!isTest) await "pointKey".setSharedPrefInt(prefs, gamesBestScore);
    "bestScore: $gamesBestScore".debugPrint();
    return gamesBestScore;
  }
}
