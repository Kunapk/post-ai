part of 'client.dart';

class BrokerConfig {
  String broker = '152.42.170.154';
  int port = 1883;
  String username = 'app';
  String passwd = 'lxQDVvAGxGcNxHST5leT';
  String clientIdentifier = '';

  BrokerConfig() {
    var uuid = const Uuid();
    clientIdentifier = uuid.v4();
    debugPrint('[MQTT Client] client id: $clientIdentifier');
  }
}
