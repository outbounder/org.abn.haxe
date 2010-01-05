package org.abn.bot.operation;

import neko.db.Connection;
import org.abn.bot.BotContext;
import org.abn.neko.AppContext;

class BotOperation 
{
	public var botContext:BotContext;
	
	public function new(botContext:BotContext)
	{
		this.botContext = botContext;
	}
	
	public function getDbConn():Connection
	{
		return this.botContext.getDatabase().getConnection();
	}
	
	public function execute(params:Hash<String>):String
	{
		return "not implemented";
	}
	
}