package org.abn.neko;

import neko.Lib;
import neko.Web;
import org.abn.neko.http.HTTPContext;
import org.abn.neko.xmpp.XMPPContext;

class AppContext 
{
	private var xmppContext:XMPPContext;
	
	public function new()
	{
		
	}
	
	public function createHTTPContext():HTTPContext
	{
		return new HTTPContext(Web.getParams(), Web.getMethod(), this);
	}
	
	public function createXMPPContext(username:String, password:String, server:String):XMPPContext
	{
		this.xmppContext = new XMPPContext(username, password, server, this);
		return this.xmppContext;
	}
	
	public function getXMPPContext():XMPPContext
	{
		return this.xmppContext;
	}
}