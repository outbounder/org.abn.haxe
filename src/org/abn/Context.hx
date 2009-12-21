package org.abn;

class Context 
{
	private var properties:Hash<Dynamic>;
	
	public function new(properties:Hash<Dynamic>) 
	{
		this.properties = properties;
	}
	
	public function has(name:String):Bool
	{
		return this.properties.exists(name);
	}
	
	public function set(name:String, value:Dynamic):Void
	{
		if(value != null)
			this.properties.set(name, value);
		else
			this.properties.remove(name);
	}
	
	public function get(name:String):Dynamic
	{
		return this.properties.get(name);
	}
	
	public function getProperties():Hash<Dynamic>
	{
		return this.properties;
	}
}