import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../register/models/model.dart';
import '../../../repository/authen/authen_repository.dart';
import 'package:formz/formz.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterModelState> {
  final AuthenticationRepository _authenticationRepository;

  RegisterBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(RegisterModelState()) {
    on<InputTextChangedEvent>((event, emit) => _onTextChange(event, emit));
    on<SubmittedEvent>((event, emit) => _onSubmited(event, emit));
  }

  void _onTextChange(InputTextChangedEvent event, Emitter<RegisterState> emit) {
    if (event is FirstNameChangedEvent) {
      final firstName = FirstName.dirty(event.text!);
      emit(
        state.copyWith(
          firstName: firstName,
          isValidated: Formz.validate(
            [state.lastName, state.userName, state.password, firstName],
          ),
        ),
      );
    }
    if (event is LastNameChangedEvent) {
      final lastName = LastName.dirty(event.text!);
      emit(
        state.copyWith(
          lastName: lastName,
          isValidated: Formz.validate(
            [state.firstName, state.userName, state.password, lastName],
          ),
        ),
      );
    }
    if (event is UserNameChangedEvent) {
      final userName = UserName.dirty(event.text!);
      emit(
        state.copyWith(
          userName: userName,
          isValidated: Formz.validate(
            [state.firstName, state.lastName, state.password, userName],
          ),
        ),
      );
    }
    if (event is PasswordChangedEvent) {
      final password = UserPassword.dirty(event.text!);
      emit(
        state.copyWith(
          password: password,
          isValidated: Formz.validate(
            [state.firstName, state.lastName, state.userName, password],
          ),
        ),
      );
    }
  }

  void _onSubmited(SubmittedEvent event, Emitter<RegisterState> emit) async {
    if (state.isValidated!) {
      try {
        emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
        var result = await _authenticationRepository.register(
            firstName: state.firstName.value,
            lastName: state.lastName.value,
            userName: state.userName.value,
            password: state.password.value);
        if (result) {
          emit(state.copyWith(status: FormzSubmissionStatus.success));
        } else {
          emit(state.copyWith(status: FormzSubmissionStatus.failure));
        }
      } on Exception catch (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    } else {
      var _status = Formz.validate(
          [state.firstName, state.lastName, state.userName, state.password]);
      emit(
        state.copyWith(status: _status ? FormzSubmissionStatus.success : FormzSubmissionStatus.failure),
      );
    }
  }
}
