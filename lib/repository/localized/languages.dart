import 'package:flutter/material.dart';

abstract class Languages {
  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  String get appName;

  String get labelWelcome;

  String get labelInfo;

  String get labelAbout;

  String get labelSelectLanguage;

  String get labelVersion;

  String get wifiSetup;

  String get logOut;

  String get deleteAccount;

  String get selectedMode;

  String get theme;

  String get confirm;

  String get ok;

  String get cancel;

  String get confirmLogout;

  String get labaelConfirmLogout;

  String get confirmDelUser;

  String get labelConfirmDelUser;

  // Home
  String get labelNewDevice;

  String get lbSomethingWentWrong;

  String get lbAddBySerial;

  String get lbAddByQrCode;

  String get confirmDelete;

  String get wantDelete;

  String get confirmYes;

  // Sensor
  String get lbTemperature;

  String get lbHumidity;

  String get lbLight;

  String get lbSoil;

  // Edit device
  String get titleEditDevice;

  String get titleNewDevice;

  String get lbSubmitFail;

  String get lbSave;

  String get lbDeviceName;

  String get lbDeviceId;

  // Device
  String get close;

  String get lbNotFound;

  String get lbConnectionTimeout;

  String get lbLastUpdate;

  String get lbTimer;

  String get lbAuto;

  String get lbEdit;

  String get lbDelete;

  String get btnNewFarm;

  String get lbNewFarm;

  String get btnNewDevice;

  String get lbGreenHouseStatus;

  // Device IO
  String get lbNotiIo;

  // Timer
  String get titleTimer;

  // Edit Timer
  String get titleEditTimer;
  String get titleNewTimer;
  String get lbMonday;
  String get lbTuesday;
  String get lbWednesday;
  String get lbThursday;
  String get lbFriday;
  String get lbSaturday;
  String get lbSunday;
  String get lbStartTime;
  String get lbQuantity;
  String get lbStopType;
  String get lbSecond;
  String get lbMinute;
  String get lbHour;
  String get lbServerCall;

  // Auto
  String get titleAuto;
  String get lbUse;
  String get lbOpen;
  String get lbMinimum;
  String get lbMaximum;

  // editor farm
  String get inputFarmName;
  String get inputDescription;
  String get inputLongitude;
  String get inputLatitude;
  String get newFarmTitle;
  String get editFarmTitle;

  // gpio editor
  String get newGpioTitle;
  String get editGpioTitle;
  String get gpioName;
  String get gpioDescription;
  String get gpioChannel;
  String get gpioSymbol;

  String get lbButtonSave;

  // device setting
  String get deviceSettingTitle;
  String get lbFirmwareVersion;
  String get lbButtonRestart;
  String get lbButtonUpdateFirmware;
  String get lbButtonSensorType;
  String get lbButtonModbusSensor;
  String get lbButtonModbusRelay;
  String get lbConfirmUpdate;
  String get lbConfirmRestart;

  String get lbDeviceDisconnected;

  String get lbSensorType;

  // modbus
  String get lbChannel;
  // output relay editor
  String get lbName;
  String get lbDescription;
  String get lbRegStartAddress;
  String get lbModbusAddress;
  String get lbRegCount;
  String get lbRegAddress;
  String get lbDecimalPoint;
  String get lbUnit;
  String get lbDisplay;
}

class LanguageEn extends Languages {
  // modbus
  @override
  String get lbDisplay => "Display name";
  @override
  String get lbUnit => "Display Unit";
  @override
  String get lbDecimalPoint => "Decimal point";
  @override
  String get lbChannel => "Channel";
  @override
  String get lbName => "Name";
  @override
  String get lbDescription => "Description";
  @override
  String get lbRegStartAddress => "Register start address";
  @override
  String get lbModbusAddress => "Modbus address";
  @override
  String get lbRegCount => "Register count";
  @override
  String get lbRegAddress => "Register address";

  @override
  String get lbSensorType => "Sensor Type";

