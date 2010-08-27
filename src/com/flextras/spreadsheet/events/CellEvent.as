package com.flextras.spreadsheet.events
{
import flash.events.Event;
import flash.geom.Rectangle;

/**
 *
 *
 */
public class CellEvent extends Event
{
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 */
	public static const UPDATE : String = "com.flextras.spreadsheet.events.CellEvent::UPDATE";
	
	/**
	 *
	 */
	public static const RESIZE : String = "com.flextras.spreadsheet.events.CellEvent::RESIZE";
	
	/**
	 *
	 */
	public static const CLEAR : String = "com.flextras.spreadsheet.events.CellEvent::CLEAR";
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
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
	 * @param type
	 * @param data
	 *
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
	 *
	 * @return
	 *
	 */
	override public function clone () : Event
	{
		return new CellEvent (type, amount);
	}
}
}