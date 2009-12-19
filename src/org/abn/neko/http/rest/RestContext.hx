package org.abn.neko.http.rest;

import org.abn.neko.http.HTTPContext;

class RestContext extends HTTPContext
{
	private var uriParts:Array<String>;
	private var routingMap:Hash<Dynamic>;
	private var route:String;
	
	public function new(routingMap:Hash<Dynamic>, route:String, uriParts:Array<String>, context:HTTPContext) 
	{
		super(context.getCurrentHTTPRequest().getParams(), context.getCurrentHTTPRequest().method(), context);
		this.uriParts = uriParts;
		this.routingMap = routingMap;
		this.route = route;
	}
	
	public function execute():String
	{
		if (this.hasNext())
			return this.forwardNext();
		else
			return "not implemented";
	}
	
	public function hasNext():Bool
	{
		return this.uriParts.length != 0;
	}
	
	public function next():String
	{
		return this.uriParts[0];
	}
	
	public function forwardNext():String
	{
		try
		{
			this.route += "/" + this.next();
			
			var nextClass:Dynamic = this.routingMap.get(this.route);
			this.uriParts.shift();
			
			var component:RestContext = Type.createInstance(nextClass, [this.routingMap, this.route, this.uriParts, this] );
			return component.execute();
		}
		catch (e:Dynamic)
		{
			trace("failed to forward to next "+ this.next() +" reson:"+ e);
			throw e;
		}
	}
}