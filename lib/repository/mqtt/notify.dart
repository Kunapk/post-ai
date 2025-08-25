part of 'client.dart';

abstract class Event {} 
 
class DeviceConnectedEvent extends Event {}

class DeviceDisconnectedEvent extends Event {}
 
 
class DeviceWillEvent extends Event {
  final String? deviceId;
  DeviceWillEvent({this.deviceId});
}

class DevicePongEvent extends Event {
  final String? deviceId;
  DevicePongEvent({this.deviceId});
}

class DeviceCheckinEvent extends Event {
  final String? deviceId;
  final Map<String, dynamic>? json;

  DeviceCheckinEvent({this.deviceId, this.json});
}

class RebootEvent extends Event {
  final String? deviceId;
  RebootEvent({this.deviceId});
}

class OtaEvent extends Event {
  final String? deviceId;
  OtaEvent({this.deviceId});
}

 


