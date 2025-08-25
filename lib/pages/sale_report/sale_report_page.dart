import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pos/constants/values.dart';
import 'package:pos/model/order_view_model.dart';
import 'package:pos/pages/sale_report/bloc/sale_report_bloc.dart';
import 'package:pos/repository/order/order_repoository.dart';

class SaleReportPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const SaleReportPage(),
    );
  }

  const SaleReportPage({super.key});

  @override
  State<SaleReportPage> createState() => _SaleReportPageState();
}

class _SaleReportPageState extends State<SaleReportPage> {
  final DateFormat formatDateTime = DateFormat('d/M/y H:m:s', 'th-TH');
  final DateFormat formatTime = DateFormat('H:m:s', 'th-TH');
  final NumberFormat formatNumber = NumberFormat("#,###.00", "th-TH'");
  @override
  void initState() {
    initializeDateFormatting('th-TH', null)
        .then((_) => debugPrint('initializeDateFormatting::th-TH'));

    // DateFormat format = DateFormat.yMMMd('th-TH');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SaleReportBloc(
          orderRepoository: RepositoryProvider.of<OrderRepoository>(context),
        )..add(FetchDataEvent()),
        child: BlocBuilder<SaleReportBloc, SaleReportState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildTabletLayout(context),
                )
              ],
            );
          },
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
        child: BlocConsumer<SaleReportBloc, SaleReportState>(
          listener: (context, state) { 
            if (state is ClosePeriodSuccessState) {
              Navigator.of(context).pop();
            }
            if (state is ClosePeriodFailedState) {}
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            CupertinoIcons.back,
                            size: headerIconSize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text('รายการขายสินค้า', style: headerStyle),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                        child: IconButton(
                          onPressed: () async {
                            var result = await _showTextInputDialog(context);
                            if (result != null) {
                              if (context.mounted) { 
                                BlocProvider.of<SaleReportBloc>(context)
                                    .add(ClosePeriodEvent(description: result)); 
                              }
                            }
                          },
                          icon: const Icon(
                            CupertinoIcons.cloud_upload,
                            size: headerIconSize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  final _textFieldController = TextEditingController();

  Future<String?> _showTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('บันทีกกข้อความปิดรอบการขาย'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * .5,
              child: TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: "หมายเหตุ"),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("ยกเลิก"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('ยืนยัน'),
                onPressed: () =>
                    Navigator.pop(context, _textFieldController.text),
              ),
            ],
          );
        });
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(children: [
      Flexible(
        flex: 1,
        child: BlocBuilder<SaleReportBloc, SaleReportState>(
          buildWhen: (previous, current) => current is FetchDataState,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'สรุปยอดขายประจำวัน',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: state is FetchDataState
                              ? Table(columnWidths: const {
                                  0: FlexColumnWidth(),
                                  1: FixedColumnWidth(100),
                                }, children: [
                                  TableRow(children: [
                                    const Text('จำนวนรายการ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text('${state.totalQty}',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold))
                                  ]),
                                  TableRow(children: [
                                    const Text('จำนวน',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text('${state.orderQty}',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold))
                                  ]),
                                  TableRow(children: [
                                    const Text('จำนวนเงิน',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        '฿${formatNumber.format(state.totalAmount)}',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold))
                                  ])
                                ])
                              : Container(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: _buildMasterOrder(context, state),
                )
              ],
            );
          },
        ),
      ),
      const VerticalDivider(),
      Flexible(
        flex: 2,
        child: BlocBuilder<SaleReportBloc, SaleReportState>(
          builder: (context, state) {
            return _buildDetailOrder(state);
          },
        ),
      ),
    ]);
  }

  Widget _buildDetailOrder(SaleReportState state) {
    if (state is FetcOrderDetailState) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Card(
          child: ListView.separated(
              itemBuilder: (context, index) {
                OrderDetailView detail = state.views![index];
                return ListTile(
                  title: Text(
                    detail.description,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    formatNumber.format(detail.totalAmount),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${detail.qty} x ${detail.amount}'),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: state.views!.length),
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              child: Icon(
                Icons.signal_cellular_no_sim_outlined,
                size: 128,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('เลือกรายการข้อมูล'),
            )
          ],
        ),
      );
    }
  }

  Widget _buildMasterOrder(BuildContext ctx, SaleReportState state) {
    if (state is FetchDataState) {
      return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          OrderView order = state.views[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
            minVerticalPadding: 1,
            selected: order.selected,
            selectedColor: Colors.white,
            selectedTileColor: Theme.of(context).primaryColor,
            title: Text(
              'เวลา: ${formatTime.format(order.orderDateTime)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    formatNumber.format(order.totalAmount),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(CupertinoIcons.forward)
                ],
              ),
            ), 
            onTap: () {
              BlocProvider.of<SaleReportBloc>(ctx).add(
                FeatchOrderDetailEvent(order: order),
              );
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
        itemCount: state.views.length,
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      );
    }
  }
}
