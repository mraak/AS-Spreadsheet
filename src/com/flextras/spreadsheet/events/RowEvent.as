package com.flextras.spreadsheet.events
{
import flash.events.Event;

public class RowEvent extends Event
{
	public static const INSERT : String = "com.flextras.spreadsheet.events.RowEvent::INSERT";
	public static const REMOVE : String = "com.flextras.spreadsheet.events.RowEvent::REMOVE";
	public static const RESIZE : String = "com.flextras.spreadsheet.events.RowEvent::RESIZE";
	public static const CLEAR : String = "com.flextras.spreadsheet.events.RowEvent::CLEAR";
	
	public static const INSERTED : String = "com.flextras.spreadsheet.events.RowEvent::INSERTED";
	public static const REMOVED : String = "com.flextras.spreadsheet.events.RowEvent::REMOVED";
	public static const RESIZED : String = "com.flextras.spreadsheet.events.RowEvent::RESIZED";
	public static const CLEARED : String = "com.flextras.spreadsheet.events.RowEvent::CLEARED";
	
	public var index : uint;
	
	public function RowEvent(type : String, index : uint)
	{
		super(type);
		
		this.index = index;
	}
	
	override public function clone() : Event
	{
		return new RowEvent(type, index);
	}
}
}