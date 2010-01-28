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
		
		public function getAllCellProperties (fromUser : Boolean = true) : Array
		{
			return fromUser ? modifiedCells : cells;
		}
		
		public function setAllCellProperties (cells : Array) : void
		{
			for each (var cell : CellProperties in cells)
				setCellProperties(cell);
		}
		
		public function getCellProperties (at : Location, fromUser : Boolean = true) : CellProperties
		{
			if (!at || !at.valid)
				return null;
			
			var cells : Array = fromUser ? modifiedCells : this.cells;
			
			for each (var cell : CellProperties in cells)
				if (cell.equalLocation(at))
					return cell;
			
			return null;
		}
		
		public function getCellPropertiesAt (row : int, column : int, fromUser : Boolean = true) : CellProperties
		{
			var location : Location = new Location(row, column);
			
			return getCellProperties(location, fromUser);
		}
		
		public function setCellProperties (value : CellProperties) : void
		{
			if (!value || !value.valid)
				return;
			
			for each (var cell : CellProperties in cells)
				if (cell.equalLocation(value))
				{
					cell.styles = value.styles;
					cell.condition = value.condition;
					
					if (!cell in modifiedCells)
						modifiedCells.push(cell);
					
					return;
				}
		}
		
		public function setCellPropertiesAt (row : int, column : int, styles : Object, condition : String = null) : void
		{
			var cell : CellProperties = new CellProperties(row, column, styles, condition);
			
			setCellProperties(cell);
		}
		
		public function getAllCellPropertiesInRange (range : Range, fromUser : Boolean = true) : Array
		{
			if (!range || !range.valid)
				return null;
			
			var result : Array;
			
			for each (var cell : CellProperties in cells)
				if (cell.inRange(range) && (fromUser || getCellProperties(cell, fromUser)))
				{
					if (!result)
						result = [];
					
					result.push(cell);
				}
			
			return result;
		}
		
		public function getAllCellPropertiesInRangeBy (start : Location, end : Location, fromUser : Boolean = true) : Array
		{
			var range : Range = new Range(start, end);
			
			return getAllCellPropertiesInRange(range, fromUser);
		}
		
		public function setAllCellPropertiesInRange (range : Range, styles : Object, condition : String = null) : void
		{
			if (!range || !range.valid || !styles)
				return;
			
			for each (var cell : CellProperties in cells)
				if (cell.inRange(range))
				{
					cell.styles = new ObjectProxy(styles);
					cell.condition = condition;
					
					if (!cell in modifiedCells)
						modifiedCells.push(cell);
				}
		}
		
		public function setAllCellPropertiesInRangeBy (start : Location, end : Location, styles : Object, condition : String = null) : void
		{
			var range : Range = new Range(start, end);
			
			setAllCellPropertiesInRange(range, styles, condition);
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