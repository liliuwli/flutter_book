import 'dart:async';
import 'dart:convert';

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

    Map<String,ParserRule> ChapterRule = <String,ParserRule>{
        'chapter':new ParserRule(ParserType.xpath,'//div[@class="content_read"]/div[@class="box_con"]/div[@id="content"]/text()'),
    };


    @override
    String toString() {
        return jsonEncode(this);
    }

    Source();

    static Source getSource(){
        return new Source();
    }

    static Future<Source> getSourceById(int sourceid) async {
        Completer _completer = Completer<Source>();
        _completer.complete(new Source());
        return await _completer.future;
    }

    //从json解析出对象
    Source.fromJson(Map<String,dynamic> jsonobj){
        id = jsonobj['id'];
        name = jsonobj['name'];
        baseUrl = jsonobj['baseUrl'];
        SearchUrl = jsonobj['SearchUrl'];
        SearchKey = jsonobj['SearchKey'];

        Map<String,ParserRule> SearchRule = <String,ParserRule>{};
        (jsonobj['SearchRule'] as Map).forEach((key, value) {
            SearchRule[key] = ParserRule.fromJson(value);
        });

        Map<String,ParserRule> ListRule = <String,ParserRule>{};
        (jsonobj['ListRule'] as Map).forEach((key, value) {
            ListRule[key] = ParserRule.fromJson(value);
        });

        Map<String,ParserRule> ChapterRule = <String,ParserRule>{};
        (jsonobj['ChapterRule'] as Map).forEach((key, value) {
            ChapterRule[key] = ParserRule.fromJson(value);
        });
    }



    Map<String,dynamic> toJson() {
        final Map<String,dynamic> data = new Map<String,dynamic>();
        data["id"] = this.id;
        data["name"] = this.name;
        data["baseUrl"] = this.baseUrl;
        data["SearchUrl"] = this.SearchUrl;
        data["SearchKey"] = this.SearchKey;


        data['SearchRule'] = this.SearchRule.map((key, value){
            return new MapEntry(key, value.toJson());
        });


        data['ListRule'] = this.ListRule.map((key, value){
            return new MapEntry(key, value.toJson());
        });


        data['ChapterRule'] = this.ChapterRule.map((key, value){
            return new MapEntry(key, value.toJson());
        });

        return data;
    }
}


//规则信息
class ParserRule{
    ParserType type;

    String reg;

    ParserRule(this.type,this.reg);

    ParserRule.fromJson(Map<String,dynamic> jsonobj){
        switch(jsonobj['type']){
            case 0:
                type = ParserType.regular;
                break;
            case 1:
                type = ParserType.xpath;
                break;
            case 2:
                type = ParserType.jquery;
                break;
        }

        reg = jsonobj['reg'];
    }

    Map<String,dynamic> toJson() {
        final Map<String,dynamic> data = new Map<String,dynamic>();
        switch(this.type){
            case ParserType.regular:
                data["type"] = 0;
                break;
            case ParserType.xpath:
                data["type"] = 1;
                break;
            case ParserType.jquery:
                data["type"] = 2;
                break;
        }

        data["reg"] = this.reg;

        return data;
    }
}

enum ParserType{
    regular,
    xpath,
    jquery
}