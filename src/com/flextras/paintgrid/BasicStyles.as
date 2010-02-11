package com.flextras.paintgrid
{

public class BasicStyles
{
	protected var owner : PaintGridColumnItemRenderer;
	
	public function BasicStyles (owner : PaintGridColumnItemRenderer)
	{
		this.owner = owner;
	}
	
	/**
	 * Foreground styles
	 */
	
	protected var _foregroundChanged : Boolean;
	
	public function get foregroundChanged () : Boolean
	{
		return _foregroundChanged;
	}
	
	public function set foregroundChanged (value : Boolean) : void
	{
		_foregroundChanged = value;
		
		if (value)
			owner.invalidateDisplayList();
	}
	
	protected var _foregroundColor : uint;
	
	public function get foregroundColor () : uint
	{
		return _foregroundColor;
	}
	
	public function set foregroundColor (value : uint) : void
	{
		if (_foregroundColor == value)
			return;
		
		_foregroundColor = value;
		foregroundChanged = true;
	}
	
	protected var _foregroundAlpha : Number;
	
	public function get foregroundAlpha () : Number
	{
		return _foregroundAlpha;
	}
	
	public function set foregroundAlpha (value : Number) : void
	{
		if (_foregroundAlpha == value)
			return;
		
		_foregroundAlpha = value;
		foregroundChanged = true;
	}
	
	/**
	 * Background styles
	 */
	
	protected var _backgroundChanged : Boolean;
	
	public function get backgroundChanged () : Boolean
	{
		return _backgroundChanged;
	}
	
	public function set backgroundChanged (value : Boolean) : void
	{
		_backgroundChanged = value;
		
		if (value)
			owner.invalidateDisplayList();
	}
	
	protected var _backgroundColor : uint;
	
	public function get backgroundColor () : uint
	{
		return _backgroundColor;
	}
	
	public function set backgroundColor (value : uint) : void
	{
		if (_backgroundColor == value)
			return;
		
		_backgroundColor = value;
		backgroundChanged = true;
	}
	
	protected var _backgroundAlpha : Number;
	
	public function get backgroundAlpha () : Number
	{
		return _backgroundAlpha;
	}
	
	public function set backgroundAlpha (value : Number) : void
	{
		if (_backgroundAlpha == value)
			return;
		
		_backgroundAlpha = value;
		backgroundChanged = true;
	}
	
	public function change (property : Object, value : Object) : void
	{
		switch (property)
		{
			case "color":
				foregroundColor = value as uint;
				
				break;
			
			case "alpha":
				foregroundAlpha = value as Number;
				
				break;
			
			case "backgroundColor":
				backgroundColor = value as uint;
				
				break;
			
			case "backgroundAlpha":
				backgroundAlpha = value as Number;
				
				break;
		}
	}
	
	public function assign (value : BasicStyles) : void
	{
		if (!value)
			return;
		
		foregroundColor = value.foregroundColor;
		foregroundAlpha = value.foregroundAlpha;
		backgroundColor = value.backgroundColor;
		backgroundAlpha = value.backgroundAlpha;
	}
	
	public function apply (value : Object) : void
	{
		if (!value)
			return;
		
		if (value.hasOwnProperty("color"))
			foregroundColor = value.color;
		
		if (value.hasOwnProperty("alpha"))
			foregroundAlpha = value.alpha;
		
		if (value.hasOwnProperty("backgroundColor"))
			backgroundColor = value.backgroundColor;
		
		if (value.hasOwnProperty("backgroundAlpha"))
			backgroundAlpha = value.backgroundAlpha;
	}
}
}