package com.flextras.spreadsheet.context
{
import com.flextras.spreadsheet.vos.Cell;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;

final public class ClipboardData extends EventDispatcher
{
	public static const instance : ClipboardData = new ClipboardData;
	
	protected var _range : Vector.<Cell>;
	
	public function get range() : Vector.<Cell>
	{
		return _range;
	}
	
	public function set range(value : Vector.<Cell>) : void
	{
		if (_range === value)
			return;
		
		_range = value;
		
		allowPaste = value && value.length > 0;
	}
	
	protected var _allowPaste : Boolean;
	
	public function get allowPaste() : Boolean
	{
		return _allowPaste;
	}
	
	public function set allowPaste(value : Boolean) : void
	{
		if (_allowPaste == value)
			return;
		
		_allowPaste = value;
		
		dispatchEvent(new Event("allowPasteChanged"));
	}

}
}