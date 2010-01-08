package org.abn.neko.xmpp;

import jabber.JIDUtil;
import jabber.MessageListener;
import neko.vm.Thread;
import org.abn.neko.AppContext;
import util.Timer;
import xmpp.Message;
import xmpp.vcard.Org;

class XMPPContext extends AppContext
{
	private var username:String;
	private var password:String;
	private var server:String;
	
	private var connection:XMPPConnection;
	private var messageListener:MessageListener;
	
	private var onIncomingMessage:String->String-> Void;
	private var onConnected:Void->Void;
	private var onDisconnected:Void->Void;

	private var requests:Hash<MessageRequest>;
	
	public function new(id:String, properties:Hash<Dynamic>)
	{
		super(properties);
		
		this.username = this.get(id + ".username");
		this.password = this.get(id + ".password");
		this.server = this.get(id + ".server");
	}
	
	public function openConnection(onConnected:Void->Void, onDisconnected:Void->Void, 
										onConnectFailed:Dynamic->Void, onIncomingMessage:String->String->Void):Void
	{
		if (this.connection != null)
			this.connection.disconnect();
			
		this.onConnected = onConnected;
		this.onDisconnected = onDisconnected;
		this.onIncomingMessage = onIncomingMessage;
			
		this.connection = new XMPPConnection(this.username, this.password, this.server);
		this.connection.onConnected = onConnectionEstablished;
		this.connection.onDisconnected = onConnectionLost;
		this.connection.onConnectFailed = onConnectFailed;
		this.connection.connect();
	}
	
	public function closeConnection():Void
	{
		if(this.connection != null)
			this.connection.disconnect();
	}
	
	private function onConnectionEstablished():Void
	{
		if(this.onConnected != null)
			this.onConnected();
			
		this.requests = new Hash();
		this.messageListener = new MessageListener(this.connection.getStream(), messageHandler, true);
	}
	
	private function onConnectionLost():Void
	{
		if(this.messageListener != null)
			this.messageListener.listen = false;
			
		this.messageListener = null;
		
		if(this.onDisconnected != null)
			this.onDisconnected();
	}
	
	private function messageHandler(msg:Message):Void
	{
		if (msg.body == null)
			return;
			
		var jid:String = JIDUtil.parseBare(msg.from);
		if (this.requests.exists(jid))
		{
			var msgRequest:MessageRequest = this.requests.get(jid);
			msgRequest.stopTimeoutTimer();
			this.requests.remove(jid);
			
			msgRequest.onResponse(jid, msg.body.split("&lt;").join("<").split("&gt;").join(">"));
		}
		else
		if (this.onIncomingMessage != null)
		{
			this.onIncomingMessage(msg.from, msg.body.split("&lt;").join("<").split("&gt;").join(">"));
		}
	}
	
	public function sendMessage(recipientJID:String, message:String, ?responseHandler:String->String->Void = null, 
		?timeoutHandler:String->Void = null, ?timeout:Int = 5000):Void
	{
		recipientJID = JIDUtil.parseBare(recipientJID);
		
		if (this.requests.exists(recipientJID))
			throw "can not send message twice to JID without the response had not been recieved";
		
		if (responseHandler != null || timeoutHandler != null)
		{
			var request:MessageRequest = new MessageRequest(this, recipientJID);
			request.onResponse = responseHandler;
			request.onTimeout = timeoutHandler;
			request.timeout = timeout;
			request.startTimeoutTimer();
			this.requests.set(JIDUtil.parseBare(recipientJID), request);
		}
		this.connection.sendMessage(recipientJID, message.split("<").join("&lt;").split(">").join("&gt;"));
	}
	
	public function clearMessageRequest(recipientJID:String):Void
	{
		this.requests.remove(JIDUtil.parseBare(recipientJID));
	}
}