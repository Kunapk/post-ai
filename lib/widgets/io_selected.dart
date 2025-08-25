import 'package:flutter/material.dart';
import 'image_provider.dart';

class IoSelected extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const IoSelected(),
    );
  }

  const IoSelected({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Image'),
        ),
        body: SafeArea(
            child: ListView.separated(
              itemCount: io.length,
              itemBuilder: (context, index) {
                var values = io.values.toList();
                var keys = io.keys.toList();
                return ListTile(
                  leading: values[index],
                  title: Text(
                    'ช่องที่ ${index + 1}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    ioDescription[index],
                    style: const TextStyle(fontSize: 16),
                  ),
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
