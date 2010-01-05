package org.abn.bot;

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
		if (!this.has("xmpp"))
			this.set("xmpp", this.createXMPPContext("xmpp"));
			
		return this.get("xmpp");
	}
	
	public function closeXMPPConnection()
	{
		this.getXMPPContext().closeConnection();
		this.set("xmpp", null);
	}
	
	public function getDatabase():MySqlContext
	{
		if (!this.has("database"))
		{
			var dbContext:MySqlContext = this.createDatabaseContext("database");
			this.set("database", dbContext);
			neko.db.Manager.cnx = dbContext.getConnection();
			neko.db.Manager.initialize();
		}
		return this.get("database");
	}
	
	public function resetDatabase():Void
	{
		this.set("database", null);
		neko.db.Manager.cleanup();
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