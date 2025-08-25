import 'package:flutter/material.dart';

/// Defines the color of the LED Bulb to be shown.
enum LedBulbColors { off, red, green, yellow }

/// Shows a kind of LED bulb to quickly indicate status of something
class LedBulbIndicator extends StatelessWidget {
  /// Which status to show by means of a [LedBulbColors]
  final LedBulbColors initialState;

  /// if true, there will be a glow shown around the bulb. State off will never show a glow.
  final bool glow;

  /// the size of the LED Bulb indicator widget (width and height always same)
  final double size;

  /// if specified, a margin around the LED Bulb widget.
  final double? margin;

  LedBulbIndicator(
      {super.key,
      required this.initialState,
      this.margin,
      required this.size,
      this.glow = false});

  final Map<LedBulbColors, List<Color>> _bulbColors = {
    LedBulbColors.green: <Color>[
      Colors.green.shade900,
      Colors.green.shade300,
      Colors.greenAccent.shade100,
    ],
    LedBulbColors.yellow: <Color>[
      Colors.amber.shade900,
      Colors.amber.shade300,
      Colors.amberAccent.shade100,
    ],
    LedBulbColors.red: <Color>[
      Colors.red.shade900,
      Colors.red.shade300,
      Colors.redAccent.shade100,
    ],
    LedBulbColors.off: <Color>[
      Colors.grey.shade600,
      Colors.grey.shade400,
      Colors.grey.shade50,
    ]
  };
  final Map<LedBulbColors, List<Color>> _reflectionBulbColors = {
    LedBulbColors.green: <Color>[
      Colors.white,
      Colors.white60,
      Colors.white10,
      Colors.transparent,
    ],
    LedBulbColors.yellow: <Color>[
      Colors.white,
      Colors.white60,
      Colors.white10,
      Colors.transparent,
    ],
    LedBulbColors.red: <Color>[
      Colors.white,
      Colors.white60,
      Colors.white10,
      Colors.transparent,
    ],
    LedBulbColors.off: <Color>[
      Colors.white,
      Colors.white60,
      Colors.white10,
      Colors.transparent,
    ]
  };
  final Map<LedBulbColors, Color> _borderBulbColors = {
    LedBulbColors.green: Colors.green,
    LedBulbColors.yellow: Colors.amber,
    LedBulbColors.red: Colors.red,
    LedBulbColors.off: Colors.blueGrey.shade300
  };
  final Map<LedBulbColors, Color> _glowBulbColors = {
    LedBulbColors.green: Colors.green,
    LedBulbColors.yellow: Colors.yellow,
    LedBulbColors.red: Colors.red,
    LedBulbColors.off: Colors.transparent
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(margin ?? 0),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: glow
                      ? [
                          BoxShadow(
                              color: _glowBulbColors[initialState]!,
                              blurRadius: size / 10,
                              spreadRadius: 2)
                        ]
                      : [],
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _borderBulbColors[initialState]!,
                      width: size / 15),
                  gradient: LinearGradient(
                    colors: _bulbColors[initialState]!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: size / 8,
                left: size / 5,
                width: size / 2.5,
                height: size / 2,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _reflectionBulbColors[initialState]!,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}