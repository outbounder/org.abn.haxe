package org.abn.neko;

import neko.Lib;
import neko.Web;
import org.abn.Context;
import org.abn.ContextParser;
import org.abn.neko.database.mysql.MySqlContext;
import org.abn.neko.xmpp.XMPPContext;

class AppContext extends Context
{	
	public function new(properies:Hash<Dynamic>)
	{
		super(properies);
	}
	
	public function createDatabaseContext(id:String):MySqlContext
	{
		return new MySqlContext(id, this.properties);
	}
	
	public function createXMPPContext(id:String):XMPPContext
	{
		return new XMPPContext(id, this.properties);
	}
}