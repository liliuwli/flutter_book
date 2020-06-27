import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reader/model/source.dart';
import 'package:reader/model/sourcemanger.dart';
import 'package:reader/h.dart';

import 'package:reader/utils/log.dart';
import 'package:reader/model/httputils.dart';

//配备增删改查
class MenuScreen extends StatelessWidget{
	BuildContext PageContext;

	@override
	Widget build(BuildContext context){
		PageContext = context;
		return WillPopScope(
			child: new SourceListPage(),
			onWillPop:_onWillPop,
		);
	}

	Future<bool> _onWillPop(){
		Navigator.pop(PageContext);
		return new Future.value(false);
	}
}

class SourceListPage extends StatefulWidget{
	@override
	createState() => new SourceListPageState();
}

class SourceListPageState extends State<SourceListPage>{
	Widget Page;
	//初始化数据
	@override
	void initState() {
		super.initState();
		//SourceManger.addSource();
	}

	Widget build(BuildContext context) {
		Page = PageContent();
		return new Scaffold(
			appBar: AppBar(
				title: Text("书源管理"),
				actions: <Widget>[
					IconButton(
						icon:new Icon(Icons.add),
						onPressed: addSource,
					),
				],
			),
			body: Page
		);
	}

	//添加书源 - 源码操作
	void addSource(){
		/// backup 记录json数据
		SourceManger.backup().then((List<String> backupContent){
			log.logData(backupContent);
		});

		Source _source = Source.getSource();
		String name;
		/// check search 点测 mark 记录利用xpath开发新书源
		Request.getInstance().SearchBookBySource("斗破苍穹", _source).then((List<SearchResult> res){
			log.logData(res);
			if( res.length<=0 ){
				print("search is empty");
				return null;
			}
			return res;
		}).then((List<SearchResult> bookResult){

			/// check chapter list
			if(bookResult == null){
				return null;
			}
			name = bookResult[0].name;
			return Request.getInstance().ParserChapterList(bookResult[0].bookinfolist.bookMsgInfoList[0].booklist,_source).then((List<BookChapter> chapterList){

				print(chapterList);

				if( chapterList.length<=0 ){
					print("chapter list is empty");
					return null;
				}

				return chapterList;
			});
		}).then((List<BookChapter> chapterList){

			/// check chapter info
			if(chapterList == null){
				return null;
			}

			return Request.getInstance().MutilReqChapter(chapterList, name, _source).then((List<BookChapter> _bookchapter){


				if( chapterList.length<=0 ){
					print("chapter list is empty");
					return null;
				}

				print(_bookchapter);

				bool isEmpty = false;
				_bookchapter.forEach((element) {
					if(element.content.length == 0){
						isEmpty = true;
					}
				});

				if(isEmpty){
					return null;
				}else{
					return _bookchapter;
				}
			});
		}).then((List<BookChapter> _bookchapter){
			/// over add source
			if(_bookchapter == null){
				return null;
			}else{
				SourceManger.addSource();
				setState(() {
					Page = PageContent();
				});
			}
		});
	}

	Widget PageContent(){
		return FutureBuilder(
			builder: _buildFuture,
			future: SourceManger.getSourceList(), // 用户定义的需要异步执行的代码，类型为Future<String>或者null的变量或函数
		);
	}

	//根据异步状态生成widget
	Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
		switch (snapshot.connectionState) {
			case ConnectionState.waiting:
				return Center(
					child: CircularProgressIndicator(),
				);
			case ConnectionState.done:
				if (snapshot.hasError) return Text('Error: ${snapshot.error}');

				List<Source> _sourceList = snapshot.data;

				return new ListView.builder(
					itemCount: _sourceList.length,
					itemBuilder: (BuildContext context, int index){
						Source sourceItem = _sourceList[index];

						return ListTile(
							title: Text(sourceItem.name),
							subtitle: Text("id:"+sourceItem.id.toString()),
						);
					},
				);
			default:
				return null;
		}
	}
}