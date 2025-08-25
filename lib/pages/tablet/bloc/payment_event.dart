part of 'payment_bloc.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class SubmitOrderEvent extends PaymentEvent {
  final int type; 
  final List<Cart>? carts;
  final double total;
  final double cash;
  final double change;

  const SubmitOrderEvent({
    this.type = 1, 
    required this.carts,
    required this.total,
    required this.cash,
    required this.change
  }); 
} 

 