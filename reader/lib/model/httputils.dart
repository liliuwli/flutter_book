import 'httpmanger.dart';
import 'source.dart';
import 'package:reader/logger/log.dart';
import '../h.dart';

import 'package:reader/fquery/fquery.dart';

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

    void SearchBook(String keyword,Function success){
        Source source = Source.getSource();
        HttpManage.getInstance().get(source.baseUrl+source.SearchUrl,{source.SearchKey:keyword},
		(String html){
        	//success
            Fquery.newDocument(html);
            List<String> booklist = Fquery.selector(source.SearchRule['booklist'].reg,source.SearchRule['booklist'].type);
            List<String> imglist = Fquery.selector(source.SearchRule['imglist'].reg,source.SearchRule['imglist'].type);
            List<String> namelist = Fquery.selector(source.SearchRule['namelist'].reg,source.SearchRule['namelist'].type);
            List<String> desclist = Fquery.selector(source.SearchRule['desclist'].reg,source.SearchRule['desclist'].type);
            List<String> authorlist = Fquery.selector(source.SearchRule['authorlist'].reg,source.SearchRule['authorlist'].type);
            List<String> lastchapterlist = Fquery.selector(source.SearchRule['lastchapterlist'].reg,source.SearchRule['lastchapterlist'].type);

            log.debugList([booklist,imglist,namelist,desclist,authorlist,lastchapterlist]);
            List<SearchResult> args =  new List.generate(booklist.length, (index){
                SearchResult _searchResult = new SearchResult(namelist[index]);
                
                _searchResult.addBookInfo(new BookMsgInfo([imglist[index],authorlist[index],booklist[index],desclist[index],lastchapterlist[index]]));
                _searchResult.addSource(source);
                return _searchResult;
            });
            success(args);
        }, (error){
            print(error);
        });
    }

}