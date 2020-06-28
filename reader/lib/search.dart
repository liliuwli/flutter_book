import 'package:flutter/material.dart';
import 'package:reader/model/sourcemanger.dart';
import 'h.dart';
import 'utils/common.dart';
import 'model/search.dart';
import 'model/httputils.dart';
import 'dart:async';

import 'package:reader/model/source.dart';

class SearchScreen extends StatelessWidget{
	BuildContext PageContext;
	@override
	Widget build(BuildContext context){
		PageContext = context;
		return WillPopScope(
			child: new SearchPage(),
			onWillPop:_onWillPop,
		);
	}

	Future<bool> _onWillPop(){
		Navigator.pop(PageContext);
		return new Future.value(false);
	}
}


class SearchPage extends StatefulWidget{
	@override
	createState() => new SearchState();
}

class SearchState extends State<SearchPage>{
	List<String> history = [];
	List<SearchResult> _searchresult = [];
	List<SearchResult> bookshelf = [];
	int page = 0;
	bool isLoading = false;//是否正在请求新数据
	bool isLoadBookShelf = false;
	bool offState = false;//是否显示进入页面时的圆形进度条

	bool _delIcon = false;      //清理搜索框
	int _searchstate = 0;       //0未开始 1搜索开始 2搜索停止
	final textEditingController = new TextEditingController();

	//监听滚动
	ScrollController scrollController = new ScrollController();

	//初始化数据
	@override
	void initState() {
		super.initState();
		searchInit().then((_){
			setState(() {
				offState = true;
			});
		});
	}

	//初始化页面数据
	Future<List<void>> searchInit() async{
		Completer<List<void>> _completer;
		final ret = await Future.wait([getBookShelf(),getHistoryData()]);

		_completer = Completer<List<void>>();
		_completer.complete(ret);
		return _completer.future;
	}

	//获取书架信息
	Future<void> getBookShelf() async {
		if (isLoadBookShelf) {
			return;
		}
		setState(() {
			isLoadBookShelf = true;
		});

		return await Search.getBookShelf().then((List<SearchResult> _bookshelf){
			setState(() {
				bookshelf = _bookshelf;
				isLoadBookShelf = false;
			});
		});
	}

	//获取历史数据
	Future<void> getHistoryData() async {
		if (isLoading) {
			return;
		}
		setState(() {
			isLoading = true;
		});

		return await Search.SearchHistory().then((List<String> _history){
			setState(() {
				isLoading = false;
				history = _history;
			});
		});
	}

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
				appBar: AppBar(
					title: Text("搜索小说"),
				),
				body: Stack(
					children: <Widget>[
						//底部刷新容器
						RefreshIndicator(
							child: choiceWidget(context),
							onRefresh: ()async{
								await Future.delayed(Duration(seconds: 1), () {
									return ;
								});
							},
						),
						Offstage(
							//loading进度条
							offstage: offState,
							child: Center(
								child: CircularProgressIndicator(),
							),
						),
					],
				)
		);
	}

	@override
	void dispose() {
		super.dispose();
		//手动停止滑动监听
		scrollController.dispose();
	}

	//初始化页面
	Widget choiceWidget(BuildContext context) {

		return new Column(
			children: [
				_searchWidget(),
				_searchstate==0?_getHistory():_getSearch(),
			]
		);
	}

	void _clickSearch(String searchtext) {
		if (isLoading) {
			return;
		}
		setState(() {
			//搜索中
			isLoading = true;
			_searchstate = 1;
			offState = false;
		});

		textEditingController.text = searchtext;
		_delIcon = true;

		//新搜索词
		if(history.indexOf(searchtext) < 0){
			history.add(searchtext);
		}

		Search.SaveSearchHistory(history).then((bool status) async {
			//后续修改为多源操作
			await Request.getInstance().MutilSearchBook(searchtext).then((List<SearchResult> args){
				print(args.length);
				setState(() {
					_searchresult = args;
					offState = true;
					isLoading = false;
					_searchstate = 2;
				});
			});
			//SourceManger.addSource(sourceType:SourceType.file);

			/*

			//指定书源搜索
			await SourceManger.getSourceById(2).then((Source _source) async {
				//print("搜索书源规则：");
				//print(_source);
				await Request.getInstance().SearchBookBySource(searchtext, _source).then((List<SearchResult> args){
					setState(() {
						_searchresult = args;
						offState = true;
						isLoading = false;
						_searchstate = 2;
					});
				});
			});

			 */
		});

	}

	//清理搜索框 还原搜索状态
	void _clickClear(){
		Search.ClearSearchHistory().then((value){
			setState(() {
				history.clear();
			});
		});
	}

	//获取历史
	Widget _getHistory(){
		return new Container(
			child:history.length == 0 ?new Text(""):new Wrap(
				spacing: 10,     //主轴元素间距
				runSpacing:20,  //交叉轴间距
				children: List.generate(
					history.length+1, (index) {
						String _text;
						if(index == history.length){
							_text = '清空历史记录';
						}else{
							_text = history[index];
						}

						return new GestureDetector(
							child: new Container(
								child: new Text(
									_text,
									style: new TextStyle(
										fontSize: 18,
										color: Colors.black,
									),
								),
								decoration: BoxDecoration(
									color: Colors.amberAccent,
								),
								padding: new EdgeInsets.all(6),
							),
							onTap: (){
								if(index == history.length){
									_clickClear();
								}else{
									_clickSearch(history[index]);
								}
							},
						);
					}
				),
			),
		);
	}


	//搜索显示搜索结果
	Widget _getSearch(){
		if(_searchstate != 2){
			return new Text("");
		}

		return new Expanded(
			child: new Container(
				child:new ListView.builder(
					padding: const EdgeInsets.all(5.0),
					shrinkWrap: true,
					itemCount: _searchresult.length,
					itemBuilder:(context,i){
						if( _searchresult[i] != null ){
							return new SearchItem(_searchresult[i],bookshelf);
						}else{
							return new Text("");
						}
					},
				),
				decoration: new BoxDecoration(
					color: Colors.white70,
				),
				padding: const EdgeInsets.only(left:15.0,right: 15),
			),
		);
	}

	//清空搜索栏
	Widget getDelIcon(){
		if(_delIcon){
			return new Container(
				width: 20,
				height: 20,
				child: new IconButton(
						icon: new Icon(Icons.cancel),
						onPressed: (){
							setState(() {
								//后续触发退出搜索
								textEditingController.text = "";
								_delIcon = false;
								_searchstate = 0;
								_searchresult = [];
							});
						}
				),
			);
		}else{
			return new Text("");
		}
	}

	Widget _searchWidget(){
		return new Container(
			child: new TextField(
				//管理input 附属del操作
				decoration: new InputDecoration(
					hintText:'输入书籍或作者',
					//清理框内内容
					suffixIcon:getDelIcon(),
				),
				autofocus: true,
				controller: textEditingController,
				textInputAction: TextInputAction.search,
				onChanged: (str){
					setState(() {
						if( str.length>0 ){
							_delIcon = true;
						}else{
							_delIcon = false;
						}
					});
				},
				onSubmitted: (e){
					String searchtext = e.toString();
					_clickSearch(searchtext);
				},
			),
			margin: new EdgeInsets.all(20),
		);
	}
}

