import 'package:shared_preferences/shared_preferences.dart';
/*
*     依据shared_preferences 进行应用内部存储 小型持久化性存储
*
*     需要配合futurebuilder渲染页面
* */
class Cache{
    String name = 'shared_preferences';
    static Future<SharedPreferences> _instance;

    Cache(){

    }
    static init(){
        if(_instance == null){
            _instance = Cache.getInstance();
        }
    }

    static clear() async{
        return await Cache._instance.then((instance){
            return instance.clear();
        });
    }

    static Future<void> remove(String key) async{
        return await Cache._instance.then((instance){
            return instance.remove(key);
        });
    }

    static Future<SharedPreferences> getInstance() async {
        return await SharedPreferences.getInstance();
    }

    static Future<String> GetString(String key) async {
        return await Cache._instance.then((instance){
            return instance.getString(key);
        });
    }

    static Future<bool> SetString(String key,String value) async {
        final SharedPreferences prefs = await Cache._instance;
        prefs.setString(key, value).then((bool status){
            return status;
        });
    }

    static Future<List<String>> GetList(String key) async {
        return await Cache._instance.then((instance){
            return instance.getStringList(key);
        });
    }

    static Future<bool> SetList(String key,List<String> value) async {
        final SharedPreferences prefs = await Cache._instance;

        return await Cache._instance.then((instance){
            return instance.setStringList(key, value);
        });
    }
}
