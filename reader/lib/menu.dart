import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget{
	@override
	Widget build(BuildContext context){
		return new Scaffold(
			appBar: new AppBar(
				title: new Text('书源一览'),
			),
			body: new Center(
				child: new Text("显示多个list书源"),
			),
		);
	}
}