package org.abn.bot;

import org.abn.bot.operation.AsyncBotOperation;
import org.abn.bot.operation.BotOperation;
import org.abn.bot.operation.BotOperationFactory;
import org.abn.neko.AppContext;
import org.abn.neko.database.mysql.MySqlContext;
import org.abn.neko.xmpp.XMPPContext;

class BotContext extends AppContext
{
	public function new(context:AppContext) 
	{
		super(context.properties);
	}
	
	public function getXMPPContext():XMPPContext
	{
		return this.get("xmpp");
	}
	
	public function openXMPPConnection(onConnected:Void->Void, onConnectFailed:Dynamic->Void, onDisconnected:Void->Void):Void
	{
		if (!this.has("xmpp"))
			this.set("xmpp", this.createXMPPContext("xmpp"));
			
		this.getXMPPContext().openConnection(onConnected, onDisconnected, onConnectFailed, onIncomingMessage);
	}
	
	public function closeXMPPConnection()
	{
		this.getXMPPContext().closeConnection();
		this.set("xmpp", null);
	}
	
	private function onIncomingMessage(from:String, msg:String):Void
	{
		var asynchBotOperation:AsyncBotOperation = new AsyncBotOperation(this, from, msg);
		asynchBotOperation.handle();
	}
	
	public function createDatabaseConnection(?id:String = "database"):MySqlContext
	{
		var dbContext:MySqlContext = this.createDatabaseContext(id);
		dbContext.openConnection();
		return dbContext;
	}
	
	public function getOperationFactory():BotOperationFactory
	{
		if (!this.has("operationFactory"))
			this.set("operationFactory", new BotOperationFactory(this));
		return this.get("operationFactory");
	}
	
	public function executeOperation(id:String, params:Hash<String>, ?requestContext:Dynamic = null):String
	{
		var operation:BotOperation = this.getOperationFactory().getOperationById(id);
		if (operation == null)
			return id;
			
		operation.requestContext = requestContext;
		var result:String = null;
		try
		{
			result = operation.execute(params);
		}
		catch (e:Dynamic)
		{ 
			trace(e);
			trace(haxe.Stack.toString(haxe.Stack.exceptionStack()));
			result = "exceptionfound";
		}
		operation.closeDbConn();
		return result;
	}
	
}
