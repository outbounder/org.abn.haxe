package org.abn.uberTora;

class ClientRequestContext
{
	private var request:Dynamic;
	
	static var _base_decode = neko.Lib.load("std","base_decode",2);
	
	public function new(request:Dynamic) 
	{
		this.request = request;
	}
	
	public function sendResponse(value:Dynamic):Void
	{
		this.request.sendResponse(value);
	}
	
	/**
		Returns the GET and POST parameters.
	**/
	public function getParams() {
		var p = this.request.get_params();
		var h = new Hash<String>();
		var k = "";
		while( p != null ) {
			untyped k.__s = p[0];
			h.set(k,new String(p[1]));
			p = untyped p[2];
		}
		return h;
	}

	/**
		Returns an Array of Strings built using GET / POST values.
		If you have in your URL the parameters [a[]=foo;a[]=hello;a[5]=bar;a[3]=baz] then
		[neko.Web.getParamValues("a")] will return [["foo","hello",null,"baz",null,"bar"]]
	**/
	public function getParamValues( param : String ) : Array<String> {
		var reg = new EReg("^"+param+"(\\[|%5B)([0-9]*?)(\\]|%5D)=(.*?)$", "");
		var res = new Array<String>();
		var explore = function(data:String){
			if (data == null || data.length == 0)
				return;
			for (part in data.split("&")){
				if (reg.match(part)){
					var idx = reg.matched(2);
					var val = StringTools.urlDecode(reg.matched(4));
					if (idx == "")
						res.push(val);
					else
						res[Std.parseInt(idx)] = val;
				}
			}
		}
		explore(StringTools.replace(getParamsString(), ";", "&"));
		explore(getPostData());
		if (res.length == 0)
			return null;
		return res;
	}

	/**
		Returns the local server host name
	**/
	public function getHostName() {
		return  this.request.get_host_name();
	}

	/**
		Surprisingly returns the client IP address.
	**/
	public function getClientIP() {
		return  this.request.get_client_ip();
	}

	/**
		Returns the original request URL (before any server internal redirections)
	**/
	public function getURI():String 
	{
		return this.request.get_uri();
	}

	/**
		Tell the client to redirect to the given url ("Location" header)
	**/
	public function redirect( url : String ) {
		 this.request.redirect(untyped url.__s);
	}

	/**
		Set an output header value. If some data have been printed, the headers have
		already been sent so this will raise an exception.
	**/
	public function setHeader( h : String, v : String ) {
		 this.request.set_header(untyped h.__s,untyped v.__s);
	}

	/**
		Set the HTTP return code. Same remark as setHeader.
	**/
	public function setReturnCode( r : Int ) {
		 this.request.return_code(r);
	}

	/**
		Retrieve a client header value sent with the request.
	**/
	public function getClientHeader( k : String ) {
		var v =  this.request.get_client_header(untyped k.__s);
		if( v == null )
			return null;
		return new String(v);
	}

	/**
		Retrieve all the client headers.
	**/
	public function getClientHeaders() {
		var v =  this.request.get_client_headers();
		var a = new List();
		while( v != null ) {
			a.add({ header : new String(v[0]), value : new String(v[1]) });
			v = cast v[2];
		}
		return a;
	}

	/**
		Returns all the GET parameters String
	**/
	public function getParamsString() {
		return this.request.get_params_string();
	}

	/**
		Returns all the POST data. POST Data is always parsed as
		being application/x-www-form-urlencoded and is stored into
		the getParams hashtable. POST Data is maximimized to 256K
		unless the content type is multipart/form-data. In that
		case, you will have to use [getMultipart] or [parseMultipart]
		methods.
	**/
	public function getPostData() {
		var v =  this.request.get_post_data();
		if( v == null )
			return null;
		return new String(v);
	}

