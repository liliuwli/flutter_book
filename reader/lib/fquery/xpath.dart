import 'package:html/dom.dart';
import 'package:reader/model/source.dart';

class Xpath{
	static List<Element> root;
	static NodeType state;
	static List<SelectorRule> dpath;

	//暂时不考虑. ..节点操作
	static List<String> query(String selector,Document document){
		if(selector==""){
			return null;
		}
		List<SelectorRule> depath = Xpath.parse(selector);

		//print(dpath);
		return Xpath.domParse(document,dpath);
	}

	static List<String> domParse(Document document,List<SelectorRule> _dpath){
		List<String> ret = [];
		//ret list string
		//print(_dpath);
		switch(state){
			//match start
			case NodeType.match:
			case NodeType.root:
				//attr 暂时只处理class
				_dpath.forEach((_selectorRule) {
					//提取节点
					switch(_selectorRule.selectorType){
						case SelectorType.attr:
							if(_selectorRule.nodeTag != ''){
								//提取筛选属性
								attrMatch _attrMatch = attrMatch.pickattr(_selectorRule.attr);
								root = Xpath.getChild(_attrMatch.attrName.toLowerCase(), _attrMatch.attrValue,_selectorRule.nodeTag,document);
							}
							break;
						case SelectorType.node:
							if(_selectorRule.nodeTag != "."){
								//提取node节点
								root = Xpath.getChild("unattr","",_selectorRule.nodeTag,document);
							}else{
								//当前节点 不改变节点
							}
							break;

						case SelectorType.element_child:
							root = Xpath.getChild("func", _selectorRule.attr, _selectorRule.nodeTag,  document);
							break;
					}
					//print(root);
					//处理返回值
					switch(_selectorRule.returnType){
						case ReturnType.attr:
							ret = new List.generate(root.length, (index) => root[index].attributes[_selectorRule.attr]);
							return;
						case ReturnType.func:
							ret = new List.generate(root.length, (index) => Xpath.callFunc(root[index], _selectorRule.attr));
							return;
					}
				});
				Xpath.reset();
				return ret;
				break;
		}
	}

	static String callFunc(Element element,String func){
		switch(func.toLowerCase()){
			case 'text':
				return element.innerHtml.trim();
				break;
		}
	}

	static void reset(){
		root = null;
		state = null;
		dpath = null;
	}

	//获取子节点 后续切换root节点
	static List<Element> getChild(String attrname,String attrval,String nodeTag,Document document){
		List<Element> _root = [];
		List<Element> ret;

		//last
		bool isLast = false;
		//[123]
		bool isInt = false;
		int IntIndex;

		//position
		int positionType = 0;           //0不启用 1大于 2小于
		int positionKey = 0;            //判断条件

		switch(attrname){
			case "class":
				if(root == null){
					//第一级
					_root = document.querySelectorAll("."+attrval);
				}else{
					//多级筛选
					root.forEach((element) {
						ret = element.getElementsByClassName(attrval);
						ret.forEach((element) {
							if(nodeTag == "*" || element.localName == nodeTag){
								_root.add(element);
							}
						});
					});
				}
				break;
			case "id":
				//id选择器
				if(root == null){
					//第一级
					_root = document.querySelectorAll("#"+attrval);
				}else{
					//多级筛选
					root.forEach((element) {
						ret = element.querySelectorAll("#"+attrval);
						ret.forEach((element) {
							if(nodeTag == "*" || element.localName == nodeTag){
								_root.add(element);
							}
						});
					});
				}
				break;
			case "unattr":
				if(root == null){
					_root = document.querySelectorAll(nodeTag);
				}else{
					root.forEach((element) {
						ret = element.querySelectorAll(nodeTag);
						_root.addAll(ret);
					});
				}
				break;

			case "func":
				//处理数字和函数
				bool isFunc = false;
				String funcname;

				isInt = new RegExp('^[\\d\\s]+\$').hasMatch(attrval);
				if(isInt){
					///html 库不支持 css选择器 nth-child
					attrval = attrval.replaceAll(new RegExp('[\s]'), "");
					IntIndex = int.parse(attrval);
				}else{

					isFunc = new RegExp('([^\(]*?)\\(\\)[+-><]?([\\d]+?)?').hasMatch(attrval);
					if(isFunc){
						RegExpMatch func_match = new RegExp('([^\(]*?)\\(\\)([+-><]?)([\\d]+)?').firstMatch(attrval);

						funcname = func_match.group(1);
						String operator = func_match.group(2);
						String _int = func_match.group(3);


						switch(funcname.toLowerCase()){
							case 'position':
								if(operator == "<"){
									positionType = 2;
								}else if(operator == ">"){
									positionType = 1;
								}
								positionKey = int.parse(_int);
								break;
							case 'last':
								isLast = true;
								/*
								if(_int == null || int.parse(_int) == 0){
									nodeTag = nodeTag+":last-of-type";
								}else{
									nodeTag = nodeTag+":nth-last-child($_int)";
								}
								 */
								break;
							default:
								throw FormatException('not support [] func'+funcname);
								break;
						}

					}else{
						throw FormatException('not support [] has '+attrval);
					}
				}

				if(root == null){
					if(isInt){
						///填坑 css选择器问题  p[2]
						final result = document.querySelectorAll(nodeTag);
						if(IntIndex < result.length && IntIndex >0){
							_root.add(result[IntIndex-1]);
						}
					}else if(isLast){
						///填坑 css选择器问题  p[last()]
						final result = document.querySelectorAll(nodeTag);
						_root.add(result[result.length-1]);
					}else{
						_root = document.querySelectorAll(nodeTag);
					}

					if(positionType>0){
						if(positionKey != 0){
							if(positionType == 1){
								//大于n
								_root.removeRange(0,positionKey-1);
							}

							if(positionType == 2){
								//小于n
								_root.removeRange(positionKey,_root.length-1);
							}
						}else{
							throw FormatException('cant use position not use condition '+attrval);
						}
					}
				}else{
					root.forEach((element) {
						//ret = element.querySelectorAll(nodeTag);
						List<Element> ret = [];

						if(isInt){
							///填坑 css选择器问题  p[2]
							final result = element.querySelectorAll(nodeTag);
							if(IntIndex < result.length && IntIndex >0){
								ret.add(result[IntIndex-1]);
							}
						}else if(isLast){
							///填坑 css选择器问题  p[last()]
							final result = element.querySelectorAll(nodeTag);
							ret.add(result[result.length-1]);
						}else{
							ret = element.querySelectorAll(nodeTag);
						}

						if(positionType>0){
							if(positionKey != 0){
								if(positionType == 1){
									//大于n
									ret.removeRange(0,positionKey);
								}

								if(positionType == 2){
									//小于n
									ret.removeRange(positionKey,ret.length-1);
								}
							}else{
								print(positionType);
								throw FormatException('cant use position not use condition '+attrval);
							}
						}

						ret.forEach((element) {
							_root.add(element);
						});
					});
				}
				break;

			default:
				//String selector_string = nodeTag+'[$attrname="$attrval"]';
				String selector_string = "[name]";
				//print(selector_string);
				if(root == null){
					//第一级
					_root = document.querySelectorAll(selector_string);
				}else{
					//多级筛选
					root.forEach((element) {
						ret = element.querySelectorAll(selector_string);
						ret.forEach((element) {
							_root.add(element);
						});
					});
				}
				break;
		}

		return _root;
	}

