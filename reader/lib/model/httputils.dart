import 'package:reader/model/search.dart';

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

    //同时请求多个小说  设计未考虑章节名  可以从url倒推章节名
    Future<List<BookChapter>> MutilReqChapter(List<BookChapter> chapterList,String bookname , Source _source) async {
        int length = 5;
        int index;
        //待处理队列
        List<String> RequestUrl = List<String>();
        List<BookChapter> waitload = List<BookChapter>();

        String readmark;

        return await Search.getBookShelfByName(bookname).then((SearchResult _searchResult){
            readmark = _searchResult.readmark;
            //根据已读章节名匹配章节记录  （如果出现重复章节名可能有bug）
            if(readmark != null){
                for(int i=0;i<chapterList.length;i++){
                    if(readmark == chapterList[i].name){
                        index = i;
                        break;
                    }
                }
            }

            //匹配不到  从头阅读
            if(index == null){
                index = 0;
            }

            //阅读队列  大于剩余章节  剩余章节全部纳入队列
            if(length > chapterList.length-1-index){
                for(int i=index;i<chapterList.length;i++){
                    RequestUrl.add(chapterList[i].chapterUrl);
                    waitload.add(chapterList[i]);
                }
            }else{
                //否则从记录点  加载满阅读队列
                for(int i = index;i<(index+length);i++){
                    RequestUrl.add(chapterList[i].chapterUrl);
                    waitload.add(chapterList[i]);
                }
            }

            if(RequestUrl.length == 0){
                //已经阅读到最后一章
                index = chapterList.length - 1;
                RequestUrl.add(chapterList[index].chapterUrl);
                waitload.add(chapterList[index]);
            }


            List<String> _requestUrl = List<String>();
            //如果请求是相对路径 补全请求地址
            RequestUrl.forEach((String _url) {
                if( !RegExp("http").hasMatch(_url.toLowerCase()) ){
                    _url = _source.baseUrl+_url;
                }
                _requestUrl.add(_url);
            });
            return _requestUrl;
        }).then((List<String> _requestUrl) async {
            return await HttpManage.getInstance().MutilRequest(_requestUrl).then((List<String> html){

                int i = 0;
                html.forEach((String htmlItem) {
                    Fquery.newDocument(htmlItem);
                    List<String> namelist = Fquery.selector(_source.ChapterRule['chapter'].reg,_source.ChapterRule['chapter'].type);
                    String htmlString = "";
                    namelist.forEach((item) {
                        htmlString += item;
                    });
                    htmlString = htmlString.replaceAll("&nbsp;", " ");
                    htmlString = htmlString.replaceAll(new RegExp("<br[^>]*?>"), "\r\n");

                    waitload[i].content = htmlString;
                    waitload[i].sortid = index+i;
                    i++;
                });
                return waitload;
            });
        });
    }
}