package com.flextras.spreadsheet
{
	import com.flextras.calc.Utils;
	import com.flextras.workbook.CalcSheet;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.Canvas;
	import mx.controls.Text;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.core.IDataRenderer;
	import mx.events.FlexEvent;
	
	[Event(name="error", type="com.flextras.spreadsheet.SpreadsheetEvent")]
	[Event(name="warning", type="com.flextras.spreadsheet.SpreadsheetEvent")]
	[Event(name="cellClick", type="com.flextras.spreadsheet.SpreadsheetEvent")]
	[Event(name="cellDoubleClick", type="com.flextras.spreadsheet.SpreadsheetEvent")]
	[Event(name="cellRollOver", type="com.flextras.spreadsheet.SpreadsheetEvent")]
	[Event(name="cellRollOut", type="com.flextras.spreadsheet.SpreadsheetEvent")]
	[Event(name="cellDataChange", type="com.flextras.spreadsheet.SpreadsheetEvent")]
	
	public class SpreadsheetItemRenderer1 extends Text implements IDataRenderer
	{
		
		private var background:Canvas;
		private var backgroundOver:Canvas;
		private var backgroundColor:uint = 0xCCCCCC;
		private var selectedColor:uint = 0xEECC99;
		private var rollOverColor:uint = 0xCCFF99;
		private var _rowIndex:int;
		private var _columnIndex:int;
		private var _cellId:String;
		private var _selected:Boolean;
		private var _editable:Boolean = true;
		private var dragging:Boolean;
		private var dragable:Boolean;
		private var registered:Boolean;
		private var _type:String;

		public function SpreadsheetItemRenderer1()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.height = 18;
			this.doubleClickEnabled = true;
			this.selectable = false;
			this.addEventListener(FlexEvent.PREINITIALIZE, preinit);
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.addEventListener("dataChange", dataChangeHandler);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(MouseEvent.DOUBLE_CLICK, dblClickHandler)
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverhandler);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOuthandler);

			background = new Canvas();
			background.y = -2;
			background.height = CalcSheet.DEF_ROWHEADER_HEIGHT;
			background.width = CalcSheet.DEF_COL_WIDTH;
			background.setStyle("backgroundColor", backgroundColor);
			
			
/*			backgroundOver = new Canvas();
			backgroundOver.y = -2;
			backgroundOver.height = CalcSheet.DEF_ROWHEADER_HEIGHT;
			backgroundOver.width = CalcSheet.DEF_COL_WIDTH;
			backgroundOver.visible = false;
			backgroundOver.setStyle("backgroundColor", rollOverColor);
*/			
			BindingUtils.bindSetter(widthChange,super,"width");
			BindingUtils.bindSetter(heightChange,super,"height");
			
			
			
			//this.addChild(background);
			//this.addChild(backgroundOver);
		}
		
		
		override protected function createChildren() : void
		{
			super.createChildren();
		}
		
		override public function setStyle(styleProp:String, newValue:*) : void
		{
			if(styleProp == "backgroundColor")
			{
				background.setStyle(styleProp, newValue);
				backgroundColor = newValue;
			}
			else if(styleProp == "selectedColor")
			{
				selectedColor = newValue;
			}
			else if(styleProp == "rollOverColor")
			{
				rollOverColor = newValue;
			}
			else
			{
				super.setStyle(styleProp, newValue);
			}
		}
		
		private function register():void
		{
			if(this.owner is ISpreadsheet)
			{
				if(!registered)
				{
					var cevt:SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.CELL_REGISTER, true);
					this.dispatchEvent(cevt);
					
					this.owner.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandlerer);
					this.owner.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandlerer);
					this.owner.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandlerer);

				
					registered = true;
				}

			}
			else
			{
				var wevt:SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.WARNING, true);
				wevt.message = "SpreadsheetItemRenderer1.owner does not implement ISpreadsheet interface"
			}
		}
		
		private function addedToStageHandler(evt:Event):void
		{
			
		}
		
		private function dataChangeHandler(evt:Event):void
		{
			var myListData:DataGridListData = DataGridListData(listData);

			//_rowIndex = myListData.rowIndex;
			_rowIndex = data.rowIndex;
			_columnIndex = myListData.columnIndex;
			_cellId = String(Utils.alphabet[_columnIndex]).toLowerCase() + _rowIndex;
			
			this.text =_cellId + " h: " + data.rowHeight;
			//this.height = data.rowHeight as Number;
			
			BindingUtils.bindSetter(setHeight, data, "rowHeight");
			
			register();
		}

		private function mouseMoveHandlerer(evt:MouseEvent):void
		{
			if(this.mouseY > (this.height - 4) && this.mouseY < (this.height + 4))
			{
				dragable = true;
			}
			else
			{
				dragable = false;
			}
			
			if(dragging)
			{
				//this.height = this.mouseY;
			}
		}
		
		private function mouseDownHandlerer(evt:MouseEvent):void
		{
			if(dragable)
			{
				dragging = true
			}
		}
		
		private function mouseUpHandlerer(evt:MouseEvent):void
		{
			dragging = false;
		}
		
		private function preinit(evt:Event):void
		{
			
		}
		
		private function clickHandler(evt:MouseEvent):void
		{
			dragging = true;
			background.setStyle("backgroundColor", selectedColor);
			var cevt:SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.CELL_CLICK, true);
			this.dispatchEvent(cevt);
		}
		
		private function dblClickHandler(evt:MouseEvent):void
		{
			background.setStyle("backgroundColor", selectedColor);
			var cevt:SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.CELL_DOUBLE_CLICK, true);
			cevt.data = evt;
			this.dispatchEvent(cevt);
		}
		
		private function rollOverhandler(evt:MouseEvent):void
		{
			if(!_selected) background.setStyle("backgroundColor", rollOverColor);
			//if(!_selected) backgroundOver.visible = true;
		}
		
		private function rollOuthandler(evt:MouseEvent):void
		{
			if(!_selected) background.setStyle("backgroundColor", backgroundColor);
			//if(!_selected) backgroundOver.visible = false;
		}
		
		private function setHeight(value:Object):void
		{
			this.height = value as Number;
		}
		
		private function widthChange(value:*):void
		{
			background.width = value;
			//backgroundOver.width = value;
		}
		
		private function heightChange(value:*):void
		{
			background.height = value + 5;
			//backgroundOver.height = value + 5;
		}
		
		
		//////////////////////////////////////////////
		//  GETTERS && SETTERS
		//////////////////////////////////////////////
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
			background.setStyle("backgroundColor", selectedColor);
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set editable(value:Boolean):void
		{
			_editable = value;
		}
		
		public function get editable():Boolean
		{
			return _editable;
		}
		
		public function get rowIndex():int
		{
			return _rowIndex;
		}
		
		public function get columnIndex():int
		{
			return _columnIndex;
		}
		
		public function get cellId():String
		{
			return _cellId;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		
	}
}