  @override
  String get lbDeviceDisconnected => "Device disconnected";
  // device setting
  @override
  String get lbConfirmRestart => "Are you sure you want restart device?";
  @override
  String get lbConfirmUpdate => "Are you sure you want Firmware Update?";
  @override
  String get deviceSettingTitle => "Device Setting";
  @override
  String get lbFirmwareVersion => "Firmware Version";
  @override
  String get lbButtonRestart => "Restart Device";
  @override
  String get lbButtonUpdateFirmware => "Firmware Update";
  @override
  String get lbButtonSensorType => "Sensor Type";
  @override
  String get lbButtonModbusSensor => "MODBUS Sensor";
  @override
  String get lbButtonModbusRelay => "MODBUS Relay";

  // gpio editor
  @override
  String get newGpioTitle => "New Control Channel";
  @override
  String get editGpioTitle => "Edit Control Channel";
  @override
  String get gpioName => "Name";
  @override
  String get gpioDescription => "Description";
  @override
  String get gpioChannel => "Control Channel";
  @override
  String get gpioSymbol => "Symbol";

  // editor farm
  @override
  String get newFarmTitle => "New Farm";
  @override
  String get editFarmTitle => "Edit Farm";
  @override
  String get inputFarmName => "Farm Name";
  @override
  String get inputDescription => "Description";
  @override
  String get inputLongitude => "Longitude";
  @override
  String get inputLatitude => "Latitude";

  @override
  String get lbButtonSave => "Save";

  @override
  String get selectedMode => "Selected manual mode";

  @override
  String get btnNewDevice => "Add new device";

  @override
  String get lbNewFarm => "New farm";

  @override
  String get btnNewFarm => "Add new farm";

  @override
  String get lbMinimum => "Minimum";

  @override
  String get lbMaximum => "Maximum";

  @override
  String get lbOpen => "Open";

  @override
  String get lbUse => "Action";

  @override
  String get titleAuto => "Auto Start";

  @override
  String get lbSecond => "Second";

  @override
  String get lbMinute => "Minute";

  @override
  String get lbHour => "Hour";

  @override
  String get lbStartTime => "Start time";

  @override
  String get lbQuantity => "Quantity";

  @override
  String get lbStopType => "Stop type";

  @override
  String get lbMonday => "Mon";

  @override
  String get lbTuesday => "Tue";

  @override
  String get lbWednesday => "Wed";

  @override
  String get lbThursday => "Thu";

  @override
  String get lbFriday => "Fri";

  @override
  String get lbSaturday => "Sat";

  @override
  String get lbSunday => "Sun";

  @override
  String get titleEditTimer => "Edit timer";

  @override
  String get titleNewTimer => "New timer";

  @override
  String get titleTimer => "Timer";

  @override
  String get lbServerCall => "Process by server";

  @override
  String get lbNotiIo => "Notify me when it works";

  @override
  String get lbEdit => "Edit";

  @override
  String get lbDelete => "Delete";

  @override
  String get lbTimer => "Timer";

  @override
  String get lbAuto => "Auto";

  @override
  String get lbLastUpdate => "Last update:";

  @override
  String get lbConnectionTimeout => "Connection Timeout";

  @override
  String get lbNotFound => "Not Found";

  @override
  String get close => "Close";

  @override
  String get lbDeviceName => "Device name";

  @override
  String get lbDeviceId => "Device serial";

  @override
  String get lbSave => "Save";

  @override
  String get lbSubmitFail => "Submited Failure";

  @override
  String get titleNewDevice => "New";

  @override
  String get titleEditDevice => "Edit";

  @override
  String get lbTemperature => "Temperature";

  @override
  String get lbHumidity => "Humidity";

  @override
  String get lbLight => "Light";

  @override
  String get lbSoil => "Soil";

  @override
  String get confirmDelete => "Confirm delete?";

  @override
  String get wantDelete => "Are you sure you want to delete";

  @override
  String get confirmYes => "";

  @override
  String get lbAddBySerial => "Add by serial";

  @override
  String get lbAddByQrCode => "Add by QR Code";

  @override
  String get lbSomethingWentWrong => "Something went wrong";

  @override
  String get labelNewDevice => "Add new you device";

  @override
  String get confirmDelUser => "are you sure you want to delete";

  @override
  String get labelConfirmDelUser => "Confirm Delete";

  @override
  String get confirmLogout => "are you sure you want to log out";

  @override
  String get labaelConfirmLogout => "Confirm Logout";

  @override
  String get confirm => "Confirm";

  @override
  String get ok => "OK";

