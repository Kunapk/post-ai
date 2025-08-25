import 'package:flutter/material.dart';

import 'constants.dart';

class RoundedButton extends StatelessWidget {
  final String? text;
  final VoidCallback? press;
  final Color color, textColor;
  const RoundedButton({
    super.key,
    this.text,
    this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: TextButton(
          onPressed: press,
          style: TextButton.styleFrom(
              foregroundColor: Colors.pinkAccent, backgroundColor: color,
              minimumSize: const Size(200, 60)),
          child: Text(
            text.toString(),
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
