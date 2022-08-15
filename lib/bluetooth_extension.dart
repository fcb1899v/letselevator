// import 'package:flutter/services.dart';
// import 'constant.dart';
//
// extension BoolExt on bool {
//
//   int boolToInt() => (this) ? 1: 0;
//
// }
//
// extension ListIntExt on List<int> {
//
//   List<int> sendBLEData(List<bool> isAboveSelectedList, List<bool> isUnderSelectedList, int counter, int nextFloor) =>
//     List.generate(floors.length + 2, (i) =>
//       (i == floors.length) ? counter:
//       (i == floors.length + 1) ? nextFloor:
//       (this[i] < 0) ? isUnderSelectedList[this[i] * (-1)].boolToInt():
//       isAboveSelectedList[this[i]].boolToInt()
//     );
// }
//
// // final FlutterBlue _flutterBlue = FlutterBlue.instance;
// // void scanDevices() {
// //   _flutterBlue.scan(timeout: const Duration(seconds: 10),)
// //       .listen((scanResult) {
// //     "${scanResult.uuid.toString()}".debugPrint();
// //   }, onDone: stopScan);
// // }
