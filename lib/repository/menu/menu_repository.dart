import 'package:pos/api/api.dart';
import 'package:pos/model/menu_model.dart';

class MenuRepository {
  Future<List<Menu>?> get() async {
      try {
        var result = await Api().getMenus();
        return result;
      } on Exception {
        rethrow;
      }
    // await Future.delayed(const Duration(milliseconds: 200)); 
    // return  menuTest;
  }

  // Future<DeviceModel?> insert(DeviceModel model) async {
  //   try {
  //     var result = await Api().postDevice(model);
  //     return result;
  //   } on ApiException {
  //     rethrow;
  //   }
  // }

  // Future<Map<String, dynamic>?> delete(DeviceModel model) async {
  //   try {
  //     var result = await Api().deleteDevice(model);
  //     return result;
  //   } on Exception {
  //     rethrow;
  //   }
  // }

  // Future<DeviceModel?> update(DeviceModel model) async {
  //   try {
  //     var result = await Api().updateDevice(model);
  //     return result;
  //   } on Exception   {
  //     rethrow;
  //   }
  // }   
}