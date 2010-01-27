package com.flextras.paintgrid
{
	import flash.events.Event;
	
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.ListBaseContentHolder;
	import mx.core.ClassFactory;
	import mx.core.ScrollPolicy;
	import mx.core.mx_internal;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.utils.ObjectProxy;
	
	use namespace mx_internal;
	
	public class PaintGrid extends DataGrid
	{
		public function PaintGrid ()
		{
			super();
			
			variableRowHeight = true;
			horizontalScrollPolicy = ScrollPolicy.AUTO;
			itemRenderer = new ClassFactory(PaintGridItemRenderer);
		}
		
		[ArrayElementType("CellProperties")]
		protected var cells : Array = [];
		
		[ArrayElementType("CellProperties")]
		protected var modifiedCells : Array = [];
		
		public function getModifiedCellProperties () : Array
		{
			return modifiedCells;
		}
		
		public function getMultipleCellProperties () : Array
		{
			return cells;
		}
		
		public function setMultipleCellProperties (cells : Array) : void
		{
			for each (var cell : CellProperties in cells)
				setCellProperties(cell);
		}
		
		public function getCellProperties (at : Location) : CellProperties
		{
			if (!at || !at.valid)
				return null;
			
			for each (var cell : CellProperties in cells)
				if (cell.equalLocation(at))
					return cell;
			
			return null;
		}
		
		public function setCellProperties (value : CellProperties) : void
		{
			if (!value || !value.valid)
				return;
			
			modifiedCells.push(value);
			
			for each (var cell : CellProperties in cells)
				if (cell.equalLocation(value))
				{
					cell.styles = value.styles;
					cell.condition = value.condition;
					
					return;
				}
			
			cells.push(value);
		}
		
		public function getCellPropertiesAt (row : int, column : int) : CellProperties
		{
			if (row < 0 || column < 0)
				return null;
			
			for each (var cell : CellProperties in cells)
				if (cell.row == row && cell.column == column)
					return cell;
			
			return null;
		}
		
		public function setCellPropertiesAt (row : int, column : int, styles : Object, condition : String = null) : void
		{
			var cell : CellProperties = new CellProperties(row, column, styles, condition);
			
			setCellProperties(cell);
		}
		
		public function getMultipleCellPropertiesInRange (range : Range) : Array
		{
			if (!range || !range.valid)
				return null;
			
			var result : Array;
			
			for each (var cell : CellProperties in cells)
				if (cell.inRange(range))
				{
					if (!result)
						result = [];
					
					result.push(cell);
				}
			
			return result;
		}
		
		public function setMultipleCellPropertiesInRange (range : Range, styles : Object, condition : String = null) : void
		{
			if (!range || !range.valid || !styles)
				return;
			
			for each (var cell : CellProperties in cells)
				if (cell.inRange(range))
				{
					cell.styles = new ObjectProxy(styles);
					cell.condition = condition;
				}
		}
		
		public function getMultipleCellPropertiesInRangeBy (start : Location, end : Location) : Array
		{
			var range : Range = new Range(start, end);
			
			return getMultipleCellPropertiesInRange(range);
		}
		
		public function setMultipleCellPropertiesInRangeBy (start : Location, end : Location, styles : Object, condition : String = null) : void
		{
			var range : Range = new Range(start, end);
			
			setMultipleCellPropertiesInRange(range, styles, condition);
		}
		
		[ArrayElementType("Column")]
		protected var columnWidths : Array = [];
		
		protected var columnWidthsChanged : Boolean;
		
		public function getColumnWidthAt (index : int) : Number
		{
			if (value < 0)
				return -1;
			
			for each (var column : Column in columnWidths)
				if (column.index == index)
					return column.width;
			
			return -1;
		}
		
		public function setColumnWidthAt (index : int, value : Number) : void
		{
			if (index < 0 || value < 0)
				return;
			
			for each (var column : Column in columnWidths)
				if (column.index == index)
				{
					column.width = value;
					
					columnWidthsChanged = true;
					
					invalidateProperties();
					
					return;
				}
			
			columnWidths.push(new Column(index, value));
			
			columnWidthsChanged = true;
			
			invalidateProperties();
		}
		
		[ArrayElementType("Row")]
		protected var rowHeights : Array = [];
		
		protected var rowHeightsChanged : Boolean;
		
		public function getRowHeightAt (index : int) : Number
		{
			if (value < 0)
				return -1;
			
			for each (var row : Row in rowHeights)
				if (row.index == index)
					return row.height;
			
			return -1;
		}
		
		public function setRowHeightAt (index : int, value : Number) : void
		{
			if (index < 0 || value < 0)
				return;
			
			for each (var row : Row in rowHeights)
				if (row.index == index)
				{
					row.height = value;
					
					rowHeightsChanged = true;
					
					invalidateProperties();
					
					return;
				}
			
			rowHeights.push(new Row(index, value));
			
			rowHeightsChanged = true;
			invalidateSize();
		}
		
		override protected function commitProperties () : void
		{
			super.commitProperties();
			
			if (columnWidthsChanged)
			{
				for each (var column : Column in columnWidths)
					resizeColumn(column.index, column.width);
				
				columnWidthsChanged = false;
			}
			
			// TODO!!!
			if (rowHeightsChanged)
			{
				rowHeightsChanged = false;
			}
		}
		
		override protected function calculateRowHeight (data : Object, hh : Number, skipVisible : Boolean = false) : Number
		{
			return super.calculateRowHeight(data, hh, skipVisible);
			
			return 100;
		}
		
		override protected function setupColumnItemRenderer (c : DataGridColumn, contentHolder : ListBaseContentHolder, rowNum : int, colNum : int, data : Object, uid : String) : IListItemRenderer
		{
			var item : PaintGridItemRenderer = super.setupColumnItemRenderer(c, contentHolder, rowNum, colNum, data, uid) as PaintGridItemRenderer;
			
			if (!item)
				return null;
			
			if (data.hasOwnProperty("cells"))
				item.cell = data.cells[colNum + horizontalScrollPosition];
			
			return item;
		}
		
		override mx_internal function shiftColumns (oldIndex : int, newIndex : int, trigger : Event = null) : void
		{
			super.shiftColumns(oldIndex, newIndex, trigger);
			
			if (newIndex >= 0 && oldIndex != newIndex)
			{
				var incr : int = oldIndex < newIndex ? 1 : -1;
				var i : int, j : int, cell : CellProperties;
				
				for each (var row : Object in collection)
				{
					for (i = oldIndex; i != newIndex; i += incr)
					{
						j = i + incr;
						cell = row.cells[i];
						row.cells[i] = row.cells[j];
						row.cells[j] = cell;
						row.cells[i].column = i;
						row.cells[j].column = j;
					}
				}
			}
		}
		
		override protected function collectionChangeHandler (event : Event) : void
		{
			super.collectionChangeHandler(event);
			
			if (!event is CollectionEvent)
				return;
			
			var ce : CollectionEvent = CollectionEvent(event);
			
			var row : int, rows : int, col : int, cols : int, cell : CellProperties;
			
			switch (ce.kind)
			{
				case CollectionEventKind.ADD:
					for (rows = ce.items.length, cols = columns.length; row < rows; ++row)
					{
						ce.items[row].cells = [];
						
						for (col = 0; col < cols; ++col)
						{
							cell = new CellProperties(ce.location, col, {});
							ce.items[row].cells[col] = cell;
							
							cells.push(cell);
						}
					}
					break;
				
				case CollectionEventKind.REFRESH:
					for (rows = collection.length, cols = collection[row].cells.length; row < rows; ++row)
					{
						for (col = 0; col < cols; ++col)
						{
							cell = collection[row].cells[col];
							cell.row = row;
							cell.column = col;
						}
					}
					break;
			}
		}
	}
}