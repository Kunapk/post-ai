import 'dart:async';

import 'package:equatable/equatable.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/repository/authen/authen_repository.dart';
import 'package:pos/repository/user_repository/models/user.dart';
import 'package:pos/repository/user_repository/user_repository.dart'; 

part 'authen_event.dart';
part 'authen_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
  })  : _authenticationRepository = authenticationRepository,
        _userRepository = userRepository,
        super(const AuthenticationState.unknown()) { 

    on<AuthenStatusChanged>((event, emit) => _onAuthenStatusChanged(event, emit));

    _authenticationStatusSubscription = _authenticationRepository.status.listen((status) { 
      add(AuthenStatusChanged(status));
    });
    _authenticationRepository.loginStatus();
  }

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;
  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    _authenticationRepository.dispose();
    return super.close();
  }
 

  Future<User?> _tryGetUser() async {
    try {
      final user = await _userRepository.getUser();
      return user;
    } on Exception {
      return null;
    }
  }
  
  void _onAuthenStatusChanged(AuthenStatusChanged event, Emitter<AuthenticationState> emit) async {
    switch (event.status) {
      case AuthenticationStatus.unauthenticated:
        emit(const AuthenticationState.unauthenticated());
        break;
      case AuthenticationStatus.unknown:
        emit( const AuthenticationState.unknown());
        break;
      case AuthenticationStatus.authenticated:
        final user = await _tryGetUser();
        if (user != null) {
          emit (AuthenticationState.authenticated(user));
        } else {
          emit (const AuthenticationState.unauthenticated());
        }
        break;
    }
  }
}
