package com.flextras.spreadsheet.events
{
import flash.events.Event;

/**
 * Only reason we used event instead of directly calling the required function is that user can prevent executing the actions.
 */
public class RowEvent extends Event
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
	 * Dispatched when user wants to insert the row.
	 */
	public static const INSERT : String = "com.flextras.spreadsheet.events.RowEvent::INSERT";
	
	/**
	 * Dispatched when user wants to remove the row.
	 */
	public static const REMOVE : String = "com.flextras.spreadsheet.events.RowEvent::REMOVE";
	
	/**
	 * Dispatched when user wants to clear the row.
	 */
	public static const CLEAR : String = "com.flextras.spreadsheet.events.RowEvent::CLEAR";
	
	//----------------------------------
	//  notifiers
	//----------------------------------
	
	/**
	 * Dispatched after the row was inserted.
	 */
	public static const INSERTED : String = "com.flextras.spreadsheet.events.RowEvent::INSERTED";
	
	/**
	 * Dispatched after the row was removed.
	 */
	public static const REMOVED : String = "com.flextras.spreadsheet.events.RowEvent::REMOVED";
	
	/**
	 * Dispatched after the row was cleared.
	 */
	public static const CLEARED : String = "com.flextras.spreadsheet.events.RowEvent::CLEARED";
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Index of row where an action should occur.
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
	 * @param type Event type.
	 * @param index Index of row where an action should occur.
	 *
	 */
	public function RowEvent (type : String, index : uint)
	{
		super (type);
		
		this.index = index;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override public function clone () : Event
	{
		return new RowEvent (type, index);
	}
}
}