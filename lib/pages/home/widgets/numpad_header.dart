import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NumpadHeader extends StatelessWidget {
    NumpadHeader({
    super.key,
    required this.total,
  });

  final double? total;
  final NumberFormat? formatter = NumberFormat("#,###.0#", "th-TH'");

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 8, top: 8, bottom: 8),
          child: Column(
            children: [
              const Text('ชำระเงิน'),
              Text('(฿${formatter!.format(total)})')
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              right: 8, top: 8, bottom: 8),
          child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close, color: Colors.grey,)),
        ),
      ],
    );
  }
}