	static List<SelectorRule> parse(String selector){
		String _selector = Xpath.parseHead(selector);
		Xpath.parseDpath(_selector);
	}

	static void parseDpath(String _selector){
		if(_selector.length == 0){
			//返回html节点
			Xpath.dpath = new List<SelectorRule>.generate(1, (index) => new SelectorRule(SelectorType.node,ReturnType.element,"html",""));
		}else{
			List<String> matchlist = _selector.split('/');
			//print(matchlist);
			Xpath.dpath = new List<SelectorRule>.generate(matchlist.length,
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

class attrMatch{
	String attrName;
	String attrValue;
	attrMatch(this.attrName,this.attrValue);

	static pickattr(String attr){
		RegExpMatch attr_match = new RegExp('([^=]*?)=[\'"]([^\'"]*?)[\'"]').firstMatch(attr);
		if(attr_match == null){
			throw FormatException('xpath attr selector error');
		}else{
			String attrname = attr_match.group(1);
			String attrval = attr_match.group(2);
			return new attrMatch(attrname, attrval);
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


	@override
	String toString() {
		return 'SelectorRule{selectorType: $selectorType, returnType: $returnType, nodeTag: $nodeTag, attr: $attr}\n';
	}

	//根据string 生成规则
	static SelectorRule getRuleByMatch(String match){
		//match = '*[@class="result-game-item-pic"]';
		//属性筛选子元素必须要中括号
		var hasAttrMatch = new RegExp('\\[@?[^\\]]*?\\]').hasMatch(match);
		if(hasAttrMatch){
			//取出中括号属性内容
			RegExpMatch attr_matchres = new RegExp('([^\\[]*?)\\[@([^\\]]*?)\\]').firstMatch(match);
			if(attr_matchres == null){
				//int func
				RegExpMatch attr_matchres = new RegExp('([^\\[]*?)\\[([^\\]]*?)\\]').firstMatch(match);
				//attr
				String elementStr = attr_matchres.group(1);
				String indexStr = attr_matchres.group(2);
				//检查是否为attr 或者int  mark 暂时未处理下标
				return new SelectorRule(SelectorType.element_child,ReturnType.element_child,elementStr,indexStr);
			}else{
				//attr
				String elementStr = attr_matchres.group(1);
				String attrStr = attr_matchres.group(2);
				//检查是否为attr 或者int
				return new SelectorRule(SelectorType.attr,ReturnType.element,elementStr,attrStr);
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
				//如果是函数
				bool isFunc = new RegExp('([^\(]*?)\\(\\)\$').hasMatch(match);
				if(isFunc){
					RegExpMatch func_match = new RegExp('([^\(]*?)\\(\\)\$').firstMatch(match);
					return new SelectorRule(SelectorType.attr, ReturnType.func,"", func_match.group(1));
				}else{
					String elementStr = match;
					return new SelectorRule(SelectorType.node,ReturnType.element,elementStr,"");
				}
			}
		}
	}
}

enum ReturnType{
	attr,
	func,
	element,
	element_child
}

enum SelectorType{
	attr,
	node,
	element_child
}

enum NodeType{
	// 从根节点匹配
	root,
	// 从匹配到节点匹配
	match
}