package com.flextras.paintgrid
{
import flash.events.MouseEvent;

import mx.controls.dataGridClasses.DataGridItemRenderer;
import mx.core.mx_internal;
import mx.utils.ObjectProxy;

use namespace mx_internal;

// TODO: effects

public class PaintGridItemRenderer extends DataGridItemRenderer
{
	public function PaintGridItemRenderer ()
	{
		super();
		
		height = 18;
		doubleClickEnabled = true;
		selectable = false;
		
		/*addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);*/
		addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
	}
	
	protected var _cell : CellProperties;
	
	[Bindable]
	public function get cell () : CellProperties
	{
		return _cell;
	}
	
	public function set cell (value : CellProperties) : void
	{
		if (!value || value === _cell)
			return;
		
		if (cell)
		{
			cell.removeEventListener(CellEvent.STYLES_CHANGED, stylesChangedHandler);
			cell.removeEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, rollOverStylesChangedHandler);
			cell.removeEventListener(CellEvent.SELECTED_STYLES_CHANGED, selectedStylesChangedHandler);
			cell.removeEventListener(CellEvent.DISABLED_STYLES_CHANGED, disabledStylesChangedHandler);
			
			resetStyles();
		}
		
		_cell = value;
		
		if (cell)
		{
			cell.addEventListener(CellEvent.STYLES_CHANGED, stylesChangedHandler);
			cell.addEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, rollOverStylesChangedHandler);
			cell.addEventListener(CellEvent.SELECTED_STYLES_CHANGED, selectedStylesChangedHandler);
			cell.addEventListener(CellEvent.DISABLED_STYLES_CHANGED, disabledStylesChangedHandler);
			
			applyStyles(cell.styles);
		}
	}
	
	override public function validateNow () : void
	{
		super.validateNow();
		
		if (data && parent && cell)
		{
			var dg : PaintGrid = listData.owner as PaintGrid;
			
			if (enabled)
			{
				if (dg.isItemHighlighted(listData.uid))
				{
					applyStyles(cell.rollOverStyles);
				}
				else if (dg.isItemSelected(listData.uid))
				{
					applyStyles(cell.selectedStyles);
				}
				else
				{
					applyStyles(cell.styles);
				}
			}
			else
			{
				applyStyles(cell.disabledStyles);
			}
		}
	}
	
	protected var currentStyles : ObjectProxy;
	
	protected function applyStyle (on : ObjectProxy, name : String, style : String) : void
	{
		if (!currentStyles || on[name] != currentStyles[name])
			setStyle(style, on[name]);
	}
	
	protected function applyStyles (on : ObjectProxy) : void
	{
		if (currentStyles === on)
			return;
		
		/*if (cell.styles.hasOwnProperty("color"))
		   setStyle("color", cell.styles.color);
		
		   if (cell.rollOverStyles.hasOwnProperty("color"))
		   setStyle("textRollOverColor", cell.rollOverStyles.color);
		
		   if (cell.selectedStyles.hasOwnProperty("color"))
		   setStyle("textSelectedColor", cell.selectedStyles.color);
		
		   if (cell.disabledStyles.hasOwnProperty("color"))
		 setStyle("disabledColor", cell.disabledStyles.color);*/
		
		applyStyle(on, "color", "color");
		applyStyle(on, "alpha", "alpha");
		applyStyle(on, "antiAliasType", "fontAntiAliasType");
		applyStyle(on, "family", "fontFamily");
		applyStyle(on, "gridFitType", "fontGridFitType");
		applyStyle(on, "sharpness", "fontSharpness");
		applyStyle(on, "size", "fontSize");
		applyStyle(on, "style", "fontStyle");
		applyStyle(on, "thickness", "fontThickness");
		applyStyle(on, "weight", "fontWeight");
		applyStyle(on, "kerning", "kerning");
		applyStyle(on, "spacing", "letterSpacing");
		applyStyle(on, "align", "textAlign");
		applyStyle(on, "decoration", "textDecoration");
		applyStyle(on, "indent", "textIndent");
		
		if (on.hasOwnProperty("backgroundColor"))
		{
			if (!currentStyles || on.backgroundColor != currentStyles.backgroundColor)
			{
				background = true;
				backgroundColor = on.backgroundColor;
			}
		}
		else
			background = false;
		
		currentStyles = on;
	}
	
	protected function resetStyles () : void
	{
		clearStyle("color");
		clearStyle("alpha");
		/*clearStyle("textRollOverColor");
		 clearStyle("textSelectedColor");*/
		clearStyle("disabledColor");
		clearStyle("fontAntiAliasType");
		clearStyle("fontFamily");
		clearStyle("fontGridFitType");
		clearStyle("fontSharpness");
		clearStyle("fontSize");
		clearStyle("fontStyle");
		clearStyle("fontThickness");
		clearStyle("fontWeight");
		clearStyle("kerning");
		clearStyle("letterSpacing");
		clearStyle("textAlign");
		clearStyle("textDecoration");
		clearStyle("textIndent");
		
		background = false;
	}
	
	protected function stylesChangedHandler (e : CellEvent) : void
	{
		applyStyles(cell.styles);
	}
	
	protected function rollOverStylesChangedHandler (e : CellEvent) : void
	{
		applyStyles(cell.rollOverStyles);
	}
	
	protected function selectedStylesChangedHandler (e : CellEvent) : void
	{
		applyStyles(cell.selectedStyles);
	}
	
	protected function disabledStylesChangedHandler (e : CellEvent) : void
	{
		applyStyles(cell.disabledStyles);
	}
	
	protected function rollOverHandler (e : MouseEvent) : void
	{
		applyStyles(cell.rollOverStyles);
	}
	
	protected function rollOutHandler (e : MouseEvent) : void
	{
		applyStyles(cell.styles);
	}
	
	protected function clickHandler (e : MouseEvent) : void
	{
		applyStyles(cell.selectedStyles);
		
		PaintGrid(owner).selectedCellProperties = cell;
	}

}
}