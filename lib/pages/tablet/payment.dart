import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:intl/intl.dart';

import 'package:pos/api/api.dart';
import 'package:pos/constants/values.dart';
import 'package:pos/model/cart_model.dart';
import 'package:pos/pages/tablet/bloc/payment_bloc.dart';
import 'package:pos/repository/mqtt/client.dart';
import 'package:pos/repository/order/order_repoository.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ordering/repository/student/student_repository.dart';
// import 'package:ordering/widgets/prompt_dialog.dart';

class MoneyModel {
  final String title;
  final double value;
  final int type;

  MoneyModel({required this.title, required this.value, required this.type});
}

List<MoneyModel> monies = [
  MoneyModel(title: '10', value: 10, type: 1),
  MoneyModel(title: '50', value: 50, type: 1),
  MoneyModel(title: '100', value: 100, type: 1),
  MoneyModel(title: '500', value: 500, type: 1),
  MoneyModel(title: '1,000', value: 1000, type: 1),
  MoneyModel(title: 'บัตรเครดิต', value: 0, type: 2),
  MoneyModel(title: 'เงินเชื่อ', value: 0, type: 3),
  MoneyModel(title: 'อื่น ๆ', value: 0, type: 4),
];

class PaymentPage extends StatefulWidget {
  static Route<bool?> route(
    BuildContext context,
    List<Cart>? carts,
    double total,
  ) {
    return MaterialPageRoute(
      builder: (_) => PaymentPage(context: context, carts: carts, total: total),
    );
  }

  const PaymentPage({
    super.key,
    required this.context,
    this.carts,
    required this.total,
  });

  final BuildContext context;
  final List<Cart>? carts;
  final double total;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  ReceiptController? controller;
  NumberFormat formatter = NumberFormat("#,###.00", "th-TH'");
  String? address;
  SharedPreferences? prefs;
  final TextEditingController textController = TextEditingController();
  int paymentType = 0;
  bool paymentState = false;

