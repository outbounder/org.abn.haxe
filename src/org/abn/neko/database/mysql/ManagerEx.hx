package org.abn.neko.database.mysql;

import haxe.xml.Fast;
import Reflect;
import neko.db.Object;
import neko.db.ResultSet;
import Type;

class ManagerEx <T : Object>  extends neko.db.Manager <T>
{
    private var classOriginal:Class<Object>;
	private var classInfo:Fast;
	
	public function new(classval : Class<neko.db.Object>) 
	{
		super(classval);
		this.classOriginal = classval;
	}
	
	public function updateTable():Void
	{
		var query:String = "SHOW TABLES LIKE '" + this.table_name + "'";
		var result:ResultSet = execute(query);
		if (result.length == 0)
			this.createTable();
		else
			this.alterTable();
	}
	
	private function createTable():Void
	{
		var s = new StringBuf();
		var fields = new List();
		var values = new List();
		var proto : { local_manager : ManagerEx<T> } = this.class_proto.prototype;
		var protoFields: Array<String> = Reflect.fields(proto);
		for ( f in this.table_fields ) 
		{
			for ( v in protoFields)
			{
				if ( v == f ) 
				{
					if (f == "id")
						fields.add(this.quoteField(f) + " INT NOT NULL AUTO_INCREMENT");
					else
						fields.add(this.quoteField(f)+ " "+this.getMysqlFieldType(v));
				}
			}
		}
		s.add("CREATE TABLE `");
		s.add(this.table_name);
		s.add("` (");
		s.add(fields.join(","));
		s.add(", PRIMARY KEY (`id`)) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_general_ci");
		execute(s.toString());
	}
	
	private function alterTable():Void
	{
		var currentTableColumns:List<String> = this.getTableColumns();
		
		var s = new StringBuf();
		var fields = new List(); 
		var values = new List();
		for ( f in this.table_fields ) 
		{
			if (f == "id")
				continue;
			var found:Bool = false;
			for(tf in currentTableColumns)
			{
				if (tf.toLowerCase() == f.toLowerCase())
					found = true;
			}
			if (found)
				fields.add("MODIFY COLUMN "+this.quoteField(f)+" "+this.getMysqlFieldType(f)+" NULL");
			else
				fields.add("ADD COLUMN "+this.quoteField(f)+" "+this.getMysqlFieldType(f)+" NULL");
		}
		
		s.add("ALTER TABLE `");
		s.add(this.table_name);
		s.add("` ");
		s.add(fields.join(","));
		
		execute(s.toString());
	}
	
	private function getMysqlFieldType(f:String):String
	{
		var valType:String = this.getFieldType(f);
		switch(valType)
		{
			case "Int": return "INT";
			case "Float": return "FLOAT";
			case "Bool": return "BOOL";
			case "Date": return "DATETIME";
			default: return "TEXT";
		}
	}
	
	
	private function getFieldType(f:String):String
	{
		if (this.classInfo == null)
		{
			var xml:Xml = Xml.parse(untyped this.classOriginal.__rtti);
			this.classInfo = new Fast(xml.firstElement());
		}
		
		var fieldInfo:Fast = this.classInfo.node.resolve(f);
		if (!fieldInfo.hasNode.c)
			return null;
		var c:Fast = fieldInfo.node.c;
		return c.att.path;
	}
	
	private function getTableColumns():List<String>
	{
		var query = "SHOW COLUMNS FROM "+this.table_name;
		var resultSet:ResultSet = execute(query);
		var result:List<String> = new List();
		for(row in resultSet)
		{
			result.push(row.Field);
		}
		return result;
	}
	
}