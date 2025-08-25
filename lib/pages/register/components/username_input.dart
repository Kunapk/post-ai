import '../../register/bloc/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/text_field_container.dart';
import '../../../widgets/constants.dart';

class UserNameInput extends StatefulWidget {
  final String? deviceId;
  const UserNameInput({super.key, this.deviceId});

  @override
  State<UserNameInput> createState() => _UserNameInputState();
}

class _UserNameInputState extends State<UserNameInput> {
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
        buildWhen: (previous, current) => previous.userName != current.userName,
        builder: (context, state) {
          return TextFieldContainer(
            child: TextField(
              controller: textController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => context
                  .read<RegisterBloc>()
                  .add(UserNameChangedEvent(text: value)),
              decoration: InputDecoration(
                icon: const Icon(
                  Icons.email,
                  color: kPrimaryColor,
                ),
                hintText: 'Email',
                errorText: state.userName.isNotValid
                    ? state.userName.getErrorMessage()
                    : null,
                border: InputBorder.none,
              ),
            ),
          );
        });
  }
}
