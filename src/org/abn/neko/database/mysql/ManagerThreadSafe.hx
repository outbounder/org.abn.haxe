package org.abn.neko.database.mysql;

import Reflect;
import neko.db.Connection;

class ManagerThreadSafe<T : DataObject>
{
	private var cnx:Connection;
	private var KEYWORDS:Hash<Bool>;

	var table_name : String;
	var table_fields : List<String>;
	var table_keys : Array<String>;
	var class_proto : Dynamic;

	public function new(cnx:Connection, classval : Class<DataObject> ) 
	{
		this.cnx = cnx;
		var cl : Dynamic = classval;
		
		this.KEYWORDS = new Hash();
		for( k in ["read","write","desc","out","group","version","option",
				"primary","exists","from","key","keys","limit","lock","use"] )
			this.KEYWORDS.set(k,true);


		// get basic infos
		var cname : Array<String> = cl.__name__;
		table_name = quoteField(if( cl.TABLE_NAME != null ) cl.TABLE_NAME else cname[cname.length-1]);
		table_keys = if( cl.TABLE_IDS != null ) cl.TABLE_IDS else ["id"];
		class_proto = cl;

		// get the list of private fields
		var apriv : Array<String> = cl.PRIVATE_FIELDS;
		apriv = if( apriv == null ) new Array() else apriv.copy();
		apriv.push("__class__");
		apriv.push("__name__");

		// get the proto fields not marked private (excluding methods)
		table_fields = new List();
		for ( f in Reflect.fields(class_proto.prototype) ) 
		{
			var isfield = !Reflect.isFunction(Reflect.field(class_proto.prototype,f));
			if( isfield )
				for( f2 in apriv )
					if( f == f2 ) {
						isfield = false;
						break;
					}
			if( isfield )
				table_fields.add(f);
		}
	}
	
	public function insert( x:T )
	{
		this.doInsert( x );
	}
	
	public function update( x:T)
	{
		this.doUpdate(x);
	}

	public function get( id : Int ) : T 
	{
		if( table_keys.length != 1 )
			throw "Invalid number of keys";
		if( id == null )
			return null;

		var s = new StringBuf();
		s.add("SELECT * FROM ");
		s.add(table_name);
		s.add(" WHERE ");
		s.add(quoteField(table_keys[0]));
		s.add(" = ");
		addQuote(s,id);
		
		return object(s.toString());
	}

	public function getWithKeys( keys : { } ) : T 
	{

		var s = new StringBuf();
		s.add("SELECT * FROM ");
		s.add(table_name);
		s.add(" WHERE ");
		addKeys(s,keys);

		return object(s.toString());
	}

	public function delete( x : { } ) 
	{
		var s = new StringBuf();
		s.add("DELETE FROM ");
		s.add(table_name);
		s.add(" WHERE ");
		addCondition(s,x);
		execute(s.toString());
	}

	public function search( x : { } ) : List<T> 
	{
		var s = new StringBuf();
		s.add("SELECT * FROM ");
		s.add(table_name);
		s.add(" WHERE ");
		addCondition(s,x);
		return objects(s.toString());
	}

	function addCondition(s : StringBuf, x) 
	{
		var first = true;
		if( x != null )
			for ( f in Reflect.fields(x) ) 
			{
				if( first )
					first = false;
				else
					s.add(" AND ");
				s.add(quoteField(f));
				var d = Reflect.field(x,f);
				if( d == null )
					s.add(" IS NULL");
				else {
					s.add(" = ");
					addQuote(s,d);
				}
			}
		if( first )
			s.add("1");
	}

	public function all( ) : List<T> 
	{
		return objects("SELECT * FROM " + table_name);
	}

	public function count( ?x : { } ) : Int 
	{
		var s = new StringBuf();
		s.add("SELECT COUNT(*) FROM ");
		s.add(table_name);
		s.add(" WHERE ");
		addCondition(s,x);
		return execute(s.toString()).getIntResult(0);
	}

	public function quote( s : String ) : String 
	{
		return cnx.quote( s );
	}

	public function result( sql : String ) : Dynamic 
	{
		return cnx.request(sql).next();
	}

	public function results<T>( sql : String ) : List<T> 
	{
		return cast cnx.request(sql).results();
	}

