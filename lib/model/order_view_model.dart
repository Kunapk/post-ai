import 'dart:convert';

class OrderStudent {
  final String studentId;
  final String firstName;
  final String lastName;

  OrderStudent({required this.studentId, required this.firstName, required this.lastName});
 

  factory OrderStudent.fromMap(Map<String, dynamic> map) {
    return OrderStudent(
      studentId: map['student_id'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
    );
  }
 

  factory OrderStudent.fromJson(String source) => OrderStudent.fromMap(json.decode(source));
}

class OrderDetailView {
  final String description;
  final int qty;
  final num amount;
  final num totalAmount;

  OrderDetailView({
    required this.description,
    required this.qty,
    required this.amount,
    required this.totalAmount
  });
 
  factory OrderDetailView.fromMap(Map<String, dynamic> map) {
    return OrderDetailView(
      description: map['description'] ?? '',
      qty: map['qty']?.toInt() ?? 0,
      amount: map['amount'] ?? 0,
      totalAmount: map['total_amount'] ?? 0,
    );
  }


  factory OrderDetailView.fromJson(String source) => OrderDetailView.fromMap(json.decode(source));
}

class OrderView {
  final DateTime orderDateTime;
  final double totalAmount;
  final int totalQty;
  final int paymentType;
  final OrderStudent? orderStudent;
  final List<OrderDetailView> orderDetail;
   bool selected = false;

  OrderView({
    required this.orderDateTime,
    required this.totalAmount,
    required this.totalQty,
    required this.paymentType,
    required this.orderStudent,
    required this.orderDetail
  });
 

  factory OrderView.fromMap(Map<String, dynamic> map) {
    return OrderView(
      orderDateTime: DateTime.parse(map['order_datetime']),
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
      totalQty: map['total_qty']?.toInt() ?? 0,
      paymentType: map['payment_type']?.toInt() ?? 0,
      orderStudent: map.containsKey('student') ? OrderStudent.fromMap(map['student']) : null,
      // orderDetail: []
      orderDetail: List<OrderDetailView>.from(map['orderdetails']?.map((x) => OrderDetailView.fromMap(x))),
    );
  }
 
  factory OrderView.fromJson(String source) => OrderView.fromMap(json.decode(source));
}
