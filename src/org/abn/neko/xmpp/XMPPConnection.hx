package org.abn.neko.xmpp;
import jabber.StreamStatus;
import neko.vm.Thread;

import xmpp.filter.MessageFilter;
import xmpp.PacketFilter;
import xmpp.PresenceShow;

import jabber.client.NonSASLAuthentication;
import jabber.client.SASLAuthentication;
import jabber.client.Stream;
import jabber.SocketConnection;
import jabber.stream.PacketCollector;
import jabber.stream.TPacketInterceptor;
import jabber.XMPPError;

class XMPPConnection 
{
	private var username:String;
	private var password:String;
	private var server:String;
	private var useThread:Bool;
	
	private var stream:Stream;
	private var cnx:SocketConnection;
	private var socketThread:Thread;
	
	public var onConnected:Void->Void;
	public var onDisconnected:Void->Void;
	
	
	public function new(username:String, password:String, server:String, useThread:Bool) 
	{
		this.username = username;
		this.password = password;
		this.server = server;
		this.useThread = useThread;
	}
	
	public function disconnect():Void
	{
		if (this.stream == null)
			return;
			
		this.disconnectFromServer();
	}
	
	public function connect():Void
	{
		if (this.stream != null)
			return;
			
		if (this.useThread)
			this.socketThread = Thread.create(this.connectToServer);
		else
			this.connectToServer();
	}
	
	public function addMessageListener(handler:Dynamic->Void)
	{
		if (this.stream == null)
			throw "not connected";
			
		var filters = new Array<PacketFilter>();
		filters.push(new MessageFilter());
		this.stream.addCollector( new PacketCollector( filters, handler, true, null, false) );
	}
	
	public function sendMessage(recipientJID:String, message:String):Void
	{
		if (this.stream.status != StreamStatus.open)
			throw "not connected";
			
		this.stream.sendMessage(recipientJID, message);
	}
	
	private function disconnectFromServer():Void
	{
		trace("disconnecting...");
		if (this.stream == null && this.cnx == null)
			return;
		if (this.stream.status == StreamStatus.open)
			this.stream.close();
		if (this.cnx != null)
			this.cnx.disconnect();		
		this.stream = null;
		this.cnx = null;
		trace("disconnected");
		
		if(this.onDisconnected != null)
			this.onDisconnected();
	}
	
	private function connectToServer():Void
	{
		trace("connecting...");
		
		this.cnx = new jabber.SocketConnection( this.server, Stream.defaultPort );
		this.stream = new Stream( new jabber.JID( this.username+"@"+this.server ), cnx );
		this.stream.onOpen = this.handleOpen;
		this.stream.onClose = this.handleClose;
		this.stream.open();
		
		var msg:String = Thread.readMessage(true); // waiting for one message to disconnect
		trace("disconnecting / exit from thread");
		this.disconnectFromServer();
	}

	private function handleClose(?e:Dynamic):Void
	{
		trace("handle close...");
		this.disconnect();
	}
	
	private function handleOpen():Void
	{
		trace("handle open...");
		var mechanisms = new Array<net.sasl.Mechanism>();
		mechanisms.push( new net.sasl.PlainMechanism() );
		
		var auth = new SASLAuthentication(this.stream, mechanisms);
		auth.onSuccess = this.handleLogin;
		auth.onFail = this.handleFail;
		auth.authenticate( this.password );
	}
	
	private function handleFail(?e:Dynamic)
	{
		trace("handle faile "+e);
		this.disconnect();
	}
	
	private function handleLogin() 
	{
		trace("connected");
		stream.sendPresence(PresenceShow.chat);
		if(this.onConnected != null)
			this.onConnected();
	}
	
}