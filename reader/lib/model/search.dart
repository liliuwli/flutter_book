import 'package:reader/h.dart';
class Search{
    String _searchtext;

    SearchResult _result;

    Search(this._searchtext){
      this._result = new SearchResult("小哥老","https://www.booktxt.com/files/article/image/28/28228/28228s.jpg","三戒大师","第二百四十五章 火并",new List());
    }

    SearchResult get result => _result;


}