
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../models/password.dart';
import '../models/username.dart';
import '../../../repository/authen/authen_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const LoginState()) { 
    on<LoginUsernameChanged>(
        (event, emit) => _mapUsernameChangedToState(event, emit));
    on<LoginPasswordChanged>(
        (event, emit) => _mapPasswordChangedToState(event, emit));
    on<LoginSubmitted>((event, emit) => _mapLoginSubmittedToState(event, emit));
    on<VisibilityChanged>(
        (event, emit) => _mapVisibilityChangedToState(event, emit));
  }

  final AuthenticationRepository _authenticationRepository;

  void _mapVisibilityChangedToState(
    VisibilityChanged event,
    Emitter<LoginState> emit,
  ) {
    // final isVisibility = !state.visibility!;
    // emit(state.copyWith(
    //   visibility: isVisibility,
    // ));
    final isVisibility = !state.visibility!;
    emit(state.copyWith(
        isValidated: Formz.validate([state.password, state.username]),
        visibility: isVisibility, status: FormzSubmissionStatus.canceled));
  }

  void _mapUsernameChangedToState(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    final username = Username.dirty(event.username);
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
      username: username,
      isValidated: Formz.validate([state.password, username]),
    ));
  }

  void _mapPasswordChangedToState(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final password = Password.dirty(event.password);
    final isVisibility = state.visibility!;
    emit(state.copyWith(
      visibility: isVisibility,
      status: FormzSubmissionStatus.initial,
      password: password,
      isValidated: Formz.validate([password, state.username]),
    ));
  }

  void _mapLoginSubmittedToState(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isValidated!) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        bool result = await _authenticationRepository.logIn(
          username: state.username.value,
          password: state.password.value,
        );
        if (result) {
          emit(state.copyWith(status: FormzSubmissionStatus.success));
        } else {
          emit(state.copyWith(status: FormzSubmissionStatus.failure));
        }
      } on Exception catch (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    }
  }
}
