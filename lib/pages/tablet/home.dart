import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:intl/intl.dart';
import 'package:pos/constants/values.dart';
import 'package:pos/model/category_model.dart';
import 'package:pos/model/menu_model.dart';
import 'package:pos/pages/home/bloc/home_bloc.dart';
import 'package:pos/pages/home/widgets/menu_card.dart';
import 'package:pos/pages/home/widgets/price_bottom_sheet.dart';
import 'package:pos/pages/sale_report/sale_report_page.dart';
import 'package:pos/pages/tablet/payment.dart';
import 'package:pos/repository/authen/authen_repository.dart';
import 'package:pos/repository/category/category_repository.dart';
import 'package:pos/repository/localized/languages.dart';
import 'package:pos/repository/menu/menu_repository.dart';
import 'package:pos/repository/mqtt/client.dart';
import 'package:pos/repository/order/order_repoository.dart';
import 'package:pos/repository/theme/theme_repository.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabletHome extends StatefulWidget {
  const TabletHome({super.key});

  @override
  State<TabletHome> createState() => _TabletHomeState();
}

class _TabletHomeState extends State<TabletHome> {
  final StreamController<CartCountState> menuStream =
      StreamController<CartCountState>.broadcast();
  final StreamController<Menu> menuPriceStream =
      StreamController<Menu>.broadcast();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  NumberFormat formatter = NumberFormat("#,###.0#", "th-TH'");

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
    ThemeRepository theme = RepositoryProvider.of<ThemeRepository>(context);

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
                _buildHeader(context),
                Expanded(child: _buildTabletLayout(context)),
              ],
            ),
            drawer: _buildDrawer(theme, context),
          );
        },
      ),
    );
  }

  Drawer _buildDrawer(ThemeRepository theme, BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  stops: const [0.1, 0.9],
                  colors: [
                    theme.currentTheme!.drawerGradientStartColor!,
                    theme.currentTheme!.drawerGradientEndColor!,
                  ],
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "POS SYSTEM",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              color: Theme.of(context).primaryColor,
              Icons.print_rounded,
              size: 32,
            ),
            title: const Text('ตั้งค่าเครื่องพิมพ์'),
            onTap: () async {
              Navigator.of(context).pop();
              final selectedDevice = await FlutterBluetoothPrinter.selectDevice(
                context,
              );
              if (selectedDevice != null) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('PRIBTER', selectedDevice.address);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              color: Theme.of(context).primaryColor,
              Icons.view_list,
              size: 32,
            ),
            title: const Text('รายการขาย'),
            onTap: () async {
              Navigator.of(context).pop();
              await Navigator.of(context).push(SaleReportPage.route());
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              color: Theme.of(context).primaryColor,
              Icons.list,
              size: 32,
            ),
            title: const Text('รายการสินค้า'),
            onTap: () async {
              Navigator.of(context).pop();
              // await Navigator.of(context).push(
              //   About.route(),
              // );
            },
          ),
          const Divider(),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                title: Text(Languages.of(context)!.logOut),
                onTap: () async {
                  Navigator.pop(context);
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (_) => CupertinoActionSheet(
                      title: Text(Languages.of(context)!.confirm),
                      message: Text(Languages.of(context)!.confirmLogout),
                      actions: <CupertinoActionSheetAction>[
                        CupertinoActionSheetAction(
                          child: Text(
                            Languages.of(context)!.labaelConfirmLogout,
                          ),
                          onPressed: () {
                            context.read<HomeBloc>().add(LogoutEvent());
                            // Navigator.pop(context);
                          },
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        isDestructiveAction: true,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(Languages.of(context)!.cancel),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Column(
            children: [
              _buildCategory(),
              Expanded(child: _buildMenu()),
            ],
          ),
        ),
        Flexible(flex: 1, child: _buildSaleList(context)),
      ],
    );
  }

  // +++++++++++++++++++ Sale page +++++++++++++++++++
  Card _buildSaleList(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Column(
        children: [
          BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) async {
              if (state is PaymentState) {
                bool? result = await Navigator.of(context).push<bool?>(
                  PaymentPage.route(context, state.carts, state.totalAmount),
                );
                if (result != null) {
                  if (result) {
                    if (context.mounted) {
                      BlocProvider.of<HomeBloc>(context).add(ClearOrderEvent());
                    }
                  }
                }
              }
              if (state is ClearOrderState) {
                if (context.mounted) {
                  await QuickAlert.show(
                    context: context,
                    type: QuickAlertType.confirm,
                    title: 'คุณแน่ใจหรือไม่?',
                    text: 'ต้องการยกเลิกรายการสั่งซื้อหรือไม่?',
                    confirmBtnText: 'ใช่',
                    cancelBtnText: 'ไม่',
                    confirmBtnColor: Colors.green,
                    width: 350,
                    onConfirmBtnTap: () {
                      if (context.mounted) {
                        BlocProvider.of<HomeBloc>(
                          context,
                        ).add(ClearOrderEvent());
                      }
                      Navigator.pop(context);
                    },
                  );
                }
              }
            },
            builder: (context, state) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("รายการขาย", style: TextStyle(fontSize: 18)),
                    Spacer(),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          // List Items
          _saleListItems(),
          const Divider(),
          // Footer
          _saleFooter(size),
          // Button footer
          _buttonFooter(size, context),
        ],
      ),
    );
  }

  Expanded _saleListItems() {
    return Expanded(
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) => current is CartCountState,
        builder: (context, state) {
          if (state is CartCountState) {
            return ListView(
              children: List.generate(state.carts!.length, (index) {
                var cart = state.carts![index];
                return Dismissible(
                  direction: DismissDirection.startToEnd,
                  key: Key(cart.menuId!),
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      BlocProvider.of<HomeBloc>(
                        context,
                      ).add(CartRemoveItemEvent(cart: cart));
                    }
                  },
                  confirmDismiss: (direction) async {
                    return true;
                  },
                  child: ListTile(
                    title: Text(
                      '${cart.title!} x ${cart.quantity}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      '฿${formatter.format(cart.total)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Row _buttonFooter(Size size, BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: SizedBox(
            height: size.height * .1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: double.infinity,
                minHeight: 80,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<HomeBloc>(context).add(ShowPaymentEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 4.0,
                    backgroundColor: Theme.of(context).primaryColor,
                    textStyle: const TextStyle(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Text(
                    'ชำระเงิน',
                    style: TextStyle(
                      fontSize: size.height * .03,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: SizedBox(
            height: size.height * .1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: double.infinity,
                minHeight: 80,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (context.mounted) {
                      BlocProvider.of<HomeBloc>(
                        context,
                      ).add(ClearOrderReqEvent());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 4.0,
                    backgroundColor: Colors.amber.shade700,
                    textStyle: const TextStyle(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Text(
                    'ยกเลิก',
                    style: TextStyle(
                      fontSize: size.height * .03,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BlocBuilder<HomeBloc, HomeState> _saleFooter(Size size) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) => current is CartCountState,
      builder: (context, state) {
        if (state is CartCountState) {
          return ListTile(
            title: Text(
              'รวม',
              style: TextStyle(
                fontSize: size.height * .03,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              '฿${formatter.format(state.total)}',
              style: TextStyle(
                fontSize: size.height * .03,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          return ListTile(
            title: Text(
              'รวม',
              style: TextStyle(
                fontSize: size.height * .03,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              '0.0',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          );
        }
      },
    );
  }
  // +++++++++++++++++++ Sale page +++++++++++++++++++

  Widget _buildCategory() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
      child: Column(
        children: [
          const Row(
            children: [
              Text("หมวดหมู่", style: titleStyle),
              Spacer(),
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
        return Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 1),
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
                        childAspectRatio: 0.78,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        crossAxisCount: 5,
                        physics: const BouncingScrollPhysics(),
                        children: menus.map((menu) {
                          return FoodCard(
                            isMobile: false,
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
  }

  Widget _buildHeader(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        minimum: EdgeInsets.all(5),
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.center,
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
            IconButton(
              onPressed: () {
                BlocProvider.of<HomeBloc>(context).add(FetchDataEvent());
              },
              icon: const Icon(
                Icons.refresh,
                size: headerIconSize,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
