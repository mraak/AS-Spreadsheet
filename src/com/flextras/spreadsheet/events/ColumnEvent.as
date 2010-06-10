package com.flextras.spreadsheet.events
{
import flash.events.Event;

public class ColumnEvent extends Event
{
	public static const INSERT : String = "com.flextras.spreadsheet.events.ColumnEvent::INSERT";
	public static const REMOVE : String = "com.flextras.spreadsheet.events.ColumnEvent::REMOVE";
	public static const RESIZE : String = "com.flextras.spreadsheet.events.ColumnEvent::RESIZE";
	public static const CLEAR : String = "com.flextras.spreadsheet.events.ColumnEvent::CLEAR";
	
	public static const INSERTED : String = "com.flextras.spreadsheet.events.ColumnEvent::INSERTED";
	public static const REMOVED : String = "com.flextras.spreadsheet.events.ColumnEvent::REMOVED";
	public static const RESIZED : String = "com.flextras.spreadsheet.events.ColumnEvent::RESIZED";
	public static const CLEARED : String = "com.flextras.spreadsheet.events.ColumnEvent::CLEARED";
	
	public var index : uint;
	
	public function ColumnEvent(type : String, index : uint)
	{
		super(type);
		
		this.index = index;
	}
	
	override public function clone() : Event
	{
		return new ColumnEvent(type, index);
	}
}
}