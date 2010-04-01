package com.flextras.spreadsheet.context
{
import mx.collections.ArrayCollection;

[ExcludeClass]
[Bindable]
public class Data
{
	public var arr : ArrayCollection = new ArrayCollection();
	
	public var conditions : Array = ["<", ">", "=", ">=", "<="];
	
	public var firstNames : Array = ["Janez", "Marija", "Jože", "Ana", "Anton", "Jožefa"];
	
	public var aligns : Array = ["left", "center", "right"];
	
	public var gridFitTypes : Array = ["none", "pixel", "subpixel"];
	
	public var fontFamilyArray : Array = ["_sans", "_serif", "_typewriter", "Arial", "Courier", "Courier New", "Geneva", "Georgia", "Helvetica", "Times New Roman", "Times", "Verdana"];
	
	public var rowCount : int = 300;
	
	public var columnCount : int = 20;
	
	public function init () : void
	{
		for (var i : int = 0, n : int = rowCount; i < n; i++)
			arr.addItem(generateRow);
	}
	
	public function get generateRow () : Object
	{
		var result : Object = {};
		
		for (var i : int; i < columnCount; ++i)
			switch (Math.floor(Math.random() * 7))
		{
			case 0:
				result[String.fromCharCode(97 + i)] = i;
				break;
			case 1:
				result[String.fromCharCode(97 + i)] = firstName;
				break;
			case 2:
				result[String.fromCharCode(97 + i)] = randomColor;
				break;
			case 3:
				result[String.fromCharCode(97 + i)] = align;
				break;
			case 4:
				result[String.fromCharCode(97 + i)] = bold;
				break;
			case 5:
				result[String.fromCharCode(97 + i)] = randomFontSize;
				break;
			case 6:
				result[String.fromCharCode(97 + i)] = randomFontFamily;
				break;
		}
		
		return result;
	}
	
	public function get firstName () : String
	{
		return firstNames[Math.floor(Math.random() * firstNames.length)];
	}
	
	public function get gridFitType () : String
	{
		return gridFitTypes[Math.floor(Math.random() * gridFitTypes.length)];
	}
	
	public function get rowIndex () : int
	{
		return Math.floor(Math.random() * arr.length);
	}
	
	public function get columnIndex () : int
	{
		return Math.floor(Math.random() * columnCount);
	}
	
	/* public function get styleObject () : Object
	   {
	   var n : int = 7, result : Object = {};
	
	   for (var i : int = 0; i < n; i++)
	   switch (Math.floor(Math.random() * n))
	   {
	   case 0:
	   result.color = randomColor;
	   break;
	   case 1:
	   result.backgroundColor = randomColor;
	   break;
	   case 2:
	   result.rollOverColor = randomColor;
	   break;
	   case 3:
	   result.align = align;
	   break;
	   case 4:
	   result.bold = bold;
	   break;
	   case 5:
	   result.fontSize = randomFontSize;
	   break;
	   case 6:
	   result.fontFamily = randomFontFamily;
	   break;
	   }
	
	   return result;
	 } */
	
	public function get condition () : String
	{
		return conditions[Math.floor(Math.random() * conditions.length)];
	}
	
	public function get align () : String
	{
		return aligns[Math.floor(Math.random() * aligns.length)];
	}
	
	public function get randomColor () : int
	{
		return Math.floor(Math.random() * 0xFFFFFF);
	}
	
	public function get randomFontSize () : int
	{
		var min : int = 10, max : int = 64;
		
		return random(min, max);
	}
	
	public static function random (min : int = 0, max : int = 10) : int
	{
		return Math.floor(Math.random() * (max - min)) + min;
	}
	
	public function get randomFontFamily () : String
	{
		return fontFamilyArray[Math.floor(Math.random() * fontFamilyArray.length)];
	}
	
	public var _bold : Boolean;
	
	public function get bold () : Boolean
	{
		return (_bold = !_bold);
	}
}
}