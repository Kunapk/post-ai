import 'package:flutter/material.dart';

import 'constants.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget? child;
  final Color? color;
  const TextFieldContainer({super.key, this.child, this.color = kTextBgColor});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(60),
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}
