package uk.co.currentlabel.spreadsheet.events
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
	public static const INSERT : String = "insertRow";
	
	/**
	 * Dispatched when user wants to remove the row.
	 */
	public static const REMOVE : String = "removeRow";
	
	/**
	 * Dispatched when user wants to clear the row.
	 */
	public static const CLEAR : String = "clearRow";
	
	//----------------------------------
	//  notifiers
	//----------------------------------
	
	/**
	 * Dispatched after the row was inserted.
	 */
	public static const INSERTED : String = "rowInserted";
	
	/**
	 * Dispatched after the row was removed.
	 */
	public static const REMOVED : String = "rowRemoved";
	
	/**
	 * Dispatched after the row was cleared.
	 */
	public static const CLEARED : String = "rowCleared";
	
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