import 'package:flutter/material.dart';

import 'app.dart';
import 'repository/repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    App(
      authenticationRepository: AuthenticationRepository(),
      userRepository: UserRepository(),
    ),
  );
}
