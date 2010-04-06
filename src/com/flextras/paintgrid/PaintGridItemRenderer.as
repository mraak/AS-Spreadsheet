package com.flextras.paintgrid
{
import com.flextras.calc.FormulaLogic;

import flash.events.Event;
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

public class PaintGridItemRenderer extends UIComponent implements IListItemRenderer, IDropInListItemRenderer
{
	public function PaintGridItemRenderer ()
	{
		super();
		
		backgroundColorEffect.colorPropertyName = "colorTo";
		backgroundAlphaEffect.property = "alphaTo";
		backgroundColorEffect.duration = backgroundAlphaEffect.duration = 500;
		
		addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
	}
	
	protected const styles : CellStyles = new CellStyles(this as PaintGridItemRenderer);
	
	protected const globalStyles : CellStyles = new CellStyles(this as PaintGridItemRenderer);
	
	protected const conditionalStyles : CellStyles = new CellStyles(this as PaintGridItemRenderer);
	
	protected const globalConditionalStyles : CellStyles = new CellStyles(this as PaintGridItemRenderer);
	
	protected const backgroundColorEffect : AnimateColor = new AnimateColor(this);
	
	protected const backgroundAlphaEffect : AnimateProperty = new AnimateProperty(this);
	
	protected var _currentStyles : BasicStyles;
	
	protected var currentStylesChanged : Boolean;
	
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
	
	protected var _currentConditionalStyles : BasicStyles;
	
	protected var currentConditionalStylesChanged : Boolean;
	
	protected function get currentConditionalStyles () : BasicStyles
	{
		return _currentConditionalStyles;
	}
	
	protected function set currentConditionalStyles (value : BasicStyles) : void
	{
		if (value === _currentConditionalStyles)
			return;
		
		_currentConditionalStyles = value;
		currentConditionalStylesChanged = true;
		
		invalidateDisplayList();
	
	}
	
	protected var _currentGlobalConditionalStyles : BasicStyles;
	
	protected var currentGlobalConditionalStylesChanged : Boolean;
	
	protected function get currentGlobalConditionalStyles () : BasicStyles
	{
		return _currentGlobalConditionalStyles;
	}
	
	protected function set currentGlobalConditionalStyles (value : BasicStyles) : void
	{
		if (value === _currentGlobalConditionalStyles)
			return;
		
		_currentGlobalConditionalStyles = value;
		currentGlobalConditionalStylesChanged = true;
		
		invalidateDisplayList();
	
	}
	
	protected var _dataGrid : PaintGrid;
	
	public function get dataGrid () : PaintGrid
	{
		return _dataGrid;
	}
	
	public function set dataGrid (value : PaintGrid) : void
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
		conditionalStyles.assign(globalConditionalStyles);
		
		if (_cell)
		{
			_cell.removeEventListener("enabledChanged", enabledChangedHandler);
			_cell.removeEventListener("selectedChanged", selectedChangedHandler);
			_cell.removeEventListener(CellEvent.STYLES_CHANGED, stylesChangedHandler);
			_cell.removeEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, rollOverStylesChangedHandler);
			_cell.removeEventListener(CellEvent.SELECTED_STYLES_CHANGED, selectedStylesChangedHandler);
			_cell.removeEventListener(CellEvent.DISABLED_STYLES_CHANGED, disabledStylesChangedHandler);
			_cell.removeEventListener(CellEvent.CONDITION_CHANGED, conditionChangedHandler);
			
			_cell.condition.removeEventListener("enabledChanged", condition_enabledChangedHandler);
			_cell.condition.addEventListener(CellEvent.STYLES_CHANGED, condition_stylesChangedHandler);
			_cell.condition.addEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, condition_rollOverStylesChangedHandler);
			_cell.condition.addEventListener(CellEvent.SELECTED_STYLES_CHANGED, condition_selectedStylesChangedHandler);
			_cell.condition.addEventListener(CellEvent.DISABLED_STYLES_CHANGED, condition_disabledStylesChangedHandler);
		}
		
		_cell = value;
		
		invalidateSize();
		invalidateDisplayList();
		
		if (value)
		{
			value.addEventListener("enabledChanged", enabledChangedHandler);
			value.addEventListener("selectedChanged", selectedChangedHandler);
			value.addEventListener(CellEvent.STYLES_CHANGED, stylesChangedHandler);
			value.addEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, rollOverStylesChangedHandler);
			value.addEventListener(CellEvent.SELECTED_STYLES_CHANGED, selectedStylesChangedHandler);
			value.addEventListener(CellEvent.DISABLED_STYLES_CHANGED, disabledStylesChangedHandler);
			value.addEventListener(CellEvent.CONDITION_CHANGED, conditionChangedHandler);
			
			value.condition.addEventListener("enabledChanged", condition_enabledChangedHandler);
			value.condition.addEventListener(CellEvent.STYLES_CHANGED, condition_stylesChangedHandler);
			value.condition.addEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, condition_rollOverStylesChangedHandler);
			value.condition.addEventListener(CellEvent.SELECTED_STYLES_CHANGED, condition_selectedStylesChangedHandler);
			value.condition.addEventListener(CellEvent.DISABLED_STYLES_CHANGED, condition_disabledStylesChangedHandler);
			
			styles.apply(value);
			conditionalStyles.apply(value.condition);
			
			currentStyles = value.enabled
				? value.selected
					? styles.selectedStyles
					: styles.styles
				: styles.disabledStyles;
			
			currentConditionalStyles = value.enabled
				? value.selected
					? conditionalStyles.selectedStyles
					: conditionalStyles.styles
				: conditionalStyles.disabledStyles;
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
			_globalCell.removeEventListener(CellEvent.CONDITION_CHANGED, global_conditionChangedHandler);
			
			_globalCell.condition.removeEventListener(CellEvent.STYLES_CHANGED, global_condition_stylesChangedHandler);
			_globalCell.condition.removeEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, global_condition_rollOverStylesChangedHandler);
			_globalCell.condition.removeEventListener(CellEvent.SELECTED_STYLES_CHANGED, global_condition_selectedStylesChangedHandler);
			_globalCell.condition.removeEventListener(CellEvent.DISABLED_STYLES_CHANGED, global_condition_disabledStylesChangedHandler);
		}
		
		_globalCell = value;
		
		if (value)
		{
			value.addEventListener(CellEvent.STYLES_CHANGED, global_stylesChangedHandler);
			value.addEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, global_rollOverStylesChangedHandler);
			value.addEventListener(CellEvent.SELECTED_STYLES_CHANGED, global_selectedStylesChangedHandler);
			value.addEventListener(CellEvent.DISABLED_STYLES_CHANGED, global_disabledStylesChangedHandler);
			value.addEventListener(CellEvent.CONDITION_CHANGED, global_conditionChangedHandler);
			
			value.condition.addEventListener(CellEvent.STYLES_CHANGED, global_condition_stylesChangedHandler);
			value.condition.addEventListener(CellEvent.ROLLOVER_STYLES_CHANGED, global_condition_rollOverStylesChangedHandler);
			value.condition.addEventListener(CellEvent.SELECTED_STYLES_CHANGED, global_condition_selectedStylesChangedHandler);
			value.condition.addEventListener(CellEvent.DISABLED_STYLES_CHANGED, global_condition_disabledStylesChangedHandler);
			
			globalStyles.apply(value);
			globalConditionalStyles.apply(value.condition);
			
			currentGlobalStyles = value.enabled
				? value.selected
					? globalStyles.selectedStyles
					: globalStyles.styles
				: globalStyles.disabledStyles;
			
			currentGlobalConditionalStyles = value.enabled
				? value.selected
					? globalConditionalStyles.selectedStyles
					: globalConditionalStyles.styles
				: globalConditionalStyles.disabledStyles;
		}
	}
	
	[Bindable]
	protected var textField : UITextField;
	
	override protected function createChildren () : void
	{
		super.createChildren();
		
		dataGrid = owner as PaintGrid;
		
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
		
		textField.setActualSize(w, h);
		
		var s : BasicStyles, ss : Styles;
		
		if(cell)
		{
			if(cell.conditionEnabled && cell.condition.operatorValid && textField && FormulaLogic.compare(parseFloat(cell.condition.leftValid
				? cell.condition.left : textField.text)
				, cell.condition.operator
				, parseFloat(cell.condition.right)))
			{
				s = currentConditionalStyles;
				ss = conditionalStyles.styles;
			}
			else
			{
				s = currentStyles;
				ss = styles.styles;
			}
		}
		/*else
		if(globalCell)
		{
			if(globalCell.condition.operatorValid && textField && FormulaLogic.compare(parseFloat(globalCell.condition.leftValid
				? globalCell.condition.left : textField.text)
				, globalCell.condition.operator
				, parseFloat(globalCell.condition.right)))
			{
				s = currentGlobalConditionalStyles;
				ss = globalConditionalStyles.styles;
			}
			else
			{
				s = currentGlobalStyles;
				ss = globalStyles.styles;
			}
		}*/
		
		currentStylesChanged = true;
		
		if (s)
		{
			if (rollOverActive || rollOutActive)
			{
				backgroundAlphaEffect.toValue = s.backgroundAlpha;
				backgroundColorEffect.colorTo = s.backgroundColor;
				
				backgroundAlphaEffect.play();
				backgroundColorEffect.play();
				
				rollOverActive = false;
				rollOutActive = false;
			}
			else
			{
				backgroundAlphaEffect.fromValue = s.backgroundAlpha;
				backgroundColorEffect.colorFrom = s.backgroundColor;
				
				drawBackground(s.backgroundColor, s.backgroundAlpha);
			}
			
			/*if (currentStylesChanged || s.backgroundChanged)
			   {
			   graphics.clear();
			   graphics.beginFill(s.backgroundColor, s.backgroundAlpha);
			   graphics.drawRect(0, 0, w, h);
			   graphics.endFill();
			
			   s.backgroundChanged = false;
			 }*/
			
			if (currentStylesChanged || s.foregroundChanged)
			{
				textField.textColor = s.foregroundColor;
				textField.alpha = s.foregroundAlpha;
				
				s.foregroundChanged = false;
			}
			
			if (currentStylesChanged || ss.fontStylesChanged)
			{
				if (ss.antiAliasType)
					textField.antiAliasType = ss.antiAliasType;
				
				if (ss.gridFitType)
					textField.gridFitType = ss.gridFitType;
				
				textField.sharpness = ss.sharpness;
				textField.thickness = ss.thickness;
				
				var tf : TextFormat = new TextFormat();
				tf.font = ss.family;
				tf.size = ss.size;
				tf.align = ss.align;
				tf.bold = ss.weight == "bold";
				tf.indent = ss.indent;
				tf.italic = ss.style == "italic";
				tf.kerning = ss.kerning;
				tf.letterSpacing = ss.spacing;
				tf.underline = ss.decoration == "underline";
				
				textField.setTextFormat(tf);
				
				//measuredHeight = info && info.height > textField.measuredHeight ? info.height : (textField.measuredHeight > minHeight ? textField.measuredHeight : minHeight);
				invalidateSize();
				ss.fontStylesChanged = false;
			}
			
			currentStylesChanged = false;
			currentConditionalStylesChanged = false;
		}
	
	/*
	   if (dataGrid && cell)
	   dataGrid.setColumnWidthAt(cell.column, textField.measuredWidth > width ? textField.measuredWidth : width);
	 */
	}
	
	/**
	 * Event handlers
	 */
	
	protected var useRollOver : Boolean;
	
	protected var rollOverActive : Boolean;
	
	protected function rollOverHandler (e : MouseEvent) : void
	{
		if (!cell || cell.selected || !cell.enabled)
			return;
		
		currentStyles = styles.rollOverStyles;
		currentGlobalStyles = globalStyles.rollOverStyles;
		currentConditionalStyles = conditionalStyles.rollOverStyles;
		
		backgroundColorEffect.stop();
		backgroundAlphaEffect.stop();
		
		if (useRollOver)
		{
			rollOverActive = true;
			invalidateDisplayList();
		}
	}
	
	protected var rollOutActive : Boolean;
	
	protected function rollOutHandler (e : MouseEvent) : void
	{
		if (!cell || cell.selected || !cell.enabled)
			return;
		
		currentStyles = styles.styles;
		currentGlobalStyles = globalStyles.styles;
		currentConditionalStyles = conditionalStyles.styles;
		
		backgroundColorEffect.stop();
		backgroundAlphaEffect.stop();
		
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
			currentConditionalStyles = conditionalStyles.selectedStyles;
		}
		else
		{
			currentStyles = styles.styles;
			currentGlobalStyles = globalStyles.styles;
			currentConditionalStyles = conditionalStyles.styles;
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
			currentConditionalStyles = cell.selected ? conditionalStyles.selectedStyles : conditionalStyles.styles;
		}
		else
		{
			currentStyles = styles.disabledStyles;
			currentGlobalStyles = globalStyles.disabledStyles;
			currentConditionalStyles = conditionalStyles.disabledStyles;
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
	
	protected function conditionChangedHandler (e : Event) : void
	{
		invalidateDisplayList();
	}
	
	protected function condition_enabledChangedHandler (e : Event) : void
	{
		if (!cell)
			return;
		
		cell.enabled = cell.condition.enabled;
	}
	
	protected function condition_stylesChangedHandler (e : CellEvent) : void
	{
		conditionalStyles.styles.change(e.property, e.newValue);
	}
	
	protected function condition_rollOverStylesChangedHandler (e : CellEvent) : void
	{
		conditionalStyles.rollOverStyles.change(e.property, e.newValue);
	}
	
	protected function condition_selectedStylesChangedHandler (e : CellEvent) : void
	{
		conditionalStyles.selectedStyles.change(e.property, e.newValue);
	}
	
	protected function condition_disabledStylesChangedHandler (e : CellEvent) : void
	{
		conditionalStyles.disabledStyles.change(e.property, e.newValue);
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
	
	protected function global_conditionChangedHandler (e : Event) : void
	{
		invalidateDisplayList();
	}
	
	protected function global_condition_stylesChangedHandler (e : CellEvent) : void
	{
		globalConditionalStyles.styles.change(e.property, e.newValue);
		
		globalStyles.styles.change(e.property, e.newValue);
	}
	
	protected function global_condition_rollOverStylesChangedHandler (e : CellEvent) : void
	{
		globalConditionalStyles.rollOverStyles.change(e.property, e.newValue);
		
		globalStyles.rollOverStyles.change(e.property, e.newValue);
	}
	
	protected function global_condition_selectedStylesChangedHandler (e : CellEvent) : void
	{
		globalConditionalStyles.selectedStyles.change(e.property, e.newValue);
		
		globalStyles.selectedStyles.change(e.property, e.newValue);
	}
	
	protected function global_condition_disabledStylesChangedHandler (e : CellEvent) : void
	{
		globalConditionalStyles.disabledStyles.change(e.property, e.newValue);
		
		globalStyles.disabledStyles.change(e.property, e.newValue);
	}
	
	protected function heightChangedHandler (e : Event) : void
	{
		//measuredHeight = textField && textField.measuredHeight > info.height ? textField.measuredHeight : info.height;
		invalidateSize();
	}
	
	override public function styleChanged (styleProp : String) : void
	{
		super.styleChanged(styleProp);
		
		var value : Object;
		
		if ((value = getStyle("cellColor")) || (value = getStyle("color")))
			globalStyles.styles.foregroundColor = value as uint;
		
		if ((value = getStyle("cellAlpha")) || (value = getStyle("alpha")))
			globalStyles.styles.foregroundAlpha = value as Number;
		
		if ((value = getStyle("cellBackgroundColor")) || (value = getStyle("backgroundColor")))
			globalStyles.styles.backgroundColor = value as uint;
		
		if ((value = getStyle("cellBackgroundAlpha")) || (value = getStyle("backgroundAlpha")))
			globalStyles.styles.backgroundAlpha = value as Number;
		
		if ((value = getStyle("align"))) // textAlign
			globalStyles.styles.align = value as String;
		
		if ((value = getStyle("fontAntiAliasType")))
			globalStyles.styles.antiAliasType = value as String;
		
		if ((value = getStyle("textDecoration")))
			globalStyles.styles.decoration = value as String;
		
		if ((value = getStyle("fontFamily")))
			globalStyles.styles.family = value as String;
		
		if ((value = getStyle("fontGridFitType")))
			globalStyles.styles.gridFitType = value as String;
		
		if ((value = getStyle("textIndent")))
			globalStyles.styles.indent = value as int;
		
		if ((value = getStyle("kerning")))
			globalStyles.styles.kerning = value as Boolean;
		
		if ((value = getStyle("fontSharpness")))
			globalStyles.styles.sharpness = value as Number;
		
		if ((value = getStyle("fontSize")))
			globalStyles.styles.size = value as uint;
		
		if ((value = getStyle("spacing")))
			globalStyles.styles.spacing = value as int;
		
		if ((value = getStyle("fontStyle")))
			globalStyles.styles.style = value as String;
		
		if ((value = getStyle("fontThickness")))
			globalStyles.styles.thickness = value as Number;
		
		if ((value = getStyle("fontWeight")))
			globalStyles.styles.weight = value as String;
		
		// Roll over styles
		
		/*if ((value = getStyle("useRollOver")))
		 useRollOver = value as Boolean;*/
		
		if ((value = getStyle("cellRollOverColor")) || (value = getStyle("textRollOverColor")))
			globalStyles.rollOverStyles.foregroundColor = value as uint;
		
		if ((value = getStyle("cellRollOverAlpha")) || (value = getStyle("textRollOverAlpha")))
			globalStyles.rollOverStyles.foregroundAlpha = value as Number;
		
		if ((value = getStyle("cellRollOverBackgroundColor")) || (value = getStyle("rollOverColor")))
			globalStyles.rollOverStyles.backgroundColor = value as uint;
		
		if ((value = getStyle("cellRollOverBackgroundAlpha")) || (value = getStyle("rollOverAlpha")))
			globalStyles.rollOverStyles.backgroundAlpha = value as Number;
		
		// Selected styles
		
		if ((value = getStyle("cellSelectedColor")) || (value = getStyle("textSelectedColor")))
			globalStyles.selectedStyles.foregroundColor = value as uint;
		
		if ((value = getStyle("cellSelectedAlpha")) || (value = getStyle("textSelectedAlpha")))
			globalStyles.selectedStyles.foregroundAlpha = value as Number;
		
		if ((value = getStyle("cellSelectedBackgroundColor")) || (value = getStyle("selectionColor")))
			globalStyles.selectedStyles.backgroundColor = value as uint;
		
		if ((value = getStyle("cellSelectedBackgroundAlpha")) || (value = getStyle("selectionAlpha")))
			globalStyles.selectedStyles.backgroundAlpha = value as Number;
		
		// Disabled styles
		
		if ((value = getStyle("cellDisabledColor")) || (value = getStyle("disabledColor")))
			globalStyles.disabledStyles.foregroundColor = value as uint;
		
		if ((value = getStyle("cellDisabledAlpha")) || (value = getStyle("disabledAlpha")))
			globalStyles.disabledStyles.foregroundAlpha = value as Number;
		
		if ((value = getStyle("cellDisabledBackgroundColor")) || (value = getStyle("backgroundDisabledColor")))
			globalStyles.disabledStyles.backgroundColor = value as uint;
		
		if ((value = getStyle("cellDisabledBackgroundAlpha")) || (value = getStyle("backgroundDisabledAlpha")))
			globalStyles.disabledStyles.backgroundAlpha = value as Number;
	}
}
}
