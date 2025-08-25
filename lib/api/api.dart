import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:pos/model/category_model.dart';
import 'package:pos/model/menu_model.dart';
import 'package:pos/model/order_model.dart';
import 'package:pos/model/order_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;

  const ApiException({this.message = ""});
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({this.message = ""});
}

// My Server
// const apiBaseUrl = '127.0.0.1:8001';
// const staticBaseUrl = '127.0.0.1:8001/';
const apiBaseUrl = 'smartpos.safebsc.finance';
const staticBaseUrl = 'smartpos.safebsc.finance/';

const apiVersion = 'api/v1';
String? jwtToken;
String? userId = "";
String? _fullName;
String? _storeName = "ร้านทดสอบ";

SharedPreferences? prefs;

class Api {
  static final Api _singleton = Api._internal();
  static const String tokenKey = 'TOKEN';
  static const String userKey = 'U_ID';
  static const String nameKey = 'NAME_ID';
  static const String storeNameKey = 'STORE_NAME_ID';

  factory Api() => _singleton;
  Api._internal() {
    // print('-----------> Api._internal');
  }

  bool hasToken() {
    bool has = jwtToken != null;
    return has;
  }

  String? get fullName => _fullName;
  String? get storeName => _storeName;

  Future<bool> clear() async {
    await prefs!.clear();
    jwtToken = null;
    userId = null;
    _fullName = null;
    return true;
  }

  Future<bool> getToken() async {
    prefs = await SharedPreferences.getInstance();
    jwtToken = prefs!.getString(tokenKey);
    userId = prefs!.getString(userKey);
    _fullName = prefs!.getString(nameKey);
    return jwtToken != null;
  }

  String? get menuImageUrl {
    return 'http://$staticBaseUrl';
  }

  Map<String, String>? get header {
    if (jwtToken == null) {
      throw UnauthorizedException(message: 'Token is missing');
    }
    return {
      'Content-type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'x-token': jwtToken!,
    };
  }

  Future<void> pushToken(Map<String, dynamic> json) async {
    prefs ??= await SharedPreferences.getInstance();
    //final SharedPreferences prefs = await _prefs;
    jwtToken = json['token'];
    userId = json['_id'];
    _fullName = '${json['firstName']} ${json['lastName']}';

    await prefs!.setString(userKey, userId!);
    await prefs!.setString(tokenKey, jwtToken!);
    await prefs!.setString(nameKey, _fullName!);
  }

  // Future<bool> upload(File image) async {
  //   try {
  //     var url = Uri.https(apiBaseUrl, '$apiVersion/user/upload');
  //     var request = http.MultipartRequest('POST', url);
  //     request.files.add(await http.MultipartFile.fromPath('file', image.path));
  //     request.fields['userId'] = userId!;
  //     var res = await request.send();
  //     //Get the response from the server
  //     if (res.statusCode == 200) {
  //       var responseData = await res.stream.toBytes();
  //       var responseString = String.fromCharCodes(responseData);
  //       debugPrint(responseString);
  //       Map<String, dynamic> result = json.decode(responseString);
  //       await prefs!.setString(profileKey, _profile!);
  //     }
  //     return res.statusCode == 200;
  //   } catch (e) {
  //     debugPrint('$e');
  //   }
  //   return false;
  // }

