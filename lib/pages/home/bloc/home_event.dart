part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LogoutEvent extends HomeEvent {}

class FetchDataEvent extends HomeEvent {}

class CategorySelectedEvent extends HomeEvent {
  final Category model;

  const CategorySelectedEvent({required this.model});
}

class AddItemEvent extends HomeEvent {
  final Cart model;
  final double price;
  const AddItemEvent({required this.model, this.price = 0});
}

class AddMenuItemEvent extends HomeEvent {
  final Menu model;
  final double price;
  const AddMenuItemEvent({required this.model, this.price = 0});
}

class AddItemCodeEvent extends HomeEvent {
  final String code;
  const AddItemCodeEvent({required this.code});
}

class RemoveItemEvent extends HomeEvent {
  final Cart model;
  final double price;
  const RemoveItemEvent({required this.model, this.price = 0});
}

class ClearItemEvent extends HomeEvent {
  final Menu model;

  const ClearItemEvent({required this.model});
}

class ClearOrderEvent extends HomeEvent {}

class ClearOrderReqEvent extends HomeEvent {}
 

class SubmitOrderEvent extends HomeEvent {
  final List<Cart> carts;
  final double total;
  final double change;
  final double paymant;
  final int type;
  final String studentId;

  const SubmitOrderEvent(
      {this.type = 1,
      this.studentId = '',
      required this.carts,
      required this.total,
      required this.change,
      required this.paymant});
}

// class SubmitOrderEvent extends HomeEvent { 
//   final int type;
//   final String studentId;

//   const SubmitOrderEvent(
//       {this.type = 1,
//       this.studentId = '',
//        });
// }

// Add item by price selected
class AddItemPriceEvent extends HomeEvent {
  final Menu model;
  final MenuPrice price;
  const AddItemPriceEvent({required this.model, required this.price});
}

// Remove item by price selected
class RemoveItemPriceEvent extends HomeEvent {
  final Menu model;
  final MenuPrice price;
  const RemoveItemPriceEvent({required this.model, required this.price});
}

class ConfirmOrderEvent extends HomeEvent {
  final Menu model;
  final MenuPrice price;
  final int qty;
  const ConfirmOrderEvent(
      {required this.model, required this.price, required this.qty});
}

class AdditionalEvent extends HomeEvent {
  final Menu menu;

  const AdditionalEvent({required this.menu});
}

class ShowPaymentEvent extends HomeEvent {}

class CartRemoveItemEvent extends HomeEvent {
  final Cart cart;

  const CartRemoveItemEvent({required this.cart});
}

// class FetchStudentInfoEvent extends HomeEvent {
//   final String studentId;

//   const FetchStudentInfoEvent({ required this.studentId});
// }
