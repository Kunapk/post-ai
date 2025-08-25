 
import '../../register/bloc/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/text_field_container.dart';
import '../../../widgets/constants.dart';

class PasswordInput extends StatefulWidget {
  final String? deviceId;
  const PasswordInput({super.key, this.deviceId});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    if (widget.deviceId != null) {
      textController.text = widget.deviceId!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterModelState>(
        buildWhen: (previous, current) => previous.password != current.password,
        builder: (context, state) {
          return TextFieldContainer(
            child: TextField(
              controller: textController,
              onChanged: (value) => context
                  .read<RegisterBloc>()
                  .add(PasswordChangedEvent(text: value)),
              decoration: InputDecoration(
                icon: const Icon(
                  Icons.password,
                  color: kPrimaryColor,
                ),
                hintText: 'Password',
                errorText: state.password.isNotValid
                    ? state.password.getErrorMessage()
                    : null,
                border: InputBorder.none,
              ),
            ),
          );
        });
  }
}
