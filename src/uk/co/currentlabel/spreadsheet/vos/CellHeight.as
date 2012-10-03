package uk.co.currentlabel.spreadsheet.vos
{

/**
 * Represents height of a cell. It's also used as row height.
 */
public class CellHeight extends CellSize
{
	public function CellHeight ()
	{
		super ();
		
		setMin (40);
	}
}
}