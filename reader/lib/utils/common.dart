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

//list转string
String implode(List<String> _list,String character){
	String ret = '';
	_list.forEach((element) {
		ret += element+character;
	});
	return ret.substring(0,ret.length-character.length);
}



//获取相对路径
String GetUrlRelativePath(String url){

	Uri _uri = Uri.parse(url);

	if(_uri.pathSegments == null || _uri.pathSegments.length == 0){
		return _uri.origin;
	}

	String _pathSegments = implode(List.generate(_uri.pathSegments.length-1, (index) => _uri.pathSegments[index]), "/");

	return _uri.origin + "/" + _pathSegments + "/";
}