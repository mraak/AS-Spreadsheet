package com.flextras.paintgrid
{
import flash.text.AntiAliasType;
import flash.text.FontStyle;
import flash.text.GridFitType;
import flash.text.engine.FontWeight;

import flashx.textLayout.formats.TextAlign;
import flashx.textLayout.formats.TextDecoration;

import mx.utils.ObjectProxy;

public class CellStyles
{
	public function CellStyles (owner : PaintGridColumnItemRenderer)
	{
		this.owner = owner;
	}
	
	public var owner : PaintGridColumnItemRenderer;
	
	/**
	 * Default styles
	 */
	
	public var defaultForegroundColor : uint = 0x000000;
	
	public var defaultForegroundAlpha : Number = 1;
	
	public var defaultBackgroundColor : uint = 0xFFFFFF;
	
	public var defaultBackgroundAlpha : Number = 1;
	
	public var defaultAlign : String = TextAlign.LEFT;
	
	public var defaultAntiAliasType : String = AntiAliasType.NORMAL;
	
	public var defaultDecoration : String = TextDecoration.NONE;
	
	public var defaultFamily : String;
	
	public var defaultGridFitType : String = GridFitType.NONE;
	
	public var defaultIndent : int;
	
	public var defaultKerning : Boolean;
	
	public var defaultSharpness : Number;
	
	public var defaultSize : uint = 12;
	
	public var defaultSpacing : int;
	
	public var defaultStyle : String = FontStyle.REGULAR;
	
	public var defaultThickness : Number;
	
	public var defaultWeight : String = FontWeight.NORMAL;
	
	/**
	 * Foreground styles
	 */
	
	public var foregroundChanged : Boolean;
	
	public var _foregroundColor : uint = 0xFFFFFF;
	
	public function set foregroundColor (value : uint) : void
	{
		if (_foregroundColor == value)
			return;
		
		_foregroundColor = value;
		foregroundChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _foregroundAlpha : Number = 1;
	
	public function set foregroundAlpha (value : Number) : void
	{
		if (_foregroundAlpha == value)
			return;
		
		_foregroundAlpha = value;
		foregroundChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	/**
	 * Background styles
	 */
	
	public var backgroundChanged : Boolean;
	
	public var _backgroundColor : uint = 0xFFFFFF;
	
	public function set backgroundColor (value : uint) : void
	{
		if (_backgroundColor == value)
			return;
		
		_backgroundColor = value;
		backgroundChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _backgroundAlpha : Number = 1;
	
	public function set backgroundAlpha (value : Number) : void
	{
		if (_backgroundAlpha == value)
			return;
		
		_backgroundAlpha = value;
		backgroundChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	/**
	 * Font styles
	 */
	
	public var fontStylesChanged : Boolean;
	
	public var _align : String;
	
	public function set align (value : String) : void
	{
		if (_align == value)
			return;
		
		_align = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _antiAliasType : String;
	
	public function set antiAliasType (value : String) : void
	{
		if (_antiAliasType == value)
			return;
		
		_antiAliasType = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _decoration : String;
	
	public function set decoration (value : String) : void
	{
		if (_decoration == value)
			return;
		
		_decoration = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _family : String;
	
	public function set family (value : String) : void
	{
		if (_family == value)
			return;
		
		_family = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _gridFitType : String;
	
	public function set gridFitType (value : String) : void
	{
		if (_gridFitType == value)
			return;
		
		_gridFitType = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _indent : int;
	
	public function set indent (value : int) : void
	{
		if (_indent == value)
			return;
		
		_indent = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _kerning : Boolean;
	
	public function set kerning (value : Boolean) : void
	{
		if (_kerning == value)
			return;
		
		_kerning = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _sharpness : Number;
	
	public function set sharpness (value : Number) : void
	{
		if (_sharpness == value)
			return;
		
		_sharpness = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _size : uint;
	
	public function set size (value : uint) : void
	{
		if (_size == value)
			return;
		
		_size = value;
		fontStylesChanged = true;
		
		owner.invalidateSize();
		owner.invalidateDisplayList();
	}
	
	public var _spacing : int;
	
	public function set spacing (value : int) : void
	{
		if (_spacing == value)
			return;
		
		_spacing = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _style : String;
	
	public function set style (value : String) : void
	{
		if (_style == value)
			return;
		
		_style = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _thickness : Number;
	
	public function set thickness (value : Number) : void
	{
		if (_thickness == value)
			return;
		
		_thickness = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public var _weight : String;
	
	public function set weight (value : String) : void
	{
		if (_weight == value)
			return;
		
		_weight = value;
		fontStylesChanged = true;
		
		owner.invalidateDisplayList();
	}
	
	public function stylesChangedHandler (e : CellEvent) : void
	{
		if (owner.currentState == "normal")
			commonStyles(e);
		
		switch (e.property)
		{
			case "antiAliasType":
				antiAliasType = e.newValue as String;
				
				break;
			
			case "family":
				family = e.newValue as String;
				
				break;
			
			case "gridFitType":
				gridFitType = e.newValue as String;
				
				break;
			
			case "sharpness":
				sharpness = e.newValue as Number;
				
				break;
			
			case "size":
				size = e.newValue as uint;
				
				break;
			
			case "style":
				style = e.newValue as String;
				
				break;
			
			case "thickness":
				thickness = e.newValue as Number;
				
				break;
			
			case "weight":
				weight = e.newValue as String;
				
				break;
			
			case "kerning":
				kerning = e.newValue as Boolean;
				
				break;
			
			case "spacing":
				spacing = e.newValue as int;
				
				break;
			
			case "align":
				align = e.newValue as String;
				
				break;
			
			case "decoration":
				decoration = e.newValue as String;
				
				break;
			
			case "indent":
				indent = e.newValue as int;
				
				break;
		}
	}
	
	public function rollOverStylesChangedHandler (e : CellEvent) : void
	{
		if (owner.currentState == "over")
			commonStyles(e);
	}
	
	public function selectedStylesChangedHandler (e : CellEvent) : void
	{
		if (owner.currentState == "selected")
			commonStyles(e);
	}
	
	public function disabledStylesChangedHandler (e : CellEvent) : void
	{
		if (owner.currentState == "disabled")
			commonStyles(e);
	}
	
	protected function commonStyles (e : CellEvent) : void
	{
		switch (e.property)
		{
			case "color":
				foregroundColor = e.newValue as uint;
				
				break;
			
			case "alpha":
				foregroundAlpha = e.newValue as Number;
				
				break;
			
			case "backgroundColor":
				backgroundColor = e.newValue as uint;
				
				break;
			
			case "backgroundAlpha":
				backgroundAlpha = e.newValue as Number;
				
				break;
		}
	}
	
	public function applyStyles (on : ObjectProxy, all : Boolean = true) : void
	{
		if (!on)
			return;
		
		foregroundColor = on.color || defaultForegroundColor;
		foregroundAlpha = on.alpha || defaultForegroundAlpha;
		
		backgroundColor = on.backgroundColor || defaultBackgroundColor;
		backgroundAlpha = on.backgroundAlpha || defaultBackgroundAlpha;
		
		if (!all)
			return;
		
		antiAliasType = on.antiAliasType || defaultAntiAliasType;
		family = on.family || defaultFamily;
		gridFitType = on.gridFitType || defaultGridFitType;
		sharpness = on.sharpness || defaultSharpness;
		size = on.size || defaultSize;
		style = on.style || defaultStyle;
		thickness = on.thickness || defaultThickness;
		weight = on.weight || defaultWeight;
		kerning = on.kerning || defaultKerning;
		spacing = on.spacing || defaultSpacing;
		align = on.align || defaultAlign;
		decoration = on.decoration || defaultDecoration;
		indent = on.indent || defaultIndent;
	}
	
	public function resetStyles () : void
	{
		foregroundColor = defaultForegroundColor;
		foregroundAlpha = defaultForegroundAlpha;
		
		backgroundColor = defaultBackgroundColor;
		backgroundAlpha = defaultBackgroundAlpha;
		
		antiAliasType = defaultAntiAliasType;
		family = defaultFamily;
		gridFitType = defaultGridFitType;
		sharpness = defaultSharpness;
		size = defaultSize;
		style = defaultStyle;
		thickness = defaultThickness;
		weight = defaultWeight;
		kerning = defaultKerning;
		spacing = defaultSpacing;
		align = defaultAlign;
		decoration = defaultDecoration;
		indent = defaultIndent;
	}
	
	public function styleChanged (styleProp : String) : void
	{
		switch (styleProp)
		{
			/* case null:
			   defaultForegroundColor = owner.getStyle("color") as uint;
			   defaultForegroundAlpha = owner.getStyle("alpha") as Number;
			   defaultBackgroundColor = owner.getStyle("backgroundColor") as uint;
			   defaultBackgroundAlpha = owner.getStyle("backgroundAlpha") as Number;
			   defaultAntiAliasType = owner.getStyle("antiAliasType") as String;
			   defaultFamily = owner.getStyle("family") as String;
			   defaultGridFitType = owner.getStyle("gridFitType") as String;
			   defaultSharpness = owner.getStyle("sharpness") as Number;
			   defaultSize = owner.getStyle("size") as uint;
			   defaultStyle = owner.getStyle("style") as String;
			   defaultThickness = owner.getStyle("thickness") as Number;
			   defaultWeight = owner.getStyle("weight") as String;
			   defaultKerning = owner.getStyle("kerning") as Boolean;
			   defaultSpacing = owner.getStyle("spacing") as int;
			   defaultAlign = owner.getStyle("align") as String;
			   defaultDecoration = owner.getStyle("decoration") as String;
			   defaultIndent = owner.getStyle("indent") as int;
			
			 break; */
			
			case "color":
				defaultForegroundColor = owner.getStyle(styleProp) as uint;
				
				break;
			
			case "alpha":
				defaultForegroundAlpha = owner.getStyle(styleProp) as Number;
				
				break;
			
			case "backgroundColor":
				defaultBackgroundColor = owner.getStyle(styleProp) as uint;
				
				break;
			
			case "backgroundAlpha":
				defaultBackgroundAlpha = owner.getStyle(styleProp) as Number;
				
				break;
			
			case "antiAliasType":
				defaultAntiAliasType = owner.getStyle(styleProp) as String;
				
				break;
			
			case "family":
				defaultFamily = owner.getStyle(styleProp) as String;
				
				break;
			
			case "gridFitType":
				defaultGridFitType = owner.getStyle(styleProp) as String;
				
				break;
			
			case "sharpness":
				defaultSharpness = owner.getStyle(styleProp) as Number;
				
				break;
			
			case "size":
				defaultSize = owner.getStyle(styleProp) as uint;
				
				break;
			
			case "style":
				defaultStyle = owner.getStyle(styleProp) as String;
				
				break;
			
			case "thickness":
				defaultThickness = owner.getStyle(styleProp) as Number;
				
				break;
			
			case "weight":
				defaultWeight = owner.getStyle(styleProp) as String;
				
				break;
			
			case "kerning":
				defaultKerning = owner.getStyle(styleProp) as Boolean;
				
				break;
			
			case "spacing":
				defaultSpacing = owner.getStyle(styleProp) as int;
				
				break;
			
			case "align":
				defaultAlign = owner.getStyle(styleProp) as String;
				
				break;
			
			case "decoration":
				defaultDecoration = owner.getStyle(styleProp) as String;
				
				break;
			
			case "indent":
				defaultIndent = owner.getStyle(styleProp) as int;
				
				break;
		}
	}
}
}