/**
 * ...
 * @author outbounder
 */

package org.abn.neko.xmpp;
import util.Timer;

class MessageRequest 
{
	public var to:String;
	public var xmppContext:XMPPContext;
	public var timeout:Int;
	public var onResponse:String->String->Void;
	public var onTimeout:String->Void;
	
	private var timeoutTimer:Timer;
	
	public function new(xmppContext:XMPPContext, to:String) 
	{
		this.to = to;
		this.timeout = 5000;
		this.xmppContext = xmppContext;
	}
	
	public function startTimeoutTimer():Void
	{
		if (this.onTimeout != null)
		{
			this.timeoutTimer = new Timer(this.timeout);
			this.timeoutTimer.run = handleTimeout;
		}
	}
	
	public function stopTimeoutTimer():Void
	{
		if (this.timeoutTimer != null)
			this.timeoutTimer.stop();
		this.timeoutTimer = null;
	}
	
	private function handleTimeout():Void
	{
		this.stopTimeoutTimer();
		
		this.xmppContext.clearMessageRequest(this.to);
		this.onTimeout(this.to);
	}
	
}