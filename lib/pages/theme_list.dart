import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/repository/theme/app_theme.dart';
import 'package:pos/repository/theme/theme_repository.dart';

class ThemeList extends StatefulWidget {
  const ThemeList({super.key});

  @override
  State<ThemeList> createState() => _ThemeListState();
}

class _ThemeListState extends State<ThemeList> {
  @override
  Widget build(BuildContext context) {
    ThemeRepository theme = RepositoryProvider.of<ThemeRepository>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Theme")),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: Container(
                width: 24,
                height: 24,
                color: Colors.white,
                child: const Icon(
                  Icons.light_mode,
                  color: Colors.black,
                  size: 16,
                ),
              ),
              title: const Text("Maroon Gold Light"),
              onTap: () {
                theme.setTheme(AppTheme.maroonGoldLight);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Container(
                width: 24,
                height: 24,
                color: Colors.black,
                child: const Icon(
                  Icons.dark_mode,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              title: const Text("Maroon Gold Dark"),
              onTap: () {
                theme.setTheme(AppTheme.maroonGoldDark);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
