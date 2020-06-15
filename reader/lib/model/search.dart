import 'package:flutter/cupertino.dart';
import 'package:reader/h.dart';
class Search{
    static SearchResult getSearch(String searchtext){
        return new SearchResult("小哥老","https://www.booktxt.com/files/article/image/28/28228/28228s.jpg","三戒大师","第二百四十五章 火并","介绍巴拉巴拉");
    }

    static List<String> SearchHistory(){
        return ['三戒','雪中狂刀行','斗破苍穹','斗罗大陆','小阁老'];
    }
}