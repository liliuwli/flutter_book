class Source{
  String name = '顶点小说网';

  String baseUrl = "https://www.booktxt.com";
  String SearchUrl = "/search.php?keyword=|match|";
  num SearchType = 0;     //urlencode

  static Map<String,ParserRule> SearchRule = <String,ParserRule>{
      'list_uri':new ParserRule('search_lastchapter',ParserType.xpath,'/html"]'),
      'img':new ParserRule('search_img',ParserType.xpath,'//*[@class="result-game-item-pic"]/a/img/attribute:src'),
      'name':new ParserRule('search_name',ParserType.xpath,'//*[@class="result-game-item-detail"]/h3/a/span/text()'),
      'desc':new ParserRule('search_desc',ParserType.xpath,'//*[@class="result-game-item-desc"]/text()'),
      'author':new ParserRule('search_author',ParserType.xpath,'//*[@class="result-game-item-info"]/p[1]/span/text()'),
      'lastchapter':new ParserRule('search_lastchapter',ParserType.xpath,'//*[@class="result-game-item-info"]/p[last()]/a/text()'),
  };

  Source();


}


//规则信息
class ParserRule{
  String name;

  ParserType type;

  String reg;

  ParserRule(this.name,this.type,this.reg);
}

enum ParserType{
  regular,
  xpath,
  jquery
}