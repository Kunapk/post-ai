import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';

class LoginButton extends StatelessWidget {
  final String? text;
  final VoidCallback? press;
  final Color color, textColor;
  const LoginButton({
    super.key,
    this.text,
    this.press,
    this.color = const Color(0xFFE95038),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: size.width * 0.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(29),
            child: TextButton(
              onPressed: state.isValidated!
                  ? () {
                      FocusManager.instance.primaryFocus!.unfocus();
                      context.read<LoginBloc>().add(const LoginSubmitted());
                    }
                  : null,
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor, backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(200, 60)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.login, color: Colors.white),
                  Text(
                    text.toString(),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