Widget getImg(String img){
	if(img==""){
		return new Image.asset(
			'lib/assets/images/nocover.jpg'
		);
	}else{
		return new FadeInImage.assetNetwork(
			placeholder: 'lib/assets/images/nocover.jpg',
			image: img,
		);
	}
}

//初始化单本书
class SearchItem extends StatelessWidget {
	String img;
	String name;
	String author;
	String lastChapter;
	String booklist;
	BookSource source;

	//搜索结果和键
	int index;
	SearchResult args;
	//加载数据
	bool dataload = false;

	//加入书架操作
	bool isset = false;

	SearchItem(SearchResult args,List<SearchResult> _bookshelf){
		this.index = args.index;
		this.name = args.name;
		this.author = args.bookinfolist.bookMsgInfoList[this.index].author;
		this.img = args.bookinfolist.bookMsgInfoList[this.index].imgurl;
		this.lastChapter = args.bookinfolist.bookMsgInfoList[this.index].lastChapter;
		this.booklist = args.bookinfolist.bookMsgInfoList[this.index].booklist;
		this.source = args.sourcelist.bookSourceList[this.index];

		this.args = args;
		this.index = index;

		_bookshelf.forEach((element) {
			if(element.name == name){
				isset = true;
			}
		});
	}

	final titlefont = const TextStyle(fontSize: 14.0,height: 1);
	final otherfont = const TextStyle(fontSize: 12,height: 1);

	Widget build(BuildContext context) {
		//创建具备点击事件
		return new GestureDetector(
			child:new Container(
				child:new Row(
					children: [
							//封面
						new Expanded(
							child: new Container(
								//加载占位图,
								child: getImg(this.img),
								margin: EdgeInsets.only(right: 10,bottom: 10,top: 10),
							),
							flex:1
						),
						new Expanded(
							child: new Column(
								children: [
									//标题
									new Container(
										child: new Text(
											this.name,
											style: titlefont,
										),
										alignment: FractionalOffset.centerLeft,
										margin: EdgeInsets.only(bottom: 15),
									),
											//标题
									new Container(
										child: new Text(
											this.author,
											style: titlefont,
										),
										alignment: FractionalOffset.centerLeft,
										margin: EdgeInsets.only(bottom: 15),
									),
											//更新
									new Container(
										child: new Text(
											this.lastChapter,
											style: titlefont,
										),
										alignment: FractionalOffset.centerLeft,
										margin: EdgeInsets.only(bottom: 15),
									),
									//来源
									new Container(
										child: new Text(
											this.source.name,
											style: titlefont,
										),
										alignment: FractionalOffset.centerLeft,
									),
								],
								mainAxisSize: MainAxisSize.max,
							),
							flex:3
						)
					],
				),
				decoration: BoxDecoration(
					border:Border(
						bottom:BorderSide(width: 1,color: Colors.black26)
					)
				),

			),
			onTap:(){
				_showBookActionsDialog(context,this.name,args.bookinfolist.bookMsgInfoList,args.sourcelist.bookSourceList,this.index);
			}
		);
	}

