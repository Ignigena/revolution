#import "RSDarkScroller.h"

@implementation RSDarkScroller

// Draws the knob
- (void)drawKnob
{
	NSRect knobRect = [self rectForPart:NSScrollerKnob];
   
	NSRect knobRectTop = NSMakeRect(knobRect.origin.x+1, knobRect.origin.y, 13, 8);
	NSRect knobRectBottom = NSMakeRect(knobRect.origin.x+1, knobRect.origin.y+knobRect.size.height-9, 13, 8);
	NSRect knobRectFill = NSMakeRect(knobRect.origin.x+1, knobRect.origin.y+8, 13, knobRect.size.height-17);
	
	NSImage *knobImage = [NSImage imageNamed:@"DarkScrollerKnob"];
	[knobImage setFlipped: YES];
	
	//if ([[super window] isMainWindow] && [[super window] isKeyWindow])
	
	[knobImage drawInRect:knobRectTop fromRect: NSMakeRect(0, 0, 13, 8) operation:NSCompositeSourceAtop fraction:1.0];
	[knobImage drawInRect:knobRectBottom fromRect: NSMakeRect(0, 16, 13, 8) operation:NSCompositeSourceAtop fraction:1.0];
	[knobImage drawInRect:knobRectFill fromRect: NSMakeRect(0, 8, 13, 8) operation:NSCompositeSourceAtop fraction:1.0];
}

// Draw the scroll bar arrows
- (void)drawArrow:(NSScrollerArrow)arrow highlightPart:(int)flag
{
	BOOL scrollBarsTogether = YES;
	NSRect upArrowRect = [self rectForPart:NSScrollerDecrementLine];
	NSRect downArrowRect = [self rectForPart:NSScrollerIncrementLine];
	
	// Check to see if scroll arrows are positioned either:
	//    0: At top and bottom
	//    1: Together
	
	if (upArrowRect.origin.y==0.0)
		scrollBarsTogether = NO;
		
	// Calculate where to copy from the source images
	// based on the scroll arrow positions
	
	if (scrollBarsTogether==1) {
		upArrowRect.origin.y-=9;
		upArrowRect.size.height=25;
		downArrowRect.origin.y+=1;
		downArrowRect.size.height = 15;
		
		NSImage *upArrowImage = [NSImage imageNamed:@"DarkScrollerArrowUp2"];
		[upArrowImage setFlipped: YES];
		[upArrowImage drawInRect:upArrowRect fromRect: NSMakeRect(0, 0, 15, 25) operation:NSCompositeSourceOver fraction:1.0];
		
		NSImage *downArrowImage = [NSImage imageNamed:@"DarkScrollerArrowDown2"];
		[downArrowImage setFlipped: YES];
		[downArrowImage drawInRect:downArrowRect fromRect: NSMakeRect(0, 0, 15, 15) operation:NSCompositeSourceOver fraction:1.0];
	} else {
		NSImage *upArrowImage = [NSImage imageNamed:@"DarkScrollerArrowUp2"];
		[upArrowImage setFlipped: YES];
		[upArrowImage drawInRect:NSMakeRect(upArrowRect.origin.x, upArrowRect.origin.y, 15, 15) fromRect: NSMakeRect(0, 9, 15, 15) operation:NSCompositeSourceOver fraction:1.0];
		
		NSImage *downArrowImage = [NSImage imageNamed:@"DarkScrollerArrowDown2"];
		[downArrowImage setFlipped: YES];
		[downArrowImage drawInRect:downArrowRect fromRect: NSMakeRect(0, 0, 15, 15) operation:NSCompositeSourceOver fraction:1.0];
		[upArrowImage drawInRect:NSMakeRect(downArrowRect.origin.x, downArrowRect.origin.y-7, 15, 10) fromRect: NSMakeRect(0, 0, 15, 10) operation:NSCompositeSourceOver fraction:1.0];
	}
}

// Draws the knob background
- (void)drawKnobSlotInRect:(NSRect)rect highlight:(BOOL)highlight
{
	scrollTrack = [NSImage imageNamed:@"DarkScrollerTrack"];
	NSImage *scrollCap = [NSImage imageNamed:@"DarkScrollerCap"];
	[scrollCap setFlipped: TRUE];
	
	[scrollTrack drawInRect:rect fromRect: NSMakeRect(0, 0, 15, 15) operation:NSCompositeSourceOver fraction:1.0];
	
	// Only draw the cap if there is a scroll knob present
	if ([self knobProportion]!=0)
		[scrollCap drawInRect:NSMakeRect(rect.origin.x, rect.origin.y-4, rect.size.width, 13) fromRect: NSMakeRect(0, 0, 15, 13) operation:NSCompositeSourceOver fraction:1.0];
}

- (void)drawArrow:(NSScrollerArrow)arrow highlight:(BOOL)highlight
{
	[self drawArrow:arrow highlightPart:highlight ? 0 : -1];
}

- (BOOL)isOpaque
{
	return NO;
}

@end
