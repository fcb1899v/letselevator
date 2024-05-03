import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'common_widget.dart';
import 'extension.dart';
import 'constant.dart';
import 'admob_banner.dart';
import 'main.dart';

class MyMenuPage extends HookConsumerWidget {
  final bool isHome;
  const MyMenuPage({super.key, required this.isHome});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final isShimada = ref.watch(isShimadaProvider);
    final isMenu = ref.watch(isMenuProvider);
    final isSoundOn = useState(true);
    final AudioPlayer audioPlayer = AudioPlayer();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await audioPlayer.setReleaseMode(ReleaseMode.loop);
        await audioPlayer.setVolume(0.5);
      });
      return null;
    }, []);

    ///Pressed menu button action
    pressedMenu() async {
      selectButton.playAudio(audioPlayer, isSoundOn.value);
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      ref.read(isMenuProvider.notifier).state = false;
    }

    ///Pressed menu links action
    pressedMenuLink(int i) async {
      await pressedMenu();
      if (i == 0) {
        ref.read(isShimadaProvider.notifier).update((state) => !state);
      } else if (i == 1) {
        ref.read(isShimadaProvider.notifier).update((state) => false);
        (isHome ? "/r": "/h").pushPage(context);
      } else if (i == 2) {
        launchUrl(Uri.parse(context.shimaxLink()));
      } else if (i == 3) {
        launchUrl(Uri.parse(context.articleLink()));
      }
    }
    // GamesServices.signIn(shouldEnableSavedGame: true);

    ///Menu
    return Scaffold(
      backgroundColor: transpWhiteColor,
      body: SizedBox(
        width: context.width(),
        height: context.height(),
        child: Column(children: [
          const Spacer(flex: 2),
          ///App Logo
          SizedBox(
            width: context.menuTitleWidth(),
            child: Image.asset(appLogo),
          ),
          const Spacer(flex: 1),
          ///Menu Title
          Text(context.menu(),
            style: TextStyle(
              color: blackColor,
              fontSize: context.menuTitleFontSize(),
              fontWeight: FontWeight.bold,
              fontFamily: menuFont,
            ),
          ),
          const Spacer(flex: 1),
          ///Mode Change
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              if (isHome) GestureDetector(
                onTap: () async => pressedMenuLink(0),
                child: menuButton(context, isHome, isShimada, 0),
              ),
              if (isHome) SizedBox(width: context.menuButtonMargin()),
              GestureDetector(
                onTap: () async => pressedMenuLink(1),
                child: menuButton(context, isHome, isShimada, 1)
              ),
              const Spacer(flex: 1),
            ],
          ),
          SizedBox(height: context.menuButtonMargin()),
          ///Menu Links
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              GestureDetector(
                onTap: () async => pressedMenuLink(2),
                child: menuButton(context, isHome, isShimada, 2),
              ),
              SizedBox(width: context.menuButtonMargin()),
              GestureDetector(
                onTap: () async => pressedMenuLink(3),
                child: menuButton(context, isHome, isShimada, 3),
              ),
              const Spacer(flex: 1),
            ],
          ),
          const Spacer(flex: 1),
          ///Sns Links
          Row(children: [
            const Spacer(flex: 1),
            ...List.generate(context.snsIcons().length, (i) => Container(
              width: context.menuSnsLogoSize(),
              height: context.menuSnsLogoSize(),
              margin: EdgeInsets.symmetric(horizontal: context.menuSnsLogoMargin()),
              child: GestureDetector(
                onTap: () {
                  pressedMenu();
                  launchUrl(Uri.parse(context.snsLinks()[i]));
                },
                child: Image.asset(context.snsIcons()[i]),
              ),
            )),
            const Spacer(flex: 1),
          ]),
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
      ),
    );
  }
}