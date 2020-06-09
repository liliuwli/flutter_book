import 'package:flutter/material.dart';
import 'search.dart';
import 'menu.dart';
import 'book.dart';
import 'searchinfo.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Reader',
      home: new App(),
      routes: {
        '/Search':(context) => new SearchScreen(),
        '/SearchInfo':(context){
          return new SearchInfoScreen();
        },
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
  @override
  //控制TextField 焦点的获取与关闭
  FocusNode focusNode = new FocusNode();

  //build被setState触发
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('阅读'),
          actions: <Widget>[
            new IconButton(icon:new Icon(Icons.list),onPressed: _clickMenu,),
          ],
        ),
        body: new Column(
          children: [
            //初始化一个盒子容纳搜索框
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
            new Expanded(
                //嵌套解决 ListView高度超标问题
                child:new Container(
                  child:new ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    shrinkWrap: true,
                    itemCount: 10,
                    itemBuilder:(context,i){
                      if(i<10){
                        return new BookItem(this,'https://www.booktxt.com/files/article/image/28/28228/28228s.jpg','小阁老','三戒大师','新书感言','第二百四十五章 火并',null);
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

  void _clickBook(num id){
    print("点击成功，但是并未触发小键盘，后面改成路由跳转");
    Navigator.pushNamed(
        context,
        "/Book"
    );
    return;
  }
}

//初始化单本书
class BookItem extends StatelessWidget {
  @override
  num  id;
  AppState _appState;
  String img;
  String name;
  String author;
  String readmark;
  String lastChapter;
  Map Source;

  BookItem(this._appState,this.img,this.name,this.author,this.readmark,this.lastChapter,this.Source);

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
                    child: new Image.network(this.img),
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
      onTap:(){
        this._appState._clickBook(this.id);
      }
    );
  }
}