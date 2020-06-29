import 'package:reader/h.dart';
import 'package:reader/model/sourcemanger.dart';
import 'cache.dart';
import 'dart:convert';
import 'package:reader/model/httputils.dart';
import 'package:reader/model/source.dart';

/**
 * history  List<String> 书籍名称list
 *
 * bookshelf List<String> 书籍信息json SearchResult
 */

class Search{
    static Future<int> GetSortIdByName(String bookname,String chaptername) async {
        return await Search.BookDir(bookname).then((List<BookChapter> chapterlist){
            int ret;
            for(int i=0;i<chapterlist.length;i++){
                if(chaptername == chapterlist[i].name){
                    ret = i;
                    break;
                }
            }
            return ret==null?0:ret;
        });
    }

    //根据书架内书源反推书的目录
    static Future<List<BookChapter>> BookDir(String bookname) async {
        return await Search.getBookShelfByName(bookname).then((SearchResult _searchResult) async {
            int sourceid = _searchResult.sourcelist.bookSourceList[_searchResult.index].id;

            //寻找解析数据源
            return await SourceManger.getSourceById(sourceid).then((Source source) async {
                //寻找小说目录
                return await Request.getInstance().ParserChapterList(_searchResult.bookinfolist.bookMsgInfoList[_searchResult.index].booklist, source);
            });
        });
    }

    //倒退已读
    static Future<bool> BackMark(String chaptername , int sortid , String bookname) async {
        int _backid;

        return await Search.BookDir(bookname).then((List<BookChapter> chapterlist) async {
            for(int i=0;i<chapterlist.length;i++){
                if(chaptername == chapterlist[i].name){
                    _backid = i;
                    break;
                }
            }

            //如果未匹配到 或者 为第一章
            if(_backid == null || _backid == 0){
                return false;
            }else{
                _backid--;
                String newreadmark =  chapterlist[_backid].name;

                return await FreshMark(newreadmark, _backid , bookname);
            }
        });
    }

    //刷新已读
    static Future<bool> FreshMark(String chaptername , int sortid , String bookname) async {
        return await Search.getBookShelfByName(bookname).then((SearchResult _searchResult) async {
            if(_searchResult == null){
                //书架无数据  异常情况
                return false;
            }else{
                _searchResult.readmark = chaptername;
                await SetBookShelf(_searchResult);
                return true;
            }
        });
    }

    static Future<List<String>> SearchHistory() {
        Cache.init();
        return Cache.GetList('history').then((value) {
            if(value == null){
                return [];
            }else{
                return value;
            }
        });
    }

    static Future<bool> SaveSearchHistory(List<String> _history) {
        Cache.init();
        return Cache.SetList('history', _history);
    }

    static Future<void> ClearSearchHistory() {
        Cache.init();
        return Cache.remove('history');
    }

    //获取书架指定书籍信息
    static Future<SearchResult>getBookShelfByName(String bookname) async{
        Cache.init();

        //书籍内容
        SearchResult bookinfo;

        return await Cache.GetList('bookshelf').then((List<String> _bookshelf){
            if(_bookshelf == null){
                return null;
            }else{
                _bookshelf.forEach((String item){
                    SearchResult result = SearchResult.fromJson(jsonDecode(item));
                    if(result.name == bookname){
                        bookinfo = result;
                    }
                });
                return bookinfo;
            }
        });
    }

    //获取书架信息
    static Future<List<SearchResult>> getBookShelf() {
        Cache.init();
        
        //书架内容
        List<SearchResult> bookShelfList;
        return Cache.GetList('bookshelf').then((List<String> _bookshelf){
            if(_bookshelf == null){
                return new List<SearchResult>();
            }else{
                return bookShelfList = List.generate(_bookshelf.length, (i) => SearchResult.fromJson(jsonDecode(_bookshelf[i])));
            }
        });
    }

    //删除书架书籍
    static Future<dynamic> DelBookShelf(String name){
        Cache.init();
        //书架内容
        List<SearchResult> bookShelfList;
        //临时存储书架json
        List<String> bookshelfjson;
        //删除下标
        int index = -1;

        return Cache.GetList('bookshelf').then((List<String> _bookshelf){
            if(_bookshelf != null){
                bookshelfjson = _bookshelf;
                bookShelfList = List.generate(_bookshelf.length, (i) => SearchResult.fromJson(jsonDecode(_bookshelf[i])));
                for(int i=0;i<bookShelfList.length;i++){
                    SearchResult item = bookShelfList[i];
                    //如果已存在 返回下标
                    if(name == item.name){
                        index = i;
                        break;
                    }
                }
                if(index >= 0){
                    bookshelfjson.removeAt(index);
                    return Cache.SetList("bookshelf", bookshelfjson);
                }
            }

            return true;
        });
    }

    //加入或更新书架 bookshelf=>list[key,searchresult]
    static Future<bool> SetBookShelf(SearchResult _searchResult){
        Cache.init();
        //书架内容
        List<SearchResult> bookShelfList;
        //临时存储书架json
        List<String> bookshelfjson;
        return Cache.GetList("bookshelf").then((List<String> _bookshelf){
            //判断是否存在
            if(_bookshelf != null){
                bookshelfjson = _bookshelf;
                bookShelfList = List.generate(_bookshelf.length, (i) => SearchResult.fromJson(jsonDecode(_bookshelf[i])));
                for(int i=0;i<bookShelfList.length;i++){
                    SearchResult item = bookShelfList[i];
                    //如果已存在 返回下标
                    if(_searchResult.name == item.name){
                        return i;
                    }
                }
            }else{
                bookshelfjson = new List<String>();
            }
            return -1;
        }).then((int index){
            if(index >= 0){
                bookshelfjson[index] = json.encode(_searchResult);
            }else{
                bookshelfjson.add(json.encode(_searchResult));
            }
            return Cache.SetList("bookshelf", bookshelfjson);
        });
    }
}