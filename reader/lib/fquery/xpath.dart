import 'package:html/dom.dart';

class Xpath{
	static Element root;
	static NodeType state;
	static List<SelectorRule> dpath;

	//暂时不考虑. ..节点操作
	static List<String> query(String selector,Document document){
		List<SelectorRule> depath = Xpath.parse(selector);

		//loop dom
		var ret;
		ret = Xpath.domParse(document,dpath);
		return ret;
	}

	static List<String> domParse(Document document,List<SelectorRule> _dpath){
		switch(state){
			case NodeType.match:
				//match start
				break;
			case NodeType.root:
				//html start
				break;
		}
		return List<String>.generate(1, (index) => 'abc');
	}

	static List<SelectorRule> parse(String selector){
		String _selector = Xpath.parseHead(selector);
		Xpath.parseDpath(_selector);
	}

	static void parseDpath(String _selector){
		if(_selector.length == 0){
			//返回html节点
			Xpath.dpath = List<SelectorRule>.generate(1, (index) => new SelectorRule(SelectorType.node,ReturnType.element,"html",""));
		}else{
			List<String> matchlist = _selector.split('/');
			Xpath.dpath = List<SelectorRule>.generate(matchlist.length,
				(int index) => SelectorRule.getRuleByMatch(matchlist[index])
			);
		}
	}

	//确定检索起点
	static String parseHead(String selector){
		String _selector = selector.replaceAll(new RegExp('^//'), "");
		//依据头定义根节点
		if(selector.length != _selector.length){
			Xpath.state = NodeType.match;
			return _selector;
		}else{
			//直接从根目录开始检索
			_selector = selector.replaceAll(new RegExp('^/'), "");
			if(selector.length != _selector.length && _selector.length != _selector.replaceAll(new RegExp('^/'), "").length){
				Xpath.state = NodeType.root;
				return _selector;
			}else{
				throw FormatException('error xpath');
			}
		}
	}

}

class SelectorRule{
	//根据类型确定检索方式
	SelectorType selectorType;
	//根据类型确定返回值内容
	ReturnType returnType;

	//节点标签
	String nodeTag;
	//节点属性
	String attr;

	SelectorRule(this.selectorType,this.returnType,this.nodeTag,this.attr);

	//根据string 生成规则
	static SelectorRule getRuleByMatch(String match){
		//match = '*[@class="result-game-item-pic"]';
		//属性筛选子元素必须要中括号
		var hasAttrMatch = new RegExp('\\[[^\\]]*?\\]').hasMatch(match);
		if(hasAttrMatch){
			//取出中括号属性内容
			RegExpMatch attr_matchres = new RegExp('\\[([^\\]]*?)\\]').firstMatch(match);
			String matchStr = attr_matchres.group(1);

			//查看元素限定
			String elementStr = match.replaceAll('\\[[^\\]]*?\\]', '');

			//检查是否为attr 或者int
			String attrStr = matchStr.replaceAll('@', '');
			if(matchStr.length != attrStr.length){
				return new SelectorRule(SelectorType.attr,ReturnType.element,elementStr,attrStr);
			}else{
				//暂时不支持 int last() position() 等子元素定位
			}

		}else{
			bool isPickAttr = new RegExp('\:(.*?)\$').hasMatch(match);
			if(isPickAttr){
				//处理 a:href img:src
				RegExpMatch attrval_match = new RegExp('([^:]*?)\:(.*?)\$').firstMatch(match);
				//查看元素限定
				String elementStr = attrval_match[1];
				//提取属性内容
				String attrval = attrval_match[2];

				return new SelectorRule(SelectorType.node,ReturnType.attr,elementStr,attrval);
			}else{
				String elementStr = match;
				return new SelectorRule(SelectorType.node,ReturnType.attr,elementStr,"");
			}
		}
	}
}

enum ReturnType{
	attr,
	text,
	element
}

enum SelectorType{
	attr,
	node
}

enum NodeType{
	// 从根节点匹配
	root,
	// 从匹配到节点匹配
	match
}