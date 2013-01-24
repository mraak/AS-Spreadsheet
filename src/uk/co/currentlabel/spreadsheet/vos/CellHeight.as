
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