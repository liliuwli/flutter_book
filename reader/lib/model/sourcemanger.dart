import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:reader/model/source.dart';
import 'package:reader/model/cache.dart';
import 'dart:async';

import 'dart:io';


class SourceManger{

	///从资源文件读书源
	static Future<List<String>> loadFileSource() async {
		String dir = "lib/assets/images/";
		List<String> FileList = ["source_1.json"];

		return await Future.wait(List.generate(FileList.length, (index) => rootBundle.loadString(dir+FileList[index])));
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
				_sourceList = await SourceManger.loadFileSource().then((List<String> jsonlist){

					if(jsonlist == null){
						return [];
					}else{
						return List.generate(jsonlist.length, (index) => Source.fromJson(json.decode(jsonlist[index]))).toList();
					}

				});
				break;
		//从服务器获取
			case SourceType.network:
				break;
			default:
		//源码中class定义
				_sourceList = await List<Source>()..add(Source.getSource());
		}

		///print(_sourceList[0].SearchRule['booklist'].reg);

		if(_sourceList == null || _sourceList.length == 0){
			//添加失败
			Completer _completer = Completer<bool>()..complete(false);
			return await _completer.future;
		}else{
			return await SourceManger.getSourceList().then((List<Source> sourcelistdata) async{
				///书源修改
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


	//获取全部书源
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

	//获取指定id书源
	static Future<Source> getSourceById(int id) async{

		Cache.init();
		return await Cache.GetList("source").then((List<String> jsonlist){
			if(jsonlist == null){
				return null;
			}else{
				List<Source> sourceList = jsonlist.map((e) => Source.fromJson(json.decode(e))).toList();

				Source ret;
				sourceList.forEach((element) {
					if( element.id == id ){
						ret = element;
					}
				});
				return ret;
			}
		});
	}
}

enum SourceType{
	network,
	file,
	define
}