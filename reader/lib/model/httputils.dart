import 'httpmanger.dart';
import 'source.dart';
import 'package:reader/utils/log.dart';
import 'package:reader/h.dart';

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

    //后续发展多源异步获取数据
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

            //log.debugList([booklist,imglist,namelist,desclist,authorlist,lastchapterlist]);
            List<SearchResult> args =  new List.generate(booklist.length, (index){
                SearchResult _searchResult = new SearchResult(namelist[index]);
                
                _searchResult.addBookInfo(new BookMsgInfo([imglist[index],authorlist[index],booklist[index],desclist[index],lastchapterlist[index]]));
                _searchResult.addSource(new BookSource(source.name,source.id));
                return _searchResult;
            });
            success(args);
        }, (error){
            print(error);
        });
    }

    //异步获取小说目录
    Future<List<BookChapter>> ParserChapterList(String chapterlisturl,Source source) async {
        return await HttpManage.getInstance().asyncGet(chapterlisturl, {}).then((String html){
            Fquery.newDocument(html);
            List<String> namelist = Fquery.selector(source.ListRule['chapterName'].reg,source.ListRule['chapterName'].type);
            List<String> urllist = Fquery.selector(source.ListRule['chapterUrl'].reg,source.ListRule['chapterUrl'].type);

            return List.generate(namelist.length, (index) => new BookChapter(namelist[index], urllist[index]));
        });
    }

    //同时请求多个小说
    Future<List<String>> MutilReqChapter(List<BookChapter> chapterList,String readmark , Source _source) async {
        int length = 5;
        int index;
        List<String> RequestUrl = [];
        if(readmark != null){
            for(int i=0;i<chapterList.length;i++){
                if(readmark == chapterList[i].name){
                    index = i;
                    break;
                }
            }
        }

        if(index == null){
            index = 0;
        }

        if(length > chapterList.length-1-index){
            for(int i=index;i<chapterList.length;i++){
                if( RegExp("http").hasMatch(chapterList[i].chapterUrl.toLowerCase()) ){
                    RequestUrl.add(chapterList[i].chapterUrl);
                }else{
                    RequestUrl.add(_source.baseUrl+chapterList[i].chapterUrl);
                }
            }
        }else{
            for(int i = index;i<(index+length);i++){
                if( RegExp("http").hasMatch(chapterList[i].chapterUrl.toLowerCase()) ){
                    RequestUrl.add(chapterList[i].chapterUrl);
                }else{
                    RequestUrl.add(_source.baseUrl+chapterList[i].chapterUrl);
                }
            }
        }

        if(RequestUrl.length == 0){
            //阅读到最后
            index = chapterList.length - 1;
            if( RegExp("http").hasMatch(chapterList[index].chapterUrl.toLowerCase()) ){
                RequestUrl.add(chapterList[index].chapterUrl);
            }else{
                RequestUrl.add(_source.baseUrl+chapterList[index].chapterUrl);
            }
        }

        //mark 缺少读取小说内容
        return await HttpManage.getInstance().MutilRequest(RequestUrl).then((List<String> html){
            List<String> ret = List<String>();
            html.forEach((String htmlItem) {
                Fquery.newDocument(htmlItem);
                List<String> namelist = Fquery.selector(_source.ChapterRule['chapter'].reg,_source.ChapterRule['chapter'].type);
                String htmlString = "";
                namelist.forEach((item) {
                    htmlString += item;
                });
                htmlString = htmlString.replaceAll("&nbsp;", " ");
                htmlString = htmlString.replaceAll(new RegExp("<br[^>]*?>"), "\r\n");
                ret.add(htmlString);
            });
            return ret;
        });
    }
}