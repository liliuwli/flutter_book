import 'package:flutter/material.dart';
import 'h.dart';
import 'model/search.dart';

class SearchScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return new SearchPage();
  }
}

//创建一个可以转动得刷新icon
class LoadWidget extends AnimatedWidget{
  LoadWidget({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return new Transform(
      child: new Container(
        height: 20,
        width: 20,
        child: new Icon(Icons.refresh),
      ),
      alignment: Alignment.center,
      transform: Matrix4.rotationZ(animation.value*3.14/180),
    );
  }
}

class SearchPage extends StatefulWidget{
  @override
  createState() => new SearchState();
}

class SearchState extends State<SearchPage> with SingleTickerProviderStateMixin {
  List<String> list = ['紫川','雪中狂刀行','斗破苍穹','斗罗大陆','小阁老'];

  List<SearchResult> _searchresult = new List(5);

  final textEditingController = new TextEditingController();

  bool _delIcon = false;
  num _searchstate = 0;       //0未开始 1搜索开始 2搜索停止
  bool isLoading = false;

  //动画
  AnimationController controller;
  Animation<double> animation;

  initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this
    );
    animation = new Tween(begin: 0.0, end: 360.0).animate(controller);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.repeat();
      }
    });
  }


  dispose() {
    controller.dispose();
    super.dispose();
  }

  void _clickClear(){
    setState(() {
      list.clear();
    });
  }

  void _clickSearch(String searchtext){
    textEditingController.text = searchtext;
    //跳转新页面执行搜索
    //Navigator.pushNamed(
    //    context,
    //    "/SearchInfo",
    //    arguments: new SearchInfoArguments(searchtext)
    //);

    //搜索 提供关键词返回结果
    setState(() {
      _searchstate = 1;
      Search _search = new Search(searchtext);
      _searchresult[0] = _search.result;
    });

    //执行搜索后 更新历史搜索词
    setState((){
      if(list.contains(searchtext)){
        list.remove(searchtext);
      }
      list.add(searchtext);
    });
  }

  Widget _getLoadWidget(){
    controller.forward();

    return new Container(
      child: new Center(
        //加载动画
        child: new LoadWidget(animation:animation),
      ),
    );
  }

  //获取历史
  Widget _getHistory(){
    return new Expanded(
      //嵌套解决 ListView高度超标问题
        child:new Container(
          child:new ListView.builder(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder:(context,i){
                return new Wrap(
                  spacing: 10,     //主轴元素间距
                  runSpacing:20,  //交叉轴间距
                  children: List.generate(
                      list.length+1, (index) {
                    if(index == list.length){
                      return new GestureDetector(
                        child: new Container(
                          child: new Text(
                            '清空历史记录',
                            style: new TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          decoration: new BoxDecoration(
                            color: Colors.white30,
                          ),
                          padding: new EdgeInsets.all(6),
                        ),
                        onTap: _clickClear,
                      );
                    }
                    return new GestureDetector(
                      child: new Container(
                        child: new Text(
                          list[index],
                          style: new TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white30,
                        ),
                        padding: new EdgeInsets.all(6),
                      ),
                      onTap: (){
                        _clickSearch(list[index]);
                      },
                    );
                  }
                  ),
                );
              }

          ),

          //背景色
          decoration: new BoxDecoration(
            color:  Colors.black26,
          ),
        )
    );
  }

  //搜索显示搜索结果
  Widget _getSearch(){
    _clickSearch("a");
    return new  Expanded(
      child:new Container(
        child:new ListView.builder(
          padding: const EdgeInsets.all(5.0),
          shrinkWrap: true,
          itemCount: _searchresult.length+1,
          itemBuilder:(context,i){
            if(i==0){
              return _getLoadWidget();
            }
            num _key = i - 1;

            if( _searchresult[_key] != null ){
              return new SearchItem(_searchresult[_key]);
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

  Widget _getbody(){
    if(_searchstate==0){
      //非搜索显示搜索历史
      return _getHistory();
    }else{
      //搜索显示搜索结果
      return _getSearch();
    }
  }

  @override
  Widget build(BuildContext context){

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('搜索历史'),
      ),
      body: new Column(
        children: [
          //初始化一个盒子容纳搜索框
          new Container(
            child: new TextField(
              //管理input 附属del操作
              decoration: new InputDecoration(
                  hintText:'输入书籍或作者',
                  //清理框内内容
                  suffixIcon:_delIcon
                      ?new Container(
                          width: 20,
                          height: 20,
                          child: new IconButton(
                              icon: new Icon(Icons.cancel),
                              onPressed: (){
                                setState(() {
                                  textEditingController.text = "";
                                  _delIcon = false;
                                  //mark 后续触发退出搜索
                                });
                              }
                          ),
                      )
                      :new Text(""),
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
                var searchtext = e.toString();

                _clickSearch(searchtext);
              },
            ),
            margin: new EdgeInsets.all(20),
          ),

          _getbody(),
        ],
      ),
    );
  }
}


//初始化单本书
class SearchItem extends StatelessWidget {
  num  id;
  String img;
  String name;
  String author;
  String lastChapter;
  List Source;

  SearchItem(SearchResult args){
    this.name = args.name;
    this.author = args.author;
    this.img = args.imgurl;
    this.lastChapter = args.lastChapter;
    this.Source = args.source_list;
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
                          this.lastChapter,
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
          _showBookActionsDialog(context);
        }
    );
  }
}

void _showBookActionsDialog(BuildContext context){
  //显示result信息
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
            content: new Container(
              child: new Text("test"),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  //
                },
                child: Text('加入书架'),
              ),
              FlatButton(
                onPressed: (){
                  //
                },
                child: Text('开始阅读'),
              ),
            ],

        );
      }
  );
}