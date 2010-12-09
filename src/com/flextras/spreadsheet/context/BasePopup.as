package com.flextras.spreadsheet.context
{
import com.flextras.spreadsheet.Spreadsheet;
import com.flextras.spreadsheet.vos.Cell;

import flash.events.Event;

import mx.containers.TitleWindow;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

/**
 * Base class for all popups in context package.
 */
public class BasePopup extends TitleWindow
{
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Selected cells
	 */
	public var cells : Vector.<Cell>;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function BasePopup ()
	{
		super ();
		
		showCloseButton = true;
		addEventListener (CloseEvent.CLOSE, closeHandler);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  cell
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _cell : Cell;
	
	[Bindable(event="cellChanged")]
	/**
	 * Currently selected cell
	 */
	public function get cell () : Cell
	{
		return _cell;
	}
	
	/**
	 * @private
	 */
	public function set cell (value : Cell) : void
	{
		if (cell === value)
			return;
		
		_cell = value;
		
		dispatchEvent (new Event ("cellChanged"));
	}
	
	//----------------------------------
	//  grid
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _grid : Spreadsheet;
	
	[Bindable]
	/**
	 * Cells owner.
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
		if (grid === value)
			return;
		
		_grid = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  closeHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function closeHandler (e : CloseEvent) : void
	{
		PopUpManager.removePopUp (this);
	}
}
}