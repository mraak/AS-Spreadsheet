package com.flextras.spreadsheet.context
{
import com.flextras.spreadsheet.Spreadsheet;
import com.flextras.spreadsheet.vos.Cell;

import flash.events.Event;

import mx.containers.TitleWindow;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

public class BasePopup extends TitleWindow
{
	public var cells : Vector.<Cell>;
	
	private var _cell : Cell;
	
	[Bindable(event="cellChanged")]
	public function get cell () : Cell
	{
		return _cell;
	}
	
	public function set cell (value : Cell) : void
	{
		if (cell === value)
			return;
		
		_cell = value;
		
		dispatchEvent (new Event ("cellChanged"));
	}
	
	private var _grid : Spreadsheet;
	
	[Bindable]
	public function get grid () : Spreadsheet
	{
		return _grid;
	}
	
	public function set grid (value : Spreadsheet) : void
	{
		if (grid === value)
			return;
		
		_grid = value;
	}
	
	public function BasePopup ()
	{
		super ();
		
		showCloseButton = true;
		addEventListener (CloseEvent.CLOSE, closeHandler);
	}
	
	protected function closeHandler (e : CloseEvent) : void
	{
		PopUpManager.removePopUp (this);
	}
}
}