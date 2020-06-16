import 'model/source.dart';
//路由传参
class SearchInfoArguments{
    final searchtext;
    SearchInfoArguments(this.searchtext);
}
/*
*         搜索逻辑-举例
*         1、书源模糊搜索五条不重复书籍信息
*         2、五条不重复书籍信息精准查询所有书源
*         3、数据结构反馈书籍信息+书源信息
*
* */

//搜索结果 对应多个书源 默认以书名为唯一键
class SearchResult{
    //书籍名称
    String name;

    //选中书源
    int index;

    List<BookMsgInfo> bookinfo = [];

    //书源信息
    List<Source> sourcelist = [];


    SearchResult(this.name);

    void addSource(Source _source){
        this.sourcelist.add(_source);
    }

    void addBookInfo(infoArgs){
        this.bookinfo.add(infoArgs);
    }


}

class BookMsgInfo{
    //书籍封面
    String imgurl;

    //书籍作者
    String author;

    //阅读列表url
    String booklist;

    //书籍简介
    String desc;

    //最新更新
    String lastChapter;

    BookMsgInfo(List<String> Args):this.imgurl = Args[0],this.author = Args[1],this.booklist = Args[2],this.desc = Args[3],this.lastChapter = Args[4];
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