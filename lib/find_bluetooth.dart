// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'admob.dart';
// import 'bluetooth_body.dart';
// import 'constant.dart';
// import 'common_extension.dart';
// import 'my_home_body.dart';
// import 'my_home_body.dart';
//
// class FindBluetooth extends StatefulWidget {
//   const FindBluetooth({Key? key}) : super(key: key);
//   @override
//   State<FindBluetooth> createState() => _FindBluetoothState();
// }
//
// class _FindBluetoothState extends State<FindBluetooth> {
//
//   late double width;
//   late double height;
//   late BannerAd myBanner;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
//     setState(() {
//       myBanner = AdmobService().getBannerAd();
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     "call didChangeDependencies".debugPrint();
//     super.didChangeDependencies();
//     setState((){
//       width = MediaQuery.of(context).size.width;
//       height = MediaQuery.of(context).size.height;
//     });
//     "width: $width, height: $height".debugPrint();
//   }
//
//   @override
//   void didUpdateWidget(oldWidget) {
//     "call didUpdateWidget".debugPrint();
//     super.didUpdateWidget(oldWidget);
//   }
//
//   @override
//   void deactivate() {
//     "call deactivate".debugPrint();
//     super.deactivate();
//   }
//
//   @override
//   void dispose() {
//     "call dispose".debugPrint();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey,
//       body: Container(width: width, height: height,
//         padding: const EdgeInsets.only(top: 30),
//         decoration: metalDecoration(),
//         child: Column(children: [
//           const SizedBox(height: 60), bluetoothTitle(),
//           const SizedBox(height: 40), Stack(children: [scanButton(), nextButton()]),
//           const Spacer(), Stack(children: [connectButton(), connectedButton()]),
//           const Spacer(),
//           Row(children: [
//             const Spacer(), adMobBannerWidget(width, height, myBanner),
//             const Spacer(), findBluetoothSpeedDial(),
//             const Spacer(),
//           ]),
//         ]),
//       ),
//     );
//   }
//
//   Widget bluetoothTitle() =>
//       SizedBox(width: (width < 500) ? width * 0.6: 300,
//         child: FittedBox(
//           fit: BoxFit.fitWidth,
//           child: Text(AppLocalizations.of(context)!.bluetoothTitle,
//             style: const TextStyle(
//               color: blackColor,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       );
//
//   Widget scanButton() =>
//       StreamBuilder<bool>(
//         stream: FlutterBlue.instance.isScanning,
//         initialData: false,
//         builder: (c, snapshot) => SizedBox(
//           width: (width < 500) ? width * 0.6: 300,
//           height: 50,
//           child: (snapshot.data != null) ? ElevatedButton(
//             style: ElevatedButton.styleFrom(primary: whiteColor),
//             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//               Icon((snapshot.data!) ?
//                 Icons.stop:
//                 Icons.search,
//                 size: 28,
//               ),
//               const SizedBox(width: 10),
//               Text((snapshot.data!) ?
//                 AppLocalizations.of(context)!.bluetoothStop:
//                 AppLocalizations.of(context)!.bluetoothSearch,
//                 style: const TextStyle(
//                   color: blackColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//               const SizedBox(width: 20),
//             ]),
//             onPressed: () => (snapshot.data!) ?
//               FlutterBlue.instance.stopScan():
//               FlutterBlue.instance.startScan(timeout: const Duration(seconds: 4)),
//           ): const SizedBox(height: 50),
//         ),
//       );
//
//   Widget nextButton() =>
//       StreamBuilder<List<BluetoothDevice>>(
//         stream: Stream.periodic(const Duration(seconds: 2))
//           .asyncMap((_) => FlutterBlue.instance.connectedDevices),
//         initialData: const [],
//         builder: (c, snapshot) => (snapshot.data != null) ? Column(children: snapshot.data!
//           .map((d) => SizedBox(
//             width: (width < 500) ? width * 0.6: 300,
//             height: 50,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(primary: lampColor),
//               child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                 const Icon(Icons.navigate_next_outlined, size: 28),
//                 const SizedBox(width: 10),
//                 Text(AppLocalizations.of(context)!.bluetoothNext,
//                   style: const TextStyle(
//                     color: blackColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//               ]),
//               onPressed: () => Navigator.of(context).push(
//                 MaterialPageRoute(builder: (context) => BluetoothBody(device: d)),
//               ),
//             ),
//           ))
//           .toList(),
//         ): const SizedBox(height: 50),
//       );
//
//   Widget connectButton() =>
//       StreamBuilder<List<ScanResult>>(
//         stream: FlutterBlue.instance.scanResults,
//         initialData: const [],
//         builder: (c, snapshot) => SizedBox(
//           width: width / 2,
//           height: width / 2,
//           child: (snapshot.data != null) ? Stack(children: snapshot.data!
//             .where((r) => r.device.name == deviceName)
//             .map((r) => ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 primary: transpColor,
//                 shadowColor: transpColor,
//               ),
//               child: Stack(alignment: Alignment.center, children: [
//                 buttonBackGround(width / 2, circleButton),
//                 Icon(Icons.bluetooth, size: width / 4, color: whiteColor),
//               ]),
//               onPressed: () async {
//                 if (r.advertisementData.connectable) {
//                   await r.device.connect();
//                   await FlutterBlue.instance.stopScan();
//                 }
//               }
//             )).toList(),
//           ): const CircularProgressIndicator(color: darkBlackColor),
//         ),
//       );
//
//   Widget connectedButton() =>
//       StreamBuilder<List<BluetoothDevice>>(
//         stream: Stream.periodic(const Duration(seconds: 2))
//           .asyncMap((_) => FlutterBlue.instance.connectedDevices),
//         initialData: const [],
//         builder: (c, snapshot) => SizedBox(
//           width: width / 2,
//           height: width / 2,
//           child: (snapshot.data != null) ? Stack(children: snapshot.data!
//             //.where((d) => d.state == BluetoothDeviceState.connected)
//             .map((d) => ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 primary: transpColor,
//                 shadowColor: transpColor,
//               ),
//               child: Stack(alignment: Alignment.center, children: [
//                 buttonBackGround(width / 2 , pressedCircle),
//                 Icon(Icons.bluetooth_connected, size: width / 4, color: lampColor),
//               ]),
//               onPressed: () => d.disconnect(),
//             ))
//             .toList()
//           ): null,
//         ),
//       );
//
//   //　メニュー画面のSpeedDial
//   Widget findBluetoothSpeedDial() =>
//       SizedBox(width: 50, height: 50,
//         child: Stack(children: [
//           const Image(image: AssetImage(buttonChan)),
//           SpeedDial(
//             backgroundColor: Colors.transparent,
//             overlayColor: const Color.fromRGBO(56, 54, 53, 1),
//             spaceBetweenChildren: 20,
//             children: [
//               changePage(context, width, false),
//               changePage(context, width, true),
//               info1000Buttons(context, width),
//               infoShimada(context, width),
//               infoLetsElevator(context, width),
//             ],
//           ),
//         ]),
//       );
// }