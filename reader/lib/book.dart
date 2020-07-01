import 'package:flutter/material.dart';
import 'package:reader/h.dart';
import 'package:reader/model/source.dart';
import 'package:reader/model/search.dart';
import 'package:reader/model/httputils.dart';
import 'package:reader/model/sourcemanger.dart';
import 'package:reader/utils/chapterPage.dart';

//Toast弹窗
import 'package:fluttertoast/fluttertoast.dart';

class BookScreen extends StatelessWidget{
	Widget page;
	BuildContext PageContext;
	BookPageArguments args;

	@override
	Widget build(BuildContext context){
		PageContext = context;
		args = ModalRoute.of(context).settings.arguments;
		return WillPopScope(
			child: new BookPage(args),
			onWillPop:_onWillPop,
		);
	}

	Future<bool> _onWillPop(){
		Navigator.pop(PageContext,args.name);
		return new Future.value(false);
	}
}



class BookPage extends StatefulWidget{
	BookPageArguments args;
	BookPage(this.args);

	@override
	createState() => new BookState(args);
}

class BookState extends State<BookPage>{
	static const routeName = '/Book';
	//阅读器
	Widget root;
	//当前章节
	String chapterName = "";
	bool offState = false;
	bool isLoading = false;
	bool isPre = false;
	bool isNext = false;
	bool isMenu = true;

	List<BookChapter> dir;
	//缓存未读章节队列
	List<BookChapter> chapterCache;
	int cacheKey = 0;
	//当前源规则
	Source source;
	//章节分页器
	Paging chapterPage;
	List<String> pagelist = List<String>();
	int pagenum = 0;

	//pages merge content
	BuildContext pagecontext;

	//pageController
	PageController pageController;

	//获取页面宽高
	final GlobalKey globalKey = GlobalKey();

	//记录末页中心起点
	double endPageStart;

	double pageWidth;

	EdgeInsets padding;


	double _pageSizeWidth = 0;
	double _pageSizeHeight = 0;

	//文字样式
	final contentText = const TextStyle(
		inherit: false,
		fontSize: 18.0,
		height: 1.2,
		color: Colors.black,
		letterSpacing:1,
		wordSpacing:0,
		decoration: TextDecoration.none,
		fontWeight: FontWeight.normal,
		textBaseline: TextBaseline.alphabetic,
	);

	final noticeText = const TextStyle(
		fontSize: 10.0,
		height: 1,
		color: Colors.black,
		letterSpacing:1,
		wordSpacing:0,
		decoration: TextDecoration.none,
	);

	//传参
	BookPageArguments args;
	BookState(this.args);

	@override
	void initState() {
		super.initState();
		args.name = args.name == null ? "未获取书名":args.name;

		initSource().then((value){
			//加载爬虫源
			initdir().then((value){

				//初始化分页器
				pageWidth = globalKey.currentContext.size.width;
				///最外层widget 减去padding
				_pageSizeWidth = globalKey.currentContext.size.width - padding.left - padding.right;
				_pageSizeHeight = globalKey.currentContext.size.height - 35 - padding.bottom - padding.top;
				setState(() {
					_pageSizeWidth = _pageSizeWidth;
					_pageSizeHeight = _pageSizeHeight;
				});

				//根据爬虫源 加载列表页
				initChapter().then((value){
					//对文本进行分页
					initPage();
				});
			});
		});
	}


