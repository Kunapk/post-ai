import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:pos/pages/home/bloc/home_bloc.dart';
import 'package:pos/pages/sale_report/sale_report_page.dart';
import 'package:pos/repository/localized/languages.dart';
import 'package:pos/repository/theme/theme_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeRepository theme = RepositoryProvider.of<ThemeRepository>(context);
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
              // await Navigator.of(context).push(
              //   About.route(),
              // );
              final selected = await FlutterBluetoothPrinter.selectDevice(
                context,
              );
              if (selected != null) {
                String address = selected.address;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('PRIBTER', address);
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
}
