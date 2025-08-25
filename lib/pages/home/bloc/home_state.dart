part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

final class MenuLoading extends HomeState {}

final class ScanFoundState extends HomeState {}

final class ClearOrderState extends HomeState {}

final class ScanNotFoundState extends HomeState {
  final String? code;
  final String uuid = const Uuid().v4();

  ScanNotFoundState({required this.code});

  @override
  List<Object> get props => [code!, uuid];
}

class CaterotyLoaded extends HomeState {
  final List<Category>? categories;
  final String uuid = const Uuid().v4();

  CaterotyLoaded({this.categories});

  @override
  List<Object> get props => [categories!, uuid];
}

class MenuLoaded extends HomeState {
  final List<Menu>? menus;
  final String uuid = const Uuid().v4();

  MenuLoaded({this.menus});

  @override
  List<Object> get props => [menus!, uuid];
}

class ItemCountState extends HomeState {
  final Menu menu;
  final String uuid = const Uuid().v4();

  ItemCountState({required this.menu});

  @override
  List<Object> get props => [menu, uuid];
}

class CartCountState extends HomeState {
  final int count;
  final double total;
  final List<Cart>? carts;
  final String uuid = const Uuid().v4();

  CartCountState({
    required this.carts,
    required this.count,
    required this.total,
  });

  @override
  List<Object> get props => [carts!, count, total, uuid];
}

class PaymentState extends HomeState {
  final double totalAmount;
  final List<Cart>? carts;
  final String uuid = const Uuid().v4();

  PaymentState({required this.totalAmount, required this.carts});

  @override
  List<Object> get props => [totalAmount, carts!, uuid];
}

final class PaymentSuccess extends HomeState {
  final double totalAmount;
  final double change;
  final double payment;
  final List<Cart>? carts;
  final bool isPrint;
  final String? printerAddress;

  const PaymentSuccess({
    required this.carts,
    required this.totalAmount,
    required this.change,
    required this.payment,
    this.printerAddress,
    this.isPrint = false,
  });
}

final class PaymentFailed extends HomeState {}
