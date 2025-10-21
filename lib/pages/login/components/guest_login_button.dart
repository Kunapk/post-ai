import 'package:flutter/material.dart';

class GuestLoginButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Color color, textColor;

  const GuestLoginButton({
    super.key,
    this.text,
    this.onPressed,
    this.color = const Color(0xFF6C757D),
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
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: color,
            backgroundColor: color,
            minimumSize: const Size(200, 60),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.person_outline, color: Colors.white),
              Text(text.toString(), style: TextStyle(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
