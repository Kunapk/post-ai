import 'package:pos/api/api.dart';
import 'package:pos/model/order_model.dart';
import 'package:pos/model/order_view_model.dart';

class OrderRepoository {
  Future<bool?> createOrder(OrderCreate order) async {
    try {
      return await Api().createOrder(order);
    } on Exception {
      rethrow;
    }
  }

  Future<bool?> createClosePeriod(CreateClosePeriod model) async {
    try {
      return await Api().createClosePeriod(model);
    } on Exception {
      rethrow;
    }
  }

  Future<List<OrderView>?> getCurrentOrder() async {
    try {
      return await Api().getCurrentOrder();
    } on Exception {
      rethrow;
    }
  } 
}
