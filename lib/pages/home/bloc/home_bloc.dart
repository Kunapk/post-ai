import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/api/api.dart';
import 'package:pos/model/cart_model.dart';
import 'package:pos/model/category_model.dart';
import 'package:pos/model/menu_model.dart';
import 'package:pos/model/order_model.dart';
import 'package:pos/repository/authen/authen_repository.dart';
import 'package:pos/repository/category/category_repository.dart';
import 'package:pos/repository/menu/menu_repository.dart';
import 'package:pos/repository/mqtt/client.dart';
import 'package:pos/repository/order/order_repoository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthenticationRepository _authenticationRepository;
  final OrderRepoository _orderRepoository;
  final MenuRepository _menuRepository;
  final CategoryRepository _categoryRepository;
  final DisplayClient _displayClient;

  static List<Category>? categories;
  static List<Menu>? menus = [];
  static List<Cart>? shoppingCarts = [];

  NumberFormat formatter = NumberFormat("#,###.0#", "th-TH'");
  bool isPrint = true;
  String? printerAddress;

  HomeBloc({
    required AuthenticationRepository authenticationRepository,
    required OrderRepoository orderRepoository,
    required MenuRepository menuRepository,
    required CategoryRepository categoryRepository,
    required DisplayClient displayClient,
  }) : _authenticationRepository = authenticationRepository,
       _orderRepoository = orderRepoository,
       _menuRepository = menuRepository,
       _categoryRepository = categoryRepository,
       _displayClient = displayClient,
       super(HomeInitial()) {
    on<LogoutEvent>((event, emit) => _onLogout(event, emit));
    on<FetchDataEvent>((event, emit) => _onFetchData(event, emit));
    on<CategorySelectedEvent>(
      (event, emit) => _onCategorySelected(event, emit),
    );
    on<RemoveItemEvent>((event, emit) => _onRemoveItem(event, emit));
    on<AddItemEvent>(
      (event, emit) => _onAddItem(event, emit),
    ); // ClearItemEvent
    on<ClearItemEvent>(
      (event, emit) => _onClearItem(event, emit),
    ); // ShowCartEvent
    on<ClearOrderEvent>((event, emit) => _onClearOrder(event, emit)); //
    on<ClearOrderReqEvent>((event, emit) => _onClearOrderReq(event, emit)); //
    on<AddItemCodeEvent>((event, emit) => _onAddItemCode(event, emit)); //
    on<AddItemPriceEvent>((event, emit) => _onAddItemPrice(event, emit));
    on<RemoveItemPriceEvent>((event, emit) => _onRemoveItemPrice(event, emit));
    on<AdditionalEvent>((event, emit) => _onUpdateCart(event, emit));

    on<AddMenuItemEvent>((event, emit) => _onAddMenuItem(event, emit));
    on<ConfirmOrderEvent>((event, emit) => _onConfirmOrder(event, emit));
    on<ShowPaymentEvent>((event, emit) => _onShowPayment(event, emit));

    on<CartRemoveItemEvent>((event, emit) => _onCartRemoveItem(event, emit));

    on<SubmitOrderEvent>((event, emit) => _onSubmitOrder(event, emit));

    _loadPrinterAddress();
    try {
      if (!_displayClient.isConnected) {
        connect();
      }
    } catch (e) {
      debugPrint('MQTT connection skipped: $e');
    }
  }

  Future<void> connect() async {
    await _displayClient.connect();
  }

  Future<void> _loadPrinterAddress() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    printerAddress = prefs.getString('PRIBTER');
    isPrint = printerAddress != null;
  }

  _onLogout(Object? event, Emitter<HomeState> emit) {
    _authenticationRepository.logOut();
  }

  void _onFetchData(FetchDataEvent event, Emitter<HomeState> emit) async {
    try {
      categories = await _categoryRepository.get();
      emit(CaterotyLoaded(categories: categories));
      if (menus!.isEmpty) {
        menus = await _menuRepository.get();
      } else {
        var newMenu = await _menuRepository.get();
        for (var menu in newMenu!) {
          var obj = menus!.where((e) => e.id == menu.id).firstOrNull;
          if (obj == null) {
            menus!.add(menu);
          }
        }
      }
      if (shoppingCarts!.isNotEmpty) {
        int count = 0;
        double total = 0;
        List<Cart> innerList = shoppingCarts!
            .where((e) => e.quantity > 0)
            .toList();
        for (var e in innerList) {
          count += e.quantity;
          total += e.total;
        }
        emit(CartCountState(carts: innerList, count: count, total: total));
      }

      emit(MenuLoaded(menus: menus));
    } catch (e) {
      if (e is ApiException) {}
      if (e is UnauthorizedException) {
        _authenticationRepository.logOut();
      }
    }
  }

  void _onCategorySelected(
    CategorySelectedEvent event,
    Emitter<HomeState> emit,
  ) async {
    for (var e in categories!) {
      e.selected = false;
      if (event.model.id == e.id) {
        e.selected = true;
      }
    }
    emit(MenuLoading());
    if (event.model.id == '0') {
      emit(MenuLoaded(menus: menus));
    } else {
      List<Menu> innerList = menus!
          .where((e) => e.categoryId == event.model.id)
          .toList();
      emit(MenuLoaded(menus: innerList));
    }
  }

  void _onRemoveItem(RemoveItemEvent event, Emitter<HomeState> emit) {
    Menu menuModel = menus!.firstWhere((e) => e.id == event.model.menuId);
    menuModel.quantity--;
    if (menuModel.quantity < 0) {
      menuModel.quantity = 0;
    }
    menuModel.price = event.price;
    emit(ItemCountState(menu: menuModel));

    Cart cart = shoppingCarts!.firstWhere(
      (e) => ((e.menuId == menuModel.id) && (e.price == menuModel.price)),
    );
    cart.quantity--;
    cart.total -= event.price;
    if (cart.quantity <= 0) {
      shoppingCarts!.remove(cart);

      /// MQTT REMOVE DISPLAY ITEM ///
      _removeDisplayItem(cart);
      //////////////////////////////
    } else {
      /// MQTT UPDATE DISPLAY ITEM ///
      _addDisplayItem(cart);
      //////////////////////////////
    }

    int count = 0;
    double total = 0;
    List<Cart> innerList = shoppingCarts!.where((e) => e.quantity > 0).toList();
    for (var e in innerList) {
      count += e.quantity;
      total += e.total;
    }
    emit(CartCountState(carts: innerList, count: count, total: total));
  }

  void _addDisplayItem(Cart cart) {
    Map<String, dynamic> data = {
      "type": 1,
      "text": cart.title,
      "id": cart.menuId,
      "qty": cart.quantity,
      "price": cart.price,
      "total": cart.total,
    };
    String payload = jsonEncode(data);
    String topic = "display/48057c33e864/show/display";
    _displayClient.publishMessage(topic, payload);
  }

  void _removeDisplayItem(Cart cart) {
    Map<String, dynamic> data = {"type": 3, "id": cart.menuId};
    String payload = jsonEncode(data);
    String topic = "display/48057c33e864/show/display";
    _displayClient.publishMessage(topic, payload);
  }

  void _paymentDisplayItem(double total, double received, double change) {
    Map<String, dynamic> data = {
      "type": 2,
      "total": total,
      "received": received,
      "change": change,
    };
    String payload = jsonEncode(data);
    String topic = "display/48057c33e864/show/display";
    _displayClient.publishMessage(topic, payload);
  }

  void _homeDisplay() {
    Map<String, dynamic> data = {"type": 0};
    String payload = jsonEncode(data);
    String topic = "display/48057c33e864/show/display";
    _displayClient.publishMessage(topic, payload);
  }

  void _onAddItem(AddItemEvent event, Emitter<HomeState> emit) {
    Menu menuModel = menus!.firstWhere((e) => e.id == event.model.menuId);
    menuModel.quantity++;
    menuModel.price = event.price;
    emit(ItemCountState(menu: menuModel));
    // shopping cart
    Cart? cart = shoppingCarts!
        .where((e) => ((e.menuId == menuModel.id) && (e.price == event.price)))
        .firstOrNull;
    if (cart == null) {
      cart = Cart(
        menuId: menuModel.id,
        categoryId: menuModel.categoryId,
        title: menuModel.name,
        price: event.price,
        quantity: 1,
        total: event.price * 1,
        image: menuModel.image,
      );
      shoppingCarts!.add(cart);
    } else {
      cart.quantity++;
      cart.total = event.price * cart.quantity;
    }

    _addDisplayItem(cart);

    int count = 0;
    double total = 0;
    List<Cart> innerList = shoppingCarts!.where((e) => e.quantity > 0).toList();
    for (var e in innerList) {
      count += e.quantity;
      total += e.total;
    }
    emit(CartCountState(carts: innerList, count: count, total: total));
    // end shopping cart
  }

  void _onClearItem(ClearItemEvent event, Emitter<HomeState> emit) {
    Menu menuModel = menus!.firstWhere((e) => e.id == event.model.id);
    menuModel.quantity = 0;
    for (var price in menuModel.prices) {
      price.quantity = 0;
    }
    emit(ItemCountState(menu: menuModel));
    // shopping cart
    List<Cart> carts = shoppingCarts!
        .where((e) => ((e.menuId == menuModel.id)))
        .toList();
    if (carts.isNotEmpty) {
      for (var cart in carts) {
        shoppingCarts!.remove(cart);

        /// MQTT REMOVE DISPLAY ITEM ///
        _removeDisplayItem(cart);
        //////////////////////////////
      }
    }

    int count = 0;
    double total = 0;
    List<Cart> innerList = shoppingCarts!.where((e) => e.quantity > 0).toList();
    for (var e in innerList) {
      count += e.quantity;
      total += e.total;
    }
    emit(CartCountState(carts: innerList, count: count, total: total));
    // end shopping cart
  }

  void _onClearOrderReq(ClearOrderReqEvent event, Emitter<HomeState> emit) {
    double total = 0;
    for (var e in shoppingCarts!) {
      total += e.total;
    }
    if (total > 0) {
      emit(ClearOrderState());
    }
  }

  // Cancel all order
  void _onClearOrder(ClearOrderEvent event, Emitter<HomeState> emit) {
    for (var e in menus!) {
      if (e.quantity != 0) {
        e.quantity = 0;
        // e.price = 0;
        for (var price in e.prices) {
          price.quantity = 0;
        }
        emit(ItemCountState(menu: e));
      }
    }
    shoppingCarts!.clear();
    //// MQTT HOME DISPLAY ////
    _homeDisplay();
    //////////////////////////
    emit(CartCountState(carts: shoppingCarts, count: 0, total: 0));
  }

  // scan barcode
  void _onAddItemCode(AddItemCodeEvent event, Emitter<HomeState> emit) {
    Menu? menuModel = menus!.where((e) => e.id == event.code).firstOrNull;
    if (menuModel != null) {
      emit(ScanFoundState());
      if (menuModel.prices.length == 1) {
        menuModel.quantity++;
        menuModel.price = menuModel.prices[0].price;
        // shopping cart
        Cart? cart = shoppingCarts!
            .where(
              (e) =>
                  ((e.menuId == menuModel.id) && (e.price == menuModel.price)),
            )
            .firstOrNull;
        if (cart == null) {
          shoppingCarts!.add(
            Cart(
              categoryId: menuModel.categoryId,
              menuId: menuModel.id,
              title: menuModel.name,
              price: menuModel.price,
              quantity: 1,
              total: menuModel.price * 1,
              image: menuModel.image,
            ),
          );
        } else {
          cart.quantity++;
          cart.total = menuModel.price * cart.quantity;
        }
        int count = 0;
        double total = 0;
        List<Cart> innerList = shoppingCarts!
            .where((e) => e.quantity > 0)
            .toList();
        for (var e in innerList) {
          count += e.quantity;
          total += e.total;
        }
        emit(CartCountState(carts: innerList, count: count, total: total));
        emit(ItemCountState(menu: menuModel));
      }
    } else {
      emit(ScanNotFoundState(code: event.code));
    }
  }

  // add item form selected menu
  void _onAddMenuItem(AddMenuItemEvent event, Emitter<HomeState> emit) {
    Menu menuModel = menus!.firstWhere((e) => e.id == event.model.id);
    menuModel.quantity++;
    menuModel.price = event.price;
    emit(ItemCountState(menu: menuModel));
    // shopping cart
    Cart? cart = shoppingCarts!
        .where((e) => ((e.menuId == menuModel.id) && (e.price == event.price)))
        .firstOrNull;
    if (cart == null) {
      cart = Cart(
        menuId: menuModel.id,
        categoryId: menuModel.categoryId,
        title: menuModel.name,
        price: event.price,
        quantity: 1,
        total: event.price * 1,
        image: menuModel.image,
      );
      shoppingCarts!.add(cart);
    } else {
      cart.quantity++;
      cart.total = event.price * cart.quantity;
    }

    ////  MQTT ADD DISPLAY ITEM ////
    _addDisplayItem(cart);
    ////////////////////////////////

    int count = 0;
    double total = 0;
    List<Cart> innerList = shoppingCarts!.where((e) => e.quantity > 0).toList();
    for (var e in innerList) {
      count += e.quantity;
      total += e.total;
    }
    emit(CartCountState(carts: innerList, count: count, total: total));
    // end shopping cart
  }

  // Add / Remove item by price selected
  void _onAddItemPrice(AddItemPriceEvent event, Emitter<HomeState> emit) {
    Menu menuModel = menus!.firstWhere((e) => e.id == event.model.id);
    menuModel.quantity++;
    event.price.quantity++;

    // menuModel.prices[event.priceIndex].quantity++;
    emit(ItemCountState(menu: menuModel));
    // shopping cart
    Cart? cart = shoppingCarts!
        .where(
          (e) => ((e.menuId == menuModel.id) && (e.price == event.price.price)),
        )
        .firstOrNull;
    if (cart == null) {
      cart = Cart(
        menuId: menuModel.id,
        categoryId: menuModel.categoryId,
        title: menuModel.name,
        price: event.price.price,
        quantity: 1,
        total: event.price.price * 1,
        image: menuModel.image,
      );
      shoppingCarts!.add(cart);
    } else {
      cart.quantity++;
      cart.total = event.price.price * cart.quantity;
    }

    //// MQTT ADD DISPLAY ITEM ////
    _addDisplayItem(cart);
    ///////////////////////////////

    int count = 0;
    double total = 0;
    List<Cart> innerList = shoppingCarts!.where((e) => e.quantity > 0).toList();
    for (var e in innerList) {
      count += e.quantity;
      total += e.total;
    }
    emit(CartCountState(carts: innerList, count: count, total: total));
    // end shopping cart
  }

  void _onRemoveItemPrice(RemoveItemPriceEvent event, Emitter<HomeState> emit) {
    Menu menuModel = menus!.firstWhere((e) => e.id == event.model.id);
    menuModel.quantity--;
    if (menuModel.quantity < 0) {
      menuModel.quantity = 0;
    }
    for (var price in menuModel.prices) {
      price.quantity--;
      if (price.quantity < 0) {
        price.quantity = 0;
      }
    }
    emit(ItemCountState(menu: menuModel));

    // shopping cart
    if (shoppingCarts!.isNotEmpty) {
      Cart cart = shoppingCarts!.firstWhere(
        (e) => ((e.menuId == menuModel.id) && (e.price == event.price.price)),
      );
      cart.quantity--;
      if (cart.quantity <= 0) {
        shoppingCarts!.remove(cart);
        // MQTT REMOVE DISPLAY ITEM
        _removeDisplayItem(cart);
      } else {
        // MQTT ADD DISPLAY ITEM
        _addDisplayItem(cart);
      }
    }

    int count = 0;
    double total = 0;
    List<Cart> innerList = shoppingCarts!.where((e) => e.quantity > 0).toList();
    for (var e in innerList) {
      count += e.quantity;
      total += e.total;
    }
    emit(CartCountState(carts: innerList, count: count, total: total));
    // end shopping cart
  }

  void _onUpdateCart(AdditionalEvent event, Emitter<HomeState> emit) {
    int count = 0;
    double total = 0;
    for (var e in shoppingCarts!) {
      count += e.quantity;
      total += e.total;
    }
    emit(CartCountState(carts: shoppingCarts, count: count, total: total));
    emit(ItemCountState(menu: event.menu));
  }

  // order selecte by price
  void _onConfirmOrder(ConfirmOrderEvent event, Emitter<HomeState> emit) {
    Menu menuModel = menus!.firstWhere((e) => e.id == event.model.id);
    menuModel.quantity += event.qty;
    event.price.quantity = event.qty;
    emit(ItemCountState(menu: menuModel));

    double totalAmpunt = event.price.price * event.qty;
    //

    Cart shopingCart = Cart(
      menuId: menuModel.id,
      categoryId: menuModel.categoryId,
      title: '${menuModel.name}(${event.price.title})',
      price: event.price.price,
      quantity: event.qty,
      total: totalAmpunt,
      image: menuModel.image,
    );
    event.price.selected = false;
    //
    shoppingCarts!.add(shopingCart);
    ///// MQTT ADD DISPLAY ITEM /////
    _addDisplayItem(shopingCart);
    ////////////////////////////////
    int count = 0;
    double total = 0;
    List<Cart> innerList = shoppingCarts!.where((e) => e.quantity > 0).toList();
    for (var e in innerList) {
      count += e.quantity;
      total += e.total;
    }
    emit(CartCountState(carts: innerList, count: count, total: total));
  }

  void _onShowPayment(ShowPaymentEvent event, Emitter<HomeState> emit) {
    double total = 0;
    // List<Cart> innerList = shoppingCarts!.where((e) => e.quantity > 0).toList();
    for (var e in shoppingCarts!) {
      total += e.total;
    }
    if (total > 0) {
      emit(PaymentState(totalAmount: total, carts: shoppingCarts));
    }

    //
  }

  void _onCartRemoveItem(CartRemoveItemEvent event, Emitter<HomeState> emit) {
    Menu menuModel = menus!.firstWhere((e) => e.id == event.cart.menuId);
    menuModel.quantity = 0;
    for (var price in menuModel.prices) {
      price.quantity = 0;
    }
    emit(ItemCountState(menu: menuModel));

    shoppingCarts!.remove(event.cart);

    /// MQTT REMOVE DISPLAY ITEM ///
    _removeDisplayItem(event.cart);
    //////////////////////////////
    int count = 0;
    double total = 0;
    List<Cart> innerList = shoppingCarts!.where((e) => e.quantity > 0).toList();
    for (var e in innerList) {
      count += e.quantity;
      total += e.total;
    }
    emit(CartCountState(carts: shoppingCarts, count: count, total: total));
  }

  void _onSubmitOrder(SubmitOrderEvent event, Emitter<HomeState> emit) async {
    var totalQty = 0;
    for (var cart in event.carts) {
      totalQty += cart.quantity;
    }
    OrderCreate order = OrderCreate(
      totalAmount: event.total,
      totalQty: totalQty,
      paymentType: event.type,
      orderDetail: [],
      cash: 0,
      change: 0,
    );

    for (var cart in event.carts) {
      order.orderDetail.add(
        CreateOrderDetail(
          menuId: cart.menuId!,
          categoryId: cart.categoryId!,
          description: cart.title!,
          qty: cart.quantity,
          amount: cart.price!,
          totalAmount: cart.total,
        ),
      );
    }

    debugPrint(order.toJson());
    bool? result = await _orderRepoository.createOrder(order);
    if (result!) {
      /// MQTT HOME DISPLAY ///
      _paymentDisplayItem(event.total, event.paymant, event.change);
      /////////////////////////
      emit(
        PaymentSuccess(
          carts: event.carts,
          totalAmount: event.total,
          change: event.change,
          payment: event.paymant,
          isPrint: isPrint,
          printerAddress: printerAddress,
        ),
      );
    } else {
      emit(PaymentFailed());
    }
  }
}
