import 'dart:convert';

import 'package:reader/model/source.dart';
import 'package:reader/model/cache.dart';
import 'dart:async';


class SourceManger{

	static Future<List<Source>> getSourceList() async {
		Cache.init();
		return await Cache.GetList("source").then((List<String> jsonlist){
			if(jsonlist == null){
				return [];
			}else{
				return jsonlist.map((e) => Source.fromJson(json.decode(e))).toList();
			}
		});
	}

	///备份json数据
	static Future<List<String>> backup() async {
		Cache.init();
		return await Cache.GetList("source").then((List<String> jsonlist){
			if(jsonlist == null){
				return [];
			}else{
				return jsonlist;
			}
		});
	}



	static Future<bool> addSource({SourceType sourceType=SourceType.define}) async {
		List<Source> _sourceList;
		switch(sourceType){
		//源码定义来源文件
			case SourceType.file:
				break;
		//从服务器获取
			case SourceType.network:
				break;
			default:
		//源码中class定义
				_sourceList = await List<Source>()..add(Source.getSource());
		}

		if(_sourceList == null || _sourceList.length == 0){
			//添加失败
			Completer _completer = Completer<bool>()..complete(false);
			return await _completer.future;
		}else{
			return await SourceManger.getSourceList().then((List<Source> sourcelistdata) async{
				_sourceList.forEach((Source item) {
					bool isset = false;
					for(int i=0;i<sourcelistdata.length;i++){
						Source element = sourcelistdata[i];
						if(element.id == item.id){
							isset = true;
							sourcelistdata[i] = item;
						}
					}

					if(!isset){
						sourcelistdata.add(item);
					}

				});

				Cache.init();
				return await Cache.SetList("source", sourcelistdata.map((e) => json.encode(e)).toList());
			});
		}
	}
}

enum SourceType{
	network,
	file,
	define
}