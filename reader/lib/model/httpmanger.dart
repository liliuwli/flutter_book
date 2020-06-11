import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:gbk2utf8/gbk2utf8.dart';

class HttpManage{
  static final String GET = "get";
  static final String POST = "post";
  static HttpManage _instance;
  Dio dio;

  static HttpManage getInstance(){
    if(_instance == null){
      _instance = HttpManage();
    }
    return _instance;
  }

  HttpManage(){
    dio = Dio(BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 100000,
      responseType: ResponseType.bytes,
    ));
  }
  /*
  * get 获取数据
  * */
  get(String url, Map<String, dynamic> params, Function success, Function error) async {
    _requestHttp(url, GET, params, success, error);
  }

  /*
  * post 获取数据
  * */
  post(String url, Map<String, dynamic> params, Function success, Function error) async {
    _requestHttp(url, POST, params, success, error);
  }

  _requestHttp(String url, String method, Map<String, dynamic> params, Function success, Function error) async {

    int code;

    Response response;

    if (method == GET) {
      if (params != null && params.isNotEmpty) {
        response = await dio.get(url, queryParameters: params);
      } else {
        response = await dio.get(url,options: Options(responseType: ResponseType.bytes));
      }
    } else if (method == POST) {
      if (params != null && params.isNotEmpty) {
        response = await dio.post(url, queryParameters: params);
      } else {
        response = await dio.post(url);
      }
    }

    //String dataStr = json.encode(response.data);

    String data = gbk.decode(response.data);
    bool is_utf8 = new RegExp('<meta\\s*charset[^>]*?utf-8[^>]*?>').hasMatch(data);

    if(is_utf8){
      data = utf8.decode(response.data);
    }

    code = response.statusCode;

    if(code == 200){
      success(data);
    } else {
      ErrorBean errorBean = ErrorBean(code, response.statusMessage);
      error(errorBean);
    }
  }
}

class ErrorBean {

  final int code;
  final String message;

  ErrorBean(this.code, this.message){
    print(this.code);
    print("\n--------------\n");
    print(this.message);
  }
}