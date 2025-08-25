part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class InputTextChangedEvent extends RegisterEvent {
  final String? text;
  InputTextChangedEvent({this.text});
}

class FirstNameChangedEvent extends InputTextChangedEvent {
  FirstNameChangedEvent({String? text}) : super(text: text);
}

class LastNameChangedEvent extends InputTextChangedEvent {
  LastNameChangedEvent({String? text}) : super(text: text);
}

class UserNameChangedEvent extends InputTextChangedEvent {
  UserNameChangedEvent({String? text}) : super(text: text);
}

class PasswordChangedEvent extends InputTextChangedEvent {
  PasswordChangedEvent({String? text}) : super(text: text);
}

class SubmittedEvent extends RegisterEvent {}
