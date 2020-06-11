import 'httpmanger.dart';
import 'source.dart';

import 'package:xpath/xpath.dart';

class Request{
  static Request _instance;


  static Request getInstance(){
    if(_instance == null){
      _instance = Request();
    }
    return _instance;
  }

  Request(){

  }

  void PaserHttp(){
    HttpManage.getInstance().get("https://www.booktxt.com/search.php?keyword=%E5%B0%8F%E9%98%81%E8%80%81",Map(),
        //success
        (String html){
          //没得好用得xpath 需要自己实现
          html = html.replaceAll(RegExp(r"<!DOCTYPE[^>]*?html>\s*"),"");
          html = html.replaceAll(RegExp(r'<style[^>]*?>[^<]*?<[^>]style*?>'),"");
          html = html.replaceAll(RegExp(r'<script[^>]*?>[^<]*?<[^>]script*?>'),"");
          html = html.replaceAll(RegExp(r'<meta[^>]*?>'),"");


          ETree tree = ETree.fromString(html);
          Source.SearchRule['list_uri'].reg = '//*html';
          List<Element> elements = tree.xpath(Source.SearchRule['list_uri'].reg);
          //print(Source.SearchRule['list_uri'].reg);
          print(elements);
          print(html);
        },
        //error
        (error){
          print(error);
        }
    );
  }

}