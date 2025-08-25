import 'package:flutter/material.dart';

class DeviceMenu extends StatelessWidget {
  const DeviceMenu({
    super.key,
    required this.context,
    required this.title,
    this.onTap,
    required this.icon,
  });

  final BuildContext context;
  final VoidCallback? onTap;
  final String? title;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: InkWell(
        splashColor: Theme.of(context).primaryColor.withOpacity(.5),
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 15, left: 12, bottom: 0, right: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon == null ? Container() : icon!,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title!),
              )
            ],
          ),
        ),
      ),
    );
  }
}
