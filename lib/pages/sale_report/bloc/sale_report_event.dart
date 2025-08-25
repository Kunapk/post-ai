part of 'sale_report_bloc.dart';

sealed class SaleReportEvent extends Equatable {
  const SaleReportEvent();

  @override
  List<Object> get props => [];
}

class FetchDataEvent extends SaleReportEvent {}

class FeatchOrderDetailEvent extends SaleReportEvent {
  final OrderView? order;

  const FeatchOrderDetailEvent({required this.order});
}

class ClosePeriodEvent extends SaleReportEvent {
  final String description;

  const ClosePeriodEvent({required this.description});
}
