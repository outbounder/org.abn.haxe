package org.abn;

import haxe.xml.Fast;
import neko.io.File;

class ContextParser
{
    private var currentChain:String;
	
	public function new() 
	{
		/* PARSE SOMETHING LIKE :)
		 *    <namespace>
				  <namespace>
					<namespace>
						<key>value</key>
						<key>value</key>
					</namespace>
					<key>value</key>
				  </namespace>
				  <namespace>
					<key>value</value>
				  </namespace>
				</namespace>
		*/
	}
	
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
		
		if (!this.hasSimpleContext(item))
		{
			if(this.currentChain.length != 0)
				this.currentChain += "." + item.name;
			else
				this.currentChain += item.name;
		}
					
		for (elem in item.elements)
		{
			if (!this.hasSimpleContext(elem))
			{
				this.pushItem(properties, elem);
			}
			else
			{
				properties.set(this.currentChain + "." + elem.name, elem.innerData);
			}
		}
		
		this.currentChain = original;
	}
	
	private function hasSimpleContext(item:Fast):Bool
	{
		var counter:Int = 0;
		for (i in item.elements)
			counter += 1;
		if (counter > 0)
			return false;
		return true;
	}
}
