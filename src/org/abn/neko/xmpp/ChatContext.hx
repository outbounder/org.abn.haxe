package org.abn.neko.xmpp;
import xmpp.Message;

class ChatContext extends XMPPContext
{
	private var recipientJID:String;
	private var handleChatMessage:String->ChatContext->Void;
	
	public function new(recipientJID:String, context:XMPPContext)
	{
		super(context.username, context.password, context.server, context);
		this.recipientJID = recipientJID;
	}
	
	public function addMessageListener(listener:String->org.abn.neko.xmpp.ChatContext->Void):Void
	{
		this.handleChatMessage = listener;
		this.connection.addMessageListener(onMessage);
	}
	
	public function send(msg:String):Void
	{
		this.connection.sendMessage(this.recipientJID, msg);
	}
	
	private function onMessage(msg:Dynamic):Void
	{
		if (Std.is(msg, Message))
		{
			if (cast(msg, Message).from == this.recipientJID)
				this.handleChatMessage(cast(msg, Message).body , this);
		}
	}
}