  @override
  String get cancel => "Cancel";

  @override
  String get wifiSetup => "Device WIFI Setup";

  @override
  String get logOut => "Logout";

  @override
  String get deleteAccount => "Delete Account";

  @override
  String get theme => "Theme";

  @override
  String get labelVersion => "Version";

  @override
  String get labelAbout => "About";

  @override
  String get appName => "NOOB MAKER";

  @override
  String get labelWelcome => "Welcome";

  @override
  String get labelSelectLanguage => "Select Language";

  @override
  String get labelInfo => "Smart Agriculture";

  @override
  String get lbGreenHouseStatus => "Device control status";
}

class LanguageTh extends Languages {
// modbus
  @override
  String get lbDisplay => "ชื่อแสดงข้อมูล";
  @override
  String get lbUnit => "หน่วยการแสดงผล";
  @override
  String get lbDecimalPoint => "ตำแหน่งจุดทศนิยม";
  @override
  String get lbChannel => "ช่องที่";
  @override
  String get lbName => "ชื่อ";
  @override
  String get lbDescription => "รายละเอียด";
  @override
  String get lbRegStartAddress => "ตำแหน่งเรจิสเตอร์เริ่มต้น";
  @override
  String get lbModbusAddress => "หมายเลขอุปกรณ์";
  @override
  String get lbRegCount => "จำนวนเรจิสเตอร์";
  @override
  String get lbRegAddress => "ตำแหน่งเรจิสเตอร์";

  @override
  String get lbSensorType => "กำหนดเซนเซอร์วัดภูมิอากาศ";

  @override
  String get lbDeviceDisconnected => "อุปกรณ์ไม่มีการเชื่อมต่อ";
  // device setting
  @override
  String get lbConfirmRestart => "ต้องการเริ่มต้นทำงานอุปกรณ์ใหม่ จริงหรือไม่";
  @override
  String get lbConfirmUpdate => "ต้องการปรับปรุงเฟิร์มแวร์ จริงหรือไม่";
  @override
  String get deviceSettingTitle => "ตั้งค่าอุปกรณ์";
  @override
  String get lbFirmwareVersion => "รุ่นของเฟิร์มแวร์";
  @override
  String get lbButtonRestart => "เริ่มต้นทำงานอุปกรณ์ใหม่";
  @override
  String get lbButtonUpdateFirmware => "ปรับปรุง Firmware";
  @override
  String get lbButtonSensorType => "ประเภทเซนเซอร์วัดอุณหภูมิ";
  @override
  String get lbButtonModbusSensor => "MODBUS เซนเซอร์";
  @override
  String get lbButtonModbusRelay => "MODBUS รีเลย์";

  // gpio editor
  @override
  String get newGpioTitle => "เพิ่มส่วนควบคุม";
  @override
  String get editGpioTitle => "แก้ไขส่วนควบคุม";
  @override
  String get gpioName => "ชื่อ";
  @override
  String get gpioDescription => "รายละเอียด";
  @override
  String get gpioChannel => "ช่องควบคุม";
  @override
  String get gpioSymbol => "สัญลักษณ์";

  // editor farm
  @override
  String get newFarmTitle => "เพิ่มฟาร์ใหม่";
  @override
  String get editFarmTitle => "แก้ไขข้อมูลฟาร์ม";
  @override
  String get inputFarmName => "ชื่อฟาร์ม";
  @override
  String get inputDescription => "รายละเอียด";
  @override
  String get inputLongitude => "Longitude";
  @override
  String get inputLatitude => "Latitude";

  @override
  String get lbButtonSave => "บันทึก";

  @override
  String get selectedMode => "โหมดควบคุมการทำวานด้วยมือ";

  @override
  String get btnNewDevice => "เพิ่มบอร์ด";

  @override
  String get lbNewFarm => "เพิ่มฟาร์ม";

  @override
  String get btnNewFarm => "เพิ่มฟาร์มใหม่ของคุณที่นี่";

  @override
  String get lbMinimum => "จุดต่ำสุด";

  @override
  String get lbMaximum => "จุดสูงสุด";

  @override
  String get lbOpen => "เปิด";

  @override
  String get lbUse => "การกระทำ";

  @override
  String get titleAuto => "ทำงานอัตโนมัติ";

