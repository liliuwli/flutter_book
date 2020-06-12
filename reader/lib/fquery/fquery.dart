import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';
import 'package:reader/fquery/xpath.dart';


class Fquery{
    static Document document;
    //static DOMXpath xpath;

    //默认utf8编码
    static void newDocument(String makeup){
        document = parse(makeup);
    }

    static List<String> selector(String selector,selectorType _selectorType){
        switch(_selectorType){
            case selectorType.xpath:
                return Fquery._xpath_select(selector);
                break;
        }
    }

    static List<String> _xpath_select(String selector){
        return Xpath.query(selector,document);
    }
}

enum selectorType{
    xpath,
    regex,
    css
}