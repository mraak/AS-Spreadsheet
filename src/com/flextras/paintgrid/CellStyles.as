package com.flextras.paintgrid
{
import flash.text.AntiAliasType;
import flash.text.FontStyle;
import flash.text.GridFitType;
import flash.text.engine.FontWeight;

import flashx.textLayout.formats.TextAlign;
import flashx.textLayout.formats.TextDecoration;

public class CellStyles
{
	public var defaultStyles : Styles;
	
	public var styles : Styles;
	
	public var rollOverStyles : BasicStyles;
	
	public var selectedStyles : BasicStyles;
	
	public var disabledStyles : BasicStyles;
	
	public function CellStyles (owner : PaintGridColumnItemRenderer)
	{
		defaultStyles = new Styles(owner);
		styles = new Styles(owner);
		rollOverStyles = new BasicStyles(owner);
		selectedStyles = new BasicStyles(owner);
		disabledStyles = new BasicStyles(owner);
		
		defaultStyles.foregroundColor = 0x000000;
		defaultStyles.foregroundAlpha = 1;
		defaultStyles.backgroundColor = 0xFFFFFF;
		defaultStyles.backgroundAlpha = 1;
		defaultStyles.align = TextAlign.LEFT;
		defaultStyles.antiAliasType = AntiAliasType.NORMAL;
		defaultStyles.decoration = TextDecoration.NONE;
		defaultStyles.gridFitType = GridFitType.NONE;
		defaultStyles.size = 12;
		defaultStyles.style = FontStyle.REGULAR;
		defaultStyles.weight = FontWeight.NORMAL;
		
		reset();
	}
	
	public function assign (value : CellStyles) : void
	{
		if (!value)
			return;
		
		styles.assign(value.styles);
		rollOverStyles.assign(value.rollOverStyles);
		selectedStyles.assign(value.selectedStyles);
		disabledStyles.assign(value.disabledStyles);
	}
	
	public function apply (value : CellProperties) : void
	{
		if (!value)
			return;
		
		styles.apply(value.styles);
		rollOverStyles.apply(value.rollOverStyles);
		selectedStyles.apply(value.selectedStyles);
		disabledStyles.apply(value.disabledStyles);
	}
	
	public function reset () : void
	{
		styles.assign(defaultStyles);
		rollOverStyles.assign(defaultStyles);
		selectedStyles.assign(defaultStyles);
		disabledStyles.assign(defaultStyles);
	}
}
}