	//页脚需要页码+章节名 切换页面需要更变章节
	Future<bool> initPage() async {
		/**
		 *      思路是通过 TextPainter.layout 来定位页面右下角的文本长度
		 *      TextPainter.layout和text输出有差距
		 */
		if(chapterPage == null){
			print(_pageSizeHeight-contentText.fontSize*contentText.height*3);
			chapterPage = new Paging(size:new Size(_pageSizeWidth - 32 , _pageSizeHeight-contentText.fontSize*contentText.height),textStyle: contentText);
		}

		pagelist = List<String>();
		String content = chapterCache[cacheKey].content.trim();

		while(chapterPage.layout(content,onSize: false)){
			String page = content.substring(0,chapterPage.maxLength);
			pagelist.add(page);
			content = content.substring(chapterPage.maxLength).trim();
		}

		if(content.length>0){
			pagelist.add(content);
		}

		setState(() {
			_pageSizeWidth = _pageSizeWidth;
			_pageSizeHeight = _pageSizeHeight;
			endPageStart = pageWidth * (pagelist.length-1);

			pageController = new PageController(
				initialPage:pagelist.length,
				keepPage: true
			);

			root = buildBodyFunction();

		});

		pageController.addListener(() {
			//偏移敏感度
			int touchlength = 40;


			if(pagenum == pagelist.length - 1){
				//末页  触发下一章操作
				if(pageController.hasClients && pageController.offset - endPageStart > touchlength){
					this.nextChapter();
				}
			}

			if(endPageStart != null && pageController.hasClients && pageController.offset < endPageStart + touchlength){
				isNext = false;
			}

			if(pagenum == 0){
				//首页  触发上一章操作
				if(pageController.hasClients && pageController.offset < -touchlength){
					this.preChapter();
				}
			}

			if(pageController.hasClients && pageController.offset > -touchlength){
				isPre = false;
			}
		});

		///刷新阅读记录
		return await Search.FreshMark(chapterCache[cacheKey].name, chapterCache[cacheKey].sortid, args.name);
	}

	//章节切换  判断是否为最后一章
	void nextChapter(){
		if(isLoading || isNext){
			return;
		}

		setState(() {
			isLoading = true;
			isNext = true;
			offState = false;
		});

		if(chapterCache.length - cacheKey == 1 && chapterCache.length < 5){
			//最后一章 mark 追书模式
			Fluttertoast.showToast(
				msg: "所有章节阅读完毕",
				toastLength: Toast.LENGTH_SHORT,
				gravity: ToastGravity.CENTER,
				timeInSecForIos: 1
			).then((_){
				setState(() {
					isLoading = false;
					offState = true;
				});
			});
		}else{
			cacheKey++;
			//重置坐标为起点
			pageController.animateTo(0, duration: const Duration(milliseconds: 100), curve: Interval(
				0.0,
				0.1,
				curve: Curves.easeIn,
			));
			pagenum = 0;
			initPage().then((res){
				setState(() {
					isLoading = false;
					offState = true;
				});
			}).then((_){
				if(chapterCache.length - cacheKey == 1){
					//缓存队列 即将空了 异步初始化缓存 总量5 剩余量1
					initChapter();
				}
			});
		}
	}

	//章节切换 需要判断是否为第一章
	void preChapter(){
		if(isLoading || isPre){
			return;
		}

		setState(() {
			isLoading = true;
			isNext = true;
			offState = false;
		});

		if(cacheKey != 0){
			//队列未刷新可以直接切换文本
			cacheKey--;

			//重置坐标为终点
			pageController.animateTo(pageWidth * (pagelist.length - 1), duration: const Duration(milliseconds: 100), curve: Interval(
				0.0,
				0.1,
				curve: Curves.easeIn,
			));
			pagenum = pagelist.length-1;

			initPage().then((res){
				setState(() {
					isLoading = false;
					offState = true;
				});
			});
		}else{
			//如果队列无数据 需要重新请求  队列设计问题
			Search.BackMark(chapterCache[cacheKey].name, chapterCache[cacheKey].sortid ,args.name).then((bool isUpdate){
				if (isUpdate) {
					//重新初始化界面
					setState(() {
						isLoading = false;
						offState = true;
					});

					//根据爬虫源 加载列表页
					initChapter().then((value){
						//对文本进行分页
						initPage().then((_){

							//重置坐标为终点
							pageController.animateTo(pageWidth * (pagelist.length - 1), duration: const Duration(milliseconds: 100), curve: Interval(
								0.0,
								0.1,
								curve: Curves.easeIn,
							));

							pagenum = pagelist.length-1;
						});
					});
				}else{
					initPage().then((res){
						setState(() {
							isLoading = false;
							offState = true;
						});
					});
					return ;
				}
			});
		}

	}

	Future<void> initSource() async {
		if(isLoading){
			return;
		}

		isLoading = true;

		return await SourceManger.getSourceById(args.Sourceid).then((value){
			source = value;
			isLoading = false;
			return ;
		});

	}

