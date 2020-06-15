import 'package:flutter/material.dart';
import 'h.dart';
import 'model/search.dart';
import 'model/source.dart';
import 'model/httputils.dart';

class SearchScreen extends StatelessWidget{
	@override
	Widget build(BuildContext context){
		return new SearchPage();
	}
}

class SearchPage extends StatefulWidget{
	@override
	createState() => new SearchState();
}

class SearchState extends State<SearchPage>{
	List<String> history = [];
	List<SearchResult> _searchresult = [];
	int page = 0;
	bool isLoading = false;//是否正在请求新数据
	bool offState = false;//是否显示进入页面时的圆形进度条

	bool _delIcon = false;      //清理搜索框
	int _searchstate = 0;       //0未开始 1搜索开始 2搜索停止
	final textEditingController = new TextEditingController();

	ScrollController scrollController = new ScrollController();

	//初始化数据
	@override
	void initState() {
		super.initState();
		/*
		scrollController.addListener(() {
			if (scrollController.position.pixels ==
					scrollController.position.maxScrollExtent) {
				print('滑动到了最底部!');
				getMoreData();
			}
		});
		 */
		getHistoryData();
	}

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			home: Scaffold(
					appBar: AppBar(
						title: Text("搜索小说"),
					),
					body: Stack(
						children: <Widget>[
							//底部刷新容器
							RefreshIndicator(
								child: choiceWidget(context),
								onRefresh: (){

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
			),
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
			isLoading = true;
			_searchstate = 1;
			//搜索中图标
			offState = false;
		});
		textEditingController.text = searchtext;
		_delIcon = true;


		Request.getInstance().SearchBook(searchtext,(List<SearchResult> args){
			setState(() {
				_searchresult = args;
				offState = true;
				isLoading = false;
				_searchstate = 2;
			});
		});

	}

	//清理搜索框 还原搜索状态 mark
	void _clickClear(){
		setState(() {
			history.clear();
		});
	}

	//获取历史
	Widget _getHistory(){
		return new Container(
			child:new Wrap(
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
							return new SearchItem(_searchresult[i]);
						}else{
							return new Text("");
						}
					},
				),
				decoration: new BoxDecoration(
					color: Colors.white70,
				),
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

	//显示历史数据
	void getHistoryData() async {
		if (isLoading) {
			return;
		}
		setState(() {
			isLoading = true;
		});
		await Future((){
			return Search.SearchHistory();
		}).then((res){
			setState(() {
				isLoading = false;
				offState = true;

				history = res;
			});
		});//Future end
	}

}



//初始化单本书
class SearchItem extends StatelessWidget {
	num  id;
	String img;
	String name;
	String author;
	List<Source> source = [];
	List<String> lastChapter = [];

	SearchItem(SearchResult args){
		this.name = args.name;
		this.author = args.author;
		this.img = args.imgurl;
		this.lastChapter = args.lastChapter;
		this.source = args.source_list;
	}

	final titlefont = const TextStyle(fontSize: 14.0,height: 1);
	final otherfont = const TextStyle(fontSize: 12,height: 1);

	Widget build(BuildContext context) {
		//创建具备点击事件
		return new GestureDetector(
			child:new Container(
				child:new Row(
					children: [
							//img
						new Expanded(
							child: new Container(
								child: new Image.network(this.img),
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
											this.lastChapter[0],
											style: titlefont,
										),
										alignment: FractionalOffset.centerLeft,
										margin: EdgeInsets.only(bottom: 15),
									),
											//来源
									new Container(
										child: new Text(
											"来自笔趣阁等16个源",
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
				//this._appState._clickBook(this.id);
				//_showBookActionsDialog(context);
			}
		);
	}
}

