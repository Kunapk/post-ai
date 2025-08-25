import '../../register/bloc/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/text_field_container.dart';
import '../../../widgets/constants.dart';

class FirstNameInput extends StatefulWidget {
  final String? deviceId;
  const FirstNameInput({super.key, this.deviceId});

  @override
  State<FirstNameInput> createState() => _FirstNameInputState();
}

class _FirstNameInputState extends State<FirstNameInput> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    if (this.widget.deviceId != null) {
      textController.text = this.widget.deviceId!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterModelState>(
        // buildWhen: (previous, current) =>
        //     previous.firstName != current.firstName,
        builder: (context, state) {
      return TextFieldContainer(
        child: TextField(
          controller: textController,
          onChanged: (value) => context
              .read<RegisterBloc>()
              .add(FirstNameChangedEvent(text: value)),
          decoration: InputDecoration(
            icon: const Icon(
              Icons.edit,
              color: kPrimaryColor,
            ),
            hintText: 'First Name',
            errorText: state.firstName.isNotValid ? 'Enter First Name' : null,
            border: InputBorder.none,
          ),
        ),
      );
    });
  }
}