	//初始化小说到已读 并且获取多章内容
	Future<void> initChapter() async {
		if(isLoading){
			return;
		}

		isLoading = true;

		return await Request.getInstance().MutilReqChapter(dir,args.name,source).then((List<BookChapter> chapterlist){
			setState(() {
				isLoading = false;
				offState = true;
				chapterCache = chapterlist;
				cacheKey = 0;

			});
		});
	}

	//初始化加载小说目录 和 解析规则
	Future<void> initdir() async {
		if(isLoading){
			return;
		}

		isLoading = true;

		//如果参数传递失败
		if(args.chapterlisturl == null || args.Sourceid == null){
			isLoading = false;
			Navigator.pop(context);
		}

		return await Request.getInstance().ParserChapterList(args.chapterlisturl, source).then((List<BookChapter> chapterlist) async {
			return await Search.sourceRefresh(args.name,chapterlist.length,chapterlist.last.name).then((_){
				setState(() {
					isLoading = false;
					dir = chapterlist;
				});
			});
		});
	}

	//初始化阅读器UI
	@override
	Widget build(BuildContext context){
		final BookPageArguments args = ModalRoute.of(context).settings.arguments;
		//分页器获取宽高
		pagecontext = context;

		/*
		return new Scaffold(
			appBar: new AppBar(
				title: new Text(args.name),
				actions: <Widget>[
					//菜单键
					new IconButton(icon:new Icon(Icons.all_inclusive),onPressed: changeSource,),
					new IconButton(icon:new Icon(Icons.book),onPressed: showDir,),
				],
			),
			body: Stack(
				children: <Widget>[
					//阅读器
					root = buildBodyFunction(),
					Offstage(
						//loading进度条
						offstage: offState,
						child: Center(
							child: CircularProgressIndicator(),
						),
					),
				],
			),
		);
		 */

		padding = MediaQuery.of(context).padding;

		return Scaffold(
			body: new SafeArea(
				///全屏阅读
				child: new Container(
					child: Stack(
						children: <Widget>[
							//阅读器
							root = buildBodyFunction(),
							///隐藏菜单
							Offstage(
								offstage: isMenu,
								child: getBottomMenu(),
							),
							Offstage(
								//loading进度条
								offstage: offState,
								child: Center(
									child: CircularProgressIndicator(),
								),
							),
						],
					),
					decoration: new BoxDecoration(
						color: Colors.white
					),
				),
				key: globalKey,
			),
		);
	}

	Widget getBottomMenu(){
		return Container(
			child: Container(
				child: Row(
					children: [
						getBottomMenuAction(MenuAction.dir),
						getBottomMenuAction(MenuAction.source),
						getBottomMenuAction(MenuAction.pre),
						getBottomMenuAction(MenuAction.next),
					],
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
				),
				margin: EdgeInsets.only(left: 20,right: 20),
			),

			decoration: new BoxDecoration(
				color: Colors.greenAccent
			),

			width: MediaQuery.of(context).size.width,
		);
	}

	Widget getBottomMenuAction(MenuAction type){
		Tab _tab;
		Function callback;

		switch(type){
			case MenuAction.dir:
				_tab = Tab(
					icon: new Icon(Icons.menu),
					text: "目录",
				);
				callback = showDir;
				break;
			case MenuAction.source:
				_tab = Tab(
					icon: new Icon(Icons.all_inclusive),
					text: "换源",
				);
				callback = changeSource;
				break;
			case MenuAction.next:
				_tab = Tab(
					icon: new Icon(Icons.navigate_next),
					text: "下一章",
				);

				callback = nextChapter;
				break;

			case MenuAction.pre:
				_tab = Tab(
					icon: new Icon(Icons.navigate_before),
					text: "上一章",
				);

				callback = preChapter;
				break;
		}

		return GestureDetector(
			child: _tab,
			onTap: (){
				callback();
				setState(() {
					isMenu = true;
				});
			},
		);
	}

	bool isCache(String url){
		bool ret;
		chapterCache.forEach((BookChapter element) {
			if(element.chapterUrl == url){
				ret = true;
			}
		});

		if(ret == null){
			return false;
		}else{
			return true;
		}
	}

