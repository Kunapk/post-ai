import 'package:flutter/material.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

enum ConfirmAction { CANCEL, ACCEPT }

extension ColorExtension on String {
  Color? toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return null;
  }
}

// class DialogUtil {
//   static Future<ConfirmAction?> asyncConfirmDialog(
//       BuildContext? context, String? title, String? text) async {
//     return showAnimatedDialog<ConfirmAction>(
//       context: context!,
//       barrierDismissible: false, // user must tap button for close dialog!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title!),
//           content: Text(text!),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('ยกเลิก'),
//               onPressed: () {
//                 Navigator.of(context).pop(ConfirmAction.CANCEL);
//               },
//             ),
//             TextButton(
//               child: const Text('ยืนยัน'),
//               onPressed: () {
//                 Navigator.of(context).pop(ConfirmAction.ACCEPT);
//               },
//             )
//           ],
//         );
//       },
//       animationType: DialogTransitionType.scale,
//       curve: Curves.fastOutSlowIn,
//       duration: Duration(seconds: 1),
//     );
//   }

//   static Future<ConfirmAction?> asyncMessageDialog(
//       {BuildContext? context, String? title, String? text}) async {
//     return showAnimatedDialog<ConfirmAction?>(
//       context: context!,
//       barrierDismissible: false, // user must tap button for close dialog!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title!),
//           content: Text(text!),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('ปิด'),
//               onPressed: () {
//                 Navigator.of(context).pop(ConfirmAction.ACCEPT);
//               },
//             )
//           ],
//         );
//       },
//       animationType: DialogTransitionType.scale,
//       curve: Curves.fastOutSlowIn,
//       duration: Duration(seconds: 1),
//     );
//   }

//   static Future<ConfirmAction?> asyncImageDialog(
//       BuildContext context, String url, String title) async {
//     return showAnimatedDialog<ConfirmAction>(
//       context: context,
//       barrierDismissible: false, // user must tap button for close dialog!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Image.network(url),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('ปิด'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             )
//           ],
//         );
//       },
//       animationType: DialogTransitionType.scale,
//       curve: Curves.fastOutSlowIn,
//       duration: Duration(seconds: 1),
//     );
//   }

//   static Future<String?> asyncInputDialog(
//       BuildContext context, String title, String label, String value) async {
//     String groupName = '';
//     TextEditingController _controller = new TextEditingController(text: value);
//     return showAnimatedDialog<String>(
//       context: context,
//       barrierDismissible:
//           false, // dialog is dismissible with a tap on the barrier
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: new Row(
//             children: <Widget>[
//               new Expanded(
//                   child: new TextField(
//                 controller: _controller,
//                 autofocus: true,
//                 decoration: new InputDecoration(labelText: label),
//                 onChanged: (value) {
//                   groupName = value;
//                 },
//               ))
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('ยกเลิก'),
//               onPressed: () {
//                 Navigator.of(context).pop(groupName);
//               },
//             ),
//             TextButton(
//               child: const Text('ยืนยัน'),
//               onPressed: () {
//                 Navigator.of(context).pop(groupName);
//               },
//             ),
//           ],
//         );
//       },
//       animationType: DialogTransitionType.scale,
//       curve: Curves.fastOutSlowIn,
//       duration: Duration(seconds: 1),
//     );
//   }

//   static void showSnackbar(
//       BuildContext context, String text, SnackBarAction action,
//       {Color bgcolor = Colors.black}) {
//     final snackBar =
//         SnackBar(content: Text(text), action: action, backgroundColor: bgcolor);
//     // Find the ScaffoldMessenger in the widget tree
//     // and use it to show a SnackBar.
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }
