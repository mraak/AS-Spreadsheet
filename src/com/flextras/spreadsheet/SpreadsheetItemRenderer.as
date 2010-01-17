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

	public class SpreadsheetItemRenderer extends Text implements IDataRenderer
	{
		
		public var bg:Canvas;
		public var bgColor:uint;
		public var selectedColor:uint;
		public var rollOverColor:uint;
		public var borderColor:uint;
		public var inited:Boolean;
		public var rowIndex:int;
		public var columnIndex:int;
		public var cellId:String;
		public var formatted:Boolean;
		private var bLeft:Canvas;
		private var bTop:Canvas;
		private var bRight:Canvas;
		private var bBottom:Canvas;
		private var _selected:Boolean;
		private var _width:Number;
		private var _widthChanged:Boolean;
		
		public function SpreadsheetItemRenderer()
		{
			super();
			init();
			callLater(buildComplete);
		}
		
		private function init():void
		{
			bgColor = 0xCCCCCC;
			selectedColor = 0xEECC99;
			rollOverColor = 0xccff99;
			borderColor = 0xFFFFFF;
			
			this.height = 18;
			this.doubleClickEnabled = true;
			this.selectable = false;
			this.addEventListener(FlexEvent.PREINITIALIZE, preinit);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(MouseEvent.DOUBLE_CLICK, dblClickHandler)
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverhandler);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOuthandler);
			
			buildBackground();
			//buildBorder();
		}
		/*
		override protected function createChildren():void
		{
			super.createChildren();
			//buildBackground();

		}
		*/
		/*
		override protected function commitProperties():void
		{
			super.commitProperties();
			//trace("cp>  mw: " + super.measuredWidth);
			if(_widthChanged)
			{
				_widthChanged = false;
				bg.width = _width;
			}
			invalidateDisplayList();
		}
		*/
		/*		
		override public function set width(value:Number):void
		{
			super.width = value;
			//bg.width = value;
			//trace("w: " + value);
			_width  = value;
			_widthChanged = true;
			invalidateProperties();
		}
		*/
		
		/*
		override protected function setActualSize(w:Number, h:Number):void
		{
			trace("w: " + w);
		}*/
		
		/*
		override public function get width():Number
		{
			return super.width;
		}
		*/
		private function buildBackground():void
		{
			
			bg = new Canvas();
			bg.y = -2;
			bg.setStyle("backgroundColor", bgColor);
			//bg.height = CalcSheet.DEF_ROWHEADER_HEIGHT + 3;
			bg.height = CalcSheet.DEF_ROWHEADER_HEIGHT;
			bg.width = CalcSheet.DEF_COL_WIDTH;
			//bg.width = 40;
			//widthChange(super.width);
			//BindingUtils.bindProperty(bg,"width",this,"width");
			BindingUtils.bindSetter(widthChange,super,"width");
			BindingUtils.bindSetter(heightChange,super,"height");
			
			this.addChild(bg);
		}
		
		private function preinit(evt:Event):void
		{
			addEventListener("dataChange", handleDataChanged);
		}
		
		private function handleDataChanged(evt:Event):void 
		{
			 // Cast listData to DataGridListData. 
            var myListData:DataGridListData = DataGridListData(listData);
            
            // Access information about the data passed 
            // to the cell renderer.
            rowIndex = myListData.rowIndex;
            columnIndex = myListData.columnIndex;
            
            cellId = String(Utils.alphabet[columnIndex]).toLowerCase() + rowIndex;
            
			this.text = cellId;
           // trace("row index: " + String(myListData.rowIndex) + " column index: " + String(myListData.columnIndex) + " >>> " + this.text);
			registerWithOwner();
		}
		
		private function registerWithOwner():void
		{
			if(this.owner is Spreadsheet)
			{
				var fg:ISpreadsheet = ISpreadsheet(this.owner);
				fg.renderers[cellId] = this;
			}
			else
			{
			}
		}
		
		private function buildComplete():void
		{
			inited = true;
		}
		
		private function widthChange(value:*):void
		{
			//trace("wc: " + value);
			//if(inited)
			//{
				bg.width = value;
				if(bRight) bRight.x = value - 2;
				if(bTop) bTop.width = value;
				if(bBottom) bBottom.width = value;
				
			//}
		}
		private function heightChange(value:*):void
		{
			if(inited)
			{
				bg.height = value + 5;
				if(bLeft) bLeft.height = value + 5;
				if(bRight) bRight.height = value + 5;
				if(bBottom) bBottom.y = value;
			}
		}
		
		private function buildBorder():void
		{
			bLeft = new Canvas();
			bLeft.width = 2;
			bLeft.height = CalcSheet.DEF_ROWHEADER_HEIGHT + 3;
			bLeft.x = -1;
			bLeft.y = -3;
			bLeft.setStyle("backgroundColor", borderColor);
			//bLeft.visible = false;
			
			bTop = new Canvas();
			bTop.width = CalcSheet.DEF_COL_WIDTH;
			bTop.height = 2;
			bTop.x = -1;
			bTop.y = -3;
			bTop.setStyle("backgroundColor", borderColor);
			//bTop.visible = false;

			bRight = new Canvas();
			bRight.width = 2;
			bRight.height = CalcSheet.DEF_ROWHEADER_HEIGHT + 3;
			bRight.x = CalcSheet.DEF_COL_WIDTH - 2;
			bRight.y = -3;
			bRight.setStyle("backgroundColor", borderColor);
			//bRight.visible = false;
			
			bBottom = new Canvas();
			bBottom.width = CalcSheet.DEF_COL_WIDTH;
			bBottom.height = 2;
			bBottom.x = -1;
			bBottom.y = CalcSheet.DEF_ROWHEADER_HEIGHT - 4;
			bBottom.setStyle("backgroundColor", borderColor);
			//bBottom.visible = false;
				
			addChild(bLeft);
			addChild(bTop);
			addChild(bRight);
			addChild(bBottom);
		}
		
		private function clickHandler(evt:MouseEvent):void
		{
			var o:int = 9;
			//bg.setStyle("backgroundColor", 0xFFCC99);
			Spreadsheet(this.owner).itemRendererClick(this, evt);
		}
		
		private function dblClickHandler(evt:MouseEvent):void
		{
			var o:int = 9;
			//bg.setStyle("backgroundColor", 0xCCCCCC);
			Spreadsheet(this.owner).itemRendererDoubleClick(this, evt);
		}
		
		private function rollOverhandler(evt:MouseEvent):void
		{
			if(!_selected) bg.setStyle("backgroundColor", rollOverColor);
			Spreadsheet(this.owner).itemRendererRollOver(this, evt);
		}
		
		private function rollOuthandler(evt:MouseEvent):void
		{
			if(!_selected) bg.setStyle("backgroundColor", bgColor);
			Spreadsheet(this.owner).itemRendererRollOut(this, evt);
		}
		
		public function setFieldStyle(style:Object):void
		{
			formatted = true;
			if(String(style.prop).substr(0,6) == "border")
			{
				if(style.prop == "border")
				{
					showBorder(style.val);
				}
				else if(style.prop == "borderColor")
				{
					setBorderColor(style.val);
				}
			}
			else if (String(style.prop) == "backgroundColor")
			{
				style.val = uint(style.val);
				bg.setStyle(style.prop, style.val);
				//bg.setStyle("backgroundColor", 0x0000FF);
				bgColor = style.val;
			}
			else if(style.prop == "color" || style.prop == "fontWeight")
			{
				this.setStyle(style.prop, style.val);
				
			}
		}
		
		public function setBorderColor(color:uint):void
		{
			bLeft.setStyle("backgroundColor", color);
			bTop.setStyle("backgroundColor", color);
			bRight.setStyle("backgroundColor", color);
			bBottom.setStyle("backgroundColor", color);
		}
		
		public function showBorder(show:Boolean):void
		{
			bLeft.visible = show;
			bTop.visible = show;
			bRight.visible = show;
			bBottom.visible = show;
		}
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
			if(_selected)
			{
				bg.setStyle("backgroundColor", selectedColor);
			}
			else
			{
				bg.setStyle("backgroundColor", bgColor);
			}
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function get formatInfo():XML
		{
			var xf:XML = <c/>;
			xf.@id = cellId;
			xf.@bgCol = bgColor;
			xf.@fw = this.getStyle("fontWeight");
			
			xf.@col = this.getStyle("color");
			//xf.color = bgColor;
			
			return xf;
		}
		
		/*
		override public function set height(value:Number):void
		{
			super.height = value;
			bg.height = value
		}
		*/
		
		public function get delete_realHeight():Number
		{
			return (super.height + 3);
		}
		
	}
}