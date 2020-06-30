

import 'package:crypto/crypto.dart';

class log{
	static void debugList(List<List<String>> arguments){
		//分段打印内容
		arguments.forEach((element) {
			print(element);
		});
	}

	static void logData(dynamic data){
		if(data.toString().length >= 1000){
			if(data is List){
				data.forEach(
					(element) {
						int end = 0;
						int next = 1000;
						if(element.length >= 1000){
							while(end != element.toString().length){
								if(element.toString().length - end < 1000){
									next = element.toString().length  - end;
								}else{
									next = 1000;
								}

								print(element.toString().substring(end,end+next));

								end = end + next;
							}
						}else{
							print(element);
						}
					}
				);
			}

		}else{
			print("-------------notice-----------------");
			print(data);
			print("-------------notice end-----------------");
		}
	}
}