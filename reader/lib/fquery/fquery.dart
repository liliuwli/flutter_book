import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:reader/fquery/xpath.dart';
import '../model/source.dart';

class Fquery{
    static Document document;

    //默认utf8编码
    static void newDocument(String makeup){
        document = parse(makeup);
    }

    static List<String> selector(String selector,ParserType _selectorType){
        switch(_selectorType){
            case ParserType.xpath:
                return Fquery._xpath_select(selector);
                break;
        }
    }

    static List<String> _xpath_select(String selector){
        return Xpath.query(selector,document);
    }
}