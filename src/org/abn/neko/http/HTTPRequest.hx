package org.abn.neko.http;

class HTTPRequest
{
	private var _context:HTTPContext;
	private var _params:Hash<String>;
	private var _method:String;
	
	public function new(params:Hash<String>, method:String, context:HTTPContext) 
	{
		this._params = params;
		this._method = method;
		this._context = context;
	}
	
	public function getParams():Hash<String>
	{
		return this._params;
	}
	
	public function get(name:String):String
	{
		return this._params.get(name);
	}
	
	public function method():String
	{
		return this._method;
	}
}