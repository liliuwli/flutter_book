

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
						print(element);
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