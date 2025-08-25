import 'package:pos/model/menu_model.dart';

class Cart {
  final String? menuId;
  final String? categoryId;
  final String? title;
  final double? price;
  int quantity;
  double total;
  List<AdditionalPrice> additionals = [];
  final String? image;

  Cart(
      {required this.menuId,
      required this.categoryId,
      required this.title,
      required this.price,
      this.quantity = 0,
      this.total = 0, 
      required this.image});
}
