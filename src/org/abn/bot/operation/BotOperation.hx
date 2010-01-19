package org.abn.bot.operation;

import hxjson2.JSON;
import neko.db.Connection;
import org.abn.bot.BotContext;
import org.abn.neko.AppContext;
import org.abn.neko.database.mysql.MySqlContext;

class BotOperation 
{
	public var botContext:BotContext;
	private var connections:Hash<MySqlContext>;
	
	public function new(botContext:BotContext)
	{
		this.botContext = botContext;
		this.connections = new Hash();
	}
	
	public function getDbConn(?id:String):Connection
	{
		if (this.connections.get(id) == null)
			this.connections.set(id, this.botContext.createDatabaseConnection(id));
			
		return this.connections.get(id).getConnection();
	}
	
	public function closeDbConn():Void
	{
		for (key in this.connections.keys())
			this.connections.get(key).closeConnection();
		this.connections = new Hash();
	}
	
	public function execute(params:Hash<String>):String
	{
		return "not implemented";
	}
	
	public function formatResponse(o:Dynamic, ?format:String = null):String
	{
		if (format == "json")
			return JSON.encode(o);
		else
			return "<response>" + o + "</response>";
	}
	
}