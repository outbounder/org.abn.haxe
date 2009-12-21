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
	
	public function new(id:String, properties:Hash<Dynamic>)
	{
		super(properties);
		
		this.username = this.get(id + ".username");
		this.password = this.get(id + ".password");
		this.server = this.get(id + ".server");
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
	
	public function getConnection():XMPPConnection
	{
		return this.connection;
	}
}