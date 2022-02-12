import 'package:flutter/material.dart';

//アプリ名
const String appTitle = "LETS ELEVATOR";

//最高階と最低階
const int min = -4;
const int max = 163;

// ボタンの階数
const List<int> floors1 = [14, 100, 154, 163];
const List<int> floors2 = [5, 6, 7, 8];
const List<int> floors3 = [1, 2, 3, 4];
const List<int> floors4 = [-1, -2, -3, -4];

// 停止する：true・しない：false
const List<bool> isFloors1 = [true, true, true, true];
const List<bool> isFloors2 = [false, true, true, true];
const List<bool> isFloors3 = [true, true, true, true];
const List<bool> isFloors4 = [true, true, true, true];

// バイブレーション
const int vibTime = 200;
const int vibAmp = 128;

// エレベータードアの開閉時間
const int openTime = 10;
const int waitTime = 3;

// エレベータードアの状態
final List<bool> openedState = [true, false, false, false];
final List<bool> closedState = [false, true, false, false];
final List<bool> openingState = [false, false, true, false];
final List<bool> closingState = [false, false, false, true];

// エレベーターボタンの状態
final List<bool> noPressed = [false, false, false];
final List<bool> pressedOpen = [true, false, false];
final List<bool> pressedClose = [false, true, false];
final List<bool> pressedCall = [false, false, true];
final List<bool> allPressed = [true, true, true];

// 1000のボタン
const int rowMax = 99;
const int columnMax = 11;
const List<int> wideList = [0, 7, 7, 4, 0, 3, 7, 1, 6, 3, 1];

//Audio
const String countdown = "audios/pon.mp3";
const String countdownFinish = "audios/chan.mp3";
const String bestScoreSound = "audios/jajan.mp3";
const String selectButton = "audios/kako.mp3";
const String cancelButton = "audios/hi.mp3";
const String changeModeSound = "audios/popi.mp3";
const String changePageSound = "audios/tetete.mp3";
const String callSound = "audios/call.mp3";

//Font
const String numberFont = "teleIndicators";

//Image Folder
const String assetsCommon = "assets/images/common/";
const String assetsNormal = "assets/images/normalMode/";
const String assets1000 = "assets/images/1000Mode/";
const String assetsRealOn = "assets/images/realOn/";
const String assetsRealOff = "assets/images/realOff/";

//Image File
const String upArrow = "${assetsCommon}up.png";
const String downArrow = "${assetsCommon}down.png";
const String buttonChan = "${assetsCommon}button.png";
const String pressedButtonChan = "${assetsCommon}pButton.png";
const String shimadaImage = "${assetsCommon}shimada.png";
const String transpImage = "${assetsCommon}transparent.png";
const String realTitleImage = "${assetsCommon}title1000Buttons.png";

const String beforeCountImage = "${assetsNormal}circle.png";
const String circleButton = "${assetsNormal}circle.png";
const String pressedCircle = "${assetsNormal}pressedCircle.png";
const String openButton = "${assetsNormal}open.png";
const String pressedOpenButton = "${assetsNormal}pressedOpen.png";
const String closeButton = "${assetsNormal}close.png";
const String pressedCloseButton = "${assetsNormal}pressedClose.png";
const String alertButton = "${assetsNormal}phone.png";
const String pressedAlertButton = "${assetsNormal}pressedPhone.png";

const String shimadaOpen = "${assets1000}sOpen.png";
const String pressedShimadaOpen = "${assets1000}sPressedOpen.png";
const String shimadaClose = "${assets1000}sClose.png";
const String pressedShimadaClose = "${assets1000}sPressedClose.png";
const String shimadaAlert = "${assets1000}sPhone.png";
const String pressedShimadaAlert = "${assets1000}sPressedPhone.png";

//String
const String bestScoreKey = 'bestScore';
const String nextString = "Next Floor: ";

//Web Page
const String landingPageJa = "https://nakajimamasao-appstudio.web.app/ja/letselevator.html";
const String landingPageEn = "https://nakajimamasao-appstudio.web.app/letselevator.html";
const String shimadaPage = "https://www.shimada.cc/";
const String timeoutArticle = "https://www.timeout.com/tokyo/things-to-do/shimada-electric-manufacturing-company";
const String fnnArticle = "https://www.fnn.jp/articles/-/257115";
const String twitterPage = "https://twitter.com/shimax_hachioji/status/1450698944393007107";

// Color
const Color lampColor = Color.fromRGBO(247, 178, 73, 1);
const Color yellowColor = Color.fromRGBO(255, 234, 0, 1);
const Color greenColor = Color.fromRGBO(105, 184, 0, 1);
const Color redColor = Color.fromRGBO(255, 0, 0, 1);
const Color blackColor = Color.fromRGBO(56, 54, 53, 1);
const Color transpBlackColor = Color.fromRGBO(0, 0, 0, 0.8);
const Color darkBlackColor = Colors.black;
const Color whiteColor = Colors.white;
const Color transpColor = Colors.transparent;
const Color metalColor1 = Colors.black12;
const Color metalColor2 = Colors.white24;
const Color metalColor3 = Colors.white54;
const Color metalColor4 = Colors.white10;
const Color metalColor5 = Colors.black12;
const List<Color> metalColor = [metalColor1, metalColor2, metalColor3, metalColor4, metalColor5];
const List<double> metalSort = [0.1, 0.3, 0.4, 0.7, 0.9];

//＜島田電機の電球色lampColor＞
// 島田電機の電球色 → F7B249
// Red = F7 = 247
// Green = B2 = 178
// Blue = 49 = 73

//＜色温度から算出する電球色lampColor＞
// Temperature = 3000 K → FFB16E
// Red = 255 = FF
// Green = 99.47080 * Ln(30) - 161.11957 = 177 = B1
// Blue = 138.51773 * Ln(30-10) - 305.04480 = 110 = 6E
