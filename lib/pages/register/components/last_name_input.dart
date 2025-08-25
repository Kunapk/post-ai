import '../../register/bloc/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/text_field_container.dart';
import '../../../widgets/constants.dart';

class LastNameInput extends StatefulWidget {
  final String? deviceId;
  const LastNameInput({super.key, this.deviceId});

  @override
  State<LastNameInput> createState() => _LastNameInputState();
}

class _LastNameInputState extends State<LastNameInput> {
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
        // buildWhen: (previous, current) =>
        //     previous.firstName != current.firstName,
        builder: (context, state) {
      return TextFieldContainer(
        child: TextField(
          controller: textController,
          onChanged: (value) => context
              .read<RegisterBloc>()
              .add(LastNameChangedEvent(text: value)),
          decoration: InputDecoration(
            icon: const Icon(
              Icons.edit,
              color: kPrimaryColor,
            ),
            hintText: 'Last Name',
            errorText: state.lastName.isNotValid ? 'Enter Last Name' : null,
            border: InputBorder.none,
          ),
        ),
      );
    });
  }
}
