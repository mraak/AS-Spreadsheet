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
	 * @param horizontalAlign
	 * @param verticalAlign
	 * @param size
	 *
	 */
	public function Styles(color : uint = 0,
						   alpha : Number = 1,
						   backgroundColor : uint = 0xFFFFFF,
						   backgroundAlpha : Number = 1,
						   bold : Boolean = false,
						   italic : Boolean = false,
						   underline : Boolean = false,
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
	//  color
	//----------------------------------
	
	/**
	 *
	 */
	protected var _color : uint;
	
	protected var colorChanged : Boolean;
	
	[Bindable(event="colorChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get color() : uint
	{
		return colorChanged || !_global ? _color : _global._color;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set color(value : uint) : void
	{
		if (color == value)
			return;
		
		_color = value;
		
		colorChanged = true;
		
		dispatchColorChangedEvent();
	}
	
	//----------------------------------
	//  alpha
	//----------------------------------
	
	/**
	 *
	 */
	protected var _alpha : Number = 1;
	
	protected var alphaChanged : Boolean;
	
	[Bindable(event="alphaChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get alpha() : Number
	{
		return alphaChanged || !_global ? _alpha : _global._alpha;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set alpha(value : Number) : void
	{
		if (alpha == value)
			return;
		
		_alpha = value;
		
		alphaChanged = true;
		
		dispatchAlphaChangedEvent();
	}
	
	//----------------------------------
	//  backgroundColor
	//----------------------------------
	
	/**
	 *
	 */
	protected var _backgroundColor : uint = 0xFFFFFF;
	
	protected var backgroundColorChanged : Boolean;
	
	[Bindable(event="backgroundColorChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get backgroundColor() : uint
	{
		return backgroundColorChanged || !_global ? _backgroundColor : _global._backgroundColor;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set backgroundColor(value : uint) : void
	{
		if (backgroundColor == value)
			return;
		
		_backgroundColor = value;
		
		backgroundColorChanged = true;
		
		dispatchBackgroundColorChangedEvent();
	}
	
	//----------------------------------
	//  backgroundAlpha
	//----------------------------------
	
	/**
	 *
	 */
	protected var _backgroundAlpha : Number = 1;
	
	protected var backgroundAlphaChanged : Boolean;
	
	[Bindable(event="backgroundAlphaChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get backgroundAlpha() : Number
	{
		return backgroundAlphaChanged || !_global ? _backgroundAlpha : _global._backgroundAlpha;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set backgroundAlpha(value : Number) : void
	{
		if (backgroundAlpha == value)
			return;
		
		_backgroundAlpha = value;
		
		backgroundAlphaChanged = true;
		
		dispatchBackgroundAlphaChangedEvent();
	}
	
	//----------------------------------
	//  bold
	//----------------------------------
	
	/**
	 *
	 */
	protected var _bold : Boolean;
	
	protected var boldChanged : Boolean;
	
	[Bindable(event="boldChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get bold() : Boolean
	{
		return boldChanged || !_global ? _bold : _global._bold;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set bold(value : Boolean) : void
	{
		if (bold == value)
			return;
		
		_bold = value;
		
		boldChanged = true;
		
		dispatchBoldChangedEvent();
	}
	
	//----------------------------------
	//  italic
	//----------------------------------
	
	/**
	 *
	 */
	protected var _italic : Boolean;
	
	protected var italicChanged : Boolean;
	
	[Bindable(event="italicChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get italic() : Boolean
	{
		return italicChanged || !_global ? _italic : _global._italic;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set italic(value : Boolean) : void
	{
		if (italic == value)
			return;
		
		_italic = value;
		
		italicChanged = true;
		
		dispatchItalicChangedEvent();
	}
	
	//----------------------------------
	//  underline
	//----------------------------------
	
	/**
	 *
	 */
	protected var _underline : Boolean;
	
	protected var underlineChanged : Boolean;
	
	[Bindable(event="underlineChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get underline() : Boolean
	{
		return underlineChanged || !_global ? _underline : _global._underline;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set underline(value : Boolean) : void
	{
		if (underline == value)
			return;
		
		_underline = value;
		
		underlineChanged = true;
		
		dispatchUnderlineChangedEvent();
	}
	
	//----------------------------------
	//  horizontalAlign
	//----------------------------------
	
	/**
	 *
	 */
	protected var _horizontalAlign : String = TextAlign.CENTER;
	
	protected var horizontalAlignChanged : Boolean;
	
	[Bindable(event="horizontalAlignChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get horizontalAlign() : String
	{
		return horizontalAlignChanged || !_global ? _horizontalAlign : _global._horizontalAlign;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set horizontalAlign(value : String) : void
	{
		if (horizontalAlign == value)
			return;
		
		_horizontalAlign = value;
		
		horizontalAlignChanged = true;
		
		dispatchHorizontalAlignChangedEvent();
	}
	
	//----------------------------------
	//  verticalAlign
	//----------------------------------
	
	/**
	 *
	 */
	protected var _verticalAlign : String = VerticalAlign.MIDDLE;
	
	protected var verticalAlignChanged : Boolean;
	
	[Bindable(event="verticalAlignChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get verticalAlign() : String
	{
		return verticalAlignChanged || !_global ? _verticalAlign : _global._verticalAlign;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set verticalAlign(value : String) : void
	{
		if (verticalAlign == value)
			return;
		
		_verticalAlign = value;
		
		verticalAlignChanged = true;
		
		dispatchVerticalAlignChangedEvent();
	}
	
	//----------------------------------
	//  size
	//----------------------------------
	
	/**
	 *
	 */
	protected var _size : uint = 14;
	
	protected var sizeChanged : Boolean;
	
	[Bindable(event="sizeChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get size() : uint
	{
		return sizeChanged || !_global ? _size : _global._size;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set size(value : uint) : void
	{
		if (size == value)
			return;
		
		_size = value;
		
		sizeChanged = true;
		
		dispatchSizeChangedEvent();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties: Global styles
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 */
	protected var _global : Styles;
	
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get global() : Styles
	{
		return _global;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set global(value : Styles) : void
	{
		if (_global === value)
			return;
		
		if (_global)
		{
			_global.removeEventListener("colorChanged", global_colorChangedHandler);
			_global.removeEventListener("alphaChanged", global_alphaChangedHandler);
			_global.removeEventListener("backgroundColorChanged", global_backgroundColorChangedHandler);
			_global.removeEventListener("backgroundAlphaChanged", global_backgroundAlphaChangedHandler);
			_global.removeEventListener("boldChanged", global_boldChangedHandler);
			_global.removeEventListener("italicChanged", global_italicChangedHandler);
			_global.removeEventListener("underlineChanged", global_underlineChangedHandler);
			_global.removeEventListener("horizontalAlignChanged", global_horizontalAlignChangedHandler);
			_global.removeEventListener("verticalAlignChanged", global_verticalAlignChangedHandler);
			_global.removeEventListener("sizeChanged", global_sizeChangedHandler);
		}
		
		_global = value;
		
		if (value)
		{
			value.addEventListener("colorChanged", global_colorChangedHandler);
			value.addEventListener("alphaChanged", global_alphaChangedHandler);
			value.addEventListener("backgroundColorChanged", global_backgroundColorChangedHandler);
			value.addEventListener("backgroundAlphaChanged", global_backgroundAlphaChangedHandler);
			value.addEventListener("boldChanged", global_boldChangedHandler);
			value.addEventListener("italicChanged", global_italicChangedHandler);
			value.addEventListener("underlineChanged", global_underlineChangedHandler);
			value.addEventListener("horizontalAlignChanged", global_horizontalAlignChangedHandler);
			value.addEventListener("verticalAlignChanged", global_verticalAlignChangedHandler);
			value.addEventListener("sizeChanged", global_sizeChangedHandler);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Event dispatchers
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 *
	 */
	protected function dispatchColorChangedEvent() : void
	{
		dispatchEvent(new Event("colorChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchAlphaChangedEvent() : void
	{
		dispatchEvent(new Event("alphaChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchBackgroundColorChangedEvent() : void
	{
		dispatchEvent(new Event("backgroundColorChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchBackgroundAlphaChangedEvent() : void
	{
		dispatchEvent(new Event("backgroundAlphaChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchBoldChangedEvent() : void
	{
		dispatchEvent(new Event("boldChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchItalicChangedEvent() : void
	{
		dispatchEvent(new Event("italicChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchUnderlineChangedEvent() : void
	{
		dispatchEvent(new Event("underlineChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchHorizontalAlignChangedEvent() : void
	{
		dispatchEvent(new Event("horizontalAlignChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchVerticalAlignChangedEvent() : void
	{
		dispatchEvent(new Event("verticalAlignChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchSizeChangedEvent() : void
	{
		dispatchEvent(new Event("sizeChanged"));
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Cleanup
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 *
	 */
	spreadsheet function release() : void
	{
		global = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Assignment
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	public function assign(value : Styles) : void
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
		horizontalAlign = value.horizontalAlign;
		verticalAlign = value.verticalAlign;
		size = value.size;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function assignObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Styles)
		{
			assign(Styles(value));
			
			return;
		}
		
		if (value.hasOwnProperty("color"))
			color = uint(value.color);
		
		if (value.hasOwnProperty("alpha"))
			alpha = Number(value.alpha);
		
		if (value.hasOwnProperty("backgroundColor"))
			backgroundColor = uint(value.backgroundColor);
		
		if (value.hasOwnProperty("backgroundAlpha"))
			backgroundAlpha = Number(value.backgroundAlpha);
		
		if (value.hasOwnProperty("bold"))
			bold = Boolean(value.bold);
		
		if (value.hasOwnProperty("italic"))
			italic = Boolean(value.italic);
		
		if (value.hasOwnProperty("underline"))
			underline = Boolean(value.underline);
		
		if (value.hasOwnProperty("horizontalAlign"))
			horizontalAlign = String(value.horizontalAlign);
		
		if (value.hasOwnProperty("verticalAlign"))
			verticalAlign = String(value.verticalAlign);
		
		if (value.hasOwnProperty("size"))
			size = uint(value.size);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers: Global styles
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_colorChangedHandler(e : Event) : void
	{
		dispatchColorChangedEvent();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_alphaChangedHandler(e : Event) : void
	{
		dispatchAlphaChangedEvent();
	}
	
	/**
	 *
	 *
	 */
	protected function global_backgroundColorChangedHandler(e : Event) : void
	{
		dispatchBackgroundColorChangedEvent();
	}
	
	/**
	 *
	 *
	 */
	protected function global_backgroundAlphaChangedHandler(e : Event) : void
	{
		dispatchBackgroundAlphaChangedEvent();
	}
	
	/**
	 *
	 *
	 */
	protected function global_boldChangedHandler(e : Event) : void
	{
		dispatchBoldChangedEvent();
	}
	
	/**
	 *
	 *
	 */
	protected function global_italicChangedHandler(e : Event) : void
	{
		dispatchItalicChangedEvent();
	}
	
	/**
	 *
	 *
	 */
	protected function global_underlineChangedHandler(e : Event) : void
	{
		dispatchUnderlineChangedEvent();
	}
	
	/**
	 *
	 *
	 */
	protected function global_horizontalAlignChangedHandler(e : Event) : void
	{
		dispatchHorizontalAlignChangedEvent();
	}
	
	/**
	 *
	 *
	 */
	protected function global_verticalAlignChangedHandler(e : Event) : void
	{
		dispatchVerticalAlignChangedEvent();
	}
	
	/**
	 *
	 *
	 */
	protected function global_sizeChangedHandler(e : Event) : void
	{
		dispatchSizeChangedEvent();
	}
}
}