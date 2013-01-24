
////////////////////////////////////////////////////////////////////////////////
//  
//  Copyright 2012 Alen Balja
//  All Rights Reserved.
//
//  See the file license.txt for copying permission.
//
////////////////////////////////////////////////////////////////////////////////


package uk.co.currentlabel.spreadsheet.events
{
import flash.events.Event;
import flash.geom.Rectangle;

/**
 * Only reason we used event instead of directly calling the required function is that user can prevent spanning if criteria isn't met.
 */
public class CellEvent extends Event
{
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Dispatched when user sets column | row span on selected cell.
	 */
	public static const RESIZE : String = "uk.co.currentlabel.spreadsheet.events.CellEvent::RESIZE";
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Amount contains new cell boundaries. x represents column index, y row index, width column span and height the number of rows it spans - starting with 0, which means it doesn't span at all.
	 */
	public var amount : Rectangle;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 *
	 * @param type Event type.
	 * @param data Amount contains new cell boundaries.
	 */
	public function CellEvent (type : String, amount : Rectangle)
	{
		super (type);
		
		this.amount = amount;
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
		return new CellEvent (type, amount);
	}
}
}