package com.flextras.paintgrid
{
import flash.events.MouseEvent;
import flash.text.TextFormat;

import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.effects.AnimateProperty;

import spark.effects.AnimateColor;

use namespace mx_internal;

public class PaintGrid2ColumnItemRenderer extends UIComponent implements IListItemRenderer, IDropInListItemRenderer
{
	public function PaintGrid2ColumnItemRenderer ()
	{
		super();
		
		backgroundColorEffect.colorPropertyName = "colorTo";
		backgroundAlphaEffect.property = "alphaTo";
		backgroundColorEffect.duration = backgroundAlphaEffect.duration = 500;
		
		addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
	}
	
	protected const styles : CellStyles = new CellStyles(this as PaintGrid2ColumnItemRenderer);
	
	protected const globalStyles : CellStyles = new CellStyles(this as PaintGrid2ColumnItemRenderer);
	
	protected var _currentStyles : BasicStyles;
	
	protected var currentStylesChanged : Boolean;
	
	protected const backgroundColorEffect : AnimateColor = new AnimateColor(this);
	
	protected const backgroundAlphaEffect : AnimateProperty = new AnimateProperty(this);
	
	protected function get currentStyles () : BasicStyles
	{
		return _currentStyles;
	}
	
	protected function set currentStyles (value : BasicStyles) : void
	{
		if (value === _currentStyles)
			return;
		
		_currentStyles = value;
		currentStylesChanged = true;
		
		invalidateDisplayList();
	}
	
	protected var _currentGlobalStyles : BasicStyles;
	
	protected var currentGlobalStylesChanged : Boolean;
	
	protected function get currentGlobalStyles () : BasicStyles
	{
		return _currentGlobalStyles;
	}
	
	protected function set currentGlobalStyles (value : BasicStyles) : void
	{
		if (value === _currentGlobalStyles)
			return;
		
		_currentGlobalStyles = value;
		currentGlobalStylesChanged = true;
		
		invalidateDisplayList();
	}
	
	protected var _dataGrid : PaintGrid2;
	
	public function get dataGrid () : PaintGrid2
	{
		return _dataGrid;
	}
	
	public function set dataGrid (value : PaintGrid2) : void
	{
		if (_dataGrid === value)
			return;
		
		_dataGrid = value;
	}
	
	protected var _data : Object;
	
	protected var dataChanged : Boolean;
	
	public function get data () : Object
	{
		return _data;
	}
	
	public function set data (value : Object) : void
	{
		if (_data === value)
			return;
		
		_data = value;
		dataChanged = true;
		
		invalidateProperties();
	}
	
	protected var _listData : BaseListData;
	
	public function get listData () : BaseListData
	{
		return _listData;
	}
	
	public function set listData (value : BaseListData) : void
	{
		if (_listData === value)
			return;
		
		_listData = value;
		dataChanged = true;
		
		invalidateProperties();
	}
	
	protected var _info : Row;
	
	public function get info () : Row
	{
		return _info;
	}
	
	public function set info (value : Row) : void
	{
		if (value === _info)
			return;
		
		if (_info)
			_info.removeEventListener("heightChanged", heightChangedHandler);
		
		_info = value;
		
		if (value)
			value.addEventListener("heightChanged", heightChangedHandler);
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
		
		styles.assign(globalStyles);
		
		if (_cell)
		{
			_cell.removeEventListener("enabledChanged", enabledChangedHandler);
			_cell.removeEventListener("selectedChanged", selectedChangedHandler);
			_cell.removeEventListener(CellEvent.STYLES_CHANGED, stylesChangedHandler);
			_cell.removeEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, rollOverStylesChangedHandler);
			_cell.removeEventListener(CellEvent.SELECTED_STYLES_CHANGED, selectedStylesChangedHandler);
			_cell.removeEventListener(CellEvent.DISABLED_STYLES_CHANGED, disabledStylesChangedHandler);
		}
		
		_cell = value;
		
		invalidateDisplayList();
		
		if (value)
		{
			value.addEventListener("enabledChanged", enabledChangedHandler);
			value.addEventListener("selectedChanged", selectedChangedHandler);
			value.addEventListener(CellEvent.STYLES_CHANGED, stylesChangedHandler);
			value.addEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, rollOverStylesChangedHandler);
			value.addEventListener(CellEvent.SELECTED_STYLES_CHANGED, selectedStylesChangedHandler);
			value.addEventListener(CellEvent.DISABLED_STYLES_CHANGED, disabledStylesChangedHandler);
			
			styles.apply(value);
			
			currentStyles = value.enabled ? value.selected ? styles.selectedStyles : styles.styles : styles.disabledStyles;
		}
	}
	
	protected var _globalCell : CellProperties;
	
	[Bindable]
	public function get globalCell () : CellProperties
	{
		return _globalCell;
	}
	
	public function set globalCell (value : CellProperties) : void
	{
		if (!value || value === _globalCell)
			return;
		
		if (_globalCell)
		{
			_globalCell.removeEventListener(CellEvent.STYLES_CHANGED, global_stylesChangedHandler);
			_globalCell.removeEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, global_rollOverStylesChangedHandler);
			_globalCell.removeEventListener(CellEvent.SELECTED_STYLES_CHANGED, global_selectedStylesChangedHandler);
			_globalCell.removeEventListener(CellEvent.DISABLED_STYLES_CHANGED, global_disabledStylesChangedHandler);
		}
		
		_globalCell = value;
		
		if (value)
		{
			value.addEventListener(CellEvent.STYLES_CHANGED, global_stylesChangedHandler);
			value.addEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, global_rollOverStylesChangedHandler);
			value.addEventListener(CellEvent.SELECTED_STYLES_CHANGED, global_selectedStylesChangedHandler);
			value.addEventListener(CellEvent.DISABLED_STYLES_CHANGED, global_disabledStylesChangedHandler);
			
			globalStyles.apply(value);
			
			currentGlobalStyles = value.enabled ? value.selected ? globalStyles.selectedStyles : globalStyles.styles : globalStyles.disabledStyles;
		}
	}
	
	[Bindable]
	protected var textField : UITextField;
	
	override protected function createChildren () : void
	{
		super.createChildren();
		
		dataGrid = owner as PaintGrid2;
		
		if (!textField)
		{
			textField = new UITextField();
			textField.styleName = this;
			
			addChild(textField);
		}
	}
	
	override protected function commitProperties () : void
	{
		super.commitProperties();
		
		if (dataChanged && textField && _listData)
		{
			textField.text = _listData.label;
			
			dataChanged = false;
		}
	}
	
	override public function set width (value : Number) : void
	{
		super.width = value;
		
		if (textField)
			textField.width = value;
	}
	
	override public function set height (value : Number) : void
	{
		super.height = value;
		
		if (textField)
			textField.height = value;
	}
	
	override protected function measure () : void
	{
		super.measure();
		
		measuredMinHeight = measuredHeight = info && info.height > textField.measuredHeight ? info.height : (textField.measuredHeight > minHeight ? textField.measuredHeight : minHeight);
	}
	
	private var _colorTo : uint;
	
	public function get colorTo () : uint
	{
		return _colorTo;
	}
	
	public function set colorTo (value : uint) : void
	{
		if (_colorTo == value)
			return;
		
		_colorTo = value;
		
		drawBackground(value, _alphaTo);
	}
	
	private var _alphaTo : Number = 1;
	
	public function get alphaTo () : Number
	{
		return _alphaTo;
	}
	
	public function set alphaTo (value : Number) : void
	{
		if (_alphaTo == value)
			return;
		
		_alphaTo = value;
		
		drawBackground(_colorTo, value);
	}
	
	protected function drawBackground (c : uint, a : Number) : void
	{
		graphics.clear();
		graphics.beginFill(c, a);
		graphics.drawRect(0, 0, width, height);
		graphics.endFill();
	}
	
	override protected function updateDisplayList (w : Number, h : Number) : void
	{
		super.updateDisplayList(w, h);
		
		/*background.width = w;
		 background.height = h;*/
		
		textField.setActualSize(w, h);
		
		if (currentStyles)
		{
			if (rollOverActive || rollOutActive)
			{
				backgroundAlphaEffect.toValue = currentStyles.backgroundAlpha;
				backgroundColorEffect.colorTo = currentStyles.backgroundColor;
				
				backgroundAlphaEffect.play();
				backgroundColorEffect.play();
				
				rollOverActive = false;
				rollOutActive = false;
			}
			else
			{
				backgroundAlphaEffect.fromValue = currentStyles.backgroundAlpha;
				backgroundColorEffect.colorFrom = currentStyles.backgroundColor;
				
				drawBackground(currentStyles.backgroundColor, currentStyles.backgroundAlpha);
			}
			
			/*if (currentStylesChanged || currentStyles.backgroundChanged)
			   {
			   graphics.clear();
			   graphics.beginFill(currentStyles.backgroundColor, currentStyles.backgroundAlpha);
			   graphics.drawRect(0, 0, w, h);
			   graphics.endFill();
			
			   currentStyles.backgroundChanged = false;
			 }*/
			
			if (currentStylesChanged || currentStyles.foregroundChanged)
			{
				textField.textColor = currentStyles.foregroundColor;
				textField.alpha = currentStyles.foregroundAlpha;
				
				currentStyles.foregroundChanged = false;
			}
			
			if (currentStylesChanged || styles.styles.fontStylesChanged)
			{
				if (styles.styles.antiAliasType)
					textField.antiAliasType = styles.styles.antiAliasType;
				
				if (styles.styles.gridFitType)
					textField.gridFitType = styles.styles.gridFitType;
				
				textField.sharpness = styles.styles.sharpness;
				textField.thickness = styles.styles.thickness;
				
				var tf : TextFormat = new TextFormat();
				tf.font = styles.styles.family;
				tf.size = styles.styles.size;
				tf.align = styles.styles.align;
				tf.bold = styles.styles.weight == "bold";
				tf.indent = styles.styles.indent;
				tf.italic = styles.styles.style == "italic";
				tf.kerning = styles.styles.kerning;
				tf.letterSpacing = styles.styles.spacing;
				tf.underline = styles.styles.decoration == "underline";
				
				textField.setTextFormat(tf);
				
				height = info && info.height > textField.measuredHeight ? info.height : (textField.measuredHeight > minHeight ? textField.measuredHeight : minHeight);
				
				styles.styles.fontStylesChanged = false;
			}
			
			currentStylesChanged = false;
		}
	
	/*
	   if (dataGrid && cell)
	   dataGrid.setColumnWidthAt(cell.column, textField.measuredWidth > width ? textField.measuredWidth : width);
	 */
	}
	
	/**
	 * Event handlers
	 */
	
	protected var rollOverActive : Boolean;
	
	protected function rollOverHandler (e : MouseEvent) : void
	{
		if (!cell || cell.selected || !cell.enabled)
			return;
		
		currentStyles = styles.rollOverStyles;
		currentGlobalStyles = globalStyles.rollOverStyles;
		
		rollOverActive = true;
		invalidateDisplayList();
	}
	
	protected var rollOutActive : Boolean;
	
	protected function rollOutHandler (e : MouseEvent) : void
	{
		if (!cell || cell.selected || !cell.enabled)
			return;
		
		currentStyles = styles.styles;
		currentGlobalStyles = globalStyles.styles;
		
		rollOutActive = true;
		invalidateDisplayList();
	}
	
	protected function selectedChangedHandler (e : Event) : void
	{
		if (!cell || !cell.enabled)
			return;
		
		if (cell.selected)
		{
			currentStyles = styles.selectedStyles;
			currentGlobalStyles = globalStyles.selectedStyles;
		}
		else
		{
			currentStyles = styles.styles;
			currentGlobalStyles = globalStyles.styles;
		}
	}
	
	protected function enabledChangedHandler (e : Event) : void
	{
		if (!cell)
			return;
		
		if (cell.enabled)
		{
			currentStyles = cell.selected ? styles.selectedStyles : styles.styles;
			currentGlobalStyles = cell.selected ? globalStyles.selectedStyles : globalStyles.styles;
		}
		else
		{
			currentStyles = styles.disabledStyles;
			currentGlobalStyles = globalStyles.disabledStyles;
		}
	}
	
	protected function stylesChangedHandler (e : CellEvent) : void
	{
		styles.styles.change(e.property, e.newValue);
	}
	
	protected function rollOverStylesChangedHandler (e : CellEvent) : void
	{
		styles.rollOverStyles.change(e.property, e.newValue);
	}
	
	protected function selectedStylesChangedHandler (e : CellEvent) : void
	{
		styles.selectedStyles.change(e.property, e.newValue);
	}
	
	protected function disabledStylesChangedHandler (e : CellEvent) : void
	{
		styles.disabledStyles.change(e.property, e.newValue);
	}
	
	protected function global_stylesChangedHandler (e : CellEvent) : void
	{
		globalStyles.styles.change(e.property, e.newValue);
		
		styles.styles.change(e.property, e.newValue);
	}
	
	protected function global_rollOverStylesChangedHandler (e : CellEvent) : void
	{
		globalStyles.rollOverStyles.change(e.property, e.newValue);
		
		styles.rollOverStyles.change(e.property, e.newValue);
	}
	
	protected function global_selectedStylesChangedHandler (e : CellEvent) : void
	{
		globalStyles.selectedStyles.change(e.property, e.newValue);
		
		styles.selectedStyles.change(e.property, e.newValue);
	}
	
	protected function global_disabledStylesChangedHandler (e : CellEvent) : void
	{
		globalStyles.disabledStyles.change(e.property, e.newValue);
		
		styles.disabledStyles.change(e.property, e.newValue);
	}
	
	protected function heightChangedHandler (e : Event) : void
	{
		height = textField && textField.measuredHeight > info.height ? textField.measuredHeight : info.height;
	}
}
}
