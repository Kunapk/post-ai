// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'repository/repository.dart';
import 'pages/ai/voice_ai_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VoiceAIController(), // ✅ ไม่ต้องส่ง voiceIO
        ),
      ],
      child: App(
        authenticationRepository: AuthenticationRepository(),
        userRepository: UserRepository(),
      ),
    ),
  );
}
