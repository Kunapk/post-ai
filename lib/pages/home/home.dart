import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/constants/values.dart';
import 'package:pos/model/cart_model.dart';
import 'package:pos/model/category_model.dart';
import 'package:pos/model/menu_model.dart';
import 'package:pos/pages/home/bloc/home_bloc.dart';
import 'package:pos/pages/home/widgets/cart_bottom_sheet.dart';
import 'package:pos/pages/home/widgets/drawer_menu.dart';
import 'package:pos/pages/home/widgets/menu_card.dart';
import 'package:pos/pages/home/widgets/numpad_dialog.dart';
import 'package:pos/pages/home/widgets/price_bottom_sheet.dart';
import 'package:pos/pages/home/widgets/print_receipt.dart';
import 'package:pos/repository/authen/authen_repository.dart';
import 'package:badges/badges.dart' as badges;
import 'package:pos/repository/category/category_repository.dart';
import 'package:pos/repository/menu/menu_repository.dart';
import 'package:pos/repository/mqtt/client.dart';
import 'package:pos/repository/order/order_repoository.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int value = 0;
  late TabController tabController2;
  final StreamController<CartCountState> menuStream =
      StreamController<CartCountState>.broadcast();
  final StreamController<Menu> menuPriceStream =
      StreamController<Menu>.broadcast();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    // tabController2 = TabController(length: 4, vsync: this, initialIndex: 0);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        authenticationRepository:
            RepositoryProvider.of<AuthenticationRepository>(context),
        menuRepository: RepositoryProvider.of<MenuRepository>(context),
        orderRepoository: RepositoryProvider.of<OrderRepoository>(context),
        categoryRepository: RepositoryProvider.of<CategoryRepository>(context),
        displayClient: RepositoryProvider.of<DisplayClient>(context),
      )..add(FetchDataEvent()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            drawerEnableOpenDragGesture: true,
            key: _key,
            body: Column(
              children: [
                _buildHeader(),
                _buildCategory(),
                Expanded(child: _buildMenu()),
              ],
            ),
            drawer: DrawerMenu(),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Material(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      _key.currentState!.openDrawer();
                    },
                    icon: const Icon(
                      Icons.menu,
                      size: headerIconSize,
                      color: Colors.white,
                    ),
                  ),
                  const Text('MENU', style: headerStyle),
                  const Spacer(),
                  BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) => current is CartCountState,
                    builder: (context, state) {
                      bool inState = state is CartCountState;
                      CartCountState? cartCountState = inState ? state : null;
                      if (inState) {
                        menuStream.add(cartCountState!);
                      }
                      return badges.Badge(
                        badgeContent: cartCountState != null
                            ? Text(
                                '${cartCountState.count}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              )
                            : const Text(
                                '0',
                                style: TextStyle(color: Colors.white),
                              ),
                        badgeStyle: const BadgeStyle(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.white,
                            style: BorderStyle.solid,
                          ),
                        ),
                        position: badges.BadgePosition.topEnd(top: -2, end: -2),
                        child: IconButton(
                          icon: const Icon(
                            Icons.shopping_cart,
                            size: headerIconSize,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showModalBottomSheet<void>(
                              isScrollControlled: true,
                              showDragHandle: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25.0),
                                  topRight: Radius.circular(25.0),
                                ),
                              ),
                              context: context,
                              builder: (_) {
                                return showCartItem(cartCountState, context);
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.person,
                      size: headerIconSize,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      size: headerIconSize,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              BlocConsumer<HomeBloc, HomeState>(
                listener: (context, state) async {
                  if (state is ItemCountState) {
                    menuPriceStream.add(state.menu);
                  }
                  if (state is ScanNotFoundState) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.warning,
                      title: 'ไม่พบข้อมูลสินค้า',
                      text: 'ผลการค้นหา ${state.code}',
                      confirmBtnText: 'ปิด',
                      textAlignment: TextAlign.center,
                    );
                  }
                  if (state is PaymentState) {
                    showNumpadDialog(context, state.carts, state.totalAmount);
                  }

                  if (state is PaymentSuccess) {
                    await Navigator.of(context).push<void>(
                      PrintReceipt.route(
                        state.carts!,
                        state.totalAmount,
                        state.change,
                        state.payment,
                        state.isPrint,
                      ),
                    );
                    if (context.mounted) {
                      BlocProvider.of<HomeBloc>(context).add(ClearOrderEvent());
                    }
                  }

                  if (state is PaymentFailed) {}
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      // controller: textController,
                      // focusNode: myFocusNode,
                      autofocus: false,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            style: BorderStyle.none,
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        filled: true,
                        hintText: "Search",
                        // border: InputBorder.none,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            style: BorderStyle.none,
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        contentPadding: const EdgeInsets.only(
                          left: 15.0,
                          top: 15.0,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            String? res =
                                await SimpleBarcodeScanner.scanBarcode(
                                  context,
                                  barcodeAppBar: const BarcodeAppBar(
                                    appBarTitle: 'Test',
                                    centerTitle: false,
                                    enableBackButton: true,
                                    backButtonIcon: Icon(Icons.arrow_back_ios),
                                  ),
                                  isShowFlashIcon: true,
                                  delayMillis: 1000,
                                  cameraFace: CameraFace.back,
                                );
                            debugPrint(res);
                            if (res != null) {
                              if (context.mounted) {
                                BlocProvider.of<HomeBloc>(
                                  context,
                                ).add(AddItemCodeEvent(code: res));
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.barcode_reader,
                            color: Colors.grey,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                      ),
                      onChanged: (text) {},
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showNumpadDialog(
    BuildContext ctx,
    List<Cart>? carts,
    double? totalAmount,
  ) {
    var screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext _) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Dialog(
              insetPadding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SizedBox(
                width: constraints.maxWidth < 500
                    ? screenSize.width * 0.95
                    : screenSize.width * 0.65, // 95% of screen width
                // height: screenSize.height * 0.7, // 50% of screen height
                height: constraints.maxWidth < 500 ? 600 : 680,
                child: NumpadDialog(
                  totalAmount: totalAmount,
                  onCheckout: (double change, double paymant) async {
                    if (context.mounted) {
                      BlocProvider.of<HomeBloc>(ctx).add(
                        // order submit
                        SubmitOrderEvent(
                          carts: carts!,
                          total: totalAmount!,
                          change: change,
                          paymant: paymant,
                        ),
                      );
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  context: context,
                ),
              ),
            );
          },
        );
      },
    );
  }

  StreamBuilder<CartCountState> showCartItem(
    CartCountState? cartCountState,
    BuildContext context,
  ) {
    return StreamBuilder<CartCountState>(
      initialData: cartCountState,
      stream: menuStream.stream,
      builder: (BuildContext conte, AsyncSnapshot<CartCountState> snapshot) {
        if (snapshot.hasData) {
          return CartBottomSheet(
            context: context,
            cartCountState: snapshot.data,
            onAddTap: (Cart model) {
              BlocProvider.of<HomeBloc>(
                context,
              ).add(AddItemEvent(model: model, price: model.price!));
            },
            onRemoveTap: (Cart model) {
              BlocProvider.of<HomeBloc>(
                context,
              ).add(RemoveItemEvent(model: model, price: model.price!));
            },
            // onCheckout: (List<Cart> carts, double total, double change,
            //     double paymant) async {
            //   Navigator.of(context).pop();

            //   if (context.mounted) {
            //     BlocProvider.of<HomeBloc>(context).add(
            //       // order submit
            //       SubmitOrderEvent(
            //           carts: carts,
            //           total: total,
            //           change: change,
            //           paymant: paymant),
            //     );
            //   }
            //   await Navigator.of(context).push<void>(
            //       PrintReceipt.route(carts, total, change, paymant),
            //     );
            //   if (context.mounted) {
            //       BlocProvider.of<HomeBloc>(context).add(ClearOrderEvent());
            //     }
            // },
            onClearCart: () {
              BlocProvider.of<HomeBloc>(context).add(ClearOrderEvent());
              Navigator.of(context).pop();
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildCategory() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Row(
            children: [
              Text("หมวดหมู่", style: titleStyle),
              Spacer(),
              Text("ทั้งหมด", style: subtitleStyle),
            ],
          ),
          SizedBox(
            height: 60,
            child: BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) => current is CaterotyLoaded,
              builder: (context, state) {
                if (state is CaterotyLoaded) {
                  List<Category>? categories = state.categories!;
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: List.generate(categories.length, (index) {
                      Category model = categories[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ChoiceChip(
                          padding: const EdgeInsets.all(10),
                          side: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                          showCheckmark: false,
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: model.selected ? Colors.white : Colors.black,
                          ),
                          label: Text(model.title),
                          selected: model.selected,
                          onSelected: (selected) {
                            BlocProvider.of<HomeBloc>(
                              context,
                            ).add(CategorySelectedEvent(model: model));
                          },
                        ),
                      );
                    }),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool mobile = constraints.maxWidth < 500;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Row(children: [Text("เมนู", style: titleStyle)]),
                  BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (previous, current) =>
                        current is MenuLoaded || current is MenuLoading,
                    builder: (_, state) {
                      if (state is MenuLoaded) {
                        List<Menu> menus = state.menus!;
                        return Expanded(
                          child: GridView.count(
                            childAspectRatio: mobile ? 0.78 : .95,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 1,
                            crossAxisCount: mobile ? 3 : 4,
                            physics: const BouncingScrollPhysics(),
                            children: menus.map((menu) {
                              return FoodCard(
                                isMobile: mobile,
                                menu: menu,
                                onTap: (double price) {
                                  BlocProvider.of<HomeBloc>(context).add(
                                    AddMenuItemEvent(model: menu, price: price),
                                  );
                                },
                                onSelectPrice: () {
                                  showModalBottomSheet<void>(
                                    isScrollControlled: true,
                                    showDragHandle: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25.0),
                                        topRight: Radius.circular(25.0),
                                      ),
                                    ),
                                    context: context,
                                    builder: (_) {
                                      return StreamBuilder<Menu>(
                                        stream: menuPriceStream.stream,
                                        initialData: menu,
                                        builder: (_, snapshot) {
                                          return PriceBottomSheet(
                                            menu: snapshot.hasData
                                                ? snapshot.data!
                                                : menu,
                                            onConfirmTap:
                                                (
                                                  Menu menu,
                                                  MenuPrice price,
                                                  int qty,
                                                ) {
                                                  Navigator.of(context).pop();
                                                  BlocProvider.of<HomeBloc>(
                                                    context,
                                                  ).add(
                                                    ConfirmOrderEvent(
                                                      model: menu,
                                                      price: price,
                                                      qty: qty,
                                                    ),
                                                  );
                                                },
                                            // onAddTap: (
                                            //   MenuPrice price,
                                            // ) {
                                            //   BlocProvider.of<HomeBloc>(context)
                                            //       .add(AddItemPriceEvent(
                                            //           model: menu, price: price));
                                            // },
                                            // onRemoveTap: (MenuPrice price) {
                                            //   BlocProvider.of<HomeBloc>(context)
                                            //       .add(RemoveItemPriceEvent(
                                            //           model: menu, price: price));
                                            // }, onAdditionalTap: (Menu menu) {
                                            //   BlocProvider.of<HomeBloc>(context)
                                            //       .add(AdditionalEvent(menu:  menu));
                                            //  },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        return Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
