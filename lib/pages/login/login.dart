import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:pos/widgets/progress_dialog.dart';
import './bloc/login_bloc.dart';
import './components/login_rounded_button.dart';
import './components/password_input.dart';
import './components/username_input.dart';
import '../../repository/authen/authen_repository.dart';

class LoginPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late ProgressDialog progressDialog;

  @override
  void initState() {
    progressDialog = ProgressDialog(context, isDismissible: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // var height = size.width < 500 ?  .6 :  .99;
    // double pading = size.width < 500 ?  2.0 :  400.0;
    return Scaffold(
      // backgroundColor: theme.currentTheme!.themeData!.primaryColor,
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: SingleChildScrollView(
            child: BlocProvider(
              create: (BuildContext context) => LoginBloc(
                authenticationRepository:
                    RepositoryProvider.of<AuthenticationRepository>(context),
              ),
              child: BlocListener<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state.status.isFailure) {
                    // Navigator.of(context).pop();
                    if (progressDialog.isShowing()) {
                      progressDialog.hide();
                    }
                    FocusManager.instance.primaryFocus!.unfocus();
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(content: Text('Authentication Failure')),
                      );
                  }
                  if (state.status.isInProgress) {
                    debugPrint('isSubmissionInProgress');
                    if (!progressDialog.isShowing()) {
                      progressDialog.show();
                    }
                    // showDialog(
                    //   barrierDismissible: false,
                    //   context: context,
                    //   builder: (context) {
                    //     return const AlertDialog(
                    //       content: SizedBox(
                    //         width: 50,
                    //         height: 100,
                    //         child: Center(
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               CircularProgressIndicator(),
                    //               Padding(
                    //                 padding: EdgeInsets.all(15.0),
                    //                 child: Text('LOADING...'),
                    //               )
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // );
                  }
                  if (state.status.isSuccess) {
                    // Navigator.of(context).pop();
                    if (progressDialog.isShowing()) {
                      progressDialog.hide();
                    }
                    debugPrint('isSubmissionSuccess');
                  }
                },
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // bool isMobile = constraints.maxWidth < 500;
                    var isPortrait =
                        MediaQuery.of(context).orientation ==
                        Orientation.portrait;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isPortrait ? 50 : 350,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: isPortrait ? 100 : 120),
                            Image.asset(
                              'lib/assets/logo.png',
                              width: isPortrait
                                  ? size.width * .8
                                  : size.width * .8,
                            ),
                            // Text(
                            //   "easyPOS",
                            //   style: TextStyle(
                            //     fontSize: isPortrait
                            //         ? size.width * .16
                            //         : size.width * .08,
                            //     color: Theme.of(context).primaryColor,
                            //   ),
                            // ),
                            SizedBox(height: isPortrait ? 160 : 60),
                            const UsernameInput(),
                            const PasswordInput(),
                            const SizedBox(height: 20),
                            const LoginButton(text: 'LOGIN'),
                            // const RegisterButton(
                            //   text: 'REGISTER',
                            //   color: kOrangeColor,
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
