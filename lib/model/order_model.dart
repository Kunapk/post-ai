import 'dart:convert';

class Order {
  final String? orderNo;
  final DateTime? orderDateTime;
  final double? totalAmount;
  final double? totalReceived;
  final double? change;
  final int? totalQty;
  final List<OrderItem>? orderItems;
  final bool? isVoid;
  final String? shopId;
  final String? employeeId;
  final String? posId;

  Order(
      {required this.orderNo,
      required this.orderDateTime,
      required this.totalAmount,
      required this.totalReceived,
      required this.change,
      required this.totalQty,
      required this.orderItems,
      required this.isVoid,
      required this.shopId,
      required this.employeeId,
      required this.posId});
}

class DetailAdditional {
  final String? description;
  final double? price;

  DetailAdditional({required this.description, required this.price});
}

class OrderItem {
  final String? description;
  final String? category;
  final double? price;
  final int? qty;
  final double? totalAmount;
  final List<DetailAdditional>? additionals;
  final bool? isVoid;

  OrderItem(
      {required this.description,
      required this.category,
      required this.price,
      required this.qty,
      required this.totalAmount,
      required this.additionals,
      required this.isVoid});
}

class CreateOrderDetail {
  final String menuId;
  final String categoryId;
  final String description;
  final int qty;
  final double amount;
  final double totalAmount;

  CreateOrderDetail({
    required this.menuId,
    required this.categoryId,
    required this.description,
    required this.qty,
    required this.amount,
    required this.totalAmount
  });

  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId,
      'categoryId': categoryId,
      'description': description,
      'qty': qty,
      'amount': amount,
      'total_amount': totalAmount,
    };
  }

  factory CreateOrderDetail.fromMap(Map<String, dynamic> map) {
    return CreateOrderDetail(
      menuId: map['menuId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      description: map['description'] ?? '',
      qty: map['qty']?.toInt() ?? 0,
      amount: map['amount']?.toDouble() ?? 0.0,
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CreateOrderDetail.fromJson(String source) => CreateOrderDetail.fromMap(json.decode(source));
}

class OrderCreate {
  final double totalAmount;
  final int totalQty;
  final int paymentType; 
  final double cash;
  final double change;
  final List<CreateOrderDetail> orderDetail;

  OrderCreate({
    required this.totalAmount,
    required this.totalQty,
    required this.paymentType, 
    required this.orderDetail,
    required this.cash, 
    required this.change
  });

  Map<String, dynamic> toMap() {
    return {
      'total_amount': totalAmount,
      'total_qty': totalQty,
      'payment_type': paymentType, 
      'cash': cash,
      'change': change,
      'order_detail': orderDetail.map((x) => x.toMap()).toList(),
    };
  }

  factory OrderCreate.fromMap(Map<String, dynamic> map) {
    return OrderCreate(
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
      totalQty: map['total_qty']?.toInt() ?? 0,
      paymentType: map['payment_type']?.toInt() ?? 0,
      cash: map['cash'] ?? 0.0,
      change: map['change'] ?? 0.0, 
      orderDetail: List<CreateOrderDetail>.from(map['order_detail']?.map((x) => CreateOrderDetail.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderCreate.fromJson(String source) => OrderCreate.fromMap(json.decode(source));
}

class CreateClosePeriod {
  final double totalAmount;
  final int totalBill;
  final int totalQty;
  final String description; 

  CreateClosePeriod({
    required this.totalAmount,
    required this.totalQty,
    required this.totalBill,
    required this. description, 
  });

  Map<String, dynamic> toMap() {
    return {
      'total_amount': totalAmount,
      'total_bill': totalBill,
      'total_qty': totalQty,
      'description': description, 
    };
  }

  factory CreateClosePeriod.fromMap(Map<String, dynamic> map) {
    return CreateClosePeriod(
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
      totalBill: map['total_bill']?.toInt() ?? 0,
      totalQty: map['total_qty']?.toInt() ?? 0,
      description: map['description'] ?? '', 
    );
  }

  String toJson() => json.encode(toMap());

  factory CreateClosePeriod.fromJson(String source) => CreateClosePeriod.fromMap(json.decode(source));
}
