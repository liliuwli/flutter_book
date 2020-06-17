import 'package:flutter/material.dart';
import 'h.dart';

class BookScreen extends StatelessWidget{
	static const routeName = '/Book';

	@override
	Widget build(BuildContext context){
		final BookPageArguments args = ModalRoute.of(context).settings.arguments;

		return new MaterialApp(
			title: args.name,
			home:new Scaffold(
				appBar: new AppBar(
					title: new Text(args.name),
				),
				body: new Center(
					child: new Text("test book page"),
				),
			)
		);
	}
}