	/**
		Returns an hashtable of all Cookies sent by the client.
		Modifying the hashtable will not modify the cookie, use setCookie instead.
	**/
	public function getCookies() {
		var p =  this.request.get_cookies();
		var h = new Hash<String>();
		var k = "";
		while( p != null ) {
			untyped k.__s = p[0];
			h.set(k,new String(p[1]));
			p = untyped p[2];
		}
		return h;
	}


	/**
		Set a Cookie value in the HTTP headers. Same remark as setHeader.
	**/
	public function setCookie( key : String, value : String, ?expire: Date, ?domain: String, ?path: String, ?secure: Bool ) {
		var buf = new StringBuf();
		buf.add(value);
		if( expire != null ) addPair(buf, "expires=", DateTools.format(expire, "%a, %d-%b-%Y %H:%M:%S GMT"));
		addPair(buf, "domain=", domain);
		addPair(buf, "path=", path);
		if( secure ) addPair(buf, "secure", "");
		var v = buf.toString();
		 this.request.set_cookie(untyped key.__s, untyped v.__s);
	}

    function addPair( buf : StringBuf, name, value ) {
		if( value == null ) return;
		buf.add("; ");
		buf.add(name);
		buf.add(value);
	}

	/**
		Returns an object with the authorization sent by the client (Basic scheme only).
	**/
	public function getAuthorization() : { user : String, pass : String } {
		var h = getClientHeader("Authorization");
		var reg = ~/^Basic ([^=]+)=*$/;
		if( h != null && reg.match(h) ){
			var val = reg.matched(1);
			untyped val = new String(_base_decode(val.__s,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".__s));
			var a = val.split(":");
			if( a.length != 2 ){
				throw "Unable to decode authorization.";
			}
			return {user: a[0],pass: a[1]};
		}
		return null;
	}

	/**
		Get the current script directory in the local filesystem.
	**/
	public function getCwd() {
		return  this.request.get_cwd();
	}

	/**
		Get the multipart parameters as an hashtable. The data
		cannot exceed the maximum size specified.
	**/
	public function getMultipart( maxSize : Int ) : Hash<String> {
		var h = new Hash();
		var buf : haxe.io.BytesBuffer = null;
		var curname = null;
		parseMultipart(function(p,_) {
			if( curname != null )
				h.set(curname,neko.Lib.stringReference(buf.getBytes()));
			curname = p;
			buf = new haxe.io.BytesBuffer();
			maxSize -= p.length;
			if( maxSize < 0 )
				throw "Maximum size reached";
		},function(str,pos,len) {
			maxSize -= len;
			if( maxSize < 0 )
				throw "Maximum size reached";
			buf.addBytes(str,pos,len);
		});
		if( curname != null )
			h.set(curname,neko.Lib.stringReference(buf.getBytes()));
		return h;
	}

	/**
		Parse the multipart data. Call [onPart] when a new part is found
		with the part name and the filename if present
		and [onData] when some part data is readed. You can this way
		directly save the data on hard drive in the case of a file upload.
	**/
	public function parseMultipart( onPart : String -> String -> Void, onData : haxe.io.Bytes -> Int -> Int -> Void ) : Void {
		 this.request.parse_multipart(
			function(p,f) { onPart(new String(p),if( f == null ) null else new String(f)); },
			function(buf,pos,len) { onData(untyped new haxe.io.Bytes(__dollar__ssize(buf),buf),pos,len); }
		);
	}

	/**
		Flush the data sent to the client. By default on Apache, outgoing data is buffered so
		this can be useful for displaying some long operation progress.
	**/
	public function flush() : Void {
		 this.request.flush();
	}

	/**
		Get the HTTP method used by the client. This api requires Neko 1.7.1+
	**/
	public function getMethod() : String {
		return  this.request.get_http_method();
	}

	/**
		Write a message into the web server log file. This api requires Neko 1.7.1+
	**/
	public function logMessage( msg : String ) 
	{
		 this.request.log_message(untyped msg.__s);
	}
}