	///显示菜单ui
	void _showBookActionsDialog(BuildContext context, String name, List<BookMsgInfo> bookinfo, List<BookSource> sourcelist, int index){
		//显示result信息
		showDialog(
			context: context,
				barrierDismissible: true,           //点击空白退出
				builder: (BuildContext context) {
					return StatefulBuilder(builder: (context, state)
					{
						return AlertDialog(
							content: new Container(
								//显示详情
								child: new Column(
									children: [
										getContentHead(
												name, bookinfo, sourcelist,
												index),
										getContentBody(bookinfo[index].desc),
									],
								),
								decoration: BoxDecoration(
										border: Border(
												bottom: BorderSide(width: 1,
														color: Colors.black26)
										)
								),
								width: MediaQuery
										.of(context)
										.size
										.width * 0.8,
								height: MediaQuery
										.of(context)
										.size
										.height * 0.3,
							),
							actions: getBookActions(context,name, bookinfo, sourcelist,
									index,state),

						);
					});
				}
		);
	}

	List<Widget> getBookActions(BuildContext context, String name, List<BookMsgInfo> bookinfo, List<BookSource> sourcelist, int index,Function(void Function()) state){
		return [
			FlatButton(
				onPressed: () {
					Navigator.of(context).pop();
				},
				child: Text('关闭弹窗'),
			),
			FlatButton(
				onPressed: () {
					if(isset){
						//移除书架内小说
						Removebook(name, state, context);
					}else{
						//加入书架
						Addbook(name, bookinfo, sourcelist,
								index, state);
					}
				},
				child: isset?Text('移除书架'):Text('加入书架'),
			),
			FlatButton(
				onPressed: () {
					int sourceid = sourcelist[index].id;
					String chapterlisturl = bookinfo[index].booklist;
					String readmark = null;
					//String name

					Navigator.pushNamed(
						context,
						"/Book",
						arguments: BookPageArguments(name,sourceid,chapterlisturl,readmark)
					);
				},
				child: Text('开始阅读'),
			),
		];
	}

	void Removebook(String name, Function(void Function()) state , BuildContext context){
		showDialog<Null>(
			context: context,
			barrierDismissible: false,
			builder: (BuildContext _context){
				return new AlertDialog(
					title: new Text("是否清理$name"),
					content: new Text("删除后将清理阅读记录和书签"),
					actions: <Widget>[
						FlatButton(
							child: Text('取消'),
							onPressed: () {
								Navigator.pop(context);
							},
						),
						FlatButton(
							child: Text('删除'),
							onPressed: () {

								if (dataload) {
									return;
								}
								dataload = true;
								Search.DelBookShelf(name).then((value){
									Navigator.pop(context);
									state((){
										isset = false;
										dataload = false;
									});
								});
							},
						),
					],
				);
			},
		);
	}

	//加入书架
	void Addbook(String name, List<BookMsgInfo> bookinfo, List<BookSource> sourcelist, int index, Function(void Function()) state){
		if (dataload) {
			return;
		}
		dataload = true;

		SearchResult _searchResult = new SearchResult(name);
		_searchResult.setBookInfo(bookinfo);
		_searchResult.setSource(sourcelist);
		_searchResult.index = index;

		Search.SetBookShelf(_searchResult).then((value){
			state((){
				isset = true;
				dataload = false;
			});
		});
	}
}


///dialog 内容体
Widget getContentBody(String desc){
	return new Expanded(
		child: new Container(
			child: new ListView(
				children: [
					new Text(desc)
				],
				shrinkWrap: true,
			),
		)
	);
}

///dialog 内容头
Widget getContentHead(String name, List<BookMsgInfo> args, List<BookSource> source, int index){
	final titlefont = const TextStyle(fontSize: 16.0,height: 1);
	final otherfont = const TextStyle(fontSize: 10,height: 1);
	return new Row(
		children: [
			//img
			new Expanded(
					child: new Container(
						child: getImg(args[index].imgurl),
						margin: EdgeInsets.only(right: 10,bottom: 10,top: 10),
					),
					flex:2
			),
			new Expanded(
					child: new Column(
						children: [
							//标题
							new Row(
								children: [
									new Icon(Icons.book,color: Colors.black26,),
									new Text(
										stringLimit(name,7),
										style: titlefont,
									)
								],
							),
							//作者
							new Row(
								children: [
									new Icon(Icons.account_circle,color: Colors.black26,),
									new Text(
										args[index].author,
										style: otherfont,
									)
								],
							),
							//更新
							new Row(
								children: [
									new Icon(Icons.access_alarm,color: Colors.black26,),
									new Text(
										stringLimit(args[index].lastChapter,10),
										style: otherfont,
									)
								],
							),
						],
					),
					flex:4
			),
			new Expanded(
				child: new Container(
					child: new FlatButton(
						onPressed: (){
							print("click huanyuan");
						},
						child: new Text(
							"换源",
							style: otherfont,
						)
					),
				),
				flex:1
			),
		],
	);
}