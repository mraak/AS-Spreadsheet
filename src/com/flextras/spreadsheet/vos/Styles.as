package com.flextras.spreadsheet.vos
{
import flash.events.Event;
import flash.events.EventDispatcher;

import flashx.textLayout.formats.TextAlign;
import flashx.textLayout.formats.VerticalAlign;

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
	/**
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
	
	/**
	 *
	 */
	protected var _color : uint;
	
	[Bindable(event="colorChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get color() : uint
	{
		return _color;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set color(value : uint) : void
	{
		if (_color == value)
			return;
		
		_color = value;
		
		dispatchEvent(new Event("colorChanged"));
	}
	
	/**
	 *
	 */
	protected var _alpha : Number = 1;
	
	[Bindable(event="alphaChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get alpha() : Number
	{
		return _alpha;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set alpha(value : Number) : void
	{
		if (_alpha == value)
			return;
		
		_alpha = value;
		
		dispatchEvent(new Event("alphaChanged"));
	}
	
	/**
	 *
	 */
	protected var _backgroundColor : uint = 0xFFFFFF;
	
	[Bindable(event="backgroundColorChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get backgroundColor() : uint
	{
		return _backgroundColor;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set backgroundColor(value : uint) : void
	{
		if (_backgroundColor == value)
			return;
		
		_backgroundColor = value;
		
		dispatchEvent(new Event("backgroundColorChanged"));
	}
	
	/**
	 *
	 */
	protected var _backgroundAlpha : Number = 1;
	
	[Bindable(event="backgroundAlphaChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get backgroundAlpha() : Number
	{
		return _backgroundAlpha;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set backgroundAlpha(value : Number) : void
	{
		if (_backgroundAlpha == value)
			return;
		
		_backgroundAlpha = value;
		
		dispatchEvent(new Event("backgroundAlphaChanged"));
	}
	
	/**
	 *
	 */
	protected var _bold : Boolean;
	
	[Bindable(event="boldChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get bold() : Boolean
	{
		return _bold;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set bold(value : Boolean) : void
	{
		if (_bold == value)
			return;
		
		_bold = value;
		
		dispatchEvent(new Event("boldChanged"));
	}
	
	/**
	 *
	 */
	protected var _italic : Boolean;
	
	[Bindable(event="italicChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get italic() : Boolean
	{
		return _italic;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set italic(value : Boolean) : void
	{
		if (_italic == value)
			return;
		
		_italic = value;
		
		dispatchEvent(new Event("italicChanged"));
	}
	
	/**
	 *
	 */
	protected var _underline : Boolean;
	
	[Bindable(event="underlineChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get underline() : Boolean
	{
		return _underline;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set underline(value : Boolean) : void
	{
		if (_underline == value)
			return;
		
		_underline = value;
		
		dispatchEvent(new Event("underlineChanged"));
	}
	
	/**
	 *
	 */
	protected var _horizontalAlign : String = TextAlign.CENTER;
	
	[Bindable(event="horizontalAlignChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get horizontalAlign() : String
	{
		return _horizontalAlign;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set horizontalAlign(value : String) : void
	{
		if (_horizontalAlign == value)
			return;
		
		_horizontalAlign = value;
		
		dispatchEvent(new Event("horizontalAlignChanged"));
	}
	
	/**
	 *
	 */
	protected var _verticalAlign : String = VerticalAlign.MIDDLE;
	
	[Bindable(event="verticalAlignChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get verticalAlign() : String
	{
		return _verticalAlign;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set verticalAlign(value : String) : void
	{
		if (_verticalAlign == value)
			return;
		
		_verticalAlign = value;
		
		dispatchEvent(new Event("verticalAlignChanged"));
	}
	
	/**
	 *
	 */
	protected var _size : uint = 14;
	
	[Bindable(event="sizeChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get size() : uint
	{
		return _size;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set size(value : uint) : void
	{
		if (_size == value)
			return;
		
		_size = value;
		
		dispatchEvent(new Event("sizeChanged"));
	}
	
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
}
}