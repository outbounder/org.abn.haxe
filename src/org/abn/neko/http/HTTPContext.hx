package org.abn.neko.http;
import org.abn.neko.AppContext;

class HTTPContext extends AppContext
{
	private var httpRequest:HTTPRequest;
	
	public function new(params:Hash<String>,method:String, context:AppContext)
	{
		super();
		this.xmppContext = context.xmppContext;
		this.httpRequest = new HTTPRequest(params, method, this);
	}
	
	public function getCurrentHTTPRequest():HTTPRequest
	{
		return this.httpRequest;
	}
	
	public function render(templatePath:String, ?params:Dynamic):String
	{
		return this.createHTTPResponse(params).render(templatePath);
	}
	
	public function createHTTPResponse(params:Hash<String>):HTTPResponse
	{
		return new HTTPResponse(params, this);
	}
}