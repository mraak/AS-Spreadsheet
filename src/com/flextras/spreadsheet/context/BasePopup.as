package com.flextras.spreadsheet.context
{
import com.flextras.spreadsheet.Spreadsheet;

import flash.events.Event;

import mx.containers.TitleWindow;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

/**
 *  This is a default class for pop-up windows that appear through the use of the grid.
 */
public class BasePopup extends TitleWindow
{
	protected var _grid : Spreadsheet;
	
	[Bindable]
	/**
	 * This is an instance to the spreadsheet which triggered the creation of the pop up.
	 */
	public function get grid () : Spreadsheet
	{
		return _grid;
	}
	
	/**
	 * @private  
	 */
	public function set grid (value : Spreadsheet) : void
	{
		if (_grid === value)
			return;
		
		if (_grid)
			_grid.removeEventListener("selectedCellsChanged", selectedCellsChangedHandler);
		
		_grid = value;
		
		if (value)
			value.addEventListener("selectedCellsChanged", selectedCellsChangedHandler);
	}
	
	/**
	 * Constructor. 
	 */
	public function BasePopup ()
	{
		super();
		
		showCloseButton = true;
		addEventListener(CloseEvent.CLOSE, closeHandler);
	}
	
	/**
	 * This is a default handler for the close event of this TitleWindow.  
	 */
	protected function closeHandler (e : CloseEvent) : void
	{
		PopUpManager.removePopUp(this);
	}
	
	/**
	 * This is a default handler for when the selectedCellsChange event is fired from the Spreadsheet class instance.  
	 * 
	 * @see #grid
	 * @see com.flextras.spreadsheet.Spreadsheet
	 */
	protected function selectedCellsChangedHandler (e : Event) : void
	{
	
	}
}
}