  @override
  String get lbSecond => "วินาที";

  @override
  String get lbMinute => "นาที";

  @override
  String get lbHour => "ชั่วโมง";
  @override
  String get lbStartTime => "เวลาเริ่มต้น";

  @override
  String get lbQuantity => "จำนวนเวลาสิ้นสุด";

  @override
  String get lbStopType => "จำนวนเวลาสิ้นสุด";

  @override
  String get lbMonday => "จ";

  @override
  String get lbTuesday => "อ";

  @override
  String get lbWednesday => "พ";

  @override
  String get lbThursday => "พฤ";

  @override
  String get lbFriday => "ศ";

  @override
  String get lbSaturday => "ส";

  @override
  String get lbSunday => "อา";

  @override
  String get lbServerCall => "ทำงานจากเครื่องแม่ข่าย";

  @override
  String get titleEditTimer => "แก้ไขตารางเวลา";

  @override
  String get titleNewTimer => "เพิ่มตารางเวลา";

  @override
  String get titleTimer => "Timer";

  @override
  String get lbNotiIo => "แจ้งเตือนเมื่อมีการทำงาน";

  @override
  String get lbEdit => "แก้ไข";

  @override
  String get lbDelete => "ลบ";
  @override
  String get lbTimer => "ตั้งเวลา";

  @override
  String get lbAuto => "อัตโนมัติ";

  @override
  String get lbLastUpdate => "ข้อมูลล่าสุด:";

  @override
  String get lbConnectionTimeout => "หมดเวลาการเชื่อมต่อ";

  @override
  String get lbNotFound => "ไม่พบรายการ";

  @override
  String get close => "ปิด";

  @override
  String get lbDeviceName => "ชื่ออุปกรณ์";

  @override
  String get lbDeviceId => "หมายเลขอุปกรณ์";

  @override
  String get lbSave => "บันทึก";

  @override
  String get lbSubmitFail => "ส่งข้อมูลไม่สำเร็จ";

  @override
  String get titleNewDevice => "เพิ่มอุปกรณ์";

  @override
  String get titleEditDevice => "แก้ไขข้อมูล";

  @override
  String get lbTemperature => "อุณหภูมิ";

  @override
  String get lbHumidity => "ความชื้น";

  @override
  String get lbLight => "ความเข้มแสง";

  String get lbSoil => "ความชื้นดิน";
  @override
  String get confirmDelete => "ยืนยันการลบ";

  @override
  String get wantDelete => "ต้องการลบ";

  @override
  String get confirmYes => "จริงหรือไม่";
  @override
  String get lbAddBySerial => "หมายเลขซีเรียล";

  @override
  String get lbAddByQrCode => "เพิ่มจากคิวอาร์โค้ด";

  @override
  String get lbSomethingWentWrong => "มีปัญหาอะไรบางอย่าง";

  @override
  String get labelNewDevice => "เพิ่มอุปกรณ์ใหม่ของคุณที่นี่";

  @override
  String get confirmDelUser => "ต้องการลบข้อมูลการใช้งานจริงหรือไม่";

  @override
  String get labelConfirmDelUser => "ยืนยันการลบ";
  @override
  String get confirmLogout => "ต้องการออกจากระบบจริงหรือไม่";

  @override
  String get labaelConfirmLogout => "ยืนยันการออกจากระบบ";

  @override
  String get confirm => "ยืนยัน";

  @override
  String get ok => "ตกลง";

  @override
  String get cancel => "ยกเลิก";

  @override
  String get wifiSetup => "ตั่งค่าอุปกรณ์ WIFI";

  @override
  String get logOut => "ออกจากระบบ";

  @override
  String get deleteAccount => "ลบบัญชีรายชื่อการใช้งาน";

  @override
  String get theme => "ธีม";

  @override
  String get labelVersion => "รุ่น";

  @override
  String get labelAbout => "เกี่ยวกับเรา";

  @override
  String get appName => "NOOB MAKER";

  @override
  String get labelWelcome => "ยินดีต้อนรับ";

  @override
  String get labelSelectLanguage => "เลือกภาษา";

  @override
  String get labelInfo => "การทำการเกษตรอัจฉริยะ";

  @override
  String get lbGreenHouseStatus => "สถานะอุปกรณ์";
}
