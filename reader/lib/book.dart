import 'package:flutter/material.dart';
import 'package:reader/h.dart';
import 'package:reader/model/source.dart';
import 'package:reader/model/search.dart';
import 'package:reader/model/httputils.dart';

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
	String chapterContent = "";
	bool offState = false;
	bool isLoading = false;

	List<BookChapter> dir;
	//缓存未读章节
	List<String> chapterCache;
	//当前源规则
	Source source;

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
				initChapter();
			});
		});
	}

	Future<void> initSource() async {
		if(isLoading){
			return;
		}

		isLoading = true;

		return await Source.getSourceById(args.Sourceid).then((value){
			source = value;
			isLoading = false;
			print(source);
			return ;
		});

	}

	//初始化小说到已读 并且获取多章内容
	Future<void> initChapter() async {
		if(isLoading){
			return;
		}

		isLoading = true;

		return await Request.getInstance().MutilReqChapter(dir,args.readmark,source.baseUrl).then((List<String> chapterlist){
			setState(() {
				isLoading = false;
				chapterCache = chapterlist;
				offState = true;
				print(chapterCache);
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

		return new Scaffold(
			appBar: new AppBar(
				title: new Text(args.name),
			),
			body: Stack(
				children: <Widget>[
					//底部刷新容器
					Container(
						child: new Text(chapterContent),
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
		);
	}
}