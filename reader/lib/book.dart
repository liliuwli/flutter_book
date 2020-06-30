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
	SafeArea root;
	//当前章节
	String chapterName = "";
	bool offState = false;
	bool isLoading = false;
	bool isPre = false;
	bool isNext = false;

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

	final GlobalKey globalKey = GlobalKey();

	//记录末页中心起点
	double endPageStart;

	double pageWidth;

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

		if(chapterPage == null){
			//初始化分页器
			pageWidth = globalKey.currentContext.size.width;
			double _pageSizeWidth = globalKey.currentContext.size.width - 32;
			//30是预留ui的大小 20是一行文本的高度
			double _pageSizeHeight = globalKey.currentContext.size.height - 30 - 20;
			chapterPage = new Paging(size:new Size(_pageSizeWidth,_pageSizeHeight));
		}

		pagelist = List<String>();
		String content = chapterCache[cacheKey].content;

		while(chapterPage.layout(content,onSize: false)){
			String page = content.substring(0,chapterPage.maxLength-1);
			pagelist.add(page);
			content = content.substring(chapterPage.maxLength);
		}

		if(content.length>0){
			pagelist.add(content);
		}

		setState(() {
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

		return await Request.getInstance().ParserChapterList(args.chapterlisturl, source).then((List<BookChapter> chapterlist){
			setState(() {
				isLoading = false;
				dir = chapterlist;
			});
		});
	}

	//初始化阅读器UI
	@override
	Widget build(BuildContext context){
		final BookPageArguments args = ModalRoute.of(context).settings.arguments;
		//分页器获取宽高
		pagecontext = context;

		return new Scaffold(
			appBar: new AppBar(
				title: new Text(args.name),
				actions: <Widget>[
					//菜单键
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
	SafeArea buildBodyFunction() {
		///可实现左右页面滑动切换
		return new SafeArea(
			child:PageView(
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
			),
			key: globalKey,
		);
	}

	Widget CreatePage(String content){
		return new Stack(
			children: [
				Container(
					child:
					new Text(
						content,
						style: const TextStyle(fontSize: 20.0,height: 1),
					),
					padding: new EdgeInsets.only(right: 16,left: 16,top: 10,bottom: 0),
				),

				//提示栏
				Positioned(
					child: Container(
						margin: new EdgeInsets.only(right: 16,left: 16,top: 5),
						child: Row(
							children: [
								chapterCache == null ?new Text(""):new Text(chapterCache[cacheKey].name),
								//Expanded(child: SizedBox()),
								new Text((pagenum+1).toString() + '/' + pagelist.length.toString()),
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