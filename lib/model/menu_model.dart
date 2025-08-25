class Menu {
  final String id;
  final String categoryId; 
  final String name;
  final String? description;
  final List<MenuPrice> prices;
  // final List<AdditionalPrice>? additional;
  final String image;
  int quantity;
  double price;

  Menu(
      {required this.id,
      required this.categoryId, 
      required this.name,
      this.description,
      required this.prices, 
      this.quantity = 0,
      this.price = 0,
      required this.image});

  Menu.formJson(Map<String, dynamic> json, String imageUrl)
  : id = json['_id'],
    categoryId = json['categoryId'], 
    name = json['name'],
    description = json['description'],
    quantity = 0,
    prices =   List<Map<String, dynamic>>.from(json['prices']).map((e) => MenuPrice.formJson(e)).toList(),
    // prices = [],
    price = json['price'].toDouble(),
    image = json['image'] == 'no-image.png' ? '$imageUrl${json['image']}' : '$imageUrl${json['userId']}/${json['image']}';
}

class MenuPrice {
  final String title;
  final double price;
  int quantity;
  bool selected;

  MenuPrice({required this.title, required this.price, this.selected = false, this.quantity = 0});

  MenuPrice.formJson(Map<String, dynamic> json)
  : title = json['title'],
  price = json['price'].toDouble(),
  selected = false,
  quantity = 0;
}

class AdditionalPrice {
  final String title;
  final double price;
  bool selected;

  AdditionalPrice(
      {required this.title, required this.price, this.selected = false});
}

// hot_americano.jpeg
// ice_americano.jpeg
// List<Menu> menuTest = [
//   Menu(
//       id: '27078',
//       categoryId: '1',
//       name: 'คาปูชิโน่',
//       description: 'คาปูชิโน่',
//       quantity: 0,
//       image: 'hot_cappuccino.jpeg',
//       prices: [
//         MenuPrice(title: 'ร้อน', price: 45),
//         MenuPrice(title: 'เย็น', price: 60),
//         MenuPrice(title: 'ปั่น', price: 65)
//       ], ),
//   Menu(
//       id: '27012',
//       categoryId: '1',
//       name: 'เอสเปรสโซ',
//       description: 'อเมริกาโน้เย็ร',
//       quantity: 0,
//       image: 'ice_americano.jpeg',
//       prices: [
//         MenuPrice(title: 'ร้อน', price: 35),
//         MenuPrice(title: 'เย็น', price: 55),
//         MenuPrice(title: 'ปั่น', price: 60)
//       ],
//       ),
//   Menu(
//       id: '27013',
//       categoryId: '1',
//       name: 'มอคค่า',
//       description: 'มอคค่า',
//       quantity: 0,
//       image: 'ice_latte.jpeg',
//       prices: [
//         MenuPrice(title: 'ร้อน', price: 35),
//         MenuPrice(title: 'เย็น', price: 55),
//         MenuPrice(title: 'ปั่น', price: 60)
//       ],
//       ),
//   Menu(
//       id: '27014',
//       categoryId: '1',
//       name: 'ลาเต้',
//       description: 'ลาเต้ร้อน',
//       quantity: 0,
//       image: 'hot_latte.jpeg',
//        prices: [
//         MenuPrice(title: 'ร้อน', price: 35),
//         MenuPrice(title: 'เย็น', price: 55),
//         MenuPrice(title: 'ปั่น', price: 60)
//       ],
//        ),
//   Menu(
//       id: '7',
//       categoryId: '2',
//       name: 'โกโก้เย็น',
//       description: 'โกโก้เย็น',
//       quantity: 0,
//       image: 'ice_cocoa.jpeg',
//       prices: [MenuPrice(title: 'ปกติ', price: 120)]),
//   Menu(
//       id: '27015',
//       categoryId: '2',
//       name: 'โกโก้ร้อน',
//       description: 'โกโก้ร้อน',
//       quantity: 0,
//       image: 'hot_cocoa.jpeg',
//       prices: [MenuPrice(title: 'ปกติ', price: 150)]),
//   Menu(
//       id: '27016',
//       categoryId: '3',
//       name: 'กุ้งแก้ว',
//       description: 'กุ้งแก้ว',
//       quantity: 0,
//       image: 'no-image.png',
//       prices: [MenuPrice(title: 'ปกติ', price: 50)]),
//   Menu(
//       id: '27017',
//       categoryId: '3',
//       name: 'ข้าวโพกพัน',
//       description: 'ข้าวโพกพัน',
//       quantity: 0,
//       image: 'no-image.png',
//       prices: [MenuPrice(title: 'ปกติ', price: 80)]),
//   Menu(
//       id: '27018',
//       categoryId: '3',
//       name: 'ขนมจีบ',
//       description: 'ขนมจีบ',
//       quantity: 0,
//       image: 'no-image.png',
//       prices: [MenuPrice(title: 'ปกติ', price: 50)]),
//   Menu(
//       id: '27019',
//       categoryId: '4',
//       name: 'ข้าวขาหมู',
//       description: 'ข้าวขาหมู',
//       quantity: 0,
//       image: 'pork_leg_rice.jpg',
//       prices: [MenuPrice(title: 'ปกติ', price: 50)]),
//   Menu(
//       id: '27020',
//       categoryId: '4',
//       name: 'หยกขาหมู',
//       description: 'หยกขาหมู',
//       quantity: 0,
//       image: 'no-image.png',
//       prices: [MenuPrice(title: 'ปกติ', price: 50)]),
// ];
