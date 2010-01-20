package org.abn.uberTora;

class UberToraContext
{

	public static function redirectRequests(handler:Dynamic->Void) : Void 
	{
		neko.Lib.load("mod_neko","redirectRequests",1)(handler);
	}
	
	public static function getAsClientRequestContext(request:Dynamic):ClientRequestContext
	{
		return new ClientRequestContext(request);
	}
	
}