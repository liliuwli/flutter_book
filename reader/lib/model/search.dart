import 'package:flutter/cupertino.dart';
import 'package:reader/h.dart';
import 'package:flutter/material.dart';
import 'cache.dart';
import 'dart:convert';
class Search{
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