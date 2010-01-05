package org.abn.bot.operation;
import haxe.xml.Fast;
import neko.vm.Thread;
import org.abn.bot.BotContext;
import xmpp.Message;

class AsyncBotOperation 
{
	private var from:String;
	private var msg:String;
	private var botContext:BotContext;
	
	public function new(botContext:BotContext, from:String, msg:String) 
	{
		this.botContext = botContext;
		this.msg = msg;
		this.from = from;
	}
	
	public function handle():Void
	{
		Thread.create(handleSafe);
	}
	
	private function handleSafe():Void
	{
		var xml:Xml = Xml.parse(this.msg);
		var fast:Fast = new Fast(xml.firstElement());

		var result:String = this.botContext.executeOperation(fast.name, 
									this.botContext.getOperationFactory().getOperationParamsFromXML(fast));
		this.botContext.getXMPPContext().sendMessage(this.from, result);
	}
	
}