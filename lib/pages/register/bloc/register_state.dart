part of 'register_bloc.dart';

abstract class RegisterState extends Equatable {
  final FormzSubmissionStatus status;
  RegisterState({this.status = FormzSubmissionStatus.initial});
  @override
  List<Object> get props => [];
}

class RegisterModelState extends RegisterState {
  //final FormzStatus status;
  final FirstName firstName;
  final LastName lastName;
  final UserName userName;
  final UserPassword password;
  final bool? isValidated;

  RegisterModelState(
      {FormzSubmissionStatus? status = FormzSubmissionStatus.initial,
      this.firstName = const FirstName.pure(),
      this.lastName = const LastName.pure(),
      this.userName = const UserName.pure(),
      this.password = const UserPassword.pure(),
      this.isValidated = false})
      : super(status: status!);

  RegisterModelState copyWith(
      {FormzSubmissionStatus? status,
      FirstName? firstName,
      LastName? lastName,
      UserName? userName,
      UserPassword? password,
      bool? isValidated}) {
    return RegisterModelState(
        status: status ?? this.status,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        userName: userName ?? this.userName,
        password: password ?? this.password,
        isValidated: isValidated ?? this.isValidated);
  }

  @override
  List<Object> get props => [status, firstName, lastName, userName, password];
}
