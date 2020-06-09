import 'package:flutter/material.dart';
import 'h.dart';

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
  var list = ['紫川','雪中狂刀行','斗破苍穹','斗罗大陆','小阁老'];

  var textEditingController = new TextEditingController();

  @override
  void _clickClear(){
    setState(() {
      list.clear();
    });
  }

  void _clickSearch(String searchtext){
    textEditingController.text = searchtext;
    //执行搜索
    Navigator.pushNamed(
        context,
        "/SearchInfo",
        arguments: new SearchInfoArguments(searchtext)
    );

    //执行搜索后 更新历史搜索词
    setState((){
      if(list.contains(searchtext)){
        list.remove(searchtext);
      }
      list.add(searchtext);
    });
  }

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
              decoration: new InputDecoration(
                  hintText:'输入书籍或作者'
              ),
              autofocus: true,
              controller: textEditingController,
              textInputAction: TextInputAction.search,
              onSubmitted: (e){
                var searchtext = e.toString();

                _clickSearch(searchtext);
              },
            ),
            margin: new EdgeInsets.all(20),
          ),

          new Expanded(
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
                  },
                ),

                //背景色
                decoration: new BoxDecoration(
                  color:  Colors.black26,
                ),
              )
          )
        ],
      ),
    );
  }
}