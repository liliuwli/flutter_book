import 'model/source.dart';
import 'dart:convert';


//路由传参
class BookPageArguments{
    int Sourceid;
    String name;
    String chapterlisturl;

    BookPageArguments(this.name,this.Sourceid,this.chapterlisturl);
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
    int index=0;

    //设置已读
    String readmark;

    //书籍详情
    BookMsgInfoList bookinfolist;

    //书源信息
    BookSourceList sourcelist;


    @override
    String toString() {
        return jsonEncode(this);
    }

    SearchResult.fromJson(Map<String,dynamic> jsonobj){
        name = jsonobj['name'];
        index = jsonobj['index'];
        readmark = jsonobj['readmark'];
        bookinfolist = jsonobj['bookinfolist'] == null ? null :BookMsgInfoList.fromJson(jsonobj['bookinfolist']);
        sourcelist = jsonobj['sourcelist'] == null ? null :BookSourceList.fromJson(jsonobj['sourcelist']);
    }

    Map<String,dynamic> toJson() {
        final Map<String,dynamic> data = new Map<String,dynamic>();
        data["name"] = this.name;
        data["index"] = this.index;
        data["readmark"] = this.readmark;
        data["bookinfolist"] = this.bookinfolist==null?null:this.bookinfolist.toJson();
        data["sourcelist"] = this.sourcelist==null?null:this.sourcelist.toJson();

        return data;
    }


    SearchResult(String name){
        this.name = name;
        this.bookinfolist = new BookMsgInfoList([]);
        this.sourcelist = new BookSourceList([]);
    }

    void addSource(BookSource _source){
        this.sourcelist.bookSourceList.add(_source);
    }

    void addBookInfo(infoArgs){
        this.bookinfolist.bookMsgInfoList.add(infoArgs);
    }

    void setSource(List<BookSource> _sourcelist){
        this.sourcelist = new BookSourceList(_sourcelist);
    }

    void setBookInfo(List<BookMsgInfo> _bookinfo){
        this.bookinfolist = new BookMsgInfoList(_bookinfo);
    }
}

//搜索到一本书 都对应了多个源 每个源都有一条搜索信息  book =>(record[],source[])
class BookSourceList{
    List<BookSource> bookSourceList = [];
    int length = 0;
    BookSourceList(List<BookSource> _sourcelist){
        this.bookSourceList = _sourcelist;
        this.length = _sourcelist.length;
    }

    void add (BookSource item){
        this.bookSourceList.add(item);
        this.length++;
    }

    BookSource get(int index){
        if(index >= length){
            return null;
        }else{
            return this.bookSourceList[index];
        }
    }


    @override
    String toString() {
        return json.encode(this);
    }

    Map<String,dynamic> toJson() {
        final Map<String,dynamic> data = new Map<String,dynamic>();
        data["length"] = this.length;

        if(this.bookSourceList != null){
            data["bookSourceList"] = this.bookSourceList.map((element)=>element.toJson()).toList();
        }else{
            data["bookSourceList"] = null;
        }

        return data;
    }

    BookSourceList.fromJson(Map<String,dynamic> jsonobj){
        length = jsonobj['length'];
        if(jsonobj['bookSourceList'] != null ){
            bookSourceList = new List<BookSource>();
            (jsonobj['bookSourceList'] as List).forEach((element) {
                bookSourceList.add(new BookSource.fromJson(element));
            });
        }else{
            bookSourceList = null;
        }
    }
}

//搜索到一本书 都对应了多个源 每个源都有一条搜索信息  book =>(record[],source[])
class BookMsgInfoList{
    List<BookMsgInfo> bookMsgInfoList = [];
    int length = 0;
    BookMsgInfoList(List<BookMsgInfo> bookmsginfolist){
        this.bookMsgInfoList = bookmsginfolist;
        this.length = bookmsginfolist.length;
    }



    void add (BookMsgInfo item){
        this.bookMsgInfoList.add(item);
        this.length++;
    }

    BookMsgInfo get(int index){
        if(index >= length){
            return null;
        }else{
            return this.bookMsgInfoList[index];
        }
    }


    Map<String,dynamic> toJson() {
        final Map<String,dynamic> data = new Map<String,dynamic>();
        data["length"] = this.length;

        if(this.bookMsgInfoList != null){
            data["bookMsgInfoList"] = this.bookMsgInfoList.map((element)=>element.toJson()).toList();
        }else{
            data["bookMsgInfoList"] = null;
        }

        return data;
    }

    BookMsgInfoList.fromJson(Map<String,dynamic> jsonobj){
        length = jsonobj['length'];
        if(jsonobj['bookMsgInfoList'] != null ){
            bookMsgInfoList = new List<BookMsgInfo>();
            (jsonobj['bookMsgInfoList'] as List).forEach((element) {
                bookMsgInfoList.add(new BookMsgInfo.fromJson(element));
            });
        }else{
            bookMsgInfoList = null;
        }
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

    BookMsgInfo.fromJson(Map<String,dynamic> jsonobj){
        imgurl = jsonobj['imgurl'];
        author = jsonobj['author'];
        booklist = jsonobj['booklist'];
        desc = jsonobj['desc'];
        lastChapter = jsonobj['lastChapter'];
    }

    Map<String,dynamic> toJson() {
        final Map<String,dynamic> data = new Map<String,dynamic>();
        data["imgurl"] = this.imgurl;
        data["author"] = this.author;
        data["booklist"] = this.booklist;
        data["desc"] = this.desc;
        data["lastChapter"] = this.lastChapter;

        return data;
    }
}

//保存的书源信息
class BookSource{
    //书源名称
    String name;
    int id;

    BookSource(this.name,this.id);
    BookSource.fromJson(Map<String,dynamic> jsonobj){
        name = jsonobj['name'];
        id = jsonobj['id'];
    }

    Map<String,dynamic> toJson() {
        final Map<String,dynamic> data = new Map<String,dynamic>();
        data["name"] = this.name;
        data["id"] = this.id;

        return data;
    }
}