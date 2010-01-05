package org.abn.neko.xmpp;
import jabber.MessageListener;
import jabber.Ping;
import jabber.Pong;
import jabber.StreamStatus;
import neko.vm.Thread;
import xmpp.Message;

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
	public var onConnectFailed:Dynamic->Void;
	
	
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
	
	public function createMessageListener(handler:Message->Void, ?listen:Bool):MessageListener
	{
		if (this.stream == null)
			throw "not connected";
			
		var listener:MessageListener = new MessageListener(this.stream, handler, listen);
		return listener;
	}
	
	public function createPongHandler():Pong
	{
		if (this.stream == null)
			throw "not connected";
			
		var p:Pong = new Pong(this.stream);
		return p;
	}
	
	public function createPing(?recipientJID:String, ?pongHandler:Dynamic->Void, ?interval):Ping
	{
		var p:Ping = new Ping(this.stream, recipientJID, interval);
		
		if(interval == null)
			p.send();
		else
			p.start();
			
		p.onError = pongHandler;
		p.onResponse = pongHandler;
		p.onTimeout = pongHandler;
		return p;
	}

	public function sendMessage(recipientJID:String, message:String):Void
	{
		if (this.stream.status != StreamStatus.open)
			throw "not connected";
			
		this.stream.sendMessage(recipientJID, message);
	}
	
	private function disconnectFromServer():Void
	{
		if (this.stream == null && this.cnx == null)
			return;
		if (this.stream.status == StreamStatus.open)
			this.stream.close();
		if (this.cnx != null)
			this.cnx.disconnect();		
		this.stream = null;
		this.cnx = null;
		
		if(this.onDisconnected != null)
			this.onDisconnected();
	}
	
	private function connectToServer():Void
	{	
		this.cnx = new jabber.SocketConnection( this.server, Stream.defaultPort );
		this.stream = new Stream( new jabber.JID( this.username+"@"+this.server+"/abn" ), cnx );
		this.stream.onOpen = this.handleOpen;
		this.stream.onClose = this.handleClose;
		this.stream.open();
		
		var msg:String = Thread.readMessage(true); // waiting for one message to disconnect
		this.disconnectFromServer();
	}

	private function handleClose(?e:Dynamic):Void
	{
		this.disconnect();
	}
	
	private function handleOpen():Void
	{
		var mechanisms = new Array<net.sasl.Mechanism>();
		mechanisms.push( new net.sasl.PlainMechanism() );
		
		var auth = new SASLAuthentication(this.stream, mechanisms);
		auth.onSuccess = this.handleLogin;
		auth.onFail = this.handleFail;
		auth.authenticate( this.password );
	}
	
	private function handleFail(?e:Dynamic):Void
	{
		if(this.onConnectFailed != null)
			this.onConnectFailed(e);
			
		this.disconnect();
	}
	
	private function handleLogin():Void
	{
		stream.sendPresence(PresenceShow.chat);
		
		if(this.onConnected != null)
			this.onConnected();
	}
	
}