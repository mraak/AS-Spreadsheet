package com.flextras.spreadsheet.events
{
import flash.events.Event;

/**
 *
 *
 */
public class ColumnEvent extends Event
{
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  actions
	//----------------------------------
	
	/**
	 *
	 */
	public static const INSERT : String = "com.flextras.spreadsheet.events.ColumnEvent::INSERT";
	
	/**
	 *
	 */
	public static const REMOVE : String = "com.flextras.spreadsheet.events.ColumnEvent::REMOVE";
	
	/**
	 *
	 */
	public static const RESIZE : String = "com.flextras.spreadsheet.events.ColumnEvent::RESIZE";
	
	/**
	 *
	 */
	public static const CLEAR : String = "com.flextras.spreadsheet.events.ColumnEvent::CLEAR";
	
	//----------------------------------
	//  notifiers
	//----------------------------------
	
	/**
	 *
	 */
	public static const BEFORE_INSERTED : String = "com.flextras.spreadsheet.events.ColumnEvent::BEFORE_INSERTED";
	public static const INSERTED : String = "com.flextras.spreadsheet.events.ColumnEvent::INSERTED";
	
	/**
	 *
	 */
	public static const BEFORE_REMOVED : String = "com.flextras.spreadsheet.events.ColumnEvent::BEFORE_REMOVED";
	public static const REMOVED : String = "com.flextras.spreadsheet.events.ColumnEvent::REMOVED";
	
	/**
	 *
	 */
	public static const BEFORE_RESIZED : String = "com.flextras.spreadsheet.events.ColumnEvent::BEFORE_RESIZED";
	public static const RESIZED : String = "com.flextras.spreadsheet.events.ColumnEvent::RESIZED";
	
	/**
	 *
	 */
	public static const BEFORE_CLEARED : String = "com.flextras.spreadsheet.events.ColumnEvent::BEFORE_CLEARED";
	public static const CLEARED : String = "com.flextras.spreadsheet.events.ColumnEvent::CLEARED";
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 */
	public var index : uint;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 *
	 * @param type
	 * @param index
	 *
	 */
	public function ColumnEvent(type : String, index : uint)
	{
		super(type);
		
		this.index = index;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @return
	 *
	 */
	override public function clone() : Event
	{
		return new ColumnEvent(type, index);
	}
}
}