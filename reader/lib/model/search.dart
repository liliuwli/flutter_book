import 'package:flutter/cupertino.dart';
import 'package:reader/h.dart';
import 'package:flutter/material.dart';
import 'cache.dart';
import 'dart:convert';
class Search{
    static Future<List<String>> SearchHistory() {
        Cache _cache = new Cache();
        return _cache.GetList('history').then((value) {
            if(value == null){
                return [];
            }else{
                return value;
            }
        });
    }

    static Future<bool> SaveSearchHistory(List<String> _history) {
        Cache _cache = new Cache();
        return _cache.SetList('history', _history);
    }

    static Future<void> ClearSearchHistory() {
        Cache _cache = new Cache();
        return _cache.remove('history');
    }

    static Future<Map<String, SearchResult>> BookShelf() {
        Cache _cache = new Cache();
        return _cache.GetString('bookshelf').then((value) {
            if(value == null){
                return {};
            }else{
                return json.decode(value);
            }
        });
    }
}