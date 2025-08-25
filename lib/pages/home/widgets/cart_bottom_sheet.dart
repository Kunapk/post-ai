import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/constants/values.dart';
import 'package:pos/model/cart_model.dart';
// import 'package:ordering/model/num_pad_model.dart';
import 'package:pos/pages/home/bloc/home_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({
    super.key,
    required this.context,
    required this.cartCountState,
    required this.onAddTap,
    required this.onRemoveTap,
    required this.onClearCart,
  });
  final BuildContext context;
  final CartCountState? cartCountState;
  final void Function(Cart cart) onAddTap;
  final void Function(Cart cart) onRemoveTap;
  final void Function() onClearCart;

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  // final Stream<List<Menu>> stream;
  final TextEditingController controller = TextEditingController(text: '0.0');
  final StreamController<double> numStream =
      StreamController<double>.broadcast();

  double totalPayment = 0;
  NumberFormat formatter = NumberFormat("#,###.0#", "th-TH'");

  @override
  void initState() {
    initializeDateFormatting(
      'th-TH',
      null,
    ).then((_) => debugPrint('initializeDateFormatting::th-TH'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          height: constraints.maxWidth < 500 ? MediaQuery.of(context).size.height * .60 : MediaQuery.of(context).size.height * .50,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                buildTitle(context),
                widget.cartCountState!.count > 0
                    ? buildItemsList()
                    : const Expanded(
                        child: Center(
                          // child: Text('Not Found'),
                          child: Icon(
                            Icons.remove_shopping_cart,
                            size: 128,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                widget.cartCountState!.count > 0
                    ? const Divider()
                    : Container(),
                widget.cartCountState!.count > 0
                    ? buildPriceInfo()
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }

  Row buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              splashColor: Colors.white60,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Text('ตะกร้าสินค้า', style: headerStyle2),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.delete_forever,
                size: 32,
                color: Colors.red,
              ),
              splashColor: Colors.white60,
              onPressed: widget.onClearCart,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPriceInfo() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('รวม:', style: footerStyle),
              Text(
                '฿${formatter.format(widget.cartCountState!.total)}',
                style: footerStyle,
              ),
            ],
          ),
        ),
        const Divider(),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 56,
            minWidth: double.infinity,
          ),
          child: SizedBox.expand(
            child: ElevatedButton(
              onPressed: () {
                BlocProvider.of<HomeBloc>(
                  widget.context,
                ).add(ShowPaymentEvent());
              },
              style: ElevatedButton.styleFrom(
                elevation: 4.0,
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(color: Colors.white),
              ),
              child: const Text(
                'ชำระเงิน',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Expanded buildItemsList() {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: widget.cartCountState != null
            ? ListView.builder(
                itemCount: widget.cartCountState!.carts!.length,
                itemBuilder: (context, index) {
                  Cart cart = widget.cartCountState!.carts![index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                    minVerticalPadding: 1,
                    leading: SizedBox(
                      width: MediaQuery.of(context).size.width / 6.5,
                      height: MediaQuery.of(context).size.width / 6.5,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                          bottom: Radius.circular(8),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: cart.image!,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    title: Text(cart.title!, style: titleStyle2),
                    subtitle: Text('฿ ${cart.total}', style: titleStyle2),
                    // trailing: Text('x ${model.quantity}', style: subtitleStyle),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              widget.onRemoveTap(cart);
                            },
                            icon: const Icon(
                              Icons.remove_circle,
                              size: 32,
                              color: Colors.red,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                              vertical: 1,
                            ),
                            child: Text('${cart.quantity}', style: titleStyle),
                          ),
                          IconButton(
                            onPressed: () {
                              widget.onAddTap(cart);
                            },
                            icon: Icon(
                              Icons.add_circle,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : const Center(child: Text('Not Found')),
      ),
    );
  }
}
