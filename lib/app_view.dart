 
 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/authen/authen_bloc.dart';
import 'package:pos/pages/login/login.dart';
import 'package:pos/pages/responsive.dart';
import 'package:pos/pages/splash.dart';
import 'package:pos/repository/authen/authen_repository.dart';
import 'package:pos/repository/localized/locale_constant.dart';
import 'package:pos/repository/localized/localizations_delegate.dart';
import 'package:pos/repository/theme/app_theme.dart';
import 'package:pos/repository/theme/theme_repository.dart';  
import 'package:flutter_localizations/flutter_localizations.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState!;
  Locale? _locale;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    // getLocale(context).then((locale) {
    //   setState(() {
    //     if (locale != null) {
    //       _locale = locale;
    //     } else {
    //       List<Locale> locales = WidgetsBinding.instance.window.locales;
    //       _locale = locales.length == 0 ? Locale('en', '') : locales.first;
    //     }
    //   });
    // });
    super.didChangeDependencies();
  }

  @override
  void didChangeLocales(List<Locale>? locale) {
    // This is run when system locales are changed
    super.didChangeLocales(locale);
    // Update state with the new values and redraw controls
  }

  @override
  Widget build(BuildContext context) {
    ThemeRepository theme = RepositoryProvider.of<ThemeRepository>(context);
    LocalRepository localRepository =
        RepositoryProvider.of<LocalRepository>(context);
 
    List<Locale> locales = WidgetsBinding.instance.platformDispatcher.locales;
    _locale = locales.isEmpty ? const Locale('en', '') : locales.first;

    return StreamBuilder<Locale?>(
      stream: localRepository.stream,
      initialData: _locale,
      builder: (context, localeSnapshot) {
        return StreamBuilder<ThemeStyle>(
          stream: theme.stream,
          initialData: theme.initialTheme(),
          builder: (context, snapshot) {
            return MaterialApp(
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('th', 'TH'),
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode &&
                      supportedLocale.countryCode == locale?.countryCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first;
              },
              locale: localeSnapshot.data!,
              debugShowCheckedModeBanner: false,
              theme: snapshot.data!.themeData,
              navigatorKey: _navigatorKey,
              builder: (context, child) {
                return BlocListener<AuthenticationBloc, AuthenticationState>(
                  listener: (context, state) {
                    switch (state.status) {
                      case AuthenticationStatus.authenticated:
                        _navigator.pushAndRemoveUntil<void>(
                          ResponsiveLayout.route(),
                          (route) => false,
                        );
                        break;
                      case AuthenticationStatus.unauthenticated:
                        _navigator.pushAndRemoveUntil<void>(
                          LoginPage.route(),
                          (route) => false,
                        );
                        break;
                      default:
                        break;
                    }
                  },
                  child: child,
                );
              },
              onGenerateRoute: (_) => SplashPage.route(),
            );
          },
        );
      },
    );
  }
}
