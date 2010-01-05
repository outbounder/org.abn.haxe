package org.abn.bot.operation;

import haxe.xml.Fast;
import org.abn.neko.AppContext;

class BotOperationFactory
{
	private var appContext:AppContext;
	
	public function new(appContext:AppContext) 
	{
		this.appContext = appContext;
	}
	
	public function getOperationById(id:String):BotOperation
	{
		var result:BotOperation = null;
		var path:String = this.appContext.get("operations." + id + ".path");
		if (path == null)
			return null;
		result = Type.createInstance(Type.resolveClass(path), [this.appContext]);
		return result;
	}
	
	public function getOperationParamsFromXML(node:Fast):Hash<String>
	{
		var result:Hash<String> = new Hash();
		for (pair in node.elements)
		{
			result.set(pair.name, pair.innerData);
		}
		return result;
	}
}