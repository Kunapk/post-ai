import 'package:flutter/material.dart';

Map<int, Widget> sensorType = {
  1: Image.asset('assets/modbus.png', width: 24),
  2: Image.asset('assets/lora.png', width: 24),
};
Map<int, Widget> sensorType64 = {
  1: Image.asset('assets/modbus.png', width: 64),
  2: Image.asset('assets/lora.png', width: 64),
};

Map<int, Widget> icon = {
  0: Image.asset('assets/power.png', color: Colors.blue, width: 48),
  1: Image.asset('assets/valve.png', color: Colors.blue, width: 48),
  2: Image.asset('assets/pump.png', color: Colors.blue, width: 48),
  3: Image.asset('assets/lamp.png', color: Colors.blue, width: 48),
  4: Image.asset('assets/plug.png', color: Colors.blue, width: 48),
  5: Image.asset('assets/exhaust-fan.png', color: Colors.blue, width: 48),
};

Map<int, Widget> iconEdit = {
  0: Image.asset('assets/power.png', color: Colors.blue, width: 64),
  1: Image.asset('assets/valve.png', color: Colors.blue, width: 64),
  2: Image.asset('assets/pump.png', color: Colors.blue, width: 64),
  3: Image.asset('assets/lamp.png', color: Colors.blue, width: 64),
  4: Image.asset('assets/plug.png', color: Colors.blue, width: 64),
  5: Image.asset('assets/exhaust-fan.png', color: Colors.blue, width: 64),
};

Map<String, Image> weatherIcon = {
  '01d': Image.asset('assets/01d.png'),
  '02d': Image.asset('assets/02d.png'),
  '03d': Image.asset('assets/03d.png'),
  '04d': Image.asset('assets/04d.png'),
  '09d': Image.asset('assets/09d.png'),
  '10d': Image.asset('assets/10d.png'),
  '11d': Image.asset('assets/11d.png'),
  '01n': Image.asset('assets/01n.png'),
  '02n': Image.asset('assets/02n.png'),
  '03n': Image.asset('assets/03n.png'),
  '04n': Image.asset('assets/04n.png'),
  '09n': Image.asset('assets/09n.png'),
  '10n': Image.asset('assets/10n.png'),
  '11n': Image.asset('assets/11n.png'),
  '50n': Image.asset(
    'assets/50n.png',
    color: Colors.white,
  ),
  '50d': Image.asset(
    'assets/50d.png',
    color: Colors.white,
  )
};

Map<int, Widget> io = {
  0: Image.asset('assets/relay.png', width: 64),
  1: Image.asset('assets/relay.png', width: 64),
  2: Image.asset('assets/relay.png', width: 64),
  3: Image.asset('assets/relay.png', width: 64),
  4: Image.asset('assets/valve_3d.png', width: 64),
  5: Image.asset('assets/valve_3d.png', width: 64),
  6: Image.asset('assets/valve_3d.png', width: 64),
  7: Image.asset('assets/valve_3d.png', width: 64),
  8: Image.asset('assets/valve_3d.png', width: 64),
  9: Image.asset('assets/valve_3d.png', width: 64),
  10: Image.asset('assets/valve_3d.png', width: 64),
  11: Image.asset('assets/valve_3d.png', width: 64),
};

Map<int, Widget> ioSelected = {
  0: Image.asset('assets/relay.png', width: 32),
  1: Image.asset('assets/relay.png', width: 32),
  2: Image.asset('assets/relay.png', width: 32),
  3: Image.asset('assets/relay.png', width: 32),
  4: Image.asset('assets/valve_3d.png', width: 32),
  5: Image.asset('assets/valve_3d.png', width: 32),
  6: Image.asset('assets/valve_3d.png', width: 32),
  7: Image.asset('assets/valve_3d.png', width: 32),
  8: Image.asset('assets/valve_3d.png', width: 32),
  9: Image.asset('assets/valve_3d.png', width: 32),
  10: Image.asset('assets/valve_3d.png', width: 32),
  11: Image.asset('assets/valve_3d.png', width: 32),
};

List<String> ioDescription = [
  'Relay Output',
  'Relay Output',
  'Relay Output',
  'Relay Output',
  'Mosfet Output',
  'Mosfet Output',
  'Mosfet Output',
  'Mosfet Output',
  'Mosfet Output',
  'Mosfet Output',
  'Mosfet Output',
  'Mosfet Output',
];
