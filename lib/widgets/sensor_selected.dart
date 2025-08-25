import 'package:flutter/material.dart';
import 'image_provider.dart';

class SensorSelected extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const SensorSelected(),
    );
  }

  const SensorSelected({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Image'),
        ),
        body: SafeArea(
            child: ListView.separated(
              itemCount: sensorType.length,
              itemBuilder: (context, index) {
                var values = sensorType.values.toList();
                var keys = sensorType.keys.toList();
                return ListTile(
                  leading: values[index],
                  onTap: () {
                    Navigator.of(context).pop(keys[index]);
                  },
                );
              },
              padding: const EdgeInsets.all(15),
              separatorBuilder: (_, int index) => const Divider(
                color: Colors.grey,
              ),
            )));
  }
}
