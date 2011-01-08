package com.flextras.spreadsheet.vos
{
import com.flextras.spreadsheet.core.spreadsheet;

import flash.events.Event;
import flash.events.EventDispatcher;

use namespace spreadsheet;

//----------------------------------
//  Events
//----------------------------------

/**
 * Dispatched when color property gets changed.
 */
[Event(name="colorChanged", type="flash.events.Event")]

/**
 * Dispatched when alpha property gets changed.
 */
[Event(name="alphaChanged", type="flash.events.Event")]

/**
 * Dispatched when backgroundColor property gets changed.
 */
[Event(name="backgroundColorChanged", type="flash.events.Event")]

/**
 * Dispatched when backgroundAlpha property gets changed.
 */
[Event(name="backgroundAlphaChanged", type="flash.events.Event")]

/**
 * Dispatched when bold property gets changed.
 */
[Event(name="boldChanged", type="flash.events.Event")]

/**
 * Dispatched when italic property gets changed.
 */
[Event(name="italicChanged", type="flash.events.Event")]

/**
 * Dispatched when underline property gets changed.
 */
[Event(name="underlineChanged", type="flash.events.Event")]

/**
 * Dispatched when font property gets changed.
 */
[Event(name="fontChanged", type="flash.events.Event")]

/**
 * Dispatched when horizontalAlign property gets changed.
 */
[Event(name="horizontalAlignChanged", type="flash.events.Event")]

/**
 * Dispatched when verticalAlign property gets changed.
 */
[Event(name="verticalAlignChanged", type="flash.events.Event")]

/**
 * Dispatched when size property gets changed.
 */
[Event(name="sizeChanged", type="flash.events.Event")]

[RemoteClass]
/**
 * Styles class provides common api for setting the styles on current state.
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
		horizontalAlign : String = "center",
		verticalAlign : String = "middle",
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
	 * @private
	 */
	private var _alpha : Number = 1;
	
	/**
	 * @private
	 */
	protected var alphaChanged : Boolean;
	
	[Bindable(event="alphaChanged")]
	/**
	 * Sets alpha style on cell.
	 * It also dispathes an event.
	 */
	public function get alpha () : Number
	{
		return alphaChanged || !global ? _alpha : global.alpha;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _backgroundAlpha : Number = 1;
	
	/**
	 * @private
	 */
	protected var backgroundAlphaChanged : Boolean;
	
	[Bindable(event="backgroundAlphaChanged")]
	/**
	 * Sets backgroundAlpha style on cell.
	 * It also dispathes an event.
	 */
	public function get backgroundAlpha () : Number
	{
		return backgroundAlphaChanged || !global ? _backgroundAlpha : global.backgroundAlpha;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _backgroundColor : uint = 0xFFFFFF;
	
	/**
	 * @private
	 */
	protected var backgroundColorChanged : Boolean;
	
	[Bindable(event="backgroundColorChanged")]
	/**
	 * Sets backgroundColor style on cell.
	 * It also dispathes an event.
	 */
	public function get backgroundColor () : uint
	{
		return backgroundColorChanged || !global ? _backgroundColor : global.backgroundColor;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _bold : Boolean;
	
	/**
	 * @private
	 */
	protected var boldChanged : Boolean;
	
	[Bindable(event="boldChanged")]
	/**
	 * Sets bold style on cell.
	 * It also dispathes an event.
	 */
	public function get bold () : Boolean
	{
		return boldChanged || !global ? _bold : global.bold;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _color : uint;
	
	/**
	 * @private
	 */
	protected var colorChanged : Boolean;
	
	[Bindable(event="colorChanged")]
	/**
	 * Sets color style on cell.
	 * It also dispathes an event.
	 */
	public function get color () : uint
	{
		return colorChanged || !global ? _color : global.color;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _font : String = "arial";
	
	/**
	 * @private
	 */
	protected var fontChanged : Boolean;
	
	[Bindable(event="fontChanged")]
	/**
	 * Sets font style on cell.
	 * It also dispathes an event.
	 */
	public function get font () : String
	{
		return fontChanged || !global ? _font : global.font;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _global : Styles;
	
	/**
	 * @private
	 */
	spreadsheet function get global () : Styles
	{
		return _global;
	}
	
	/**
	 * Sets global styles on cell.
	 *
	 * @param value
	 * @private
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
	 * @private
	 */
	private var _horizontalAlign : String = "center";
	
	/**
	 * @private
	 */
	protected var horizontalAlignChanged : Boolean;
	
	[Bindable(event="horizontalAlignChanged")]
	/**
	 * Sets horizontalAlign style on cell.
	 * It also dispathes an event.
	 */
	public function get horizontalAlign () : String
	{
		return horizontalAlignChanged || !global ? _horizontalAlign : global.horizontalAlign;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _italic : Boolean;
	
	/**
	 * @private
	 */
	protected var italicChanged : Boolean;
	
	[Bindable(event="italicChanged")]
	/**
	 * Sets italic style on cell.
	 * It also dispathes an event.
	 */
	public function get italic () : Boolean
	{
		return italicChanged || !global ? _italic : global.italic;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _size : uint = 14;
	
	/**
	 * @private
	 */
	protected var sizeChanged : Boolean;
	
	[Bindable(event="sizeChanged")]
	/**
	 * Sets size style on cell.
	 * It also dispathes an event.
	 */
	public function get size () : uint
	{
		return sizeChanged || !global ? _size : global.size;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _underline : Boolean;
	
	/**
	 * @private
	 */
	protected var underlineChanged : Boolean;
	
	[Bindable(event="underlineChanged")]
	/**
	 * Sets underline style on cell.
	 * It also dispathes an event.
	 */
	public function get underline () : Boolean
	{
		return underlineChanged || !global ? _underline : global.underline;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _verticalAlign : String = "middle";
	
	/**
	 * @private
	 */
	protected var verticalAlignChanged : Boolean;
	
	[Bindable(event="verticalAlignChanged")]
	/**
	 * Sets verticalAlign style on cell.
	 * It also dispathes an event.
	 */
	public function get verticalAlign () : String
	{
		return verticalAlignChanged || !global ? _verticalAlign : global.verticalAlign;
	}
	
	/**
	 * @private
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
	 * Provides convenient way to replace all current styles with new ones.
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
	 * Accepts either Object or Styles.
	 * If value is typed or Styles then this setter behaves the same as regular assign otherwise it changes only the provided styles.
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
	 * @private
	 */
	protected function dispatchAlphaChangedEvent () : void
	{
		dispatchEvent (new Event ("alphaChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchBackgroundAlphaChangedEvent () : void
	{
		dispatchEvent (new Event ("backgroundAlphaChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchBackgroundColorChangedEvent () : void
	{
		dispatchEvent (new Event ("backgroundColorChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchBoldChangedEvent () : void
	{
		dispatchEvent (new Event ("boldChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchColorChangedEvent () : void
	{
		dispatchEvent (new Event ("colorChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchFontChangedEvent () : void
	{
		dispatchEvent (new Event ("fontChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchHorizontalAlignChangedEvent () : void
	{
		dispatchEvent (new Event ("horizontalAlignChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchItalicChangedEvent () : void
	{
		dispatchEvent (new Event ("italicChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchSizeChangedEvent () : void
	{
		dispatchEvent (new Event ("sizeChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchUnderlineChangedEvent () : void
	{
		dispatchEvent (new Event ("underlineChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchVerticalAlignChangedEvent () : void
	{
		dispatchEvent (new Event ("verticalAlignChanged"));
	}
	
	/**
	 * @private
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
	 * @private
	 */
	protected function global_colorChangedHandler (e : Event) : void
	{
		dispatchColorChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_alphaChangedHandler (e : Event) : void
	{
		dispatchAlphaChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_backgroundColorChangedHandler (e : Event) : void
	{
		dispatchBackgroundColorChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_backgroundAlphaChangedHandler (e : Event) : void
	{
		dispatchBackgroundAlphaChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_boldChangedHandler (e : Event) : void
	{
		dispatchBoldChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_italicChangedHandler (e : Event) : void
	{
		dispatchItalicChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_underlineChangedHandler (e : Event) : void
	{
		dispatchUnderlineChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_fontChangedHandler (e : Event) : void
	{
		dispatchFontChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_horizontalAlignChangedHandler (e : Event) : void
	{
		dispatchHorizontalAlignChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_verticalAlignChangedHandler (e : Event) : void
	{
		dispatchVerticalAlignChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_sizeChangedHandler (e : Event) : void
	{
		dispatchSizeChangedEvent ();
	}
}
}