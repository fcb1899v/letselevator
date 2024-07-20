import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'common_function.dart';
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
      pressedMenu();
      if (i == 0) {
        ref.read(isShimadaProvider.notifier).update((state) => !state);
        if (!isHome) "/h".pushPage(context);
      } else if (i == 1) {
        if (isHome) {
          ref.read(isShimadaProvider.notifier).update((state) => true);
          (isHome ? "/r": "/h").pushPage(context);
        } else {
          await gamesShowLeaderboard();
        }
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
          const Spacer(flex: 4),
          ///App Logo
          SizedBox(
            width: context.menuTitleWidth(),
            child: Image.asset(appLogo),
          ),
          const Spacer(flex: 2),
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
          ///Menu  Button
          Column(children: context.menuTitles(isHome, isShimada).asMap().entries.map((row) => Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: row.value.asMap().entries.map((col) => Row(children: [
                GestureDetector(
                  onTap: () =>  pressedMenuLink(2 * row.key + col.key),
                  child: SizedBox(
                    width: context.menuButtonSize(),
                    height: context.menuButtonSize(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(squareButton),
                        Text(context.menuTitles(isHome, isShimada)[row.key][col.key],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: context.menuListFontSize(),
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
                if (col.key == 0) SizedBox(width: context.buttonMargin()),
              ])).toList(),
            ),
            if (row.key == 0) SizedBox(height: context.buttonMargin()),
          ])).toList()),
          const Spacer(flex: 2),
          ///Menu Links
          BottomNavigationBar(
            items: List<BottomNavigationBarItem>.generate(context.linkLogos().length, (i) =>
              BottomNavigationBarItem(
                icon: Container(
                  margin: EdgeInsets.only(
                    top: context.linksMargin(),
                    bottom: context.linksTitleMargin()
                  ),
                  width: context.linksLogoWidth(),
                  height: context.linksLogoHeight(),
                  child: Image.asset(context.linkLogos()[i]),
                ),
                label: context.linkTitles()[i],
              ),
            ),
            currentIndex: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (i) => launchUrl(Uri.parse(context.linkLinks()[i])),
            elevation: 0,
            selectedItemColor: lampColor,
            unselectedItemColor: lampColor,
            selectedFontSize: context.linksTitleSize(),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedFontSize: context.linksTitleSize(),
            backgroundColor: blackColor,
          ),
          Container(
            padding: EdgeInsets.only(top: context.linksMargin()),
            color: blackColor,
            child: Row(children: [
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
          ),
        ]),
      ),
    );
  }
}