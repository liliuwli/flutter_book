import 'package:flutter/material.dart';
import 'package:reader/h.dart';
import 'package:reader/model/source.dart';
import 'package:reader/model/search.dart';
import 'package:reader/model/httputils.dart';
import 'package:reader/utils/chapterPage.dart';

class BookScreen extends StatelessWidget{
	@override
	Widget build(BuildContext context){
		final BookPageArguments args = ModalRoute.of(context).settings.arguments;
		return new BookPage(args);
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
	//当前章节
	String chapterContent = "";
	String chapterName = "";
	bool offState = false;
	bool isLoading = false;

	List<BookChapter> dir;
	//缓存未读章节
	List<String> chapterCache;
	//当前源规则
	Source source;
	//分页器
	Paging chapterPage;
	List<String> pagelist = List<String>();
	int pagenum = 1;

	//pages merge content
	BuildContext pagecontext;

	//pageController
	PageController pageController;


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
					initPage();
					//chapterPage.load()
				});
			});
		});
	}

	//页脚需要页码+章节名 切换页面需要更变章节

	initPage(){
		if(chapterPage == null){
			//初始化分页器
			double _pageSizeWidth = MediaQuery.of(context).size.width - 32;
			double _pageSizeHeight = MediaQuery.of(context).size.width*1.7;
			chapterPage = new Paging(size:new Size(_pageSizeWidth,_pageSizeHeight));
		}

		String content = chapterContent;
		var ret = chapterPage.layout(content);
		print(ret);
		print(chapterPage.maxLength);

		while(chapterPage.layout(content,onSize: false)){
			String page = content.substring(0,chapterPage.maxLength-1);
			pagelist.add(page);
			content = content.substring(chapterPage.maxLength);
		}

		if(content.length>0){
			pagelist.add(content);
		}

		pageController = new PageController(
			initialPage:pagelist.length,
			keepPage: true
		);
	}

	Future<void> initSource() async {
		if(isLoading){
			return;
		}

		isLoading = true;

		return await Source.getSourceById(args.Sourceid).then((value){
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

		return await Request.getInstance().MutilReqChapter(dir,args.readmark,source).then((List<String> chapterlist){
			setState(() {
				isLoading = false;
				chapterCache = chapterlist;
				offState = true;
				chapterContent = chapterCache[0];
				//print(chapterCache);
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

	@override
	Widget build(BuildContext context){
		final BookPageArguments args = ModalRoute.of(context).settings.arguments;
		//分页器获取宽高
		pagecontext = context;

		return new Scaffold(
			appBar: new AppBar(
				title: new Text(args.name),
			),
			body: Stack(
				children: <Widget>[
					//底部刷新容器
					buildBodyFunction(),
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

	///封装方法构建PageView组件
	PageView buildBodyFunction() {
		///可实现左右页面滑动切换
		return PageView(
			//当页面选中后回调此方法
			//参数[index]是当前滑动到的页面角标索引 从0开始
			onPageChanged: (int index){
				print("当前的页面是 $index");
				///滑动PageView时，对应切换选择高亮的标签
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
		return Container(
			child:
			new Text(
				content,
				style: const TextStyle(fontSize: 20.0,height: 1.1),
			),
			padding: new EdgeInsets.only(right: 16,left: 16,bottom: 20,top: 10),
		);
	}
}