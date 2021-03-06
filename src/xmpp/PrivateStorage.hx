/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package xmpp;

class PrivateStorage {
	
	public static var XMLNS = "jabber:iq:private";
	
	public var name : String;
	public var namespace : String;
	public var data : Xml;
	
	public function new( name : String, namespace : String, ?data : Xml ) {
		this.name = name;
		this.namespace = namespace;
		this.data = data;
	}
	
	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		var e = Xml.createElement( name );
		e.set( "xmlns", namespace );
		if( data != null ) e.addChild( data );
		x.addChild( e );
		return x;
	}
	
	public static function parse( x : Xml ) : PrivateStorage {
		var e = x.firstChild();
		return new PrivateStorage( e.nodeName, e.get("xmlns" ), e.firstElement() );
	}
	
}
