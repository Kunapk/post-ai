import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:pos/model/num_pad_model.dart';
import 'package:pos/pages/home/widgets/numpad_header.dart'; 

class NumpadDialog extends StatefulWidget {
  const NumpadDialog({super.key, required this.onCheckout,  required this.context, required this.totalAmount});

  final BuildContext context;
  final double? totalAmount; 
  final void Function(double change, double paymant) onCheckout;

  @override
  State<NumpadDialog> createState() => _NumpadDialogState();
}

class _NumpadDialogState extends State<NumpadDialog> {

  final TextEditingController controller = TextEditingController(text: '0.0');
  final StreamController<double> numStream =
      StreamController<double>.broadcast();
  NumberFormat formatter = NumberFormat("#,###.0#", "th-TH'");
  double totalPayment = 0.00;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumpadHeader(
          total: widget.totalAmount,
        ),
        const Divider(),
        buildNumpadCashType(),
        buildNumpadTextAmount(),
        Expanded(child: buildNumpad()),
        buildNumpadFooter(context)
      ],
    );
  }


  Widget buildNumpadCashType() {
    return Container();
  }

  Widget buildNumpadFooter(BuildContext context) {
    return StreamBuilder<double>(
      stream: numStream.stream, 
      initialData: totalPayment,
      builder: (context, snapshot) {
        return Column(
          children: [ 
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity, minHeight: 70),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton( 
                  onPressed: totalPayment >= widget.totalAmount! ? () {
                    Navigator.of(context).pop();
                    double changeAmount = totalPayment -  widget.totalAmount!; 
                    debugPrint(changeAmount.toString()); 
                    widget.onCheckout( 
                      changeAmount,
                      totalPayment
                    );
                  } : null, 
                  // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
                  style: ElevatedButton.styleFrom(
                      elevation: 4.0,
                      backgroundColor: Theme.of(context).primaryColor,
                      textStyle: const TextStyle(color: Colors.white)),
                  child: const Text(
                    'รับชำระเงิน',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget buildNumpad() {
    return SizedBox(
      height: 240,
      child: GridView.count(
          childAspectRatio: 1.2,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          crossAxisCount: 4,
          physics: const BouncingScrollPhysics(),
          children: List.generate(
            numPadData.length,
            (index) {
              NumPad numPad = numPadData[index];
              return Card(
                child: InkWell(
                  child: Center(
                    child: numPad.title,
                  ),
                  onTap: () => numPadTap(numPad),
                ),
              );
            },
          )),
    );
  }

  void numPadTap(NumPad numPad) {
    if (numPad.data >= 0) {
      if (numPad.data <= 9) {
        if (controller.text == '0') {
          controller.text = numPad.data.toString();
        } else {
          int index = controller.text.indexOf('.');
          if (index == -1) {
            controller.text = controller.text + numPad.data.toString();
          } else {
            List<String> numPointStr = controller.text.split('.');
            if (numPointStr.length == 2) {
              if (numPointStr[1].length == 2) {
                numPointStr[0] += numPad.data.toString();
              } else {
                numPointStr[1] += numPad.data.toString();
              }
              controller.text = '${numPointStr[0]}.${numPointStr[1]}';
            } else {
              controller.text += numPad.data.toString();
            }
          }
        }
        totalPayment = double.parse(controller.text);
      } else {
        totalPayment += numPad.data;
        controller.text = totalPayment.toString();
      }

      numStream.add(totalPayment);
    } else {
      if (numPad.data == -3) {
        controller.text = widget.totalAmount!.toString();
        totalPayment = widget.totalAmount!;
        numStream.add(totalPayment);
      }
      // back space
      if (numPad.data == -2) {
        if (controller.text.isNotEmpty) {
          controller.text =
              controller.text.substring(0, controller.text.length - 1);
          totalPayment = double.parse(controller.text);
        }
      }
      //.
      if (numPad.data == -1) {
        controller.text += '.';
        if (controller.text.lastIndexOf('.') + 1 <= controller.text.length) {}
      }
    }
    debugPrint('TOTAL RECEIPT: $totalPayment');
  }

  Widget buildNumpadTextAmount() {
    return StreamBuilder<double>(
      stream: numStream.stream, 
      initialData: totalPayment,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: TextField(
            style: const TextStyle(fontSize: 42),
            readOnly: true,
            controller: controller,
            textAlign: TextAlign.end,
            decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 220, 220, 220),
                border: InputBorder.none,
                hintText: '',
                prefixIcon: totalPayment != 0
                    ? IconButton(
                        onPressed: () {
                          controller.text = '0';
                          totalPayment = 0;
                          numStream.add(totalPayment);
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null),
          ),
        );
      }
    );
  }

}