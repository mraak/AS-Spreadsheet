package com.flextras.paintgrid
{
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;

import mx.collections.CursorBookmark;
import mx.collections.errors.ItemPendingError;
import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.dataGridClasses.DataGridHeader;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.core.ClassFactory;
import mx.core.EdgeMetrics;
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
		allowMultipleSelection = true;
		horizontalScrollPolicy = ScrollPolicy.AUTO; // !!
		itemRenderer = new ClassFactory(PaintGridColumnItemRenderer);
	}
	
	protected var rowHeader : PaintGridRowHeader;
	
	protected var rowHeaderVisible : Boolean = true;
	
	protected var rowHeaderClass : Class = PaintGridRowHeader;
	
	protected var rowHeaderMask : Shape;
	
	protected var visibleRows : Array;
	
	override public function set enabled (value : Boolean) : void
	{
		super.enabled = value;
		
		if (rowHeader)
			rowHeader.enabled = value;
	}
	
	override protected function createChildren () : void
	{
		super.createChildren();
		
		if (!rowHeader)
		{
			rowHeader = new rowHeaderClass();
			rowHeader.styleName = this;
			
			rowHeader.width = 100;
			rowHeader.graphics.beginFill(0xFF0000);
			rowHeader.graphics.drawRect(0, 0, 100, 100);
			rowHeader.graphics.endFill();
			
				//addChild(rowHeader);
		}
	}
	
	override protected function updateDisplayList (w : Number, h : Number) : void
	{
		/*if (rowHeaderVisible && rowHeader)
		   {
		   rowHeader.visibleRows = visibleRows;
		   rowHeader.headerItemsChanged = true;
		   rowHeader.invalidateSize();
		   rowHeader.validateNow();
		   }
		
		   if (horizontalScrollBar != null && horizontalScrollBar.visible && (verticalScrollBar == null || !verticalScrollBar.visible) && rowHeaderVisible)
		   {
		   var hh : Number = rowHeader.height;
		   var bm : EdgeMetrics = borderMetrics;
		
		   if (roomForScrollBar(horizontalScrollBar, w - bm.left - bm.right - rowHeader.width, h - hh - bm.top - bm.bottom))
		   {
		   horizontalScrollBar.move(rowHeader.width + horizontalScrollBar.x, viewMetrics.top + hh);
		   horizontalScrollBar.setActualSize(horizontalScrollBar.width - rowHeader.width, h - viewMetrics.top - viewMetrics.bottom - hh);
		   horizontalScrollBar.visible = true;
		
		   //rowHeaderMask.width += horizontalScrollBar.getExplicitOrMeasuredWidth() - rowHeader.width;
		
		   if (!rowHeader.needRightSeparator)
		   {
		   rowHeader.invalidateDisplayList();
		   rowHeader.needRightSeparator = true;
		   }
		   }
		   else
		   {
		   if (rowHeader.needRightSeparator)
		   {
		   rowHeader.invalidateDisplayList();
		   rowHeader.needRightSeparator = false;
		   }
		   }
		   }
		   else
		   {
		   if (rowHeader.needRightSeparator)
		   {
		   rowHeader.invalidateDisplayList();
		   rowHeader.needRightSeparator = false;
		   }
		 }*/
		
		super.updateDisplayList(w, h);
		
		if (verticalScrollBar != null && verticalScrollBar.visible && headerVisible && horizontalScrollBar != null && horizontalScrollBar.visible)
		{
			var hh : Number = header.height;
			var rhw : Number = rowHeader.width;
			var bm : EdgeMetrics = borderMetrics;
			
			if (roomForScrollBar(verticalScrollBar, unscaledWidth - bm.left - bm.right - rhw, unscaledHeight - hh - bm.top - bm.bottom - horizontalScrollBar.height))
			{
				verticalScrollBar.move(verticalScrollBar.x, viewMetrics.top + hh);
				verticalScrollBar.setActualSize(verticalScrollBar.width, unscaledHeight - viewMetrics.top - viewMetrics.bottom - hh);
				verticalScrollBar.visible = true;
				headerMask.width += verticalScrollBar.getExplicitOrMeasuredWidth();
				
			}
			
			if (roomForScrollBar(horizontalScrollBar, unscaledWidth - rhw - bm.left - bm.right - verticalScrollBar.width, unscaledHeight - bm.top - bm.bottom - hh))
			{
				horizontalScrollBar.move(viewMetrics.left + rhw, horizontalScrollBar.y);
				horizontalScrollBar.setActualSize(unscaledWidth - viewMetrics.left - viewMetrics.right - rhw, horizontalScrollBar.height);
				horizontalScrollBar.visible = true;
				headerMask.height += horizontalScrollBar.getExplicitOrMeasuredHeight();
			}
		}
	}
	
	override protected function drawSelectionIndicator (indicator : Sprite, x : Number, y : Number, width : Number, height : Number, color : uint, itemRenderer : IListItemRenderer) : void
	{
	
	}
	
	/*override protected function drawItem (item : IListItemRenderer, selected : Boolean = false, highlighted : Boolean = false, caret : Boolean = false, transition : Boolean = false) : void
	   {
	   if (item is PaintGridRowHeader)
	   PaintGridRowHeader(item).alpha = .5;
	
	   super.drawItem(item, selected, highlighted, caret, transition);
	 }*/
	
	override protected function adjustListContent (unscaledWidth : Number = -1, unscaledHeight : Number = -1) : void
	{
		//super.adjustListContent(unscaledWidth, unscaledHeight);
		var ww : Number;
		var hh : Number = 0;
		var lcx : Number;
		var lcy : Number;
		var hcx : Number;
		var lockedColumnWidth : Number = rowHeader.width;
		
		if (headerVisible)
		{
			if (lockedColumnCount > 0)
			{
				lockedColumnHeader.visible = true;
				hcx = viewMetrics.left + Math.min(DataGridHeader(lockedColumnHeader).leftOffset, 0);
				lockedColumnHeader.move(hcx, viewMetrics.top);
				hh = lockedColumnHeader.getExplicitOrMeasuredHeight();
				lockedColumnHeader.setActualSize(lockedColumnWidth + 1, hh);
				DataGridHeader(lockedColumnHeader).needRightSeparator = true;
				DataGridHeader(lockedColumnHeader).needRightSeparatorEvents = true;
			}
			header.visible = true;
			hcx = viewMetrics.left + lockedColumnWidth + Math.min(DataGridHeader(header).leftOffset, 0);
			header.move(hcx, viewMetrics.top);
			
			// If we have a vScroll only, we want the scrollbar to be below
			// the header.
			if (verticalScrollBar != null && verticalScrollBar.visible && (horizontalScrollBar == null || !horizontalScrollBar.visible) && headerVisible && roomForScrollBar(verticalScrollBar, unscaledWidth, unscaledHeight - header.height))
				ww = Math.max(0, DataGridHeader(header).rightOffset) - hcx - borderMetrics.right;
			else
				ww = Math.max(0, DataGridHeader(header).rightOffset) - hcx - viewMetrics.right;
			hh = header.getExplicitOrMeasuredHeight();
			header.setActualSize(unscaledWidth + ww, hh);
			
			/*if (!skipHeaderUpdate)
			   {
			   header.headerItemsChanged = true;
			   header.invalidateDisplayList(); // make sure it redraws, even if size didn't change
			   // internal renderers could have changed
			 }*/
		}
		else
		{
			header.visible = false;
			
			if (lockedColumnCount > 0)
				lockedColumnHeader.visible = false;
		}
		
		if (lockedRowCount > 0 && lockedRowContent && lockedRowContent.iterator)
		{
			try
			{
				lockedRowContent.iterator.seek(CursorBookmark.FIRST);
				var pt : Point = makeRows(lockedRowContent, 0, 0, unscaledWidth, unscaledHeight, 0, 0, true, lockedRowCount, true);
				
				if (lockedColumnCount > 0)
				{
					lcx = viewMetrics.left + Math.min(lockedColumnAndRowContent.leftOffset, 0);
					lcy = viewMetrics.top + Math.min(lockedColumnAndRowContent.topOffset, 0) + Math.ceil(hh);
					lockedColumnAndRowContent.move(lcx, lcy);
					lockedColumnAndRowContent.setActualSize(lockedColumnWidth, lockedColumnAndRowContent.getExplicitOrMeasuredHeight());
				}
				lcx = viewMetrics.left + lockedColumnWidth + Math.min(lockedRowContent.leftOffset, 0);
				lcy = viewMetrics.top + Math.min(lockedRowContent.topOffset, 0) + Math.ceil(hh);
				lockedRowContent.move(lcx, lcy);
				ww = Math.max(0, lockedRowContent.rightOffset) - lcx - viewMetrics.right;
				lockedRowContent.setActualSize(unscaledWidth + ww, lockedRowContent.getExplicitOrMeasuredHeight());
				hh += lockedRowContent.getExplicitOrMeasuredHeight();
			}
			catch (e : ItemPendingError)
			{
				//e.addResponder(new ItemResponder(lockedRowSeekPendingResultHandler, seekPendingFailureHandler, null));
				
			}
		}
		
		if (lockedColumnCount > 0)
		{
			lcx = viewMetrics.left + Math.min(lockedColumnContent.leftOffset, 0);
			lcy = viewMetrics.top + Math.min(lockedColumnContent.topOffset, 0) + Math.ceil(hh);
			lockedColumnContent.move(lcx, lcy);
			ww = lockedColumnWidth + lockedColumnContent.rightOffset - lockedColumnContent.leftOffset;
			lockedColumnContent.setActualSize(ww, unscaledHeight + Math.max(0, lockedColumnContent.bottomOffset) - lcy - viewMetrics.bottom);
		}
		lcx = viewMetrics.left + lockedColumnWidth + Math.min(listContent.leftOffset, 0);
		lcy = viewMetrics.top + Math.min(listContent.topOffset, 0) + Math.ceil(hh);
		listContent.move(lcx, lcy);
		ww = Math.max(0, listContent.rightOffset) - lcx - viewMetrics.right;
		hh = Math.max(0, listContent.bottomOffset) - lcy - viewMetrics.bottom;
		
		rowHeader.y = lcy;
		rowHeader.height = unscaledHeight - hh;
		listContent.setActualSize(Math.max(0, unscaledWidth + ww - lockedColumnWidth), Math.max(0, unscaledHeight + hh));
	
	}
	
	override public function set horizontalScrollPosition (value : Number) : void
	{
		super.horizontalScrollPosition = value;
	/*var oldValue : int = super.horizontalScrollPosition;
	   super.horizontalScrollPosition = value;
	
	   if (itemsSizeChanged)
	   return;
	
	   if (oldValue != value)
	   {
	   removeClipMask();
	
	   var bookmark : CursorBookmark;
	
	   if (iterator)
	   bookmark = iterator.bookmark;
	
	   clearIndicators();
	   clearVisibleData();
	   //if we scrolled more than the number of scrollable columns
	   makeRowsAndColumns(rowHeader.width, 0, listContent.width - rowHeader.width, listContent.height, 0, 0);
	
	   if (rowHeaderVisible && rowHeader)
	   {
	   rowHeader.visibleRows = visibleRows;
	   rowHeader.headerItemsChanged = true;
	   rowHeader.invalidateSize();
	   rowHeader.validateNow();
	   }
	
	   if (iterator && bookmark)
	   iterator.seek(bookmark, 0);
	
	   invalidateDisplayList();
	
	   addClipMask(false);
	 }*/
	}
	
	override public function set verticalScrollPosition (value : Number) : void
	{
		var oldValue : Number = super.verticalScrollPosition;
		super.verticalScrollPosition = value;
		
		if (oldValue != value)
		{
			if (lockedColumnContent)
				drawRowGraphics(lockedColumnContent)
			
			if (rowHeader)
			{
				rowHeader.visibleRows = visibleRows;
				rowHeader.headerItemsChanged = true;
				rowHeader.invalidateSize();
				rowHeader.validateNow();
			}
			
		}
	}
	
	/*override protected function makeRows (contentHolder : ListBaseContentHolder, left : Number, top : Number, right : Number, bottom : Number, firstCol : int, firstRow : int, byCount : Boolean = false, rowsNeeded : uint = 0, alwaysCleanup : Boolean = false) : Point
	   {
	   return super.makeRows(contentHolder, left + rowHeader.width, top, right, bottom, firstCol, firstRow, byCount, rowsNeeded, alwaysCleanup);
	 }*/
	
	/*override protected function layoutColumnItemRenderer (c : DataGridColumn, item : IListItemRenderer, xx : Number, yy : Number) : Point
	   {
	   return super.layoutColumnItemRenderer(c, item, xx + rowHeader.width, yy);
	 }*/
	
	/**
	 * Styling API
	 */
	
	[ArrayElementType("CellProperties")]
	protected var cells : Array = [];
	
	[ArrayElementType("CellProperties")]
	protected var modifiedCells : Array = [];
	
	/**
	 * Array of CellProperties
	 */
	
	/*public function getAllCellProperties (fromUser : Boolean = true) : Array
	   {
	   return fromUser ? modifiedCells : cells;
	   }
	
	   public function setAllCellProperties (cells : Array) : void
	   {
	   for each (var cell : CellProperties in cells)
	   setCellProperties(cell);
	 }*/
	
	protected var _selectedCell : CellProperties;
	
	[Bindable(event="selectedCellPropertiesChange")]
	
	/**
	 *
	 * Returns currently selected cell properties
	 *
	 * @return
	 *
	 */
	
	public function get selectedCellProperties () : CellProperties
	{
		return _selectedCell;
	}
	
	public function set selectedCellProperties (cell : CellProperties) : void
	{
		if (_selectedCell === cell)
			return;
		
		_selectedCell = cell;
		
		dispatchEvent(new Event("selectedCellPropertiesChange"));
	}
	
	/**
	 * Instance of CellProperties
	 */
	
	public function getCellProperties (at : CellLocation, fromUser : Boolean = true) : CellProperties
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
		var location : CellLocation = new CellLocation(row, column);
		
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
				cell.rollOverStyles = value.rollOverStyles;
				cell.selectedStyles = value.selectedStyles;
				cell.disabledStyles = value.disabledStyles;
				cell.condition = value.condition;
				
				if (!cell in modifiedCells)
					modifiedCells.push(cell);
				
				return;
			}
	}
	
	public function setCellPropertiesAt (row : int, column : int, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null, condition : String = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, styles, rollOverStyles, selectedStyles, disabledStyles, condition);
		
		setCellProperties(cell);
	}
	
	/**
	 * wrappers
	 */
	
	public function getCellStyles (at : CellLocation, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.styles;
	}
	
	public function getCellStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellStyles(location, fromUser);
	}
	
	public function setCellStyles (location : CellLocation, styles : Object = null) : void
	{
		if (!location || !location.valid)
			return;
		
		setCellStylesAt(location.row, location.column, styles);
	}
	
	public function setCellStylesAt (row : int, column : int, styles : Object = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, styles);
		
		setCellProperties(cell);
	}
	
	public function getCellRollOverStyles (at : CellLocation, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.rollOverStyles;
	}
	
	public function getCellRollOverStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellRollOverStyles(location, fromUser);
	}
	
	public function setCellRollOverStyles (location : CellLocation, styles : Object = null) : void
	{
		if (!location || !location.valid)
			return;
		
		setCellRollOverStylesAt(location.row, location.column, styles);
	}
	
	public function setCellRollOverStylesAt (row : int, column : int, styles : Object = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, null, styles);
		
		setCellProperties(cell);
	}
	
	public function getCellSelectedStyles (at : CellLocation, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.selectedStyles;
	}
	
	public function getCellSelectedStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellSelectedStyles(location, fromUser);
	}
	
	public function setCellSelectedStyles (location : CellLocation, styles : Object = null) : void
	{
		if (!location || !location.valid)
			return;
		
		setCellSelectedStylesAt(location.row, location.column, styles);
	}
	
	public function setCellSelectedStylesAt (row : int, column : int, styles : Object = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, null, null, styles);
		
		setCellProperties(cell);
	}
	
	public function getCellDisabledStyles (at : CellLocation, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.disabledStyles;
	}
	
	public function getCellDisabledStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellDisabledStyles(location, fromUser);
	}
	
	public function setCellDisabledStyles (location : CellLocation, styles : Object = null) : void
	{
		if (!location || !location.valid)
			return;
		
		setCellDisabledStylesAt(location.row, location.column, styles);
	}
	
	public function setCellDisabledStylesAt (row : int, column : int, styles : Object = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, null, null, null, styles);
		
		setCellProperties(cell);
	}
	
	/**
	 * Array of CellProperties in Range
	 */
	
	public function getAllCellPropertiesInRange (range : CellRange, fromUser : Boolean = true) : Array
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
	
	public function getAllCellPropertiesInRangeBy (start : CellLocation, end : CellLocation, fromUser : Boolean = true) : Array
	{
		var range : CellRange = new CellRange(start, end);
		
		return getAllCellPropertiesInRange(range, fromUser);
	}
	
	public function setAllCellPropertiesInRange (range : CellRange, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null, condition : String = null) : void
	{
		if (!range || !range.valid)
			return;
		
		for each (var cell : CellProperties in cells)
			if (cell.inRange(range))
			{
				cell.styles = new ObjectProxy(styles);
				cell.rollOverStyles = new ObjectProxy(rollOverStyles);
				cell.selectedStyles = new ObjectProxy(selectedStyles);
				cell.disabledStyles = new ObjectProxy(disabledStyles);
				cell.condition = condition;
				
				if (!cell in modifiedCells)
					modifiedCells.push(cell);
			}
	}
	
	public function setAllCellPropertiesInRangeBy (start : CellLocation, end : CellLocation, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null, condition : String = null) : void
	{
		var range : CellRange = new CellRange(start, end);
		
		setAllCellPropertiesInRange(range, styles, rollOverStyles, selectedStyles, disabledStyles, condition);
	}
	
	/**
	 * Column width API
	 */
	
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
	
	/**
	 * Row height API
	 */
	
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
		
		invalidateProperties();
	}
	
	override protected function commitProperties () : void
	{
		if (itemsNeedMeasurement && isNaN(explicitRowHeight) && iterator && columns.length > 0)
		{
			visibleRows = columns;
			columnsInvalid = true;
		}
		
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
	}
	
	override protected function setupColumnItemRenderer (c : DataGridColumn, contentHolder : ListBaseContentHolder, rowNum : int, colNum : int, data : Object, uid : String) : IListItemRenderer
	{
		var item : IListItemRenderer = super.setupColumnItemRenderer(c, contentHolder, rowNum, colNum, data, uid);
		
		if (!item)
			return null;
		
		if (item is PaintGridColumnItemRenderer)
		{
			PaintGridColumnItemRenderer(item).dataGrid = this;
			
			if (data.hasOwnProperty("cells"))
			{
				PaintGridColumnItemRenderer(item).cell = data.cells[colNum + horizontalScrollPosition];
				PaintGridColumnItemRenderer(item).cell.owner = item as PaintGridColumnItemRenderer;
			}
		}
		
		return item;
	}
	
	/*override protected function createBorder () : void
	   {
	   //super.createBorder();
	
	   if (!border)
	   {
	   var borderClass : Class = PaintGridBorder;
	
	   border = new borderClass();
	
	   if (border is IUIComponent)
	   IUIComponent(border).enabled = enabled;
	
	   if (border is ISimpleStyleClient)
	   ISimpleStyleClient(border).styleName = this;
	
	   // Add the border behind all the children.
	   addChildAt(DisplayObject(border), 0);
	
	   invalidateDisplayList();
	   }
	   }
	
	   override public function get borderMetrics () : EdgeMetrics
	   {
	   return (border as PaintGridBorder).borderMetrics;
	 }*/
	
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
			case CollectionEventKind.RESET:
				break;
			
			case CollectionEventKind.ADD:
				for (rows = ce.items.length, cols = columns.length; row < rows; ++row)
				{
					ce.items[row].cells = [];
					
					for (col = 0; col < cols; ++col)
					{
						cell = new CellProperties(ce.location, col);
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