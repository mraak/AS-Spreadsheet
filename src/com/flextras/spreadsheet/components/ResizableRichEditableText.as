package com.flextras.spreadsheet.components
{
import flash.geom.Rectangle;

import mx.core.mx_internal;

import spark.components.RichEditableText;

use namespace mx_internal;


/**
 * This component adds support for wordWrap and resizing even if boundaries are provided (left, top, right, bottom, width, height, ...) 
 * and wordWrap is false, otherwise it respects current boundaries and wraps text.
 * */
public class ResizableRichEditableText extends RichEditableText
{
	/**
	 * Flag that indicates if the component should wrap text
	 * */
	public var wordWrap : Boolean;
	
	public function ResizableRichEditableText()
	{
		super();
	}

	/**
	 * @private
	 * */
	override protected function measure() : void
	{
		var bounds : Rectangle = measureTextSize(NaN);
		
		measuredWidth = Math.ceil(bounds.right);
		measuredHeight = Math.ceil(bounds.bottom);
		
		autoSize = true;
		
		textContainerManager.horizontalScrollPosition = 0;
		textContainerManager.verticalScrollPosition = 0;
		
		width = measuredWidth;
		height = measuredHeight;
		
		invalidateDisplayList();
		
		
		
		super.measure();
	
		//trace("+measure", measuredWidth, measuredHeight, width, height);
	}
	
	/**
	 * @private
	 * */
	override protected function canSkipMeasurement() : Boolean
	{
		return false;
	}
	
	/**
	 * @private
	 * */
	override public function set maxWidth(value : Number) : void
	{
		if (wordWrap)
			super.maxWidth = value;
	}
	
	/**
	 *  @private
	 *  Returns the bounds of the measured text.  The initial composeWidth may
	 *  be adjusted for minWidth or maxWidth.  The value used for the compose
	 *  is in textContainerManager.compositionWidth.
	 */
	private function measureTextSize(composeWidth : Number,
									 composeHeight : Number = NaN) : Rectangle
	{
		// If the width is NaN it can grow up to TextLine.MAX_LINE_WIDTH wide.
		// If the height is NaN it can grow to allow all the text to fit.
		textContainerManager.compositionWidth = composeWidth;
		textContainerManager.compositionHeight = composeHeight;
		
		if(wordWrap)
		{
			if (!isNaN(explicitMinWidth) && measuredWidth < explicitMinWidth)
				textContainerManager.compositionWidth = measuredWidth = explicitMinWidth;
			
			if (!isNaN(explicitMaxWidth) && measuredWidth > explicitMaxWidth)
				textContainerManager.compositionWidth = measuredWidth = explicitMaxWidth;
		}
		else
			textContainerManager.compose();
		
		/*if (!isNaN(explicitMinHeight) && measuredHeight < explicitMinHeight)
		   measuredHeight = explicitMinHeight;
		
		   if (!isNaN(explicitMaxHeight) && measuredHeight > explicitMaxHeight)
		 measuredHeight = explicitMaxHeight;*/
		
		// Adjust width and height for text alignment.
		var bounds : Rectangle = textContainerManager.getContentBounds();
		
		//trace("measureTextSize", composeWidth, "->", bounds.width, composeHeight, "->", bounds.height);
		
		return bounds;
	}
}
}