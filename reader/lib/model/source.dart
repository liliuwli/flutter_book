import 'dart:async';

//网络加载的书源信息
class Source{
    int id = 1;
    String name = '顶点小说网';

    String baseUrl = "https://www.booktxt.com";
    String SearchUrl = "/search.php";
    String SearchKey = "keyword";

    Map<String,ParserRule> SearchRule = <String,ParserRule>{
        'booklist':new ParserRule(ParserType.xpath,'//div[@class="result-game-item-pic"]/a:href'),
        'imglist':new ParserRule(ParserType.xpath,'//div[@class="result-game-item-pic"]/a/img:src'),
        'namelist':new ParserRule(ParserType.xpath,'//div[@class="result-game-item-detail"]/h3/a/span/text()'),
        'desclist':new ParserRule(ParserType.xpath,'//div[@class="result-game-item-desc"]/text()'),
        'authorlist':new ParserRule(ParserType.xpath,'//div[@class="result-game-item-info"]/p[1]/span[2]/text()'),
        'lastchapterlist':new ParserRule(ParserType.xpath,'//div[@class="result-game-item-info"]/p[last()]/a/text()'),
    };

    Map<String,ParserRule> ListRule = <String,ParserRule>{
        'chapterName':new ParserRule(ParserType.xpath,'//div[@class="box_con"]/div[@id="list"]/dd/a/text()'),
        'chapterUrl':new ParserRule(ParserType.xpath,'//div[@class="box_con"]/div[@id="list"]/dd/a:href'),
    };

    Source();

    static Source getSource(){
        return new Source();
    }

    static Future<Source> getSourceById(int sourceid) async {
        Completer _completer = Completer<Source>();
        _completer.complete(new Source());
        return await _completer.future;
    }
}


//规则信息
class ParserRule{

  ParserType type;

  String reg;

  ParserRule(this.type,this.reg);
}

enum ParserType{
  regular,
  xpath,
  jquery
}