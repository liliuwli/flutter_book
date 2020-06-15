class log{
	static void debugList(List<List<String>> arguments){
		//分段打印内容
		arguments.forEach((element) {
			print(element);
		});
	}
}