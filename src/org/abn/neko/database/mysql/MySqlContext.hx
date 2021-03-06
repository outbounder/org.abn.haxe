﻿package org.abn.neko.database.mysql;
import neko.db.Connection;
import neko.db.ResultSet;
import neko.vm.Thread;
import org.abn.neko.AppContext;
import util.Timer;

class MySqlContext extends AppContext
{
	public var host:String;
	public var database:String;
	public var user:String;
	public var pass:String;
	public var socket:String;
	
	private var connection:Connection;
	
	public function new(id:String, properties:Hash<Dynamic>) 
	{
		super(properties);
		
		this.host = this.get(id + ".host");
		this.database = this.get(id + ".database");
		this.user = this.get(id + ".username");
		this.pass = this.get(id + ".password");
		this.socket = this.get(id + ".socket");
	}
	
	public function openConnection():Void
	{
		if (this.connection != null)
			return;
			
		this.connection  = neko.db.Mysql.connect( { user: this.user, socket: this.socket, port: 3306, pass: this.pass, host: this.host, database: this.database } );
		var result:ResultSet = this.connection.request("SET NAMES utf8");
	}
	
	public function closeConnection():Void
	{
		if(this.connection != null)
			this.connection.close();
		this.connection = null;
	}
	
	public function getConnection():Connection
	{
		return this.connection;
	}
	
}