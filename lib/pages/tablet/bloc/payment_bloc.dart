import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos/model/cart_model.dart';
import 'package:pos/model/order_model.dart';
import 'package:pos/repository/mqtt/client.dart';   
import 'package:pos/repository/order/order_repoository.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:uuid/uuid.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final OrderRepoository _orderRepoository; 
  final DisplayClient  _displayClient; 
  bool isPrint = true;

  String? printerAddress;

  PaymentBloc({
    required OrderRepoository orderRepoository, required DisplayClient displayClient
  })  : _orderRepoository = orderRepoository, _displayClient = displayClient,
        super(PaymentInitial()) {
    on<SubmitOrderEvent>((event, emit) => _onSubmitOrder(event, emit)); 
    _loadPrinterAddress();
    if (!_displayClient.isConnected) {
      connect();
    }
  }

  Future<void> connect() async {
    await _displayClient.connect();   
  }

  void _paymentDisplayItem(double total, double received, double change )  {
    Map<String, dynamic> data = {"type": 2, "total": total, "received": received, "change": change};
    String payload = jsonEncode(data);
    String topic = "display/48057c33e864/show/display";
    _displayClient.publishMessage(topic, payload);
  }

  Future<void> _loadPrinterAddress() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    printerAddress = prefs.getString('PRIBTER');
    isPrint = printerAddress != null;
  }

  void _onSubmitOrder(
      SubmitOrderEvent event, Emitter<PaymentState> emit) async {
    var totalQty = 0;
    for (var cart in event.carts!) {
      totalQty += cart.quantity;
    }
    OrderCreate order = OrderCreate(
        totalAmount: event.total,
        totalQty: totalQty,
        paymentType: event.type,  
        cash: event.cash,
        change: event.change,
        orderDetail: []);

    for (var cart in event.carts!) {
      order.orderDetail.add(CreateOrderDetail(
          menuId: cart.menuId!,
          categoryId: cart.categoryId!,
          description: cart.title!,
          qty: cart.quantity,
          amount: cart.price!,
          totalAmount: cart.total));
    }

    debugPrint(order.toJson());

    bool? result = await _orderRepoository.createOrder(order);
    if (result!) {
      _paymentDisplayItem(event.total, event.cash, event.change);
      emit(
        PaymentSuccess(
          isPrint: isPrint, 
          cash: event.cash,
          change: event.change
        ),
      ); 
    } else {
      emit(PaymentFailed());
    }
  }
 
}
