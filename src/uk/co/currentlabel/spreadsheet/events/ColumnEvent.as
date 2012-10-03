package uk.co.currentlabel.spreadsheet.events
{
import flash.events.Event;

/**
 * Only reason we used event instead of directly calling the required function is that user can prevent executing the actions.
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
	 * Dispatched when user wants to insert the column.
	 */
	public static const INSERT : String = "insertColumn";
	
	/**
	 * Dispatched when user wants to remove the column.
	 */
	public static const REMOVE : String = "removeColumn";
	
	/**
	 * Dispatched when user wants to clear the column.
	 */
	public static const CLEAR : String = "clearColumn";
	
	//----------------------------------
	//  notifiers
	//----------------------------------
	
	/**
	 * Dispatched after the column was inserted.
	 */
	public static const INSERTED : String = "columnInserted";
	
	/**
	 * Dispatched after the column was removed.
	 */
	public static const REMOVED : String = "columnRemoved";
	
	/**
	 * Dispatched after the column was cleared.
	 */
	public static const CLEARED : String = "columnCleared";
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Index of column where an action should occur.
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
	 * @param index Index of column where an action should occur.
	 *
	 */
	public function ColumnEvent (type : String, index : uint)
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
		return new ColumnEvent (type, index);
	}
}
}