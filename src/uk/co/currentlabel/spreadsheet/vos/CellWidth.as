package uk.co.currentlabel.spreadsheet.vos
{

/**
 * Represents width of a cell. It's also used as column width.
 */
public class CellWidth extends CellSize
{
	public function CellWidth ()
	{
		super ();
		
		setMin (100);
	}
}
}