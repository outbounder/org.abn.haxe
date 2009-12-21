package org.abn;

import haxe.xml.Fast;
import neko.io.File;

class ContextParser
{
    private var currentChain:String;
	
	public function new() 
	{
		
	}
	
	/*
	 *    <namespace id="">
			  <namespace id="">
				<namespace id="">
					<key>value</key>
					<key>value</key>
				</namespace>
				<key>value</key>
			  </namespace>
			  <namespace id="">
				<key>value</value>
			  </namespace>
			</namespace>
	*/
	
	public function getContext(fast:Fast):Context
	{
		this.currentChain = "";
		var properties:Hash<String> = new Hash();
		for (item in fast.elements)
		{
			this.pushItem(properties, item);
		}
		return new Context(properties);
	}
	
	private function pushItem(properties:Hash<String>, item:Fast):Void
	{
		var original:String = this.currentChain;
		
		if (item.has.id)
		{
			if(this.currentChain.length != 0)
				this.currentChain += "." + item.att.id;
			else
				this.currentChain += item.att.id;
		}
					
		for (elem in item.elements)
		{
			if (elem.has.id)
				this.pushItem(properties, elem);
			else
				properties.set(this.currentChain + "." + elem.name, elem.innerData);
		}
		
		this.currentChain = original;
	}
}
