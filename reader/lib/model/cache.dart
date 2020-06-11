import 'package:shared_preferences/shared_preferences.dart';
/*
*     依据shared_preferences 进行应用内部存储 小型持久化性存储
*
*     需要配合futurebuilder渲染页面
* */
class Cache{
  String name = 'shared_preferences';
  Future<SharedPreferences> _instance;

  cache(){
    this._instance = getInstance();
  }

  Future<SharedPreferences> getInstance() async {
    return await SharedPreferences.getInstance();
  }

  Future<String> GetString(String key){
    return this._instance.then((instance){
      return instance.getString(key);
    });
  }

  Future<void> SetString(String key,String value) async {
    final SharedPreferences prefs = await this._instance;
    prefs.setString(key, value).then((bool status){
        return status;
    });
  }

  Future<int> GetInt(String key){
    return this._instance.then((instance){
      return instance.getInt(key);
    });
  }

  Future<void> SetInt(String key,int value) async {
    final SharedPreferences prefs = await this._instance;
    prefs.setInt(key, value).then((bool status){
      return status;
    });
  }

  Future<bool> GetBool(String key){
    return this._instance.then((instance){
      return instance.getBool(key);
    });
  }

  Future<void> SetBool(String key,bool value) async {
    final SharedPreferences prefs = await this._instance;
    prefs.setBool(key, value).then((bool status){
      return status;
    });
  }

  Future<List<String>> GetList(String key){
    return this._instance.then((instance){
      return instance.getStringList(key);
    });
  }

  Future<void> SetList(String key,List<String> value) async {
    final SharedPreferences prefs = await this._instance;
    prefs.setStringList(key, value).then((bool status){
      return status;
    });
  }
}
