
////////////////////////////////////////////////////////////////////////////////
//  
//  Copyright 2012 Alen Balja
//  All Rights Reserved.
//
//  See the file license.txt for copying permission.
//
////////////////////////////////////////////////////////////////////////////////


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