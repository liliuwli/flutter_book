//防字符串溢出
String stringLimit(String text,int limit){
	if(limit > 0){
		if(limit > text.length){
			return text;
		}
		return text.substring(0,limit);
	}else{
		return "";
	}
}
