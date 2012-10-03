package uk.co.currentlabel.spreadsheet.context
{
import uk.co.currentlabel.spreadsheet.vos.Cell;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;

//----------------------------------
//  Events
//----------------------------------

/**
 * Dispatched when allowPaste property gets changed.
 */
[Event(name="allowPasteChanged", type="flash.events.Event")]

/**
 * Custom clipboard used by Spreadsheet.
 */
final public class ClipboardData extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Singleton instance of this class.
	 */
	public static const instance : ClipboardData = new ClipboardData;
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Tells whether user is performing an copy action.
	 */
	public var copy : Boolean;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  range
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _range : Vector.<Cell>;
	
	/**
	 * Selected cells
	 */
	public function get range () : Vector.<Cell>
	{
		return _range;
	}
	
	/**
	 * @private
	 */
	public function set range (value : Vector.<Cell>) : void
	{
		if (range === value)
			return;
		
		_range = value;
		
		allowPaste = value && value.length > 0;
	}
	
	//----------------------------------
	//  allowPaste
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _allowPaste : Boolean;
	
	/**
	 * Tells whether user is allowed performing an paste action.
	 */
	public function get allowPaste () : Boolean
	{
		return _allowPaste;
	}
	
	/**
	 * @private
	 */
	public function set allowPaste (value : Boolean) : void
	{
		if (allowPaste == value)
			return;
		
		_allowPaste = value;
		
		dispatchEvent (new Event ("allowPasteChanged"));
	}

}
}