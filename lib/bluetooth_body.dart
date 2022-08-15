// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'bluetooth_extension.dart';
// import 'bluetooth_widget.dart';
// import 'constant.dart';
// import 'my_home_body.dart';
// import 'common_extension.dart';
// import 'my_home_body.dart';
// import 'extension.dart';
// import 'admob.dart';
//
// class BluetoothBody extends StatefulWidget {
//   const BluetoothBody({
//     Key? key,
//     required this.device
//   }) : super(key: key);
//
//   final BluetoothDevice device;
//   @override
//   State<BluetoothBody> createState() => _BluetoothBodyState();
// }
//
// class _BluetoothBodyState extends State<BluetoothBody> {
//
//   late double width;
//   late double height;
//   late String lang;
//   late int counter;
//   late int nextFloor;
//   late bool isMoving;
//   late bool isEmergency;
//   late List<bool> isDoorState;          //[opened, closed, opening, closing]
//   late List<bool> isPressedButton;      //[open, close, call]
//   late List<bool> isAboveSelectedList;
//   late List<bool> isUnderSelectedList;
//   late BannerAd myBanner;
//   late BluetoothService bleService;
//   late BluetoothCharacteristic characteristicTX;
//   late BluetoothCharacteristic characteristicRX;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
//     setState(() {
//       counter = 1;
//       nextFloor = 1;
//       isMoving = false;
//       isEmergency = false;
//       isDoorState = closedState;
//       isPressedButton = allPressed;
//       isAboveSelectedList = List.generate(maxBLE + 1, (_) => false);
//       isUnderSelectedList = List.generate(minBLE * (-1) + 1, (_) => false);
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
//     widget.device.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder(
//         future: _connectBLE(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             _setBLEData();
//             _getBLEData();
//           }
//           return Container(
//             height: height,
//             color: darkBlackColor,
//             child: Column(children: <Widget>[
//               const Spacer(flex: 1),
//               (snapshot.hasData) ? bluetoothArrowNumber():
//               const CircularProgressIndicator(color: lampColor),
//               const Spacer(flex: 1),
//               Row(children: [
//                 const Spacer(flex: 1),
//                 StreamBuilder<BluetoothDeviceState>(
//                     stream: widget.device.state,
//                     initialData: BluetoothDeviceState.connecting,
//                     builder: (context, snapshot) => connectedBLE(snapshot)
//                 ),
//                 const Spacer(flex: 5), bluetoothSpeedDial(),
//                 const Spacer(flex: 1),
//               ]),
//               const SizedBox(height: 10),
//               adMobBannerWidget(width, height, myBanner),
//             ]),
//           );
//         },
//       ),
//     );
//   }
//
//   ///<子Widget>
//
//   // 階数の表示
//   Widget bluetoothArrowNumber() {
//     return Container(
//       height: height - 200,
//       alignment: Alignment.center,
//       color: darkBlackColor,
//       child: FittedBox(
//         fit: BoxFit.fitWidth,
//         child: StreamBuilder<List<BluetoothService>>(
//           stream: widget.device.services,
//           initialData: const [],
//           builder: (context, snapshot) => Column(
//             children: snapshot.data!.where((s) => s == bleService).map((s) => Column(
//               children: s.characteristics.where((c) => c == characteristicTX).map((c) =>
//                 StreamBuilder<List<int>>(
//                   stream: c.value,
//                   initialData: c.lastValue,
//                   builder: (context, snapshot) => Column(children: <Widget>[
//                     Column(children: [
//                       bLEImage(counter.arrowImage(isMoving, nextFloor)),
//                       const SizedBox(height: 100),
//                       bLENumber(counter.displayNumber(maxBLE)),
//                     ]),
//                   ]),
//                 ),
//               ).toList(),
//             )).toList(),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget connectedBLE(AsyncSnapshot snapshot) {
//     _reconnectBLE(snapshot);
//     return Container(width: 50,
//       color: darkBlackColor,
//       child: Stack(alignment: Alignment.center, children: [
//         buttonBackGround(50,
//           (snapshot.data == BluetoothDeviceState.connected) ?
//             pressedCircle: circleButton,
//         ),
//         Transform.rotate(angle: pi / 2,
//           child: SizedBox(width: 30,
//             child: FittedBox(
//               fit: BoxFit.fitWidth,
//               child: (snapshot.data == BluetoothDeviceState.connected) ?
//                 const Icon(Icons.bluetooth_connected, color: lampColor):
//                 const Icon(Icons.bluetooth, color: whiteColor)
//             )
//           ),
//         ),
//       ]),
//     );
//   }
//
//   //　メニュー画面のSpeedDial
//   Widget bluetoothSpeedDial() =>
//       SizedBox(width: 50, height: 50,
//         child: Stack(children: [
//           Transform.rotate(
//             angle: pi / 2,
//             child: const Image(image: AssetImage(buttonChan)),
//           ),
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
//
//   /// <setStateに関する関数>
//
//   //
//   Future<BluetoothCharacteristic> _connectBLE() async {
//     await widget.device.connect();
//     await widget.device.discoverServices();
//     widget.device.services.listen((e) async {
//       for (BluetoothService s in e) {
//         if (s.uuid == Guid(serviceUUID)) {
//           setState(() => bleService = s);
//           for (BluetoothCharacteristic c in s.characteristics) {
//             if (c.uuid == Guid(characteristicTXUUID)) {
//               setState(() => characteristicTX = c);
//               await _notifyBLEData();
//             }
//             if (c.uuid == Guid(characteristicRXUUID)) {
//               setState(() => characteristicRX = c);
//             }
//           }
//         }
//       }
//     });
//     return characteristicTX;
//   }
//
//   //
//   _reconnectBLE(AsyncSnapshot snapshot) {
//     widget.device.state.listen((e) async {
//       if (snapshot.data == BluetoothDeviceState.disconnected) {
//         await widget.device.connect();
//         await widget.device.discoverServices();
//         await _notifyBLEData();
//         await Future.delayed(const Duration(seconds: waitTime)).then((_) async {
//           if (snapshot.data == BluetoothDeviceState.disconnected) {
//             await widget.device.connect();
//             await widget.device.discoverServices();
//             await _notifyBLEData();
//           }
//           if (!characteristicTX.isNotifying) {
//             await _notifyBLEData();
//           }
//         });
//       }
//     });
//   }
//
//   _notifyBLEData() async {
//     await characteristicTX.setNotifyValue(true);
//     await characteristicTX.read();
//   }
//
//   _getBLEData() {
//     characteristicTX.value.listen((v) async {
//       if(v[0] != 0) {
//         (v[0] < maxBLE + 1) ? _floorSelected(v[0]): _floorCanceled(v[0] - 200);
//       }
//     });
//   }
//
//   _writeBLEData() async {
//     await characteristicRX.write(
//       floors.sendBLEData(isAboveSelectedList, isUnderSelectedList, counter, nextFloor),
//       withoutResponse: false
//     );
//   }
//
//   _setBLEData() {
//     _writeBLEData();
//     "counter: $counter, nextFloor: $nextFloor".debugPrint();
//     Future.delayed(const Duration(seconds: 1)).then((_) async {
//       _setBLEData();
//     });
//   }
//
//   // 開くボタンを押した時の動作
//   _pressedOpen() async {
//     setState(() => isPressedButton[0] = true);
//     if (!isMoving && !isEmergency && (isDoorState == closedState || isDoorState == closingState)) {
//       setState(() => isDoorState = openingState);
//       await AppLocalizations.of(context)!.openDoor.speakText(context);
//       await Future.delayed(const Duration(seconds: waitTime)).then((_) async {
//         _doorsOpening();
//       });
//     }
//   }
//
//   // ドアを開く
//   _doorsOpening() async {
//     if (!isMoving && !isEmergency && isDoorState == openingState) {
//       setState(() => isDoorState = openedState);
//       await Future.delayed(const Duration(seconds: openTime)).then((_) async{
//         if (!isMoving && !isEmergency && isDoorState == openedState) {
//           _doorsClosing();
//         }
//       });
//     }
//   }
//
//   // 閉じるボタンを押した時の動作
//   _pressedClose() {
//     setState(() => isPressedButton[1] = true);
//     _doorsClosing();
//   }
//
//   //ドアを閉じる
//   _doorsClosing() async {
//     if (!isMoving && !isEmergency && (isDoorState == openedState || isDoorState == openingState)) {
//       setState(() => isDoorState = closingState);
//       await AppLocalizations.of(context)!.closeDoor.speakText(context);
//       await Future.delayed(const Duration(seconds: waitTime)).then((_) async {
//         if (!isMoving && !isEmergency && isDoorState == closingState) {
//           setState(() => isDoorState = closedState);
//           (counter < nextFloor) ? _counterUp():
//           (counter > nextFloor) ? _counterDown():
//           AppLocalizations.of(context)!.pushNumber.speakText(context);
//         }
//       });
//     }
//   }
//
//   //緊急電話ボタンを押した時の動作
//   _pressedAlert() async {
//     setState(() => isPressedButton[2] = true);
//     callSound.playAudio();
//     if (isMoving) setState(() => isEmergency = true);
//     if(isEmergency && isMoving) {
//       await Future.delayed(const Duration(seconds: waitTime)).then((_) async {
//         AppLocalizations.of(context)!.emergency.speakText(context);
//         setState(() {
//           nextFloor = counter;
//           counter.clearLowerFloor(isAboveSelectedList, isUnderSelectedList, minBLE);
//           counter.clearUpperFloor(isAboveSelectedList, isUnderSelectedList, maxBLE);
//           isMoving = false;
//           isEmergency = true;
//         });
//       });
//       if (counter != 1) {
//         await Future.delayed(const Duration(seconds: openTime)).then((_) async {
//           AppLocalizations.of(context)!.return1st.speakText(context);
//         });
//         await Future.delayed(const Duration(seconds: waitTime * 2)).then((_) async {
//           setState(() => nextFloor = 1);
//           (counter < nextFloor) ? _counterUp() : _counterDown();
//         });
//       }
//     }
//   }
//
//   // 上の階へ行く
//   _counterUp() async {
//     AppLocalizations.of(context)!.upFloor.speakText(context);
//     int count = 0;
//     setState(() => isMoving = true);
//     await Future.delayed(const Duration(seconds: waitTime)).then((_) {
//       Future.forEach(counter.upFromToNumber(nextFloor), (int i) async {
//         await Future.delayed(Duration(milliseconds: i.elevatorSpeed(count, nextFloor))).then((_) async {
//           count++;
//           if (isMoving && counter < nextFloor && nextFloor <  maxBLE + 1) setState(() => counter++);
//           if (counter == 0) setState(() => counter++);
//           if (isMoving && (counter == nextFloor || counter == maxBLE)) {
//             await counter.soundFloor(context, maxBLE, false).speakText(context);
//             setState(() {
//               counter.clearLowerFloor(isAboveSelectedList, isUnderSelectedList, minBLE);
//               nextFloor = counter.upNextFloor(isAboveSelectedList, isUnderSelectedList, minBLE, maxBLE);
//               isMoving = false;
//               isEmergency = false;
//               isDoorState = openingState;
//             });
//             "$nextString$nextFloor".debugPrint();
//             await _doorsOpening();
//           }
//         });
//       });
//     });
//   }
//
//   // 下の階へ行く
//   _counterDown() async {
//     AppLocalizations.of(context)!.downFloor.speakText(context);
//     int count = 0;
//     setState(() => isMoving = true);
//     await Future.delayed(const Duration(seconds: waitTime)).then((_) {
//       Future.forEach(counter.downFromToNumber(nextFloor), (int i) async {
//         await Future.delayed(Duration(milliseconds: i.elevatorSpeed(count, nextFloor))).then((_) async {
//           count++;
//           if (isMoving && minBLE - 1 < nextFloor && nextFloor < counter) setState(() => counter--);
//           if (counter == 0) setState(() => counter--);
//           if (isMoving && (counter == nextFloor || counter == minBLE)) {
//             await counter.soundFloor(context, maxBLE, false).speakText(context);
//             setState(() {
//               counter.clearUpperFloor(isAboveSelectedList, isUnderSelectedList, maxBLE);
//               nextFloor = counter.downNextFloor(isAboveSelectedList, isUnderSelectedList, minBLE, maxBLE);
//               isMoving = false;
//               isEmergency = false;
//               isDoorState = openingState;
//             });
//             "$nextString$nextFloor".debugPrint();
//             await _doorsOpening();
//           }
//         });
//       });
//     });
//   }
//
//   //行き先階ボタンを選択する
//   _floorSelected (int i) async {
//     if(!isEmergency) {
//       if (!i.isSelected(isAboveSelectedList, isUnderSelectedList)){
//         setState(() {
//           i.trueSelected(isAboveSelectedList, isUnderSelectedList);
//           if (counter < i && i < nextFloor) nextFloor = i;
//           if (counter > i && i > nextFloor) nextFloor = i;
//           if (i.onlyTrue(isAboveSelectedList, isUnderSelectedList)) nextFloor = i;
//         });
//         //await _writeBLEData();
//         "$nextString$nextFloor".debugPrint();
//         await Future.delayed(const Duration(seconds: waitTime)).then((_) async {
//           if (!isMoving && !isEmergency && isDoorState == closedState) {
//             (counter < nextFloor) ? _counterUp() : _counterDown();
//           }
//         });
//       }
//     }
//   }
//
//   //行き先階ボタンの選択を解除する
//   _floorCanceled(int i) async {
//     if (i.isSelected(isAboveSelectedList, isUnderSelectedList) && i != nextFloor) {
//       setState(() => i.falseSelected(isAboveSelectedList, isUnderSelectedList));
//       //await _writeBLEData();
//     }
//   }
// }
//
