import 'package:flutter/material.dart';

class NumPad { 
  final Widget title;
  final int data;

  NumPad({
    required this.title,
    required this.data
  });
}

const numStyle = TextStyle(fontSize: 22);
const numStyle2 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

List<NumPad> numPadData = [
  NumPad(title: const Text("7", style: numStyle,), data: 7),
  NumPad(title: const Text("8", style: numStyle), data: 8),
  NumPad(title: const Text("9", style: numStyle), data: 9),
  NumPad(title: const Text("฿ 1000", style: numStyle2), data: 1000),
  NumPad(title: const Text("4", style: numStyle), data: 4),
  NumPad(title: const Text("5", style: numStyle), data: 5),
  NumPad(title: const Text("6", style: numStyle), data: 6),
  NumPad(title: const Text("฿ 500", style: numStyle2), data: 500),
  NumPad(title: const Text("1", style: numStyle), data: 1),
  NumPad(title: const Text("2", style: numStyle), data: 2),
  NumPad(title: const Text("3", style: numStyle), data: 3),
  NumPad(title: const Text("฿ 100", style: numStyle2), data: 100),
  NumPad(title: const Text(".", style: numStyle), data: -1),
  NumPad(title: const Text("0", style: numStyle), data: 0),
  NumPad(title: const Icon(Icons.backspace), data: -2),
  NumPad(title: const Text("เต็ม", style: numStyle2), data: -3), 

];