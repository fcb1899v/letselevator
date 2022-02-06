import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'many_buttons_extension.dart';


const String beforeCountImage = "assets/images/normalMode/circle.png";
const Color lampColor = Color.fromRGBO(247, 178, 73, 1);
const Color darkBlackColor = Colors.black;


Widget real1000ButtonsTitle(BuildContext context, double width, String realTitleImage) =>
    SizedBox(
      height: width.title1000Height(600),
      child: Image(image: AssetImage(realTitleImage)),
    );

Widget challengeTitleText(BuildContext context, double width) =>
    Container(
      width: width.title1000Height(400) * 2.25,
      height: 10,
      margin: const EdgeInsets.only(bottom: 5),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(AppLocalizations.of(context)!.challenge,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );

Widget challengeStartText(BuildContext context, int number, bool flag) =>
    Container(
      padding: EdgeInsets.only(
          top: (flag) ? 6: 4,
          left: (flag) ? 9: 3,
          right: 4,
          bottom: (flag) ? 2: 4
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(number.startButtonText(context, flag),
          style: TextStyle(
            fontFamily: (flag) ? "teleIndicators": null,
            fontSize: 40,
            fontWeight: (flag) ? FontWeight.normal: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );

ButtonStyle challengeStartStyle(int number, bool flag) =>
    ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        number.startButtonColor(flag)
      ),
      padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.only(left: 8, right: 8)
      ),
    );

Widget bestScoreText(BuildContext context, double width, int bestScore) =>
    Container(
      width: width.title1000Height(400) * 3,
      height: 10,
      margin: const EdgeInsets.only(bottom: 5),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(bestScore.bestScore(context),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );

Widget countDisplay(double width, int counter) {
  return Container(
    width: width.title1000Height(400) * 3,
    height: width.title1000Height(400),
    color: darkBlackColor,
    padding: const EdgeInsets.only(top: 6, bottom: 3, left: 10, right: 6),
    child: FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(counter.countNumber(),
        style: const TextStyle(
          color: lampColor,
          fontFamily: "teleIndicators",
          fontSize: 48,
        ),
      ),
    ),
  );
}

Widget eachButtonImage(int i, int j, double height, String image) =>
    Container(
      width: height.buttonWidth(i, j),
      height: height.buttonHeight(),
      padding: EdgeInsets.all(height.paddingSize()),
      alignment: Alignment.center,
      child: Image(image: AssetImage(image)),
    );

Widget countNumber(double width, double height, int i) =>
    Stack(
    alignment: Alignment.center,
    children: [
      SizedBox(
        width: width,
        height: height,
      ),
      SizedBox(
        width: width * 0.4,
        height: width * 0.4,
        child: const FittedBox(
          fit: BoxFit.fitWidth,
          child: Image(image: AssetImage(beforeCountImage)),
        ),
      ),
      Text("$i",
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: width * 0.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    ]
  );

Text finishChallengeText(String text, double fontSize) =>
    Text(text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      )
    );

Text finishChallengeScore(int counter) =>
    Text(counter.countNumber(),
      style: const TextStyle(
        color: lampColor,
        fontFamily: "teleIndicators",
        fontSize: 120,
      ),
    );

Text return1000Buttons(String text) =>
    Text(text,
      style: const TextStyle(
        color: blackColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );

