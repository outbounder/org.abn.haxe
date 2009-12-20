package org.abn.neko.xmpp;

import neko.vm.Thread;
import org.abn.neko.AppContext;
import xmpp.vcard.Org;

class XMPPContext extends AppContext
{
	public var username:String;
	public var password:String;
	public var server:String;
	
	private var connection:XMPPConnection;
	
	public function new(username:String, password:String, server:String, appContext:AppContext)
	{
		super();
		
		this.username = username;
		this.password = password;
		this.server = server;
	}
	
	public function openConnection(?useThread:Bool = true, ?onConnected:Void->Void):Bool
	{
		if (this.connection == null)
		{
			this.connection = new XMPPConnection(this.username, this.password, this.server, useThread);
			this.connection.onConnected = onConnected;
			this.connection.connect();
			return true;
		}
		else
			return false;
	}
	
	public function closeConnection():Void
	{
		if(this.connection != null)
			this.connection.disconnect();
	}
	
	public function createChatContext(recipientJID:String):ChatContext
	{
		return new ChatContext(recipientJID, this);
	}
	
	public function getConnection():XMPPConnection
	{
		return this.connection;
	}
}