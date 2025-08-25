import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/constants/values.dart';
import 'package:pos/model/menu_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pos/pages/home/bloc/home_bloc.dart';

class FoodCard extends StatefulWidget {
  final Menu menu;
  final bool isMobile;
  final void Function(double price)? onTap;
  final void Function()? onSelectPrice;
  const FoodCard({
    super.key,
    required this.menu,
    required this.isMobile,
    required this.onTap,
    required this.onSelectPrice,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard>
    with SingleTickerProviderStateMixin {
  Menu get menu => widget.menu; 

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: menuRoundedRectangle,
      child: InkWell(
        onTap: widget.onTap == null
            ? null
            : () {
                // selected for multi price
                if (menu.prices.isEmpty) {
                  widget.onTap!(widget.menu.price);
                } else {
                  widget.onSelectPrice!();
                }
              },
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                buildImage(),
                const SizedBox(height: 5),
                buildTitle(),
                buildPriceInfo(),
              ],
            ),
            if (widget.menu.quantity > 0)
              BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) => current is ItemCountState,
                builder: (context, state) {
                  if (state is ItemCountState) {
                    if (widget.menu.id == state.menu.id) {
                      widget.menu.quantity = state.menu.quantity;
                    }
                  }
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          widget.menu.quantity > 0
                              ? '${widget.menu.quantity}'
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (widget.menu.quantity > 0)
              BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) => current is ItemCountState,
                builder: (context, state) {
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () => {
                        BlocProvider.of<HomeBloc>(
                          context,
                        ).add(ClearItemEvent(model: menu)),
                      },
                      icon: const Icon(
                        Icons.delete,
                        size: 32,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget buildImage() {
    var size = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    var height = widget.isMobile
        ? size.width / 3.9
        : orientation == Orientation.portrait
        ? size.width / 6
        : size.width / 9;
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(menuCardRadius),
        ),
        child: CachedNetworkImage(
          imageUrl: menu.image,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
              ),
            ),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            menu.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle2,
          ),
        ],
      ),
    );
  }

  Widget buildPriceInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              !menu.prices.isNotEmpty
                  ? Text('฿${menu.price}', style: subtitleStyle)
                  : const Text('ตัวเลือก'),
            ],
          );
        },
      ),
    );
  }
}