  Future<bool> login(String userName, String password) async {
    try {
      var body = json.encode({"email": userName, "password": password});
      // var url = Uri.https(apiBaseUrl, '$apiVersion/auth/login');

      print('apiBaseUrl: $apiBaseUrl');
      print('userName: $userName');
      print('password: $password');

      var url = Uri.https(apiBaseUrl, '$apiVersion/auth/login');
      print('url: $url');

      final response = await http.post(
        url,
        body: body,
        headers: {
          'Content-type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = json.decode(response.body);
        debugPrint(jsonMap.toString());
        await pushToken(jsonMap['data']);
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception('Failed to login user $userName');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<bool> deleteAccount() async {
    try {
      var body = json.encode({"_id": userId});
      var url = Uri.https(apiBaseUrl, '$apiVersion/user');
      final response = await http.delete(url, body: body, headers: header);
      if (response.statusCode == 200) {
        return true;
      } else {
        String msg = 'เกิดข้อผิดพลาด กรุณาติดต่อผู้ดูแลระบบ';
        if (response.statusCode == 404) {
          var dataMap = Map<String, dynamic>.from(json.decode(response.body));
          debugPrint(dataMap['message']);
          msg = dataMap['message'];
        }
        if (response.statusCode == 409) {
          var dataMap = Map<String, dynamic>.from(json.decode(response.body));
          debugPrint(dataMap['message']);
          msg = dataMap['message'];
        }
        throw ApiException(message: 'CODE: ${response.statusCode}\n$msg');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register(
    String firstName,
    String lastName,
    String userName,
    String password,
  ) async {
    try {
      var body = json.encode({
        "firstName": firstName,
        "lastName": lastName,
        "email": userName,
        "password": password,
      });
      var url = Uri.https(apiBaseUrl, '$apiVersion/user/register');
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Content-type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 201) {
        // print(_json);
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception('Failed to register user $userName');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<bool> updateFbToken(String androidId, String token) async {
    try {
      var body = json.encode({
        "androidId": androidId,
        "fb_token": token,
        "userId": userId,
      });
      var url = Uri.https(apiBaseUrl, '$apiVersion/fb-token');
      final response = await http.post(url, body: body, headers: header);
      debugPrint(jwtToken);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = json.decode(response.body);
        // print(_json);
        return jsonMap['data'] != null;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception('Failed to update token user $userId');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<bool> logoutFbToken(String androidId) async {
    try {
      // var body = json.encode({"androidId": androidId, "userId": userId});
      // var url = Uri.https(apiBaseUrl, '$apiVersion/fb-token/logout');
      // final response = await http.delete(url, body: body, headers: header);
      // if (response.statusCode == 200) {
      //   Map<String, dynamic> jsonMap = json.decode(response.body);
      //   debugPrint(jsonMap.toString());
      //   bool result = jsonMap['result'];
      //   if (result) {
      //     clear();
      //   }
      //   return result;
      // } else if (response.statusCode == 404) {
      //   return false;
      // } else {
      //   throw Exception('Failed to update token user $userId');
      // }
      clear();
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<List<Category>?> getCategories() async {
    var url = Uri.https(apiBaseUrl, '$apiVersion/category');
    final response = await http.get(url, headers: header);
    Map<String, dynamic> dataMap;
    if (response.statusCode == 200) {
      debugPrint(response.body);
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        jsonDecode(response.body)['data'],
      );
      List<Category> innerList = list.map((e) => Category.formJson(e)).toList();
      innerList.insert(
        0,
        Category(id: '0', title: 'ทั้งหมด', selected: true, showing: true),
      );
      return innerList;
    } else if (response.statusCode == 403) {
      dataMap = Map<String, dynamic>.from(json.decode(response.body));
      debugPrint(dataMap['message']);
      throw Exception(dataMap['message']);
    } else if (response.statusCode == 401) {
      dataMap = Map<String, dynamic>.from(json.decode(response.body));
      debugPrint(dataMap['message']);
      throw UnauthorizedException(message: dataMap['message']);
    }
    return [];
  }

  Future<List<Menu>?> getMenus() async {
    var url = Uri.https(apiBaseUrl, '$apiVersion/menu');
    final response = await http.get(url, headers: header);
    Map<String, dynamic> dataMap;
    if (response.statusCode == 200) {
      debugPrint(response.body);
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        jsonDecode(response.body)['data'],
      );
      List<Menu> innerList = list
          .map((e) => Menu.formJson(e, '$menuImageUrl'))
          .toList();
      return innerList;
    } else if (response.statusCode == 403) {
      dataMap = Map<String, dynamic>.from(json.decode(response.body));
      debugPrint(dataMap['data']);
      throw Exception(dataMap['data']);
    } else if (response.statusCode == 401) {
      dataMap = Map<String, dynamic>.from(json.decode(response.body));
      debugPrint(dataMap['message']);
      throw UnauthorizedException(message: dataMap['message']);
    }
    return [];
  }

  Future<bool?> createOrder(OrderCreate order) async {
    var url = Uri.https(apiBaseUrl, '$apiVersion/order');
    var body = order.toJson();
    final response = await http.post(url, body: body, headers: header);
    Map<String, dynamic>? dataMap = Map<String, dynamic>.from(
      json.decode(response.body),
    );
    if (response.statusCode == 201) {
      if (dataMap['result'] == true) {
        return true;
      }
    } else if (response.statusCode == 400) {
      debugPrint(dataMap['data']);
      throw ApiException(message: dataMap['message']);
    } else if (response.statusCode == 500) {
      debugPrint(dataMap['data']);
      throw ApiException(message: dataMap['message']);
    } else if (response.statusCode == 401) {
      debugPrint(dataMap['message']);
      throw UnauthorizedException(message: dataMap['message']);
    }
    return false;
  }

  Future<bool?> createClosePeriod(CreateClosePeriod model) async {
    var body = model.toJson();
    var url = Uri.https(apiBaseUrl, '$apiVersion/store-finance');
    final response = await http.post(url, body: body, headers: header);
    Map<String, dynamic>? dataMap = Map<String, dynamic>.from(
      json.decode(response.body),
    );
    if (response.statusCode == 201) {
      if (dataMap['result'] == true) {
        return true;
      }
    } else if (response.statusCode == 400) {
      debugPrint(dataMap['message']);
      throw ApiException(message: dataMap['message']);
    } else if (response.statusCode == 500) {
      debugPrint(dataMap['message']);
      throw ApiException(message: dataMap['message']);
    } else if (response.statusCode == 401) {
      debugPrint(dataMap['message']);
      throw UnauthorizedException(message: dataMap['message']);
    }

    return false;
  }

  Future<List<OrderView>?> getCurrentOrder() async {
    var url = Uri.https(apiBaseUrl, '$apiVersion/order/current');
    final response = await http.get(url, headers: header);
    Map<String, dynamic> dataMap;
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        jsonDecode(response.body)['data'],
      );
      List<OrderView> innerList = list
          .map((e) => OrderView.fromMap(e))
          .toList();
      return innerList;
    } else if (response.statusCode == 400) {
      dataMap = Map<String, dynamic>.from(json.decode(response.body));
      debugPrint(dataMap['data']);
      throw ApiException(message: dataMap['message']);
    } else if (response.statusCode == 500) {
      dataMap = Map<String, dynamic>.from(json.decode(response.body));
      debugPrint(dataMap['data']);
      throw ApiException(message: dataMap['message']);
    } else if (response.statusCode == 401) {
      dataMap = Map<String, dynamic>.from(json.decode(response.body));
      debugPrint(dataMap['message']);
      throw UnauthorizedException(message: dataMap['message']);
    }
    return null;
  }

  // Future<List<DeviceModel>?> getDevices(String farmId) async {
  //   var url = Uri.https(apiBaseUrl, '$apiVersion/devices/farm/$farmId');
  //   final response = await http.get(url, headers: header);
  //   Map<String, dynamic> dataMap;
  //   if (response.statusCode == 200) {
  //     debugPrint(response.body);

  //     List<Map<String, dynamic>> list =
  //         List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);

  //     List<DeviceModel> innerList =
  //         list.map((e) => DeviceModel.fromJson(e)).toList();
  //     return innerList;
  //   } else if (response.statusCode == 403) {
  //     dataMap = Map<String, dynamic>.from(json.decode(response.body));
  //     debugPrint(dataMap['data']);
  //     throw Exception(dataMap['data']);
  //   }

  //   return [];
  // }

  // Future<DeviceModel?> postDevice(DeviceModel device) async {
  //   var url = Uri.https(apiBaseUrl, '$apiVersion/device');
  //   device.userId = userId;
  //   var body = jsonEncode(device.toJson());
  //   final response = await http.post(url, body: body, headers: header);
  //   Map<String, dynamic>? dataMap =
  //       Map<String, dynamic>.from(json.decode(response.body));
  //   if (response.statusCode == 201) {
  //     if (dataMap['result'] == true) {
  //       return DeviceModel.fromJson(dataMap['data']);
  //     }
  //   } else if (response.statusCode == 400) {
  //     debugPrint(dataMap['data']);
  //     throw ApiException(dataMap['description']);
  //   } else if (response.statusCode == 500) {
  //     debugPrint(dataMap['data']);
  //     throw ApiException(dataMap['description']);
  //   }
  //   return null;
  // }

  // Future<DeviceModel?> updateDevice(DeviceModel device) async {
  //   var url = Uri.https(apiBaseUrl, '$apiVersion/device');
  //   var body = json.encode(device.toJson());
  //   final response = await http.put(url, body: body, headers: header);
  //   if (response.statusCode == 200) {
  //     DeviceModel dataMap =
  //         DeviceModel.fromJson(json.decode(response.body)['data']);
  //     return dataMap;
  //   }
  //   return null;
  // }

  // Future<Map<String, dynamic>?> deleteDevice(DeviceModel device) async {
  //   var url = Uri.https(apiBaseUrl, '$apiVersion/device');
  //   var body = json.encode(device);
  //   final response = await http.delete(url, body: body, headers: header);
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> dataMap =
  //         Map<String, dynamic>.from(json.decode(response.body));
  //     return dataMap;
  //   }
  //   return null;
  // }
}
