import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:pos/api/api.dart';
 

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status => _controller.stream;

  void loginStatus() async {
      Api api = Api();
      await Future.delayed(const Duration(seconds: 1)); 
      if (await api.getToken()) {
        _controller.add(AuthenticationStatus.authenticated);
      } else {
        _controller.add(AuthenticationStatus.unauthenticated);
      }
  }

  String? get fullName {
    Api api = Api();
    return api.fullName;
  }
 

  String? get storeName {
    Api api = Api();
    return api.storeName;
  }


  Future<bool> logIn({
    required String username,
    required String password,
  }) async {
    Api api = Api();
    if (await api.login(username, password)) {
      _controller.add(AuthenticationStatus.authenticated);
      return true;
    }
    return false;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String userName,
    required String password,
  }) async {
    Api api = Api();
    return await api.register(firstName, lastName, userName, password);
  }

  // Future<bool> upload(File image) async {
  //   return await Api().upload(File(image.path));
  // }

  void logOut() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceId;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
      debugPrint('Android ID: $deviceId');
    } else if (Platform.isIOS) {
      // iOS-specific code
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
      debugPrint('iOS name: $deviceId');
    }
    try {
      Api api = Api();
      // var result = await api.logoutFbToken(deviceId!);
      await api.logoutFbToken(deviceId!);
      // if (result) {
        _controller.add(AuthenticationStatus.unauthenticated);
      // }
    } catch (e) {
      _controller.add(AuthenticationStatus.unauthenticated);
    } 
  }

  Future<bool> deleteAccount() async {
    Api api = Api();
    var result = await api.deleteAccount();
    if (result) {
      result = await api.clear();
      if (result) {
        _controller.add(AuthenticationStatus.unauthenticated);
      }
    }
    return result;
  }

  String? get imageeUrl {
    return Api().menuImageUrl;
  }

  void dispose() => _controller.close();
}
