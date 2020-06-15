import 'model/source.dart';
//路由传参
class SearchInfoArguments{
  final searchtext;
  SearchInfoArguments(this.searchtext);
}
/*
*     搜索逻辑-举例
*     1、书源模糊搜索五条不重复书籍信息
*     2、五条不重复书籍信息精准查询所有书源
*     3、数据结构反馈书籍信息+书源信息
*
* */

//搜索结果
class SearchResult{
  //书籍名称
  String name;

  //书籍封面
  String imgurl;

  //书籍作者
  String author;

  //书籍简介
  String desc;

  //最新更新
  List<String> lastChapter = [];

  //书源信息
  List<Source> source_list = [];

  //阅读列表url
  String booklist;

  SearchResult(this.name,this.imgurl,this.author,this.booklist,this.desc);

  void addSource(Source _source){
    this.source_list.add(_source);
  }

  void addLastChapter(String _lastChapter){
    this.lastChapter.add(_lastChapter);
  }
}

//书源信息
class BookSource{
  //书源名称
  String name;

  //书源api地址
  String baseurl;

  //书源规则
  List rule_list;
}