import 'package:shared_preferences/shared_preferences.dart';
/*
*     依据shared_preferences 进行应用内部存储 小型持久化性存储
*
*     需要配合futurebuilder渲染页面
* */
class Cache{
  String name = 'shared_preferences';
  Future<SharedPreferences> _instance;

  Cache(){
    this._instance = getInstance();
  }

   Future<void> remove(String key) async{
       return await this._instance.then((instance){
           return instance.remove(key);
       });
   }

  Future<SharedPreferences> getInstance() async {
    return await SharedPreferences.getInstance();
  }

  Future<String> GetString(String key) async {
    return await this._instance.then((instance){
      return instance.getString(key);
    });
  }

  Future<void> SetString(String key,String value) async {
    final SharedPreferences prefs = await this._instance;
    prefs.setString(key, value).then((bool status){
        return status;
    });
  }

  Future<List<String>> GetList(String key) async {
    return await this._instance.then((instance){
      return instance.getStringList(key);
    });
  }

    Future<bool> SetList(String key,List<String> value) async {
        final SharedPreferences prefs = await this._instance;

        return await this._instance.then((instance){
            return instance.setStringList(key, value);
        });
    }
}
