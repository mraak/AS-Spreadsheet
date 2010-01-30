package com.flextras.workbook
{
	//import com.flextras.spreadsheet.Spreadsheet2;
	//import com.flextras.spreadsheet.Spreadsheet;
	import com.flextras.spreadsheet.SpreadsheetItemRenderer;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.Canvas;
	
	[Bindable]
	public class CalcSheet extends Canvas
	{
		public static const DEF_COL_WIDTH:Number = 100;
		public static const DEF_ROW_HEIGHT:Number = 20;
		public static const DEF_ROWHEADER_HEIGHT:Number = 22;
		public static const DEF_ROWHEADER_WIDTH:Number = 20;
		public static const DEF_COLHEADER_HEIGHT:Number = 20;
		
		public var grid:Spreadsheet;
		public var objectContainer:Canvas;
		public var rowHeader:RowHeader;
		public var columnHeader:ColumnHeader;
		public var index:int;
		public var fieldStyles:Object;
		
		public function CalcSheet(id:String, rowCount:int = 15, columnCount:int = 8, displayInfo:* = null)
		{
			super();
			this.id = id;
			//this.percentHeight = 100;
			//this.percentWidth = 100;
			//this.height = 350;
			//this.width = 450;
			//this.setStyle("backgroundColor", 0x0000FF);
			fieldStyles = new Object();
			createGrid(rowCount, columnCount);
			createContainer();
			callLater(createRowHeader,[rowCount]);
			callLater(createColumnHeader,[columnCount]);
			if (displayInfo) callLater(buildDisplay,[displayInfo]);
			
		}
		
		private function createGrid(rowCount:int, columnCount:int):void
		{
			grid = new Spreadsheet();
			grid.rowCount = rowCount;
			grid.colCount = columnCount;
			grid.useFlexcelItemRenderer = true;
			grid.editable = true;
			grid.horizontalScrollPolicy="auto"
 			grid.verticalScrollPolicy="off"
			grid.id = this.id;
			grid.sheet = this;

			//grid.width = 1000;
			
			this.addChild(grid);
			grid.validateNow();
			
		}
		
		private function createRowHeader(rowCount:int):void
		{
			rowHeader = new RowHeader(rowCount, this);
			grid.rowHeader = rowHeader;
			grid.variableRowHeight = true;
			grid.wordWrap = true;
			BindingUtils.bindProperty(grid, "height", rowHeader, "height");
			addChild(rowHeader);
			grid.x = 20;

		}
		
		private function createColumnHeader(columnCount:int):void
		{
			columnHeader = new ColumnHeader(columnCount, this);
			columnHeader.x = 20;
			grid.columnHeader = columnHeader;
			grid.showHeaders = false;
			
			BindingUtils.bindProperty(grid, "width", columnHeader, "width");
			addChild(columnHeader);
			var cw:Number = grid.columnWidth;
			grid.y = 20;
			rowHeader.y = 20;
			//grid.setColumnWidthAt(2, 340);
			
		}
		
		
		
		private function createContainer():void
		{
			objectContainer = new Canvas();
			objectContainer.percentHeight = 100;
			objectContainer.percentWidth = 100;
			this.addChild(objectContainer);
		}
		
		private function buildDisplay(displayInfo:*):void
		{
			if(displayInfo is XML)
			{
				var sfd:int = 9;
				for each(var r:XML in displayInfo.rowheights.r)
				{
					rowHeader.setHeaderAndGridHeight(r.@id, r.@h);
				}
				for each(var c:XML in displayInfo.columnwidths.c)
				{
					columnHeader.setHeaderAndGridWidth(c.@id, c.@w);
				}
				for each(var cl:XML in displayInfo.cells.c)
				{
					if(cl.@bgCol) setFieldStyleAt({prop:"backgroundColor", val:cl.@bgCol}, cl.@id);
					if(cl.@fw) setFieldStyleAt({prop:"fontWeight", val:cl.@fw}, cl.@id);
					if(cl.@col) setFieldStyleAt({prop:"color", val:cl.@col}, cl.@id);
				}
			}
			else
			{
				throw(new Error("TypeError: Only XML currently supported for displayInfo"));
			}
		}
		
		public function setFieldStyle(style:Object):void
		{
			for each(var ir:SpreadsheetItemRenderer in grid.selectedRenderers)
			{
				//ir.bgColor = 0x0044FF;
				//ir.bg.setStyle("backgroundColor", 0x0044FF);
				
				ir.setFieldStyle(style);
				//setFieldStyleAt(style, "b1")
			}
		}
		
		public function setFieldStyleAt(style:Object, cellId:String):void
		{
			grid.renderers[cellId].setFieldStyle(style);
			
		}
		
		public function insertColumnAt(index:int):void
		{
			grid.insertColumnAt(index);
			columnHeader.insertColumn(index);
			grid.validateNow();
			
			callLater(recalcColumnSizesUponInsert, [index]);
		}
		
		public function deleteColumn(index:int):void
		{
			grid.deleteColumn(index);	
			columnHeader.deleteColumn(index);
		}
		
		private function recalcColumnSizesUponInsert(index:int):void
		{
			for each(var ci:ColumnHeaderItem in columnHeader.items)
			{
				grid.setColumnWidthAt(ci.index, ci.width);
			}
			recalcRowSizesUponInsert(index);
		}		
		
		public function insertRowAt(index:int):void
		{
			grid.insertRowAt(index);
			rowHeader.insertRow(index);
			grid.validateNow();
			
			callLater(recalcRowSizesUponInsert, [index]);
			
		}
		
		private function recalcRowSizesUponInsert(index:int):void
		{
			for each(var ri:RowHeaderItem in rowHeader.items)
			{
				grid.setRowHeightAt(ri.index, (ri.height - 4));
			}
		}
		
		public function deleteRow(index:int):void
		{
			grid.deleteRow(index);
			rowHeader.deleteRow(index);
		}
		
		public function get columnCount():int
		{
			return grid.colCount;	
		}
		
		public function get rowCount():int
		{
			return grid.rowCount;	
		}
		
		public function get xmlViewData():XML
		{
			//var s:String = "<sheet type='calc' id='" + this.id + "' index='" + this.index + "' rowCount='" +sh.grid.rowCount + "' columnCount='" + sh.grid.columnCount + "'>";
			//s += "</sheet>";
			
			var xSheet:XML = new XML("<sheet/>");
			xSheet.@type = "calc";
			xSheet.@id = this.id;
			xSheet.@index = this.index;
			xSheet.@rowCount = this.grid.rowCount;
			xSheet.@columnCount = this.grid.colCount;
			
			var c:int = 0;
			for each(var o:Object in rowHeader.rowsInfo)
			{
				var r:XML = new XML(<r/>);
				r.@id = o.i;
				r.@h = o.h;
				xSheet.rowheights.r[c] = r;
				c++;
			}
			
			c = 0;
			for each(o in columnHeader.columnsInfo)
			{
				var col:XML = new XML(<c/>);
				col.@id = o.i;
				col.@w = o.w;
				xSheet.columnwidths.c[c] = col;
				c++;
			}
			
			c = 0;
			for each(var rend:SpreadsheetItemRenderer in grid.renderers)
			{
				if(rend.formatted)
				{
					xSheet.cells.cell[c] = rend.formatInfo;
					c++;
				}
			}
			
			
			return xSheet;
		}
		
	}
}