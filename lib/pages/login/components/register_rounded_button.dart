 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/pages/register/register.dart';
import '../../../widgets/constants.dart';
import '../bloc/login_bloc.dart';

class RegisterButton extends StatelessWidget {
  final String? text;
  final VoidCallback? press;
  final Color color, textColor;
  const RegisterButton({
    super.key,
    this.text,
    this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: size.width * 0.8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: TextButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus!.unfocus();
                  Navigator.of(context).push<void>(Register.route());
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.pinkAccent, backgroundColor: color,
                    minimumSize: const Size(200, 60)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.perm_data_setting, color: Colors.white),
                    Text(
                      text.toString(),
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
