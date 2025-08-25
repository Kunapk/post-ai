import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/constants/values.dart';
import 'package:pos/model/cart_model.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:pos/model/menu_model.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintReceipt extends StatefulWidget {
  static Route route(
    List<Cart> carts,
    double total,
    double change,
    double paymant,
    bool isPrint,
  ) {
    return MaterialPageRoute<void>(
      builder: (_) => PrintReceipt(
        isPrint: isPrint,
        carts: carts,
        total: total,
        change: change,
        paymant: paymant,
      ),
    );
  }

  final bool isPrint;
  final List<Cart> carts;
  final double total;
  final double change;
  final double paymant;
  const PrintReceipt({
    super.key,
    required this.isPrint,
    required this.carts,
    required this.total,
    required this.change,
    required this.paymant,
  });

  @override
  State<PrintReceipt> createState() => _PrintReceiveState();
}

class _PrintReceiveState extends State<PrintReceipt> {
  String? address;
  ReceiptController? controller;
  NumberFormat formatter = NumberFormat("#,###.00", "th-TH'");
  SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildHeader(context),
          Expanded(child: buildReceipt(context)),
        ],
      ),
    );
  }

  Widget buildFooter() {
    return Container();
  }

  Widget buildReceipt(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Receipt(
                backgroundColor: Colors.grey.shade200,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [ 
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          'ร้านหมื่นแปดพันเก้า',
                          style: headerMobileReceipt,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          'สาขา: 00001',
                          style: headerMobileReceipt,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          'TAX# 0000000000000',
                          style: headerMobileReceipt,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          'เสร็จรับเงิน/ใบกำกับภาษีอย่างย่อ',
                          style: headerMobileReceipt,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          '(VAT Included)',
                          style: headerMobileReceipt,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // const Divider(thickness: 2),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: Text('------------------------'),
                      ),
                      Table(
                        columnWidths: const {
                          0: IntrinsicColumnWidth(),
                          1: FixedColumnWidth(100),
                        },
                        children: List.generate(widget.carts.length, (index) {
                          Cart cart = widget.carts[index];
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8,
                                  right: 0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            '${cart.title}',
                                            style: itemReceipt,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            '${cart.quantity}x${cart.price}',
                                            style: itemReceipt,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (cart.additionals.isNotEmpty)
                                      ...List.generate(cart.additionals.length, (
                                        index,
                                      ) {
                                        AdditionalPrice additional =
                                            cart.additionals[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: Text(
                                            '+${additional.title}(${additional.price})',
                                            style: itemReceipt,
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  formatter.format(cart.total),
                                  textAlign: TextAlign.end,
                                  style: itemReceipt,
                                ),
                              ),
                              // TableCell(child: Text("xxx"),)
                            ],
                          );
                        }),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: Text('------------------------'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 25),
                        child: Table(
                          columnWidths: const {1: IntrinsicColumnWidth()},
                          children: [
                            TableRow(
                              children: [
                                const Text(
                                  'รวมทั้งหมด',
                                  style: itemTotalMobileReceipt,
                                ),
                                Text(
                                  formatter.format(widget.total),
                                  style: itemTotalMobileReceipt,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Table(
                        columnWidths: const {1: IntrinsicColumnWidth()},
                        children: [
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Text('เงินสด', style: itemReceipt),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  formatter.format(widget.paymant),
                                  textAlign: TextAlign.end,
                                  style: itemReceipt,
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Text('เงินทอน', style: itemReceipt),
                              widget.change != 0
                                  ? Text(
                                      formatter.format(widget.change),
                                      textAlign: TextAlign.end,
                                      style: itemReceipt,
                                    )
                                  : const Text(
                                      '0.00',
                                      textAlign: TextAlign.end,
                                      style: itemReceipt,
                                    ),
                            ],
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: Text('------------------------'),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Text(
                          '*** ขอบคุณที่ใช้บริการ ***',
                          textAlign: TextAlign.center,
                          style: itemReceipt,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
                onInitialized: (controller) {
                  this.controller = controller;
                  var screenSize = MediaQuery.of(context).size;
                  Future.delayed(const Duration(milliseconds: 200), () async {
                    if (widget.isPrint) {
                      if (address == null) {
                        prefs ??= await SharedPreferences.getInstance();
                        address = prefs!.getString('PRIBTER');
                        if (context.mounted) {
                          final selectedAddress =
                              address ??
                              (await FlutterBluetoothPrinter.selectDevice(
                                context,
                              ))?.address;
                          if (selectedAddress != null) {
                            address = selectedAddress;
                            prefs!.setString('PRIBTER', selectedAddress);
                          }
                        }
                      }
                      if (context.mounted && address != null) {
                        PrintingProgressDialog.print(
                          context,
                          device: address!,
                          controller: controller,
                          onProgress: (progress) {
                            debugPrint(progress.toString());
                            if (progress == 1.0) {
                              Navigator.of(context).pop();
                              QuickAlert.show(
                                width: constraints.maxWidth < 500 ? screenSize.width * .8 : screenSize.width * .5,
                                context: context,
                                type: QuickAlertType.success,
                                title: 'เงินทอน ฿${widget.change}',
                                autoCloseDuration: const Duration(seconds: 5),
                                showConfirmBtn: false,
                              );
                            }
                          },
                        );
                      }
                    } else {
                      if (context.mounted) {
                        QuickAlert.show(
                          width: constraints.maxWidth < 500 ? screenSize.width * .8 : screenSize.width * .5,
                          context: context,
                          type: QuickAlertType.success,
                          title: 'เงินทอน ฿${widget.change}',
                          autoCloseDuration: const Duration(seconds: 5),
                          showConfirmBtn: false,
                        );
                      }
                    }
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildHeader(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: headerIconSize,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const Text('พิมพ์ใบเสร็จรับเงิน', style: headerStyle),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.print,
                      size: headerIconSize,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (address == null) {
                        prefs ??= await SharedPreferences.getInstance();
                        address = prefs!.getString('PRIBTER');
                        if (context.mounted) {
                          final selectedAddress =
                              address ??
                              (await FlutterBluetoothPrinter.selectDevice(
                                context,
                              ))?.address;
                          address = selectedAddress;
                          prefs!.setString('PRIBTER', selectedAddress!);
                        }
                      }
                      if (context.mounted) {
                        if (context.mounted && address != null) {
                          PrintingProgressDialog.print(
                            context,
                            device: address!,
                            controller: controller!,
                            onProgress: (progress) {
                              debugPrint(progress.toString());
                              if (progress == 1.0) {
                                Navigator.of(context).pop();
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  title: 'สำเร็จ!',
                                  autoCloseDuration: const Duration(seconds: 3),
                                  showConfirmBtn: false,
                                );
                              }
                            },
                          );
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      size: headerIconSize,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final selected =
                          await FlutterBluetoothPrinter.selectDevice(context);
                      if (selected != null) {
                        address = selected.address;
                        prefs ??= await SharedPreferences.getInstance();
                        prefs!.setString('PRIBTER', address!);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef ProgressCalback = void Function(double? progress);

class PrintingProgressDialog extends StatefulWidget {
  final String device;
  final ReceiptController controller;
  final ProgressCalback onProgress;
  const PrintingProgressDialog({
    super.key,
    required this.device,
    required this.controller,
    required this.onProgress,
  });

  @override
  State<PrintingProgressDialog> createState() => _PrintingProgressDialogState();

  static void print(
    BuildContext context, {
    required String device,
    required ReceiptController controller,
    required ProgressCalback onProgress,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrintingProgressDialog(
        controller: controller,
        device: device,
        onProgress: onProgress,
      ),
    );
  }
}

class _PrintingProgressDialogState extends State<PrintingProgressDialog> {
  double? progress;
  @override
  void initState() {
    super.initState();
    widget.controller.print(
      address: widget.device,
      addFeeds: 2,
      keepConnected: true,
      onProgress: (total, sent) {
        if (mounted) {
          setState(() {
            progress = sent / total;
            widget.onProgress(progress);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'กำลังพิมพ์ใบเสร็จรับเงิน',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 4),
            Text('Processing: ${((progress ?? 0) * 100).round()}%'),
            if (((progress ?? 0) * 100).round() == 100) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // await FlutterBluetoothPrinter.disconnect(widget.device);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('ปิด'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
