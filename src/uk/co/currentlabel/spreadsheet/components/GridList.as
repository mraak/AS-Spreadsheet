package uk.co.currentlabel.spreadsheet.components
{
import uk.co.currentlabel.spreadsheet.Spreadsheet;
import uk.co.currentlabel.spreadsheet.core.spreadsheet;
import uk.co.currentlabel.spreadsheet.itemRenderers.GridItemRenderer;
import uk.co.currentlabel.spreadsheet.vos.Cell;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import mx.core.mx_internal;

import spark.components.List;
import spark.core.NavigationUnit;

use namespace spreadsheet;
use namespace mx_internal;

/**
 * @private
 * This class overrides default multiselect behavior. Instead of selecting all cells between two points it selects only those that are in selected rectangle.
 */
public class GridList extends List
{
	/**
	 * @private
	 */
	public var host : Spreadsheet;
	
	/**
	 * Constructor.
	 */
	public function GridList ()
	{
		super ();
	}
	
	override public function set selectedIndex (value : int) : void
	{
		super.selectedIndex = value;
		
		dispatchEvent (new Event ("selectedIndexChanged"));
	}
	
	override public function set selectedIndices (value : Vector.<int>) : void
	{
		super.selectedIndices = value;
		
		dispatchEvent (new Event ("selectedIndicesChanged"));
	}
	
	override public function set selectedItem (value : *) : void
	{
		super.selectedItem = value;
		
		dispatchEvent (new Event ("selectedItemChanged"));
	}
	
	override public function set selectedItems (value : Vector.<Object>) : void
	{
		super.selectedItems = value;
		
		dispatchEvent (new Event ("selectedItemsChanged"));
	}
	
	/**
	 * @private
	 */
	override protected function keyDownHandler (event : KeyboardEvent) : void
	{
		if (!dataProvider || !layout || event.isDefaultPrevented ())
			return;
		
		var navigationUnit : uint = event.keyCode;
		
		if (!NavigationUnit.isNavigationUnit (navigationUnit))
		{
			var currentRenderer : GridItemRenderer = GridItemRenderer (dataGroup.getElementAt (caretIndex < 0 ? 0 : caretIndex));
			
			if (!currentRenderer.focused)
				currentRenderer.openEditor (String.fromCharCode (event.charCode));
		}
		else
			adjustSelectionAndCaretUponNavigation (event);
	}
	
	/**
	 * @private
	 */
	override protected function item_mouseDownHandler (event : MouseEvent) : void
	{
		super.item_mouseDownHandler (event);
	}
	
	/**
	 * @private
	 */
	override protected function adjustSelectionAndCaretUponNavigation (event : KeyboardEvent) : void
	{
		// Some unrecognized key stroke was entered, return. 
		var navigationUnit : uint = event.keyCode;
		
		if (!NavigationUnit.isNavigationUnit (navigationUnit))
			return;
		
		if (!allowMultipleSelection)
		{
			super.adjustSelectionAndCaretUponNavigation (event);
			
			return;
		}
		
		// Delegate to the layout to tell us what the next item is we should select or focus into.
		// TODO (dsubrama): At some point we should refactor this so we don't depend on layout
		// for keyboard handling. If layout doesn't exist, then use some other keyboard handler
		var end : int = layout.getNavigationDestinationIndex (caretIndex, navigationUnit, arrowKeysWrapFocus);
		
		// Note that the KeyboardEvent is canceled even if the current selected or in focus index
		// doesn't change because we don't want another component to start handling these
		// events when the index reaches a limit.
		if (end == -1)
			return;
		
		event.preventDefault ();
		
		var start : int = !isEmpty (selectedIndices) ? selectedIndices[selectedIndices.length - 1] : 0;
		
		if (event.shiftKey)
			setSelectedIndices (populateInterval (start, end), true);
		else if (event.ctrlKey)
		{
			selectedIndices.unshift (end);
			
			setSelectedIndices (selectedIndices, true);
		}
		else
			setSelectedIndex (end, true);
		
		ensureIndexIsVisible (end);
	}
	
	/**
	 * @private
	 */
	override protected function calculateSelectedIndices (index : int, shiftKey : Boolean, ctrlKey : Boolean) : Vector.<int>
	{
		if (!shiftKey)
			return super.calculateSelectedIndices (index, shiftKey, ctrlKey);
		
		// A contiguous selection action has occurred. Figure out which new 
		// indices to add to the selection interval and return that. 
		var start : int = !isEmpty (selectedIndices) ? selectedIndices[selectedIndices.length - 1] : 0;
		
		return populateInterval (start, index);
	}
	
	/**
	 * @private
	 */
	protected function populateInterval (start : int, end : int) : Vector.<int>
	{
		var interval : Vector.<int> = new Vector.<int>;
		
		var startCell : Cell;
		var endCell : Cell;
		var c : int, r : int;
		var startColumn : int, endColumn : int, startRow : int, endRow : int;
		
		startCell = Cell (dataProvider.getItemAt (start));
		endCell = Cell (dataProvider.getItemAt (end));
		
		startColumn = Math.min (startCell.bounds.x, endCell.bounds.x);
		startRow = Math.min (startCell.bounds.y, endCell.bounds.y);
		
		endColumn = Math.max (startCell.bounds.right, endCell.bounds.right);
		endRow = Math.max (startCell.bounds.bottom, endCell.bounds.bottom);
		
		var cell : Cell;
		
		for (c = startColumn; c <= endColumn; ++c)
			for (r = startRow; r <= endRow; ++r)
			{
				cell = host.spans[r][c];
				
				if (cell.bounds.x < startColumn)
				{
					startColumn = cell.bounds.x;
					c = startColumn - 1;
					break;
				}
				
				if (cell.bounds.y < startRow)
				{
					c = startColumn - 1;
					startRow = cell.bounds.y;
					break;
				}
				
				if (cell.bounds.right > endColumn)
				{
					c = startColumn - 1;
					endColumn = cell.bounds.right;
					break;
				}
				
				if (cell.bounds.bottom > endRow)
				{
					c = startColumn - 1;
					endRow = cell.bounds.bottom;
					break;
				}
			}
		
		var value : int;
		
		for (c = startColumn; c <= endColumn; ++c)
			for (r = startRow; r <= endRow; ++r)
			{
				value = host.getElementIndex (c, r);
				
				if (value != start || value != end)
					interval.unshift (value);
			}
		
		//interval.sort(start < end ? sortDesc : sortAsc);
		
		interval.push (start);
		interval.unshift (end);
		
		return interval;
	}
	
	/**
	 * @private
	 */
	protected function sortAsc (a : int, b : int) : int
	{
		return a - b;
	}
	
	/**
	 * @private
	 */
	protected function sortDesc (a : int, b : int) : int
	{
		return b - a;
	}
	
	/**
	 *  @private
	 *  Returns true if v is null or an empty Vector.
	 */
	private function isEmpty (v : Vector.<int>) : Boolean
	{
		return v == null || v.length == 0;
	}
}
}