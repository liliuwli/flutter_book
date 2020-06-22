import 'package:flutter/material.dart';
import 'search.dart';
import 'menu.dart';
import 'book.dart';
import 'test.dart';
import 'h.dart';
import 'model/search.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return new MaterialApp(
			title: 'Flutter Reader',
			home: new App(),
			routes: {
				'/Search':(context) => new SearchScreen(),
				'/Test':(context) => new TestScreen(),
				'/Menu':(context) => new MenuScreen(),
				'/Book':(context) => new BookScreen(),
			},
		);
	}
}

class App extends StatefulWidget {
	@override
	createState() => new AppState();
}

class AppState extends State<App> {
	bool isLoadBookShelf = false;
	List<SearchResult> bookshelf = new List<SearchResult>();
	@override
	void initState() {
		super.initState();
		getBookShelf();
	}

	//获取书架信息
	void getBookShelf(){
		if (isLoadBookShelf) {
			return;
		}
		setState(() {
			isLoadBookShelf = true;
		});

		Search.getBookShelf().then((List<SearchResult> _bookshelf){
			setState(() {
				bookshelf = _bookshelf;
				isLoadBookShelf = false;
			});
		});
	}

	@override
	//控制TextField 焦点的获取与关闭
	FocusNode focusNode = new FocusNode();

	//build被setState触发
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: new AppBar(
				title: new Text('阅读'),
				actions: <Widget>[
					//菜单键
					new IconButton(icon:new Icon(Icons.list),onPressed: _clickMenu,),
				],
			),
			body: new Column(
				children: [
					//跳转搜索页面
					new Container(
						child: new TextField(
							decoration: InputDecoration(
								hintText:'输入书籍或作者'
							),
							focusNode: focusNode,
							autofocus: false,
							onTap: _clickSearch,
						),
						margin: const EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 10),
					),
					//批量生成子元素
					new Expanded(
						//嵌套解决 ListView高度超标问题
							child:new Container(
								child:new ListView.builder(
									padding: const EdgeInsets.all(16.0),
									shrinkWrap: true,
									itemCount: bookshelf.length,
									itemBuilder:(context,i){
										if(i<bookshelf.length){
											return new BookItem(this,bookshelf[i]);
										}
									},
								),
							)
					)
				],
			),
		);
	}

	void _clickMenu(){
		print("点击成功，后面改成路由跳转");
		Navigator.pushNamed(
			context,
			"/Menu"
		);
		return;
	}

	void _clickSearch(){
		focusNode.unfocus();
		print("点击成功，但是并未触发小键盘，后面改成路由跳转");
		Navigator.pushNamed(
			context,
			"/Search"
		);
		return;
	}
}

//初始化单本书
class BookItem extends StatelessWidget {
	@override
	AppState _appState;

	String img;
	String name;
	String author;
	String readmark;
	String lastChapter;
	String chapterlisturl;
	int index;

	BookSource source;

	BookItem(this._appState,SearchResult _searchResult){
		//this.img,this.name,this.author,this.readmark,this.lastChapter,this.Source
		name = _searchResult.name;
		index = _searchResult.index;
		img = _searchResult.bookinfolist.bookMsgInfoList[index].imgurl;
		author = _searchResult.bookinfolist.bookMsgInfoList[index].author;
		lastChapter = _searchResult.bookinfolist.bookMsgInfoList[index].lastChapter;
		chapterlisturl = _searchResult.bookinfolist.bookMsgInfoList[index].booklist;
		readmark = _searchResult.readmark == null?"暂未阅读":_searchResult.readmark;
		source = _searchResult.sourcelist.bookSourceList[index];
	}

	final titlefont = const TextStyle(fontSize: 16.0,height: 1);
	final otherfont = const TextStyle(fontSize: 10,height: 1);

	Widget build(BuildContext context) {
		return new GestureDetector(
			child:new Container(
				child:new Row(
					children: [
						//img
						new Expanded(
							child: new Container(
								child: new FadeInImage.assetNetwork(
									placeholder: 'lib/assets/images/nocover.jpg',
									image: this.img
								),
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
												this.name,
												style: titlefont,
											)
										],
									),
									//作者
									new Row(
										children: [
											new Icon(Icons.account_circle,color: Colors.black26,),
											new Text(
												this.author,
												style: otherfont,
											)
										],
									),
									//已读
									new Row(
										children: [
											new Icon(Icons.access_time,color: Colors.black26,),
											new Text(
												this.readmark,
												style: otherfont,
											)
										],
									),
									//更新
									new Row(
										children: [
											new Icon(Icons.access_alarm,color: Colors.black26,),
											new Text(
												this.lastChapter,
												style: otherfont,
											)
										],
									),
								],
							),
							flex:6
						),
						new Expanded(
							child: new Container(
								child: new Icon(Icons.filter_9_plus,color: Colors.red,),
							),
							flex:1
						),
					],
				),
				decoration: BoxDecoration(
					border:Border(
						bottom:BorderSide(width: 1,color: Colors.black26)
					)
				),
			),
			onTap:() async {
				final result = await Navigator.pushNamed(
					context,
					"/Book",
					arguments: BookPageArguments(name,source.id,chapterlisturl,readmark)
				);

				///note : 缺少刷新图标
				_appState.setState(() {
					Search.getBookShelf().then((List<SearchResult> _bookshelf){
						_appState.setState(() {
							_appState.bookshelf = _bookshelf;
						});
					});
				});
			}
		);
	}
}