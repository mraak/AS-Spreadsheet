package com.flextras.spreadsheet.vos
{
import com.flextras.spreadsheet.core.spreadsheet;

import flash.events.Event;
import flash.events.EventDispatcher;

import flashx.textLayout.formats.TextAlign;
import flashx.textLayout.formats.VerticalAlign;

use namespace spreadsheet;

//----------------------------------
//  Events
//----------------------------------

/**
 *
 */
[Event(name="colorChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="alphaChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="backgroundColorChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="backgroundAlphaChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="boldChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="italicChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="underlineChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="fontChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="horizontalAlignChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="verticalAlignChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="sizeChanged", type="flash.events.Event")]

[RemoteClass]
/**
 *
 */
public class Styles extends EventDispatcher
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
	 *
	 */
	public function Styles (color : uint = 0,
		alpha : Number = 1,
		backgroundColor : uint = 0xFFFFFF,
		backgroundAlpha : Number = 1,
		bold : Boolean = false,
		italic : Boolean = false,
		underline : Boolean = false,
		font : String = "arial",
		horizontalAlign : String = TextAlign.CENTER,
		verticalAlign : String = VerticalAlign.MIDDLE,
		size : Number = 14)
	{
		this.color = color;
		this.alpha = alpha;
		this.backgroundColor = backgroundColor;
		this.backgroundAlpha = backgroundAlpha;
		this.bold = bold;
		this.italic = italic;
		this.underline = underline;
		this.font = font;
		this.horizontalAlign = horizontalAlign;
		this.verticalAlign = verticalAlign;
		this.size = size;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  alpha
	//----------------------------------
	
	/**
	 *
	 */
	private var _alpha : Number = 1;
	
	protected var alphaChanged : Boolean;
	
	[Bindable(event="alphaChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get alpha () : Number
	{
		return alphaChanged || !global ? _alpha : global.alpha;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set alpha (value : Number) : void
	{
		if (alpha == value)
			return;
		
		_alpha = value;
		
		alphaChanged = true;
		
		dispatchAlphaChangedEvent ();
	}
	
	//----------------------------------
	//  backgroundAlpha
	//----------------------------------
	
	/**
	 *
	 */
	private var _backgroundAlpha : Number = 1;
	
	protected var backgroundAlphaChanged : Boolean;
	
	[Bindable(event="backgroundAlphaChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get backgroundAlpha () : Number
	{
		return backgroundAlphaChanged || !global ? _backgroundAlpha : global.backgroundAlpha;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set backgroundAlpha (value : Number) : void
	{
		if (backgroundAlpha == value)
			return;
		
		_backgroundAlpha = value;
		
		backgroundAlphaChanged = true;
		
		dispatchBackgroundAlphaChangedEvent ();
	}
	
	//----------------------------------
	//  backgroundColor
	//----------------------------------
	
	/**
	 *
	 */
	private var _backgroundColor : uint = 0xFFFFFF;
	
	protected var backgroundColorChanged : Boolean;
	
	[Bindable(event="backgroundColorChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get backgroundColor () : uint
	{
		return backgroundColorChanged || !global ? _backgroundColor : global.backgroundColor;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set backgroundColor (value : uint) : void
	{
		if (backgroundColor == value)
			return;
		
		_backgroundColor = value;
		
		backgroundColorChanged = true;
		
		dispatchBackgroundColorChangedEvent ();
	}
	
	//----------------------------------
	//  bold
	//----------------------------------
	
	/**
	 *
	 */
	private var _bold : Boolean;
	
	protected var boldChanged : Boolean;
	
	[Bindable(event="boldChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get bold () : Boolean
	{
		return boldChanged || !global ? _bold : global.bold;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set bold (value : Boolean) : void
	{
		if (bold == value)
			return;
		
		_bold = value;
		
		boldChanged = true;
		
		dispatchBoldChangedEvent ();
	}
	
	//----------------------------------
	//  color
	//----------------------------------
	
	/**
	 *
	 */
	private var _color : uint;
	
	protected var colorChanged : Boolean;
	
	[Bindable(event="colorChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get color () : uint
	{
		return colorChanged || !global ? _color : global.color;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set color (value : uint) : void
	{
		if (color == value)
			return;
		
		_color = value;
		
		colorChanged = true;
		
		dispatchColorChangedEvent ();
	}
	
	//----------------------------------
	//  font
	//----------------------------------
	
	/**
	 *
	 */
	private var _font : String = "arial";
	
	protected var fontChanged : Boolean;
	
	[Bindable(event="fontChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get font () : String
	{
		return fontChanged || !global ? _font : global.font;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set font (value : String) : void
	{
		if (font == value)
			return;
		
		_font = value;
		
		fontChanged = true;
		
		dispatchFontChangedEvent ();
	}
	
	//----------------------------------
	//  global
	//----------------------------------
	
	/**
	 *
	 */
	private var _global : Styles;
	
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get global () : Styles
	{
		return _global;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set global (value : Styles) : void
	{
		if (global === value)
			return;
		
		if (global)
		{
			global.removeEventListener ("colorChanged", global_colorChangedHandler);
			global.removeEventListener ("alphaChanged", global_alphaChangedHandler);
			global.removeEventListener ("backgroundColorChanged", global_backgroundColorChangedHandler);
			global.removeEventListener ("backgroundAlphaChanged", global_backgroundAlphaChangedHandler);
			global.removeEventListener ("boldChanged", global_boldChangedHandler);
			global.removeEventListener ("italicChanged", global_italicChangedHandler);
			global.removeEventListener ("underlineChanged", global_underlineChangedHandler);
			global.removeEventListener ("fontChanged", global_fontChangedHandler);
			global.removeEventListener ("horizontalAlignChanged", global_horizontalAlignChangedHandler);
			global.removeEventListener ("verticalAlignChanged", global_verticalAlignChangedHandler);
			global.removeEventListener ("sizeChanged", global_sizeChangedHandler);
		}
		
		_global = value;
		
		if (value)
		{
			value.addEventListener ("colorChanged", global_colorChangedHandler);
			value.addEventListener ("alphaChanged", global_alphaChangedHandler);
			value.addEventListener ("backgroundColorChanged", global_backgroundColorChangedHandler);
			value.addEventListener ("backgroundAlphaChanged", global_backgroundAlphaChangedHandler);
			value.addEventListener ("boldChanged", global_boldChangedHandler);
			value.addEventListener ("italicChanged", global_italicChangedHandler);
			value.addEventListener ("underlineChanged", global_underlineChangedHandler);
			value.addEventListener ("fontChanged", global_fontChangedHandler);
			value.addEventListener ("horizontalAlignChanged", global_horizontalAlignChangedHandler);
			value.addEventListener ("verticalAlignChanged", global_verticalAlignChangedHandler);
			value.addEventListener ("sizeChanged", global_sizeChangedHandler);
		}
	}
	
	//----------------------------------
	//  horizontalAlign
	//----------------------------------
	
	/**
	 *
	 */
	private var _horizontalAlign : String = TextAlign.CENTER;
	
	protected var horizontalAlignChanged : Boolean;
	
	[Bindable(event="horizontalAlignChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get horizontalAlign () : String
	{
		return horizontalAlignChanged || !global ? _horizontalAlign : global.horizontalAlign;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set horizontalAlign (value : String) : void
	{
		if (horizontalAlign == value)
			return;
		
		_horizontalAlign = value;
		
		horizontalAlignChanged = true;
		
		dispatchHorizontalAlignChangedEvent ();
	}
	
	//----------------------------------
	//  italic
	//----------------------------------
	
	/**
	 *
	 */
	private var _italic : Boolean;
	
	protected var italicChanged : Boolean;
	
	[Bindable(event="italicChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get italic () : Boolean
	{
		return italicChanged || !global ? _italic : global.italic;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set italic (value : Boolean) : void
	{
		if (italic == value)
			return;
		
		_italic = value;
		
		italicChanged = true;
		
		dispatchItalicChangedEvent ();
	}
	
	//----------------------------------
	//  size
	//----------------------------------
	
	/**
	 *
	 */
	private var _size : uint = 14;
	
	protected var sizeChanged : Boolean;
	
	[Bindable(event="sizeChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get size () : uint
	{
		return sizeChanged || !global ? _size : global.size;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set size (value : uint) : void
	{
		if (size == value)
			return;
		
		_size = value;
		
		sizeChanged = true;
		
		dispatchSizeChangedEvent ();
	}
	
	//----------------------------------
	//  underline
	//----------------------------------
	
	/**
	 *
	 */
	private var _underline : Boolean;
	
	protected var underlineChanged : Boolean;
	
	[Bindable(event="underlineChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get underline () : Boolean
	{
		return underlineChanged || !global ? _underline : global.underline;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set underline (value : Boolean) : void
	{
		if (underline == value)
			return;
		
		_underline = value;
		
		underlineChanged = true;
		
		dispatchUnderlineChangedEvent ();
	}
	
	//----------------------------------
	//  verticalAlign
	//----------------------------------
	
	/**
	 *
	 */
	private var _verticalAlign : String = VerticalAlign.MIDDLE;
	
	protected var verticalAlignChanged : Boolean;
	
	[Bindable(event="verticalAlignChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get verticalAlign () : String
	{
		return verticalAlignChanged || !global ? _verticalAlign : global.verticalAlign;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set verticalAlign (value : String) : void
	{
		if (verticalAlign == value)
			return;
		
		_verticalAlign = value;
		
		verticalAlignChanged = true;
		
		dispatchVerticalAlignChangedEvent ();
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
	public function assign (value : Styles) : void
	{
		if (!value)
			return;
		
		color = value.color;
		alpha = value.alpha;
		backgroundColor = value.backgroundColor;
		backgroundAlpha = value.backgroundAlpha;
		bold = value.bold;
		italic = value.italic;
		underline = value.underline;
		font = value.font;
		horizontalAlign = value.horizontalAlign;
		verticalAlign = value.verticalAlign;
		size = value.size;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function assignObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Styles)
		{
			assign (Styles (value));
			
			return;
		}
		
		if (value.hasOwnProperty ("color"))
			color = uint (value.color);
		
		if (value.hasOwnProperty ("alpha"))
			alpha = Number (value.alpha);
		
		if (value.hasOwnProperty ("backgroundColor"))
			backgroundColor = uint (value.backgroundColor);
		
		if (value.hasOwnProperty ("backgroundAlpha"))
			backgroundAlpha = Number (value.backgroundAlpha);
		
		if (value.hasOwnProperty ("bold"))
			bold = Boolean (value.bold);
		
		if (value.hasOwnProperty ("italic"))
			italic = Boolean (value.italic);
		
		if (value.hasOwnProperty ("underline"))
			underline = Boolean (value.underline);
		
		if (value.hasOwnProperty ("font"))
			font = String (value.font);
		
		if (value.hasOwnProperty ("horizontalAlign"))
			horizontalAlign = String (value.horizontalAlign);
		
		if (value.hasOwnProperty ("verticalAlign"))
			verticalAlign = String (value.verticalAlign);
		
		if (value.hasOwnProperty ("size"))
			size = uint (value.size);
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchAlphaChangedEvent () : void
	{
		dispatchEvent (new Event ("alphaChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchBackgroundAlphaChangedEvent () : void
	{
		dispatchEvent (new Event ("backgroundAlphaChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchBackgroundColorChangedEvent () : void
	{
		dispatchEvent (new Event ("backgroundColorChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchBoldChangedEvent () : void
	{
		dispatchEvent (new Event ("boldChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchColorChangedEvent () : void
	{
		dispatchEvent (new Event ("colorChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchFontChangedEvent () : void
	{
		dispatchEvent (new Event ("fontChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchHorizontalAlignChangedEvent () : void
	{
		dispatchEvent (new Event ("horizontalAlignChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchItalicChangedEvent () : void
	{
		dispatchEvent (new Event ("italicChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchSizeChangedEvent () : void
	{
		dispatchEvent (new Event ("sizeChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchUnderlineChangedEvent () : void
	{
		dispatchEvent (new Event ("underlineChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchVerticalAlignChangedEvent () : void
	{
		dispatchEvent (new Event ("verticalAlignChanged"));
	}
	
	/**
	 *
	 *
	 */
	spreadsheet function release () : void
	{
		global = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_colorChangedHandler (e : Event) : void
	{
		dispatchColorChangedEvent ();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_alphaChangedHandler (e : Event) : void
	{
		dispatchAlphaChangedEvent ();
	}
	
	/**
	 *
	 *
	 */
	protected function global_backgroundColorChangedHandler (e : Event) : void
	{
		dispatchBackgroundColorChangedEvent ();
	}
	
	/**
	 *
	 *
	 */
	protected function global_backgroundAlphaChangedHandler (e : Event) : void
	{
		dispatchBackgroundAlphaChangedEvent ();
	}
	
	/**
	 *
	 *
	 */
	protected function global_boldChangedHandler (e : Event) : void
	{
		dispatchBoldChangedEvent ();
	}
	
	/**
	 *
	 *
	 */
	protected function global_italicChangedHandler (e : Event) : void
	{
		dispatchItalicChangedEvent ();
	}
	
	/**
	 *
	 *
	 */
	protected function global_underlineChangedHandler (e : Event) : void
	{
		dispatchUnderlineChangedEvent ();
	}
	
	/**
	 *
	 *
	 */
	protected function global_fontChangedHandler (e : Event) : void
	{
		dispatchFontChangedEvent ();
	}
	
	/**
	 *
	 *
	 */
	protected function global_horizontalAlignChangedHandler (e : Event) : void
	{
		dispatchHorizontalAlignChangedEvent ();
	}
	
	/**
	 *
	 *
	 */
	protected function global_verticalAlignChangedHandler (e : Event) : void
	{
		dispatchVerticalAlignChangedEvent ();
	}
	
	/**
	 *
	 *
	 */
	protected function global_sizeChangedHandler (e : Event) : void
	{
		dispatchSizeChangedEvent ();
	}
}
}