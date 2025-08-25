 
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:pos/pages/home/home.dart';
import 'package:pos/pages/tablet/home.dart';

class ResponsiveLayout extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ResponsiveLayout(
        mobile: HomePage(),
        tablet: TabletHome(),
        
      ),
    );
  }

  final Widget mobile;
  final Widget tablet;

  const ResponsiveLayout({super.key, required this.mobile, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) { 
        return LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 500) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            return mobile;
          } else {
            // SystemChrome.setPreferredOrientations([
            //   DeviceOrientation.landscapeRight,
            //   DeviceOrientation.landscapeLeft,
            // ]);
            if (orientation == Orientation.portrait) {
              return mobile;
            }
            return tablet;
          } 
        });
      }
    ) ;
  }
}
