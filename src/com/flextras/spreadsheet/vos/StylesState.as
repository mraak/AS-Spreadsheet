package com.flextras.spreadsheet.vos
{
import com.flextras.spreadsheet.core.spreadsheet;

import flash.events.Event;

import flashx.textLayout.formats.TextAlign;
import flashx.textLayout.formats.VerticalAlign;

use namespace spreadsheet;

//----------------------------------
//  Events
//----------------------------------

/**
 *
 */
[Event(name="borderChanged", type="flash.events.Event")]

[RemoteClass]
/**
 *
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
	 * @param horizontalAlign
	 * @param verticalAlign
	 * @param size
	 * @param border
	 *
	 */
	public function StylesState(color : uint = 0,
								alpha : Number = 1,
								backgroundColor : uint = 0xFFFFFF,
								backgroundAlpha : Number = 1,
								bold : Boolean = false,
								italic : Boolean = false,
								underline : Boolean = false,
								horizontalAlign : String = TextAlign.CENTER,
								verticalAlign : String = VerticalAlign.MIDDLE,
								size : Number = 14,
								border : Border = null)
	{
		super(color, alpha, backgroundColor, backgroundAlpha, bold, italic, underline, horizontalAlign, verticalAlign, size);
		
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
	 *
	 */
	protected const _border : Border = new Border;
	
	[Bindable(event="borderChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get border() : Border
	{
		return _border;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set border(value : Border) : void
	{
		if (!value || _border === value)
			return;
		
		_border.assign(value);
		
		dispatchEvent(new Event("borderChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set borderObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Border)
			border = Border(value);
		else
		{
			_border.assignObject(value);
			
			dispatchEvent(new Event("borderChanged"));
		}
	}
	
	//----------------------------------
	//  global
	//----------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	override spreadsheet function set global(value : Styles) : void
	{
		super.global = value;
		
		if (value)
		{
			if (value is StylesState)
				_border.global = StylesState(value)._border;
		}
		else
			_border.global = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	override public function assign(value : Styles) : void
	{
		if (!value)
			return;
		
		super.assign(value);
		
		if (value is StylesState)
			border = StylesState(value).border;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	override public function assignObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is StylesState)
		{
			assign(StylesState(value));
			
			return;
		}
		
		super.assignObject(value);
		
		if (value.hasOwnProperty("border"))
			borderObject = value.border;
	}
	
	/**
	 *
	 *
	 */
	override spreadsheet function release() : void
	{
		super.release();
		
		global = null;
	}
}
}