  @override
  void initState() {
    textController.text = formatter.format(widget.total);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => PaymentBloc(
          orderRepoository: RepositoryProvider.of<OrderRepoository>(context),
          displayClient: RepositoryProvider.of<DisplayClient>(context),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildTabletLayout(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        minimum: EdgeInsets.all(5),
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(paymentState);
                  },
                  icon: const Icon(
                    CupertinoIcons.back,
                    size: headerIconSize,
                    color: Colors.white,
                  ),
                ),
                const Text('ชำระเงิน', style: headerStyle),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Flexible(flex: 1, child: _buildReceipt()),
        Flexible(flex: 2, child: _buildPayment()),
      ],
    );
  }

  Widget _buildPayment() {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) async {},
      builder: (context, state) {
        if (state is PaymentInitial) {
          return _paymentPanel(context);
        }
        if (state is PaymentSuccess) {
          return _paymentSuccessPanel(state, context);
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Padding _paymentSuccessPanel(PaymentSuccess state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60.0),
      child: Center(
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        formatter.format(state.cash),
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("ยอดชำระ", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  VerticalDivider(thickness: 1, color: Colors.grey),
                  Column(
                    children: [
                      Text(
                        formatter.format(state.change),
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("เงินทอน", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 35),
            _printSlipButton(context, state.address),
            Spacer(),
            _endOfSaleButton(context),
          ],
        ),
      ),
    );
  }

  ConstrainedBox _endOfSaleButton(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: 70,
        maxHeight: 70,
      ),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.of(context).pop(true);
        },
        style: ElevatedButton.styleFrom(
          elevation: 4.0,
          backgroundColor: Theme.of(context).primaryColor,
          textStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, size: 32, color: Colors.white),
            SizedBox(width: 10),
            const Text(
              'เริ่มการขายใหม่',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ConstrainedBox _printSlipButton(BuildContext context, String? address) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: 70,
        maxHeight: 70,
      ),
      child: ElevatedButton(
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
            }
          }
          if (context.mounted && address != null) {
            PrintingProgressDialog.print(
              context,
              device: address!,
              controller: controller!,
              onProgress: (progress) {
                debugPrint(progress.toString());
                if (((progress ?? 0) * 100).round() == 100) {
                  // close print dialog
                  Navigator.of(context).pop();
                }
              },
            );
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 4.0,
          backgroundColor: Colors.blueAccent,
          textStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.print, size: 32, color: Colors.white),
            SizedBox(width: 10),
            const Text(
              'พิมพ์ใบเสร็จ',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _paymentPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  formatter.format(widget.total),
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'จำนวนเงินที่ต้องชำระ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      icon: Icon(Icons.money, size: 48),
                    ),
                    style: TextStyle(fontSize: 38),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: double.infinity,
                      minHeight: 80,
                      maxHeight: 80,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        double amount = double.parse(
                          textController.text.replaceAll(',', ''),
                        );
                        double change = amount > widget.total
                            ? amount - widget.total
                            : 0;
                        debugPrint(
                          'amount: $amount, change: $change, total: ${widget.total}',
                        );
                        BlocProvider.of<PaymentBloc>(context).add(
                          SubmitOrderEvent(
                            total: widget.total,
                            carts: widget.carts,
                            type: paymentType,
                            cash: amount,
                            change: change,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 4.0,
                        backgroundColor: Theme.of(context).primaryColor,
                        textStyle: const TextStyle(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: const Text(
                        'ชำระเงิน',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.count(
                  childAspectRatio: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  crossAxisCount: 4,
                  physics: const BouncingScrollPhysics(),
                  children: monies.map((e) {
                    return ElevatedButton(
                      onPressed: () async {
                        textController.text = formatter.format(
                          e.value == 0 ? widget.total : e.value,
                        );
                        paymentType = e.type;
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 4.0,
                        backgroundColor: Theme.of(context).primaryColor,
                        textStyle: const TextStyle(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Text(
                        e.title,
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceipt() {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (BuildContext context, PaymentState state) async {
        if (state is PaymentSuccess) {
          paymentState = true;
          Future.delayed(Duration(microseconds: 2000), () async {
            if (state.isPrint) {
              if (state.address == null) {
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
                  controller: controller!,
                  onProgress: (progress) {
                    debugPrint(progress.toString());
                    if (((progress ?? 0) * 100).round() == 100) {
                      // close print dialog
                      Navigator.of(context).pop();
                    }
                  },
                );
              }
            }
          });
        }
        if (state is PaymentFailed) {
          // TODO Show message
        }
      },
      buildWhen: (previous, current) => current is PaymentSuccess,
      builder: (context, state) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Receipt(
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Column(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Text(
                      Api().storeName!,
                      style: headerReceipt,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      'สาขา: 00001',
                      style: headerReceipt,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 4),
                    child: Text(
                      '----------------------',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FixedColumnWidth(100),
                    },
                    children: List.generate(widget.carts!.length, (index) {
                      Cart cart = widget.carts![index];
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, right: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Text(
                      '----------------------',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: Table(
                      columnWidths: const {1: IntrinsicColumnWidth()},
                      children: [
                        TableRow(
                          children: [
                            const Text('รวมทั้งหมด', style: itemTotalReceipt),
                            Text(
                              '฿${formatter.format(widget.total)}',
                              style: itemTotalReceipt,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (state is PaymentSuccess)
                    Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 25),
                      child: Table(
                        columnWidths: const {1: IntrinsicColumnWidth()},
                        children: [
                          TableRow(
                            children: [
                              const Text(
                                'ยอดที่ชำระ',
                                style: TextStyle(fontSize: 22),
                              ),
                              Text(
                                '฿${formatter.format(state.cash)}',
                                style: TextStyle(fontSize: 22),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Text(
                                'เงินทอน',
                                style: TextStyle(fontSize: 22),
                              ),
                              Text(
                                '฿${formatter.format(state.change)}',
                                style: TextStyle(fontSize: 22),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      '*** ขอบคุณที่ใช้บริการ ***',
                      textAlign: TextAlign.center,
                      style: itemReceipt,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 120.0),
                    child: Text(
                      '      -      ',
                      textAlign: TextAlign.center,
                      style: itemReceipt,
                    ),
                  ),
                ],
              );
            },

            onInitialized: (controller) {
              this.controller = controller;
            },
          ),
        );
      },
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
      addFeeds: 5,
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
      child: SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Printing Receipt',
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
                    await FlutterBluetoothPrinter.disconnect(widget.device);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Disconnect'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