	/* -------------------------- SPODOBJECT API -------------------------- */

	function doInsert( x : T ) 
	{
		
		var s = new StringBuf();
		var fields = new List();
		var values = new List();
		for( f in table_fields ) {
			var v = Reflect.field(x,f);
			if( v != null ) {
				fields.add(quoteField(f));
				values.add(v);
			}
		}
		s.add("INSERT INTO ");
		s.add(table_name);
		s.add(" (");
		s.add(fields.join(","));
		s.add(") VALUES (");
		var first = true;
		for( v in values ) {
			if( first )
				first = false;
			else
				s.add(", ");
			addQuote(s,v);
		}
		s.add(")");
		execute(s.toString());
		// table with one key not defined : suppose autoincrement
		if( table_keys.length == 1 && Reflect.field(x,table_keys[0]) == null )
			Reflect.setField(x,table_keys[0],cnx.lastInsertId());
	}

	function doUpdate( x : T ) 
	{
		var s = new StringBuf();
		s.add("UPDATE ");
		s.add(table_name);
		s.add(" SET ");

		var mod = false;
		for ( f in table_fields ) 
		{
			var v = Reflect.field(x,f);
			if( mod )
				s.add(", ");
			else
				mod = true;
			s.add(quoteField(f));
			s.add(" = ");
			addQuote(s,v);
		}
		if( !mod )
			return;
		s.add(" WHERE ");
		addKeys(s,x);
		execute(s.toString());
	}

	function doDelete( x : T ) 
	{
		var s = new StringBuf();
		s.add("DELETE FROM ");
		s.add(table_name);
		s.add(" WHERE ");
		addKeys(s,x);
		execute(s.toString());
	}

	function objectToString( it : T ) : String 
	{
		var s = new StringBuf();
		s.add(table_name);
		if ( table_keys.length == 1 ) 
		{
			s.add("#");
			s.add(Reflect.field(it,table_keys[0]));
		} 
		else 
		{
			s.add("(");
			var first = true;
			for ( f in table_keys ) 
			{
				if( first )
					first = false;
				else
					s.add(",");
				s.add(quoteField(f));
				s.add(":");
				s.add(Reflect.field(it,f));
			}
			s.add(")");
		}
		return s.toString();
	}

	function quoteField(f : String) 
	{
		return KEYWORDS.exists(f.toLowerCase()) ? "`"+f+"`" : f;
	}

	function addQuote( s : StringBuf, v : Dynamic ) 
	{
		var t = untyped __dollar__typeof(v);
		if( untyped (t == __dollar__tint || t == __dollar__tnull) )
			s.add(v);
		else if( untyped t == __dollar__tbool )
			s.add(if( v ) 1 else 0);
		else
			s.add(cnx.quote(Std.string(v)));
	}

	function addKeys( s : StringBuf, x : { } ) 
	{
		var first = true;
		for( k in table_keys ) {
			if( first )
				first = false;
			else
				s.add(" AND ");
			s.add(quoteField(k));
			s.add(" = ");
			var f = Reflect.field(x,k);
			if( f == null )
				throw ("Missing key "+k);
			addQuote(s,f);
		}
	}

	function execute( sql : String ) 
	{
		return cnx.request(sql);
	}

	function select( cond : String ) 
	{
		var s = new StringBuf();
		s.add("SELECT * FROM ");
		s.add(table_name);
		s.add(" WHERE ");
		s.add(cond);
		return s.toString();
	}

	function selectReadOnly( cond : String ) 
	{
		var s = new StringBuf();
		s.add("SELECT * FROM ");
		s.add(table_name);
		s.add(" WHERE ");
		s.add(cond);
		return s.toString();
	}

	public function object( sql : String ) : T 
	{
		var r = cnx.request(sql).next();
		if( r == null )
			return null;
		untyped __dollar__objsetproto(r,class_proto.prototype);
		return r;
	}

	public function objects( sql : String ) : List<T> 
	{
		var me = this;
		var l = cnx.request(sql).results();
		var l2 = new List<T>();
		for ( x in l ) {
			untyped __dollar__objsetproto(x,class_proto.prototype);
			l2.add(x);
		}
		return l2;
	}

	public function dbClass() : Class<Dynamic> 
	{
		return cast class_proto;
	}
	
}