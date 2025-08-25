import 'package:flutter/material.dart';

import 'constants.dart';
import 'text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  final String? hintText;
  final IconData? icon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? onValidate;
  final TextEditingController? textController;
  final TextInputType? keyboardType;
  const RoundedInputField(
      {super.key,
      this.hintText = 'Email',
      this.icon = Icons.person,
      this.onChanged,
      this.onValidate,
      this.textController,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        keyboardType: keyboardType,
        controller: textController,
        validator: onValidate,
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
