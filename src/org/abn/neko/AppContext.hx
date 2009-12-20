package org.abn.neko;

import neko.Lib;
import neko.Web;
import org.abn.neko.http.HTTPContext;
import org.abn.neko.xmpp.XMPPContext;

class AppContext 
{
	public function new()
	{
		
	}
	
	public function createHTTPContext():HTTPContext
	{
		return new HTTPContext(Web.getParams(), Web.getMethod(), this);
	}
	
	public function createXMPPContext(username:String, password:String, server:String):XMPPContext
	{
		return new XMPPContext(username, password, server, this);
	}
}