import '../../register/bloc/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/constants.dart'; 

class SaveButton extends StatelessWidget {
  final String? text;
  final VoidCallback? press;
  final Color color, textColor;
  const SaveButton({
    super.key,
    this.text,
    this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: size.width * 0.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(29),
            child: TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus!.unfocus();
                context.read<RegisterBloc>().add(SubmittedEvent());
              },
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
      },
    );
  }
}
