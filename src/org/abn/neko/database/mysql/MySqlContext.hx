package org.abn.neko.database.mysql;
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
	private var keepConnectionTimer:Timer;
	
	public function new(id:String, properties:Hash<Dynamic>) 
	{
		super(properties);
		
		this.host = this.get(id + ".host");
		this.database = this.get(id + ".database");
		this.user = this.get(id + ".username");
		this.pass = this.get(id + ".password");
		this.socket = this.get(id + ".socket");
	}
	
	public function openConnection(keepAlive:Bool):Void
	{
		if (this.connection != null)
			return;
			
		this.connection  = neko.db.Mysql.connect( { user: this.user, socket: this.socket, port: 3306, pass: this.pass, host: this.host, database: this.database } );
		var result:ResultSet = this.connection.request("SET NAMES utf8");
		
		if (keepAlive)
		{
			// ugly hack, TODO make this with mysql options = keep-alive connection
			this.keepConnectionTimer = new Timer(5 * 60 * 1000);
			this.keepConnectionTimer.run = keepConnectionAlive;
		}
	}
	
	private function keepConnectionAlive():Void
	{
		try
		{
			var result:ResultSet = this.connection.request("SET NAMES utf8");
		}
		catch (e:Dynamic)
		{
			trace(e);
		}
	}
	
	public function closeConnection():Void
	{
		if (this.keepConnectionTimer != null)
			this.keepConnectionTimer.stop();
		this.keepConnectionTimer = null;
		
		if(this.connection != null)
			this.connection.close();
		this.connection = null;
	}
	
	public function getConnection():Connection
	{
		return this.connection;
	}
	
}