import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../pages/login/login.dart';
import '../../repository/authen/authen_repository.dart';
import '../register/components/save_rounded_button.dart';
import 'bloc/register_bloc.dart';
import 'components/component.dart';

class Register extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => const Register());
  }

  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocProvider(
            create: (context) => RegisterBloc(
                authenticationRepository:
                    RepositoryProvider.of<AuthenticationRepository>(context)),
            child: BlocListener<RegisterBloc, RegisterState>(
              listener: (context, state) {
                if (state.status.isSuccess) {
                  FocusManager.instance.primaryFocus!.unfocus();
                  Navigator.of(context)
                      .pushAndRemoveUntil(LoginPage.route(), (route) => false);
                }
                if (state.status.isFailure) {
                  FocusManager.instance.primaryFocus!.unfocus();
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Registation Failure')),
                    );
                }
              },
              child: Container(
                padding: const EdgeInsets.only(top: 30, left: 50, right: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/register.png',
                      width: 180,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const FirstNameInput(),
                    const LastNameInput(),
                    const UserNameInput(),
                    const PasswordInput(),
                    const SaveButton(
                      text: 'SAVE',
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
