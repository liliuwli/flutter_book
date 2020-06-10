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

  //最新更新
  String lastChapter;

  //书源信息
  List source_list;

  SearchResult(this.name,this.imgurl,this.author,this.lastChapter,this.source_list);
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

//规则信息
class ParserRule{
  /*
   * 0 书名
   */
  num id;

  /*
  * 0 正则
  * 1 jquery
  * 2 xpath
  * */
  num type;

  String uri;

}