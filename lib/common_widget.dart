import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'constant.dart';
import 'extension.dart';

SizedBox menuButton(BuildContext context, bool isHome, bool isShimada, int i) => SizedBox(
  width: context.widthResponsible() / 3,
  height: context.widthResponsible() / 3,
  child: Stack(
    alignment: Alignment.center,
    children: [
      Image.asset(squareButton),
      Text(context.menuTitles(isHome, isShimada)[i],
        textAlign: TextAlign.center,
        style: TextStyle(
          color: whiteColor,
          fontWeight: FontWeight.bold,
          fontSize: context.menuListFontSize(),
        ),
      ),
    ]
  ),
);