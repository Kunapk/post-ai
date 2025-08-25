part of 'payment_bloc.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

final class PaymentInitial extends PaymentState {}

final class PaymentSuccess extends PaymentState { 
  final bool isPrint;
  final String? address;
  final double change;
  final double cash;
  final String uuid = const Uuid().v4();

  PaymentSuccess({ this.isPrint = true, required this.cash, required this.change, this.address});
  @override
  List<Object> get props => [uuid];
}

class StudentScanSuccess extends PaymentState { 
  final String uuid = const Uuid().v4();

  StudentScanSuccess( );
  @override
  List<Object> get props => [uuid];
}

class StudentScanNotFound extends PaymentState {}

final class PaymentFailed extends PaymentState {}
