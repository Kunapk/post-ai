import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos/constants/values.dart';
import 'package:pos/model/menu_model.dart';

class PriceBottomSheet extends StatefulWidget {
  final Menu menu;
  // final void Function(MenuPrice price) onAddTap;
  // final void Function(MenuPrice price) onRemoveTap;
  // final void Function(Menu menu) onAdditionalTap;
  final void Function(Menu menu, MenuPrice price, int qty) onConfirmTap;
  const PriceBottomSheet(
      {super.key, required this.menu, required this.onConfirmTap});

  @override
  State<PriceBottomSheet> createState() => _PriceBottomSheetState();
}

class _PriceBottomSheetState extends State<PriceBottomSheet> {
  final StreamController<List<MenuPrice>> priceStream =
      StreamController<List<MenuPrice>>.broadcast();
  final StreamController<List<AdditionalPrice>> additionalStream =
      StreamController<List<AdditionalPrice>>.broadcast();
  final StreamController<int> quantityStream =
      StreamController<int>.broadcast();

  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.width < 500 ? size.height * .60 : size.height * .70;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildTitle(context),
            // if (widget.menu.additional != null) buildAdditional(context),
            if (widget.menu.prices.isNotEmpty) ...[
              const SizedBox(
                height: 5,
              ),
              Expanded(child: buildChoicePriceList()),
              buildFooterQty(),
              SizedBox(
                height: 70,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth: double.infinity, minHeight: 70),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: confirmOrder,
                      style: ElevatedButton.styleFrom(
                        elevation: 4.0,
                        backgroundColor: Theme.of(context).primaryColor,
                        textStyle: const TextStyle(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (widget.menu.prices.isEmpty)
              const Expanded(
                child: Center(
                  child: Icon(
                    Icons.remove_shopping_cart,
                    size: 128,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void confirmOrder() {
    MenuPrice? selectedPrice =
        widget.menu.prices.where((e) => e.selected).firstOrNull;
    if (selectedPrice != null) {
      widget.onConfirmTap(widget.menu, selectedPrice, quantity);
    }
  }

  Widget buildFooterQty() {
    return StreamBuilder<int>(
        stream: quantityStream.stream,
        initialData: quantity,
        builder: (context, snapshot) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  quantity--;
                  if (quantity < 1) {
                    quantity = 1;
                  }
                  quantityStream.add(quantity);
                },
                icon: const Icon(
                  Icons.remove_circle,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1),
                child: Text('$quantity',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: () {
                  quantity++;
                  quantityStream.add(quantity);
                },
                icon: Icon(
                  Icons.add_circle,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          );
        });
  }

  // Widget buildAdditional(BuildContext context) {
  //   return StreamBuilder<List<AdditionalPrice>>(
  //       stream: additionalStream.stream,
  //       initialData: widget.menu.additional!,
  //       builder: (context, snapshot) {
  //         return SizedBox(
  //           height: 70,
  //           child: ListView(
  //             scrollDirection: Axis.horizontal,
  //             physics: const BouncingScrollPhysics(),
  //             children: List.generate(
  //               widget.menu.additional!.length,
  //               (index) {
  //                 AdditionalPrice model = widget.menu.additional![index];
  //                 return Padding(
  //                   padding: const EdgeInsets.all(4.0),
  //                   child: ChoiceChip(
  //                     side: const BorderSide(width: 0, style: BorderStyle.none),
  //                     showCheckmark: false,
  //                     selectedColor: Theme.of(context).primaryColor,
  //                     labelStyle: TextStyle(
  //                         color: model.selected ? Colors.white : Colors.black),
  //                     label: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [Text(model.title), Text('฿${model.price}')],
  //                     ),
  //                     selected: model.selected,
  //                     onSelected: (selected) {
  //                       model.selected = selected;
  //                       additionalStream.add(widget.menu.additional!);
  //                       // widget.onAdditionalTap(widget.menu);
  //                       // BlocProvider.of<HomeBloc>(context)
  //                       //     .add(CategorySelectedEvent(model: model));
  //                     },
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         );
  //       });
  // }

  Widget buildChoicePriceList() {
    return StreamBuilder<List<MenuPrice>>(
      stream: priceStream.stream,
      initialData: widget.menu.prices,
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            MenuPrice price = widget.menu.prices[index];
            return ListTile(
              // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
              minVerticalPadding: 1,
              selectedColor: Theme.of(context).primaryColor,
              selected: price.selected,
              subtitle: Text('฿${price.price}', style: subtitleStyle),
              title: Text(price.title, style: priceTitleStyle),
              trailing: price.selected
                  ? Icon(
                      Icons.check,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () {
                for (var e in widget.menu.prices) {
                  e.selected = false;
                }
                price.selected = true;
                priceStream.add(widget.menu.prices);
              },
            );
          },
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
            Text(widget.menu.name, style: headerStyle2),
          ],
        ),
        const Spacer()
      ],
    );
  }
}
