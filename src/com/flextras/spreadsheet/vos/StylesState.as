package com.flextras.spreadsheet.vos
{
import com.flextras.spreadsheet.core.spreadsheet;

import flash.events.Event;

use namespace spreadsheet;

//----------------------------------
//  Events
//----------------------------------

/**
 * Dispatched when border or borderObject property gets changed.
 */
[Event(name="borderChanged", type="flash.events.Event")]

[RemoteClass]
/**
 * StylesState class provides support for border on current state.
 *
 * @see com.flextras.spreadsheet.vos.CellStyles
 */
public class StylesState extends Styles
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 *
	 * @param color
	 * @param alpha
	 * @param backgroundColor
	 * @param backgroundAlpha
	 * @param bold
	 * @param italic
	 * @param underline
	 * @param font
	 * @param horizontalAlign
	 * @param verticalAlign
	 * @param size
	 * @param border
	 *
	 */
	public function StylesState (color : uint = 0,
		alpha : Number = 1,
		backgroundColor : uint = 0xFFFFFF,
		backgroundAlpha : Number = 1,
		bold : Boolean = false,
		italic : Boolean = false,
		underline : Boolean = false,
		font : String = "arial",
		horizontalAlign : String = "center",
		verticalAlign : String = "middle",
		size : Number = 14,
		border : Border = null)
	{
		super (color, alpha, backgroundColor, backgroundAlpha, bold, italic, underline, font, horizontalAlign, verticalAlign, size);
		
		this.border = border;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  border
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _border : Border = new Border;
	
	[Bindable(event="borderChanged")]
	/**
	 * Replaces current border styles with new ones.
	 * It also dispathes an event.
	 */
	public function get border () : Border
	{
		return _border;
	}
	
	/**
	 * @private
	 */
	public function set border (value : Border) : void
	{
		if (border === value)
			return;
		
		border.assign (value);
		
		dispatchEvent (new Event ("borderChanged"));
	}
	
	[Transient]
	/**
	 * Accepts either Object or Border.
	 * If value is typed as Border then this setter behaves the same as regular setter otherwise it changes only the provided styles.
	 * It also dispathes an event.
	 *
	 * @param value
	 *
	 */
	public function set borderObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Border)
			border = Border (value);
		else
		{
			border.assignObject (value);
			
			dispatchEvent (new Event ("borderChanged"));
		}
	}
	
	//----------------------------------
	//  global
	//----------------------------------
	
	/**
	 * Sets global styles both on cell and border.
	 *
	 * @param value
	 * @private
	 */
	override spreadsheet function set global (value : Styles) : void
	{
		super.global = value;
		
		if (value)
		{
			if (value is StylesState)
				border.global = StylesState (value).border;
		}
		else
			border.global = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Provides convenient way to replace all current styles with new ones.
	 *
	 * @param value
	 *
	 */
	override public function assign (value : Styles) : void
	{
		if (!value)
			return;
		
		super.assign (value);
		
		if (value is StylesState)
			border = StylesState (value).border;
	}
	
	/**
	 * Accepts either Object or StylesState or Styles.
	 * If value is typed as StylesState or Styles then this setter behaves the same as regular assign otherwise it changes only the provided styles.
	 *
	 * @param value
	 *
	 */
	override public function assignObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is StylesState)
		{
			assign (StylesState (value));
			
			return;
		}
		
		super.assignObject (value);
		
		if (value.hasOwnProperty ("border"))
			borderObject = value.border;
	}
	
	/**
	 * @private
	 */
	override spreadsheet function release () : void
	{
		super.release ();
		
		global = null;
	}
}
}