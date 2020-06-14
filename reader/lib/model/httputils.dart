import 'httpmanger.dart';
import 'source.dart';

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

    void SearchBook(String keyword){
        Source source = Source.getSource();
        HttpManage.getInstance().get(source.baseUrl+source.SearchUrl,{source.SearchKey:keyword}, (String html){
            /*
            html = html.replaceAll(RegExp(r"<!DOCTYPE[^>]*?>\s*"),"");
            html = html.replaceAll(RegExp(r'<style[^>]*?>[^<]*?<[^>]style*?>'),"");
            html = html.replaceAll(RegExp(r'<script[^>]*?>[^<]*?<[^>]script*?>'),"");
            html = html.replaceAll(RegExp(r'<meta[^>]*?>'),"");
            */
            Fquery.newDocument(html);
            List<String> booklist = Fquery.selector(source.SearchRule['booklist'].reg,source.SearchRule['booklist'].type);
            List<String> imglist = Fquery.selector(source.SearchRule['imglist'].reg,source.SearchRule['imglist'].type);
            List<String> namelist = Fquery.selector(source.SearchRule['namelist'].reg,source.SearchRule['namelist'].type);
            List<String> desclist = Fquery.selector(source.SearchRule['desclist'].reg,source.SearchRule['desclist'].type);
            List<String> authorlist = Fquery.selector(source.SearchRule['authorlist'].reg,source.SearchRule['authorlist'].type);
            List<String> lastchapterlist = Fquery.selector(source.SearchRule['lastchapterlist'].reg,source.SearchRule['lastchapterlist'].type);
            print(booklist);
            print(imglist);
            print(namelist);
            print(desclist);
            print(authorlist);
            print(lastchapterlist);
        }, (error){
            print(error);
        });
    }

    void PaserHttptest(){
        HttpManage.getInstance().get("https://www.booktxt.com/search.php?keyword=%E4%B8%89%E6%88%92",Map(),
                //success
                (String html){
                    //没得好用得xpath 需要自己实现
                    html = html.replaceAll(RegExp(r"<!DOCTYPE[^>]*?html>\s*"),"");
                    html = html.replaceAll(RegExp(r'<style[^>]*?>[^<]*?<[^>]style*?>'),"");
                    html = html.replaceAll(RegExp(r'<script[^>]*?>[^<]*?<[^>]script*?>'),"");
                    html = html.replaceAll(RegExp(r'<meta[^>]*?>'),"");

                    Fquery.newDocument(html);
                    List<String> match = Fquery.selector('//div[@class="result-game-item-pic"]/a/img:src',ParserType.xpath);
                    print(match);
                    //ETree tree = ETree.fromString(html);
                    //Source.SearchRule['list_uri'].reg = '//*html';
                    //List<Element> elements = tree.xpath(Source.SearchRule['list_uri'].reg);
                    //print(Source.SearchRule['list_uri'].reg);
                    //print(elements);
                    //print(html);
                },
                //error
                (error){
                    print(error);
                }
        );
    }

}