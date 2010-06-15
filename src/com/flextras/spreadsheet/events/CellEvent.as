package com.flextras.spreadsheet.events
{
import flash.events.Event;

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
	public var data : CellEventData;
	
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
	public function CellEvent(type : String, data : CellEventData)
	{
		super(type);
		
		this.data = data;
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
		return new CellEvent(type, data);
	}
}
}