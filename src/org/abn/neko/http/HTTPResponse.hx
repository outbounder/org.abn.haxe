package org.abn.neko.http;
import haxe.Template;
import neko.io.File;

class HTTPResponse
{
	private var context:HTTPContext;
	private var params:Dynamic;
	
	public function new(params:Dynamic, context:HTTPContext) 
	{
		this.context = context;
		this.params = params;
	}
	
	public function render(templatePath:String):String
	{
		var t:Template = new Template(File.getContent(templatePath));
		return t.execute(params);
	}
}