package org.abn.bot.operation;

import neko.db.Connection;
import org.abn.bot.BotContext;
import org.abn.neko.AppContext;
import org.abn.neko.database.mysql.MySqlContext;

class BotOperation 
{
	public var botContext:BotContext;
	private var conn:MySqlContext;
	
	public function new(botContext:BotContext)
	{
		this.botContext = botContext;
	}
	
	public function getDbConn(?id:String):Connection
	{
		if (this.conn == null)
			this.conn = this.botContext.createDatabaseConnection(id);
			
		return this.conn.getConnection();
	}
	
	public function closeDbConn():Void
	{
		if (this.conn != null)
			this.conn.closeConnection();
	}
	
	public function execute(params:Hash<String>):String
	{
		return "not implemented";
	}
	
}