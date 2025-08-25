import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/text_field_container.dart';
import '../../../widgets/constants.dart';
import '../bloc/login_bloc.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
          (previous.password != current.password) ||
          (previous.visibility != current.visibility),
      builder: (context, state) {
        return TextFieldContainer(
          child: TextField(
            onChanged: (username) => context.read<LoginBloc>().add(
                  LoginPasswordChanged(username, state.visibility!),
                ),
            onSubmitted: (value) {
              context.read<LoginBloc>().add(const LoginSubmitted());
            },
            obscureText: !state.visibility!,
            decoration: InputDecoration(
              icon: const Icon(
                Icons.vpn_key_outlined,
                color: kPrimaryColor,
              ),
              hintText: 'Password',
              suffixIcon: Material(
                color: Colors.transparent,
                child: IconButton(
                  splashRadius: 25,
                  onPressed: () {
                    context
                        .read<LoginBloc>()
                        .add(VisibilityChanged(state.visibility!));
                  },
                  icon: Icon(
                    state.visibility! ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              border: InputBorder.none,
            ),
          ),
        );
      },
    );
  }
}
