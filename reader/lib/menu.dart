import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Saved Suggestions'),
      ),
      body: new Center(
        child: new Text("test menu page"),
      ),
    );
  }
}