package com.flextras.paintgrid
{
import mx.core.UIComponent;

public class Styles extends BasicStyles
{
	public function Styles (owner : UIComponent)
	{
		super(owner);
	}
	
	/**
	 * Font styles
	 */
	
	protected var _fontStylesChanged : Boolean;
	
	public function get fontStylesChanged () : Boolean
	{
		return _fontStylesChanged;
	}
	
	public function set fontStylesChanged (value : Boolean) : void
	{
		_fontStylesChanged = value;
		
		if (owner && value)
			owner.invalidateDisplayList();
	}
	
	protected var _align : String;
	
	public function get align () : String
	{
		return _align;
	}
	
	public function set align (value : String) : void
	{
		if (_align == value)
			return;
		
		_align = value;
		fontStylesChanged = true;
	}
	
	protected var _antiAliasType : String;
	
	public function get antiAliasType () : String
	{
		return _antiAliasType;
	}
	
	public function set antiAliasType (value : String) : void
	{
		if (_antiAliasType == value)
			return;
		
		_antiAliasType = value;
		fontStylesChanged = true;
	}
	
	protected var _decoration : String;
	
	public function get decoration () : String
	{
		return _decoration;
	}
	
	public function set decoration (value : String) : void
	{
		if (_decoration == value)
			return;
		
		_decoration = value;
		fontStylesChanged = true;
	}
	
	protected var _family : String;
	
	public function get family () : String
	{
		return _family;
	}
	
	public function set family (value : String) : void
	{
		if (_family == value)
			return;
		
		_family = value;
		fontStylesChanged = true;
	}
	
	protected var _gridFitType : String;
	
	public function get gridFitType () : String
	{
		return _gridFitType;
	}
	
	public function set gridFitType (value : String) : void
	{
		if (_gridFitType == value)
			return;
		
		_gridFitType = value;
		fontStylesChanged = true;
	}
	
	protected var _indent : int;
	
	public function get indent () : int
	{
		return _indent;
	}
	
	public function set indent (value : int) : void
	{
		if (_indent == value)
			return;
		
		_indent = value;
		fontStylesChanged = true;
	}
	
	protected var _kerning : Boolean;
	
	public function get kerning () : Boolean
	{
		return _kerning;
	}
	
	public function set kerning (value : Boolean) : void
	{
		if (_kerning == value)
			return;
		
		_kerning = value;
		fontStylesChanged = true;
	}
	
	protected var _sharpness : Number;
	
	public function get sharpness () : Number
	{
		return _sharpness;
	}
	
	public function set sharpness (value : Number) : void
	{
		if (_sharpness == value)
			return;
		
		_sharpness = value;
		fontStylesChanged = true;
	}
	
	protected var _size : uint;
	
	public function get size () : uint
	{
		return _size;
	}
	
	public function set size (value : uint) : void
	{
		if (_size == value)
			return;
		
		_size = value;
		fontStylesChanged = true;
	}
	
	protected var _spacing : int;
	
	public function get spacing () : int
	{
		return _spacing;
	}
	
	public function set spacing (value : int) : void
	{
		if (_spacing == value)
			return;
		
		_spacing = value;
		fontStylesChanged = true;
	}
	
	protected var _style : String;
	
	public function get style () : String
	{
		return _style;
	}
	
	public function set style (value : String) : void
	{
		if (_style == value)
			return;
		
		_style = value;
		fontStylesChanged = true;
	}
	
	protected var _thickness : Number;
	
	public function get thickness () : Number
	{
		return _thickness;
	}
	
	public function set thickness (value : Number) : void
	{
		if (_thickness == value)
			return;
		
		_thickness = value;
		fontStylesChanged = true;
	}
	
	protected var _weight : String;
	
	public function get weight () : String
	{
		return _weight;
	}
	
	public function set weight (value : String) : void
	{
		if (_weight == value)
			return;
		
		_weight = value;
		fontStylesChanged = true;
	}
	
	override public function change (property : Object, value : Object) : void
	{
		super.change(property, value);
		
		switch (property)
		{
			case "antiAliasType":
				antiAliasType = value as String;
				
				break;
			
			case "family":
				family = value as String;
				
				break;
			
			case "gridFitType":
				gridFitType = value as String;
				
				break;
			
			case "sharpness":
				sharpness = value as Number;
				
				break;
			
			case "size":
				size = value as uint;
				
				break;
			
			case "style":
				style = value as String;
				
				break;
			
			case "thickness":
				thickness = value as Number;
				
				break;
			
			case "weight":
				weight = value as String;
				
				break;
			
			case "kerning":
				kerning = value as Boolean;
				
				break;
			
			case "spacing":
				spacing = value as int;
				
				break;
			
			case "align":
				align = value as String;
				
				break;
			
			case "decoration":
				decoration = value as String;
				
				break;
			
			case "indent":
				indent = value as int;
				
				break;
		}
	}
	
	override public function assign (value : BasicStyles) : void
	{
		if (!value)
			return;
		
		super.assign(value);
		
		if (!value is Styles)
			return;
		
		var v : Styles = Styles(value);
		
		antiAliasType = v.antiAliasType;
		family = v.family;
		gridFitType = v.gridFitType;
		sharpness = v.sharpness;
		size = v.size;
		style = v.style;
		thickness = v.thickness;
		weight = v.weight;
		kerning = v.kerning;
		spacing = v.spacing;
		align = v.align;
		decoration = v.decoration;
		indent = v.indent;
	}
	
	override public function apply (value : Object) : void
	{
		if (!value)
			return;
		
		super.apply(value);
		
		if (value.hasOwnProperty("antiAliasType"))
			antiAliasType = value.antiAliasType;
		
		if (value.hasOwnProperty("family"))
			family = value.family;
		
		if (value.hasOwnProperty("gridFitType"))
			gridFitType = value.gridFitType;
		
		if (value.hasOwnProperty("sharpness"))
			sharpness = value.sharpness;
		
		if (value.hasOwnProperty("size"))
			size = value.size;
		
		if (value.hasOwnProperty("style"))
			style = value.style;
		
		if (value.hasOwnProperty("thickness"))
			thickness = value.thickness;
		
		if (value.hasOwnProperty("weight"))
			weight = value.weight;
		
		if (value.hasOwnProperty("kerning"))
			kerning = value.kerning;
		
		if (value.hasOwnProperty("spacing"))
			spacing = value.spacing;
		
		if (value.hasOwnProperty("align"))
			align = value.align;
		
		if (value.hasOwnProperty("decoration"))
			decoration = value.decoration;
		
		if (value.hasOwnProperty("indent"))
			indent = value.indent;
	}
}
}