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
		var properties:Hash<Dynamic> = new Hash();
		for (item in fast.elements)
		{
			this.pushItem(properties, item);
		}
		return new Context(properties);
	}
	
	private function pushItem(properties:Hash<Dynamic>, item:Fast):Void
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
				if (!properties.exists(this.currentChain + "." + elem.name))
				{
					properties.set(this.currentChain + "." + elem.name, elem.innerData);
				}
				else 
				{
					var property:Dynamic = properties.get(this.currentChain + "." + elem.name);
					if (Std.is(property, List))
					{
						var pl:List<Dynamic> = property;
						pl.add(elem.innerData);
					}
					else
					{
						var pl:List<Dynamic> = new List();
						pl.add(properties.get(this.currentChain + "." + elem.name));
						pl.add(elem.innerData);
						properties.set(this.currentChain + "." + elem.name, pl);
					}
				}
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
