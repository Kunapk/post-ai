part of 'sale_report_bloc.dart';

sealed class SaleReportState extends Equatable {
  const SaleReportState();

  @override
  List<Object> get props => [];
}

final class SaleReportInitial extends SaleReportState {}

class FetchDataState extends SaleReportState {
  final List<OrderView> views;
  final int totalQty;
  final int orderQty;
  final double totalAmount;
  final String uuid = const Uuid().v4();

  FetchDataState({
    required this.views,
    required this.totalQty,
    required this.orderQty,
    required this.totalAmount
  });

  @override
  List<Object> get props => [views, totalAmount, totalQty, uuid];
}

class FetcOrderDetailState extends SaleReportState {
  final List<OrderDetailView>? views;
  final String uuid = const Uuid().v4();

  FetcOrderDetailState({
    this.views,
  });

  @override
  List<Object> get props => [views!, uuid];
}

class ClosePeriodSuccessState extends SaleReportState{
  final String uuid = const Uuid().v4();
  ClosePeriodSuccessState();
  @override
  List<Object> get props => [uuid];
}

class ClosePeriodFailedState extends SaleReportState{
  final String uuid = const Uuid().v4();
  ClosePeriodFailedState();
  @override
  List<Object> get props => [uuid];
}
