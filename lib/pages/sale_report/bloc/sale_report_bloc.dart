import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pos/api/api.dart';
import 'package:pos/model/order_model.dart';
import 'package:pos/model/order_view_model.dart';
import 'package:pos/repository/order/order_repoository.dart';
import 'package:uuid/uuid.dart';

part 'sale_report_event.dart';
part 'sale_report_state.dart';

class SaleReportBloc extends Bloc<SaleReportEvent, SaleReportState> {
  final OrderRepoository _orderRepoository;
  List<OrderView>? views;
  int totalQty = 0;
  int orderQty = 0;
  double totalAmount = 0.0;

  SaleReportBloc({required OrderRepoository orderRepoository})
      : _orderRepoository = orderRepoository,
        super(SaleReportInitial()) {
    on<FetchDataEvent>((event, emit) => _onFetchData(event, emit));
    on<FeatchOrderDetailEvent>(
        (event, emit) => _onFeatchOrderDetail(event, emit));
    // ClosePeriodEvent
    on<ClosePeriodEvent>((event, emit) => _onClosePeriod(event, emit));
  }

  void _onFetchData(FetchDataEvent event, Emitter<SaleReportState> emit) async {
    views = await _orderRepoository.getCurrentOrder();
    for (var e in views!) {
      totalQty += e.totalQty;
      totalAmount += e.totalAmount;
    }
    orderQty = views!.length;
    emit(FetchDataState(
        views: views!,
        orderQty: orderQty,
        totalAmount: totalAmount,
        totalQty: totalQty));
  }

  void _onFeatchOrderDetail(
      FeatchOrderDetailEvent event, Emitter<SaleReportState> emit) {
    for (var e in views!) {
      e.selected = false;
    }
    event.order!.selected = true;
    //
    emit(FetchDataState(
        views: views!,
        orderQty: orderQty,
        totalAmount: totalAmount,
        totalQty: totalQty));
    //
    emit(FetcOrderDetailState(views: event.order!.orderDetail));
  }

  void _onClosePeriod(
      ClosePeriodEvent event, Emitter<SaleReportState> emit) async {
    CreateClosePeriod closePerod = CreateClosePeriod(
      totalAmount: totalAmount,
      totalQty: totalQty,
      totalBill: orderQty,
      description: event.description, 
    );
   
    try {
       bool? result = await _orderRepoository.createClosePeriod(closePerod);
      if (result!) {
        emit(ClosePeriodSuccessState());
      } else {
        emit(ClosePeriodFailedState());
      }
    } on ApiException catch (error) {
      debugPrint(error.message);
    } on UnauthorizedException catch (_) {
      
    }
  }
}
