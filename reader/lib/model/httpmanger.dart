import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'dart:async';

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

    Future<List<String>> MutilRequest(List<String> RequestUrl) async {
        //[dio.post("/info"), dio.get("/token")]
        List<String> ret = new List<String>();
        Completer<List<String>> _completer;

        //批量请求url
        List<Response> responselist = await Future.wait(List.generate(RequestUrl.length, (index) => dio.get(RequestUrl[index])));
        responselist.forEach((Response response) {
            String data = gbk.decode(response.data);
            bool is_utf8 = new RegExp('<meta\\s*charset[^>]*?utf-8[^>]*?>').hasMatch(data);
            if(is_utf8){
                data = utf8.decode(response.data);
            }
            ret.add(data);
        });

        _completer = Completer<List<String>>();
        _completer.complete(ret);
        return _completer.future;
    }

    Future<Response> asyncGet(String url , Map<String, dynamic> params){
        return _asyncHttp(url, GET, params);
    }

    Future<Response> _asyncHttp(String url, String method, Map<String, dynamic> params) async {
        Response response;
        Completer<Response> _completer;

        if (method == GET) {
            if (params != null && params.isNotEmpty) {
                response = await dio.get(url, queryParameters: params,
                    options: Options(responseType: ResponseType.bytes)
                );
            }else{
                response = await dio.get(url,options: Options(responseType: ResponseType.bytes));
            }
        }

        String data = gbk.decode(response.data);
        bool is_utf8 = new RegExp('<meta\\s*charset[^>]*?utf-8[^>]*?>').hasMatch(data);

        if(is_utf8){
            data = utf8.decode(response.data);
        }
        response.data = data;

        _completer = Completer<Response>();
        _completer.complete(response);
        return _completer.future;
    }

    get(String url, Map<String, dynamic> params, Function success, Function error) async {
        _requestHttp(url, GET, params, success, error);
    }

    post(String url, Map<String, dynamic> params, Function success, Function error) async {
        _requestHttp(url, POST, params, success, error);
    }

    _requestHttp(String url, String method, Map<String, dynamic> params, Function success, Function error) async {
        int code;
        Response response;

        if (method == GET) {
            if (params != null && params.isNotEmpty) {
                response = await dio.get(url, queryParameters: params,options: Options(responseType: ResponseType.bytes));
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