package com.flextras.paintgrid
{
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.utils.ObjectProxy;
	import mx.utils.ObjectUtil;
	
	[Event(name="stylesChanged", type="com.flextras.paintgrid.CellEvent")]
	[Event(name="rollOverStylesChanged", type="com.flextras.paintgrid.CellEvent")]
	[Event(name="selectedStylesChanged", type="com.flextras.paintgrid.CellEvent")]
	[Event(name="disabledStylesChanged", type="com.flextras.paintgrid.CellEvent")]
	public class CellProperties extends Location
	{
		protected var _styles : ObjectProxy = new ObjectProxy;
		
		protected var _rollOverStyles : ObjectProxy = new ObjectProxy;
		
		protected var _selectedStyles : ObjectProxy = new ObjectProxy;
		
		protected var _disabledStyles : ObjectProxy = new ObjectProxy;
		
		[Bindable]
		public var condition : String;
		
		public function CellProperties (row : int, column : int, styles : Object, condition : String = null)
		{
			super(row, column);
			
			this.styles = new ObjectProxy(styles);
			this.condition = condition;
		}
		
		[Bindable(event="stylesChanged")]
		public function get styles () : ObjectProxy
		{
			return _styles;
		}
		
		public function set styles (value : ObjectProxy) : void
		{
			if (!value)
				return;
			
			var oldValue : Object = _styles;
			
			if (!_styles)
			{
				_styles = value;
				_styles.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, styles_changeHandler);
				
				dispatchEvent(getEvent(CellEvent.STYLES_CHANGED, "styles", oldValue, _styles));
			}
			else
				for (var style : String in value)
					_styles[style] = value[style];
		}
		
		[Bindable(event="rollOverStylesChanged")]
		public function get rollOverStyles () : ObjectProxy
		{
			return _rollOverStyles;
		}
		
		public function set rollOverStyles (value : ObjectProxy) : void
		{
			if (!value)
				return;
			
			var oldValue : Object = _rollOverStyles;
			
			if (!_rollOverStyles)
			{
				_rollOverStyles = value;
				_styles.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, rollOverStyles_changeHandler);
				
				dispatchEvent(getEvent(CellEvent.ROLLOVER_STYLES_CHANGED, "rollOverStyles", oldValue, _rollOverStyles));
			}
			else
				for (var rollOverStyle : String in value)
					_rollOverStyles[rollOverStyle] = value[rollOverStyle];
		}
		
		[Bindable(event="selectedStylesChanged")]
		public function get selectedStyles () : ObjectProxy
		{
			return _selectedStyles;
		}
		
		public function set selectedStyles (value : ObjectProxy) : void
		{
			if (!value)
				return;
			
			var oldValue : Object = _selectedStyles;
			
			if (!_selectedStyles)
			{
				_selectedStyles = value;
				_styles.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, selectedStyles_changeHandler);
				
				dispatchEvent(getEvent(CellEvent.SELECTED_STYLES_CHANGED, "selectedStyles", oldValue, _selectedStyles));
			}
			else
				for (var selectedStyle : String in value)
					_selectedStyles[selectedStyle] = value[selectedStyle];
		}
		
		[Bindable(event="disabledStylesChanged")]
		public function get disabledStyles () : ObjectProxy
		{
			return _disabledStyles;
		}
		
		public function set disabledStyles (value : ObjectProxy) : void
		{
			if (!value)
				return;
			
			var oldValue : Object = _disabledStyles;
			
			if (!_disabledStyles)
			{
				_disabledStyles = value;
				_styles.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, disabledStyles_changeHandler);
				
				dispatchEvent(getEvent(CellEvent.DISABLED_STYLES_CHANGED, "disabledStyles", oldValue, _disabledStyles));
			}
			else
				for (var disabledStyle : String in value)
					_disabledStyles[disabledStyle] = value[disabledStyle];
		}
		
		public function equalLocation (cell : Location) : Boolean
		{
			if (!cell)
				return false;
			
			return super.equal(cell);
		}
		
		override public function equal (cell : Location) : Boolean
		{
			if (!cell)
				return false;
			
			// Do we really need this?
			if (cell is CellProperties)
			{
				var info : CellProperties = CellProperties(cell);
				
				return super.equal(cell) && ObjectUtil.compare(info.styles, styles, 0) == 0 && ObjectUtil.compare(info.rollOverStyles, rollOverStyles, 0) == 0 && ObjectUtil.compare(info.selectedStyles, selectedStyles, 0) == 0 && ObjectUtil.compare(info.disabledStyles, disabledStyles, 0) == 0 && info.condition == condition;
			}
			
			return super.equal(cell);
		}
		
		override public function get valid () : Boolean
		{
			return super.valid && styles && typeof(styles) == "object";
		}
		
		protected function getEvent (type : String, property : Object, oldValue : Object, newValue : Object) : CellEvent
		{
			return new CellEvent(type, false, false, PropertyChangeEventKind.UPDATE, property, oldValue, _styles, this);
		}
		
		protected function styles_changeHandler (e : PropertyChangeEvent) : void
		{
			dispatchEvent(getEvent(CellEvent.STYLES_CHANGED, e.property, e.oldValue, e.newValue));
		}
		
		protected function rollOverStyles_changeHandler (e : PropertyChangeEvent) : void
		{
			dispatchEvent(getEvent(CellEvent.ROLLOVER_STYLES_CHANGED, e.property, e.oldValue, e.newValue));
		}
		
		protected function selectedStyles_changeHandler (e : PropertyChangeEvent) : void
		{
			dispatchEvent(getEvent(CellEvent.SELECTED_STYLES_CHANGED, e.property, e.oldValue, e.newValue));
		}
		
		protected function disabledStyles_changeHandler (e : PropertyChangeEvent) : void
		{
			dispatchEvent(getEvent(CellEvent.DISABLED_STYLES_CHANGED, e.property, e.oldValue, e.newValue));
		}
	}
}