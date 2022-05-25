import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';


class LoginProvider with ChangeNotifier {
  bool _isSuccess = false;
  String message = '';

  String email = '';
  String password = '';
  bool hidePassword = true;
  final UserModel _userModel = UserModel();

  /*
  * dotenv.get('BACKEND_URL_HOST') http://10.0.2.2:8000 は dotenv.get('BACKEND_URL_HOST_CASE_FLUTTER_WEB') http://127.0.0.1:8000/ のエイリアス
  * Mobile（エミュレータ）では 10.0.2.2:8000 ホストを利用する
  * Flutter Web の場合は 127.0.0.1:8000 ホストを利用する
  */
  final Uri _uriHost = Uri.parse(dotenv.get('BACKEND_URL_HOST'));

  String getUserId() {
    return _userModel.id;
  }

  void setMessage(String msg) {
    message = msg;
    notifyListeners();
  }

  void togglePasswordVisible() {
    hidePassword = !hidePassword;
    notifyListeners();
  }

  Future<bool> auth() async {
    _isSuccess = false;
    message = '';

    try {
      Dio dio = Dio();
      dio.options.baseUrl = _uriHost.toString();
      dio.options.connectTimeout = 5000;
      dio.options.receiveTimeout = 3000;
      dio.options.contentType = 'application/json';

      List<Cookie> cookieList = [];

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      PersistCookieJar cookieJar = PersistCookieJar(storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));

      final responseJwt = await dio.post(
          '/authen/jwt/create',
          data: {
            'email': email,
            'password': password,
          }
      );
      cookieList = [ ...cookieList, Cookie('access_token', responseJwt.data['access']) ];
      await cookieJar.saveFromResponse(_uriHost, cookieList);

      final responseUser = await dio.get(
        '/authen/users/me',
        options: Options(
          headers: {
            'Authorization': 'JWT ${cookieList.first.value}',
          },
        ),
      );
      _userModel.id = responseUser.data['id'];
      _userModel.email = responseUser.data['email'];

      _isSuccess = true;
    } catch(error) {
      message = '正しいEメールとパスワードを入力してください';
      print(error);
      _isSuccess = false;
    }
    notifyListeners();
    return _isSuccess;
  }

  Future<void> logout() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    PersistCookieJar cookieJar = PersistCookieJar(storage: FileStorage(appDocPath+"/.cookies/"));
    await cookieJar.delete(_uriHost);
    notifyListeners();
  }

  Future<bool> signup() async {
    _isSuccess = false;
    message = '';

    try {
      Dio dio = Dio();
      dio.options.baseUrl = _uriHost.toString();
      dio.options.contentType = 'application/json';

      final response = await dio.post(
          '/api/users/create/',
          data: {
            'email': email,
            'password': password,
            'username': '',
          }
      );
      _userModel.id = response.data['id'];
      message = '新規ユーザーの仮登録が成功しました。本登録にはユーザーのアクティベーションを行って下さい';
      _isSuccess = true;
    } catch(error) {
      message = '新規ユーザー登録処理が失敗しました。同じEmailは使用できません';
      print(error);
      _isSuccess = false;
    }
    notifyListeners();
    return _isSuccess;
  }

}

