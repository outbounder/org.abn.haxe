package org.abn.bot.operation;
import haxe.xml.Fast;
import neko.vm.Thread;
import org.abn.bot.BotContext;
import xmpp.Message;

class AsyncBotOperation 
{
	private var xml:Xml;
	private var msg:Message;
	private var botContext:BotContext;
	
	public function new(botContext:BotContext, msg:Message, xml:Xml) 
	{
		this.botContext = botContext;
		this.msg = msg;
		this.xml = xml;
	}
	
	public function handle():Void
	{
		Thread.create(handleSafe);
	}
	
	private function handleSafe():Void
	{
		var fast:Fast = new Fast(xml.firstElement());
					
		var result:String = this.botContext.executeOperation(fast.name, 
									this.botContext.getOperationFactory().getOperationParamsFromXML(fast));
		this.botContext.getXMPPContext().getConnection().sendMessage(msg.from, result);
	}
	
}