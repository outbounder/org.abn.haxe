package org.abn.bot.operation;
import haxe.xml.Fast;
import jabber.MessageListener;
import neko.vm.Thread;
import org.abn.bot.BotContext;
import org.abn.neko.AppContext;
import org.abn.neko.xmpp.XMPPContext;
import xmpp.Message;
import haxe.Stack;

class BotOperationListener 
{
    private var botContext:BotContext;
	private var messageListener:MessageListener;
	
	public function new(botContext:BotContext) 
	{
		this.botContext = botContext;
		this.messageListener = this.botContext.getXMPPContext().getConnection().createMessageListener(incomingMessagesHandler, true);
	}
	
	public function getListening():Bool
	{
		return this.messageListener.listen;
	}
	
	public function stopListening():Void
	{
		this.messageListener.listen = false;
	}
	
	public function startListening():Void
	{
		this.messageListener.listen = true;
	}
	
	private function incomingMessagesHandler(msg:Message):Void
	{
		try
		{
			trace(msg.body);
			if (msg.body != null)
			{
				var body:String = msg.body.split("&lt;").join("<").split("&gt;").join(">");
				var xml:Xml = Xml.parse(body);
				
				if (xml != null)
				{
					var asynchBotOperation:AsyncBotOperation = new AsyncBotOperation(this.botContext, msg, xml);
					asynchBotOperation.handle();
				}
			}
		}
		catch (e:Dynamic)
		{
			trace(e);
			trace(Stack.toString(Stack.exceptionStack()));
			trace(msg);
		}
	}
}