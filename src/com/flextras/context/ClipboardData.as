package com.flextras.context
{
import flash.geom.Point;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

[RemoteClass]
final public class ClipboardData implements IExternalizable
{
	private var _range : Array;
	
	public function get range () : Array
	{
		return _range;
	}
	
	public function set range (value : Array) : void
	{
		if (_range === value)
			return;
		
		_range = value;
		
		allowPaste = value && value.length > 0;
	}
	
	public var location : Point;
	
	public var performCopy : Boolean;
	
	public var allowPaste : Boolean;
	
	public function writeExternal (output : IDataOutput) : void
	{
		output.writeObject({x: location.x, y: location.y, copy: performCopy, paste: allowPaste, range: range});
	}
	
	public function readExternal (input : IDataInput) : void
	{
		var data : Object = input.readObject();
		
		location = new Point(data.x, data.y);
		performCopy = data.copy;
		allowPaste = data.paste;
		_range = data.range;
	}
}
}