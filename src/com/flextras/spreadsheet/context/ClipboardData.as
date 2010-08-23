package com.flextras.spreadsheet.context
{
import com.flextras.spreadsheet.vos.Cell;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;

final public class ClipboardData extends EventDispatcher
{
	public static const instance : ClipboardData = new ClipboardData;
	
	private var _range : Vector.<Cell>;
	
	public var copy : Boolean;
	
	public function get range () : Vector.<Cell>
	{
		return _range;
	}
	
	public function set range (value : Vector.<Cell>) : void
	{
		if (range === value)
			return;
		
		_range = value;
		
		allowPaste = value && value.length > 0;
	}
	
	private var _allowPaste : Boolean;
	
	public function get allowPaste () : Boolean
	{
		return _allowPaste;
	}
	
	public function set allowPaste (value : Boolean) : void
	{
		if (allowPaste == value)
			return;
		
		_allowPaste = value;
		
		dispatchEvent (new Event ("allowPasteChanged"));
	}

}
}