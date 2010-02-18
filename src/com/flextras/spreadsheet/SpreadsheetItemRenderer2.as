package com.flextras.spreadsheet
{
	import flash.events.MouseEvent;

	public class SpreadsheetItemRenderer2 extends SpreadsheetItemRendererBase
	{
		
		private var backgroundColor:uint = 0xCCCCCC;
		private var selectedColor:uint = 0xEECC99;
		private var rollOverColor:uint = 0xCCFF99;
		private var rowResizable:Boolean;
		private var columnResizable:Boolean;
		private var rowResizing:Boolean;
		private var columnResizing:Boolean;
		private var dragging:Boolean;
		
		[Event(name="error", type="com.flextras.spreadsheet.SpreadsheetEvent")]
		[Event(name="warning", type="com.flextras.spreadsheet.SpreadsheetEvent")]
		[Event(name="cellClick", type="com.flextras.spreadsheet.SpreadsheetEvent")]
		[Event(name="cellDoubleClick", type="com.flextras.spreadsheet.SpreadsheetEvent")]
		[Event(name="cellRollOver", type="com.flextras.spreadsheet.SpreadsheetEvent")]
		[Event(name="cellRollOut", type="com.flextras.spreadsheet.SpreadsheetEvent")]
		[Event(name="cellDataChange", type="com.flextras.spreadsheet.SpreadsheetEvent")]
		
		public function SpreadsheetItemRenderer2()
		{
			super();
			init();
		}
		
		private function init():void
		{
			

		}
		
		
		override protected function mouseMoveHandler(e:MouseEvent):void
		{
			
			// resize rows
			if(this.mouseY > (this.height - 4) && this.mouseY < (this.height + 4))
			{
				rowResizable = true;
			}
			else
			{
				rowResizable = false;
			}
			
			if(rowResizing)
			{
				//this.height = this.mouseY;
				Spreadsheet2(this.owner).setRowHeightAt(this.rowIndex, this.mouseY);
			}
			
			// resize columns
			if(this.mouseX > (this.width - 4) && this.mouseX < (this.width + 4))
			{
				columnResizable = true;
			}
			else
			{
				columnResizable = false;
			}
			//trace(this.rowIndex + " : " + this.columnIndex + "  - " + this.cellId);
			if(columnResizing)
			{
				//this.width = this.mouseX;
				//trace(this.rowIndex + " : " + this.columnIndex + "  - " + this.cellId);
				Spreadsheet2(this.owner).setColumnWidthAt(this.columnIndex, this.mouseX);
			}

		}
		
		override protected function mouseDownHandler(e:MouseEvent):void
		{
			if(rowResizable)
			{
				if(Spreadsheet2(this.owner).cellResizePolicy == SpreadsheetCellResizePolicy.ALL) 
					rowResizing = true;
			}
			
			if(columnResizable)
			{
				if(Spreadsheet2(this.owner).cellResizePolicy == SpreadsheetCellResizePolicy.ALL) 
					columnResizing = true;
			}

		}

		override protected function mouseUpHandler(e:MouseEvent):void
		{
			rowResizing = false;
			columnResizing = false;
		}


	}
}