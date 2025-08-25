part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState(
      {this.status = FormzSubmissionStatus.initial,
      this.username = const Username.pure(),
      this.password = const Password.pure(),
      this.visibility = false,
      this.isValidated = false});

  final FormzSubmissionStatus status;
  final Username username;
  final Password password;
  final bool? visibility;
  final bool? isValidated;

  LoginState copyWith(
      {FormzSubmissionStatus? status,
      Username? username,
      Password? password,
      bool? visibility = false,
      bool? isValidated = false}) {
    return LoginState(
        status: status ?? this.status,
        username: username ?? this.username,
        password: password ?? this.password,
        visibility: visibility ?? this.visibility,
        isValidated: isValidated ?? this.isValidated);
  }

  @override
  List<Object> get props => [status, username, password, visibility!];
}
