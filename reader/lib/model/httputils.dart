import 'package:reader/model/search.dart';

import 'httpmanger.dart';
import 'source.dart';
import 'package:reader/utils/log.dart';
import 'package:reader/utils/common.dart';
import 'package:reader/h.dart';
import 'package:reader/model/sourcemanger.dart';

import 'package:reader/fquery/fquery.dart';

import 'package:dio/dio.dart';

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

    int checkSearchResult(List<SearchResult> ret,SearchResult item){
        int isset = -1;

        for(int i = 0;i<ret.length;i++){
            if(ret[i].name == item.name){
                isset = i;
            }
        }

        return isset;
    }

    Future<List<SearchResult>> MutilSearchBook(String keyword) async {
        ///第一步 获取书源
        return await SourceManger.getSourceList().then((List<Source> sourceList) async {
            return await Future.wait(
                ///多书源并行查询
                List.generate(
                    sourceList.length,
                    (index){
                        Source sourceItem = sourceList[index];
                        return Request.getInstance().SearchBookBySource(keyword,sourceItem);
                    }
                )
            ).then((List<List<SearchResult>> mutilRes){
                List<SearchResult> ret = [];
                mutilRes.forEach((List<SearchResult> res) {
                    ///多个书源
                    res.forEach((SearchResult item) {
                        ///多个结果
                        int isset = checkSearchResult(ret,item);
                        //print(isset.toString() + "item:"+item.name);
                        if(isset>=0){
                            //已存在 进行结果合并
                            ret[isset].sourcelist.length += item.sourcelist.length;
                            ret[isset].bookinfolist.length += item.bookinfolist.length;

                            ret[isset].sourcelist.bookSourceList.addAll(item.sourcelist.bookSourceList);
                            ret[isset].bookinfolist.bookMsgInfoList.addAll(item.bookinfolist.bookMsgInfoList);
                        }else{
                            ret.add(item);
                        }
                    });
                });
                return ret;
            });
        });
    }

    ///利用指定书源搜索小说
    Future<List<SearchResult>> SearchBookBySource(String keyword,Source source) async {
        Response htmlRsp;
        switch(source.SearchType){
            case 0:
                htmlRsp = await HttpManage.getInstance().asyncGet(source.baseUrl+source.SearchUrl, {source.SearchKey:keyword});
                break;
            case 2:
                htmlRsp = await HttpManage.getInstance().checkFormPost(source.baseUrl+source.SearchUrl, {source.SearchKey:keyword},source.CheckKeyType,source.CheckUrl,source.CheckKeyReg);
                break;
        }

        if(htmlRsp.statusCode == 200){

            //print(htmlRsp.data);
            ///获取内容
            Fquery.newDocument(htmlRsp.data);
            List<String> booklist = Fquery.selector(source.SearchRule['booklist'].reg,source.SearchRule['booklist'].type);


            if(booklist == null || booklist.length == 0){
                print("小说列表页数据获取可能有问题");
                return [];
            }

            //可能没有图片
            List<String> imglist;
            if(source.SearchRule['imglist'].reg == ""){
                imglist = List.generate(booklist.length, (index) => "");
            }else{
                imglist = Fquery.selector(source.SearchRule['imglist'].reg,source.SearchRule['imglist'].type);
            }

            if(imglist == null || imglist.length == 0){
                print("小说图片获取可能有问题");
                return null;
            }

            List<String> namelist = Fquery.selector(source.SearchRule['namelist'].reg,source.SearchRule['namelist'].type);
            if(namelist == null || namelist.length == 0){
                print("小说搜索名称 获取可能有问题");
                return null;
            }

            //可能没有简介
            List<String> desclist;

            if(source.SearchRule['desclist'].reg == ""){
                desclist = List.generate(booklist.length, (index) => "");
            }else{
                desclist = Fquery.selector(source.SearchRule['desclist'].reg,source.SearchRule['desclist'].type);
            }

            if(desclist == null || desclist.length == 0){
                print("小说简介获取可能有问题");
                return null;
            }

            List<String> authorlist = Fquery.selector(source.SearchRule['authorlist'].reg,source.SearchRule['authorlist'].type);

            if(authorlist == null || authorlist.length == 0){
                print("小说作者获取可能有问题");
                return null;
            }

            List<String> lastchapterlist = Fquery.selector(source.SearchRule['lastchapterlist'].reg,source.SearchRule['lastchapterlist'].type);
            if(lastchapterlist == null || lastchapterlist.length == 0){
                print("小说最新更新获取可能有问题");
                return null;
            }

            return new List.generate(booklist.length, (index){
                SearchResult _searchResult = new SearchResult(namelist[index]);

                _searchResult.addBookInfo(new BookMsgInfo([imglist[index],authorlist[index],booklist[index],desclist[index],lastchapterlist[index]]));
                _searchResult.addSource(new BookSource(source.name,source.id));
                return _searchResult;
            });
        }else{
            return null;
        }
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

        if( !RegExp("http").hasMatch(chapterlisturl.toLowerCase()) ){
            chapterlisturl = source.baseUrl+chapterlisturl;
        }

        return await HttpManage.getInstance().asyncGet(chapterlisturl, {}).then((Response rsp){
            String html = rsp.data;
            Fquery.newDocument(html);
            List<String> namelist = Fquery.selector(source.ListRule['chapterName'].reg,source.ListRule['chapterName'].type);
            List<String> urllist = Fquery.selector(source.ListRule['chapterUrl'].reg,source.ListRule['chapterUrl'].type);

            if(urllist != null || urllist.length != 0){
                ///返回内容 判断是根目录 还是相对路径
                urllist = urllist.map((String item){

                    //如果是相对路径 返回绝对路径
                    if(!RegExp("http").hasMatch(item.toLowerCase())){
                        if(item.substring(0,1) != "/"){
                            return GetUrlRelativePath(chapterlisturl)+item;
                        }
                    }
                    return item;

                }).toList();
            }

            return List.generate(namelist.length, (index) => new BookChapter(namelist[index], urllist[index],index));
        });
    }

    //同时请求多个小说  设计未考虑章节名  可以从url倒推章节名
    Future<List<BookChapter>> MutilReqChapter(List<BookChapter> chapterList,String bookname , Source _source) async {
        int length = 5;
        int index;
        //待处理队列
        List<String> RequestUrl = List<String>();
        List<BookChapter> waitload = List<BookChapter>();

        //阅读记录
        String readmark;
        int sortid;

        //是否是重复章节名 false 初始 true
        bool isrepeat = false;

        return await Search.getBookShelfByName(bookname).then((SearchResult _searchResult){

            if(_searchResult == null){
                readmark = null;
                sortid = null;
            }else{
                readmark = _searchResult.readmark;
                sortid = _searchResult.sortid;
            }

            //根据已读章节名匹配章节记录  （如果出现重复章节名可能有bug）
            if(readmark != null){
                for(int i=0;i<chapterList.length;i++){
                    if(readmark == chapterList[i].name){
                        index = i;
                        if(isrepeat){
                            ///章节名重复，按章节数来定位
                            index = sortid;
                            break;
                        }else{
                            isrepeat = true;
                        }
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
                    List<String> contentList = Fquery.selector(_source.ChapterRule['chapter'].reg,_source.ChapterRule['chapter'].type);
                    String htmlString = "";
                    contentList.forEach((item) {
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