import 'dart:async';
import 'dart:convert';

//网络加载的书源信息
class Source{
    int id = 2;
    String name = '书趣阁';

    String baseUrl = "http://www.shuquge.com";
    String SearchUrl = "/search.php";
    String SearchKey = "searchkey";

    /**
     *       SearchType 搜索类型
     *      0 默认get请求 get参数
     *      1 post请求
     *      2 post请求带cookie校验 校验码存储在js内
     */
    int SearchType = 2;

    ///增加对表单令牌的支持
    int CheckKeyType = 0;
    String CheckUrl = "http://www.shuquge.com/js/common.js";
    String CheckKeyReg = 'input.*?name=\\\\"(s)\\\\".*?value=\\\\"([^\\\\]*?)\\\\"';

    Map<String,ParserRule> SearchRule = <String,ParserRule>{
        'booklist':new ParserRule(ParserType.xpath,'//div[@class="bookbox"]/div[@class="p10"]/div[@class="bookinfo"]/h4/a:href'),
        'imglist':new ParserRule(ParserType.xpath,''),
        'namelist':new ParserRule(ParserType.xpath,'//div[@class="bookbox"]/div[@class="p10"]/div[@class="bookinfo"]/h4/a/text()'),
        'desclist':new ParserRule(ParserType.xpath,''),
        'authorlist':new ParserRule(ParserType.xpath,'//div[@class="bookbox"]/div[@class="p10"]/div[@class="bookinfo"]/div[@class="author"]/text()'),
        'lastchapterlist':new ParserRule(ParserType.xpath,'//div[@class="bookbox"]/div[@class="p10"]/div[@class="bookinfo"]/div[@class="update"]/a/text()'),
    };

    Map<String,ParserRule> ListRule = <String,ParserRule>{
        'chapterName':new ParserRule(ParserType.xpath,'//div[@class="listmain"]/dl/dd[position()>12]/a/text()'),
        'chapterUrl':new ParserRule(ParserType.xpath,'//div[@class="listmain"]/dl/dd[position()>12]/a:href'),
    };

    Map<String,ParserRule> ChapterRule = <String,ParserRule>{
        'chapter':new ParserRule(ParserType.xpath,'//div[@class="content"]/div[@id="content"]/text()'),
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

        if(jsonobj.containsKey("SearchType")){
            SearchType = jsonobj['SearchType'];
            CheckKeyType = jsonobj['CheckKeyType'];
            CheckUrl = jsonobj['CheckUrl'];
            CheckKeyReg = jsonobj['CheckKeyReg'];
        }else{
            SearchType = 0;
            CheckKeyType = 0;
            CheckUrl = "";
            CheckKeyReg = "";
        }

        (jsonobj['SearchRule'] as Map).forEach((key, value) {
            SearchRule[key] = ParserRule.fromJson(value);
        });

        (jsonobj['ListRule'] as Map).forEach((key, value) {
            ListRule[key] = ParserRule.fromJson(value);
        });

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

        data["SearchType"] = this.SearchType;
        data["CheckKeyType"] = this.CheckKeyType;
        data["CheckUrl"] = this.CheckUrl;
        data["CheckKeyReg"] = this.CheckKeyReg;


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


    @override
    String toString() {
        return 'ParserRule{reg: $reg}';
    }

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