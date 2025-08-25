class SwitchPayload {
  final String? deviceId;
  final int? index;
  final int? state;

  SwitchPayload({required this.deviceId, required this.index, required this.state});

  SwitchPayload.formJson(Map<String, dynamic> json)
    : deviceId = json['device_id'],
      index = json['index'],
      state = json['state'];
}