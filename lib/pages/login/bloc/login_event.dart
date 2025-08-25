part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginUsernameChanged extends LoginEvent {
  const LoginUsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

class VisibilityChanged extends LoginEvent {
  const VisibilityChanged(this.visibility);

  final bool visibility;

  @override
  List<Object> get props => [visibility];
}

class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password, this.visibility);

  final String password;
  final bool visibility;

  @override
  List<Object> get props => [password, visibility];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}
