import 'package:flutter/material.dart';
import 'h.dart';

class SearchInfoScreen extends StatelessWidget{
  static const routeName = '/SearchInfo';

  @override
  Widget build(BuildContext context){
    final SearchInfoArguments args = ModalRoute.of(context).settings.arguments;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Saved Suggestions'),
      ),
      body: new Center(
        child: new Text(args.searchtext),
      ),
    );
  }
}