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
	
	public function getDatabase():MySqlContext
	{
		return this.get("database");
	}
	
	public function openDatabase():Void
	{
		if (this.has("database"))
			return;
		var dbContext:MySqlContext = this.createDatabaseContext("database");
		this.set("database", dbContext);
		dbContext.openConnection();
		neko.db.Manager.cnx = dbContext.getConnection();
		neko.db.Manager.initialize();
	}
	
	public function closeDatabase():Void
	{
		if (!this.has("database"))
			return;
		var dbContext:MySqlContext = this.get("database");
		dbContext.closeConnection();
		neko.db.Manager.cleanup();
		this.set("database", null);
	}
	
	public function getOperationFactory():BotOperationFactory
	{
		if (!this.has("operationFactory"))
			this.set("operationFactory", new BotOperationFactory(this));
		return this.get("operationFactory");
	}
	
	public function executeOperation(id:String, params:Hash<String>):String
	{
		var operation:BotOperation = this.getOperationFactory().getOperationById(id);
		if (operation == null)
			return id;
		return operation.execute(params);
	}
	
}