	//根据异步状态生成widget
	Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
		final CacheStyle = const TextStyle(fontWeight: FontWeight.bold);
		switch (snapshot.connectionState) {
			case ConnectionState.waiting:
				return Center(
					child: CircularProgressIndicator(),
				);
			case ConnectionState.done:
				if (snapshot.hasError) return Text('Error: ${snapshot.error}');

				List<BookChapter> chapterDir = snapshot.data[0];
				//已读的sortid
				int readsort = snapshot.data[1];

				return new ListView.builder(
					shrinkWrap: true,
					controller: new ScrollController(
						initialScrollOffset: 56 * readsort.ceilToDouble()
					),
					itemCount: chapterDir.length,
					itemBuilder:(context,i){
						return new GestureDetector(
							child: new ListTile(
								title: isCache(chapterDir[i].chapterUrl)
										?new Text(chapterDir[i].name,style: CacheStyle)
										:new Text(chapterDir[i].name),
							),
							onTap: (){

								Search.FreshMark(chapterDir[i].name,chapterDir[i].sortid,args.name).then((_){
									//根据爬虫源 加载列表页
									initChapter().then((value){
										//对文本进行分页
										initPage().then((_){
											//重置坐标
											pageController.animateTo(0, duration: const Duration(milliseconds: 100), curve: Interval(
												0.0,
												0.1,
												curve: Curves.easeIn,
											));
											pagenum = 0;
											Navigator.of(context).pop();
										});
									});
								});
							},
						);
					},
				);
			default:
				return null;
		}
	}

	//用书名获取目录  用当前阅读章节名获取章节序号
	_getDirData(String bookname , String chaptername) async {
		return await Future.wait([Search.BookDir(bookname),Search.GetSortIdByName(bookname,chaptername)]);
	}

	Widget getbookdir(String bookname ,Function state) {
		return FutureBuilder(
			builder: _buildFuture,
			future: _getDirData(bookname,chapterCache[cacheKey].name), // 用户定义的需要异步执行的代码，类型为Future<String>或者null的变量或函数
		);
	}

	//显示换源列表
	void changeSource(){
		if(isLoading){
			return ;
		}

		showDialog(
			context: context,
			barrierDismissible: true,           //点击空白退出
			builder: (BuildContext context) {
				return AlertDialog(
						content: new Container(
							//显示详情
							child: getBookSource(),
							decoration: BoxDecoration(
									border: Border(
											bottom: BorderSide(
													width: 1,
													color: Colors.black26
											)
									)
							),
							width: MediaQuery
									.of(context)
									.size
									.width * 0.8,
							height: MediaQuery
									.of(context)
									.size
									.height * 0.7,
						)

				);
			}
		);
	}

	///修改书源事件
	Widget changeSourceItem(bool isLighting ,String name ,BookMsgInfo _msginfo,String _sourceName,int key,BuildContext context){
		final fontstyle = isLighting?const TextStyle(fontWeight: FontWeight.bold):const TextStyle();
		return new GestureDetector(
			child: new ListTile(
				title: new Text(name+"--"+_sourceName,style: fontstyle,),
				subtitle: new Text("最近更新"+_msginfo.lastChapter),
			),
			onTap: (){
				///修改书架数据
				Search.getBookShelfByName(name).then((SearchResult _searchResult) async {
					if(_searchResult==null){
						return null;
					}else{
						_searchResult.index = key;

						return await Search.SetBookShelf(_searchResult);
					}
				}).then((_){

					///重新加载小说内容
					initSource().then((value){
						//加载爬虫源
						initdir().then((value){
							//根据爬虫源 加载列表页
							initChapter().then((value){
								//对文本进行分页
								initPage().then((_){
									///退出换源页面
									Navigator.of(context).pop();
								});
							});
						});
					});

				});
			},
		);
	}

	///构建换源弹窗主体
	Widget _buildSourceChange(BuildContext context, AsyncSnapshot snapshot) {
		final CacheStyle = const TextStyle(fontWeight: FontWeight.bold);
		switch (snapshot.connectionState) {
			case ConnectionState.waiting:
				return Center(
					child: CircularProgressIndicator(),
				);
			case ConnectionState.done:
				if (snapshot.hasError) return Text('Error: ${snapshot.error}');

				SearchResult _searchResult = snapshot.data;

				return new ListView.builder(
					shrinkWrap: true,
					itemCount: _searchResult.sourcelist.length,
					itemExtent: 100.0,
					itemBuilder:(context,i){

						if(_searchResult.index == i){
							return changeSourceItem(true,args.name,_searchResult.bookinfolist.bookMsgInfoList[i],_searchResult.sourcelist.bookSourceList[i].name,i,context);
						}else{
							return changeSourceItem(true,args.name,_searchResult.bookinfolist.bookMsgInfoList[i],_searchResult.sourcelist.bookSourceList[i].name,i,context);
						}

					},
				);
			default:
				return null;
		}
	}

	Widget getBookSource(){
		return FutureBuilder(
			builder: _buildSourceChange,
			future: Search.getBookShelfByName(args.name), // 用户定义的需要异步执行的代码，类型为Future<String>或者null的变量或函数
		);
	}

	//显示章节列表
	void showDir(){
		if(isLoading){
			return ;
		}

		showDialog(
			context: context,
			barrierDismissible: true,           //点击空白退出
			builder: (BuildContext context) {
				return StatefulBuilder(builder: (context, state)
				{
					return AlertDialog(
						content: new Container(
							//显示详情
							child: getbookdir(args.name,state),
							decoration: BoxDecoration(
									border: Border(
										bottom: BorderSide(
											width: 1,
											color: Colors.black26
										)
									)
							),
							width: MediaQuery
									.of(context)
									.size
									.width * 0.8,
							height: MediaQuery
									.of(context)
									.size
									.height * 0.7,
						)

					);
				});
			}
		);
	}

	///封装方法构建PageView组件
	Widget buildBodyFunction() {
		///可实现左右页面滑动切换
		return PageView(
			//当页面选中后回调此方法
			//参数[index]是当前滑动到的页面角标索引 从0开始
			onPageChanged: (int index){
				setState(() {
					pagenum = index;
				});
			},
			//值为flase时 显示第一个页面 然后从左向右开始滑动
			//值为true时 显示最后一个页面 然后从右向左开始滑动
			reverse: false,
			//滑动到页面底部无回弹效果
			physics: BouncingScrollPhysics(),
			//横向滑动切换
			scrollDirection: Axis.horizontal,
			//页面控制器
			controller: pageController,
			//所有的子Widget
			children: List<Widget>.generate(pagelist.length, (index) => CreatePage(pagelist[index])),
		);
	}

	Widget CreatePage(String content){
		return new Stack(
			children: [
				Container(
					child:
					GestureDetector(
						child: new Text(
							content,
							style: contentText,
						),
						onTapDown: (TapDownDetails details){
							//唤醒菜单
							double sensitive = 100;
							double centerDown = globalKey.currentContext.size.height/2+sensitive;
							double centerUp = globalKey.currentContext.size.height/2-sensitive;
							if(details.globalPosition.dy <= centerDown &&  details.globalPosition.dy>= centerUp){
								setState(() {
									if(isMenu == false){
										isMenu = true;
									}else{
										isMenu = false;
									}
								});
							}
						},
					),
					padding: new EdgeInsets.only(right: 16,left: 16,top: 10,bottom: 0),
					width: pageWidth,
					constraints: BoxConstraints(
						maxHeight: _pageSizeHeight,
						maxWidth: _pageSizeWidth
					),
				),

				//提示栏
				Positioned(
					child: Container(
						margin: new EdgeInsets.only(right: 16,left: 16,top: 5),
						child: Row(
							children: [
								chapterCache == null ?new Text(""):new Text(chapterCache[cacheKey].name,style: noticeText,),
								//Expanded(child: SizedBox()),
								new Text((pagenum+1).toString() + '/' + pagelist.length.toString(),style: noticeText,),
							],
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
						),
						decoration: BoxDecoration(
							border:Border(
								top:BorderSide(width: 1,color: Colors.black26)
							)
						),
					),
					bottom: 0,
					width: pageWidth,
					height: 30,
				),
			],
		);
	}
}

enum MenuAction{
	source,
	dir,
	next,
	pre
}