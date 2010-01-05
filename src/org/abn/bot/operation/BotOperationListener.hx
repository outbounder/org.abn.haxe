package org.abn.bot.operation;
import haxe.xml.Fast;
import jabber.MessageListener;
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
	
	public function stopListening():Void
	{
		this.messageListener.listen = false;
	}
	
	private function incomingMessagesHandler(msg:Message):Void
	{
		try
		{
			if (msg.body != null)
			{
				var body:String = msg.body.split("&lt;").join("<").split("&gt;").join(">");
				var xml:Xml = Xml.parse(body);
				
				if (xml != null)
				{
					var fast:Fast = new Fast(xml.firstElement());
												
					var operation:BotOperation = this.botContext.getOperationFactory().getOperationById(fast.name);
					if (operation == null)
					{
						this.botContext.getXMPPContext().getConnection().sendMessage(msg.from, msg.body);
						return;
					}
					
					var result:String = operation.execute(this.botContext.getOperationFactory().getOperationParamsFromXML(fast));
					result = result.split("<").join("&lt;").split(">").join("&gt;");
					this.botContext.getXMPPContext().getConnection().sendMessage(msg.from, result);
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