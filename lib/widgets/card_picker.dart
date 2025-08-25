import 'package:flutter/material.dart';

class CardPicker extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onNew;

  const CardPicker(
      {super.key,
      required this.title,
      required this.child,
      this.onNew,
      this.onEdit});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      splashRadius: 24,
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    onEdit == null
                        ? Container()
                        : IconButton(
                            splashRadius: 24,
                            onPressed: onEdit,
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                          ),
                    onNew == null
                        ? Container()
                        : IconButton(
                            splashRadius: 24,
                            onPressed: onNew,
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                          ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
