#import "HUDScroller.h"

@implementation HUDScroller

// Draws the knob
- (void)drawKnob
{
	// Check to see if scroll arrows are positioned either:
	//    0: At top and bottom
	//    1: Together
	
	BOOL scrollBarsTogether = YES;
	NSRect upArrowRect = [self rectForPart:NSScrollerDecrementLine];

	if (upArrowRect.origin.y==0.0)
		scrollBarsTogether = NO;
	
	NSRect knobRect = [self rectForPart:NSScrollerKnob];
	NSRect knobRectTop;
	NSRect knobRectFill;
	NSRect knobRectBottom;
	
	if ([self controlSize] == NSSmallControlSize) {
		knobRectTop = NSMakeRect(knobRect.origin.x+1, knobRect.origin.y+7, knobRect.size.width-2, 6);
		knobRectFill = NSMakeRect(knobRect.origin.x+1, knobRect.origin.y+13, knobRect.size.width-2, knobRect.size.height-22);
		knobRectBottom = NSMakeRect(knobRect.origin.x+1, knobRect.origin.y+knobRect.size.height-10, knobRect.size.width-2, 6);
	} else {
		knobRectTop = NSMakeRect(knobRect.origin.x+1, knobRect.origin.y+6, knobRect.size.width-2, 8);
		knobRectFill = NSMakeRect(knobRect.origin.x+1, knobRect.origin.y+14, knobRect.size.width-2, knobRect.size.height-25);
		knobRectBottom = NSMakeRect(knobRect.origin.x+1, knobRect.origin.y+knobRect.size.height-11, knobRect.size.width-2, 8);
	}
	
	if (scrollBarsTogether!=1) {
		knobRectTop.origin.y-=3;
		knobRectFill.origin.y-=3;
		knobRectFill.size.height+=3;
	}
	
	NSImage *knobImage = [NSImage imageNamed:@"HUDScrollKnob"];
	
	[knobImage drawInRect:knobRectTop fromRect: NSMakeRect(0, 0, 13, 8) operation:NSCompositeSourceAtop fraction:1.0];
	[knobImage drawInRect:knobRectBottom fromRect: NSMakeRect(0, 18, 13, 8) operation:NSCompositeSourceAtop fraction:1.0];
	[knobImage drawInRect:knobRectFill fromRect: NSMakeRect(0, 8, 13, 10) operation:NSCompositeSourceAtop fraction:1.0];
}

// Draw the scroll bar arrows
- (void)drawArrow:(NSScrollerArrow)arrow highlightPart:(int)flag
{
	BOOL scrollBarsTogether = YES;
	NSRect upArrowRect = [self rectForPart:NSScrollerDecrementLine];
	NSRect downArrowRect = [self rectForPart:NSScrollerIncrementLine];
	
	scrollArrowsActive = [NSImage imageNamed:@"HUDScrollArrowsActive"];
	scrollArrows = [NSImage imageNamed:@"HUDScrollArrows"];
	
	// Check to see if scroll arrows are positioned either:
	//    0: At top and bottom
	//    1: Together
	
	if (upArrowRect.origin.y==0.0)
		scrollBarsTogether = NO;
		
	// Calculate where to copy from the source images
	// based on the scroll arrow positions
	
	if (scrollBarsTogether==1) {
		upArrowRect.origin.y-=8;
		upArrowRect.size.height+=6;
		upArrowCopyRect = NSMakeRect(0, 35, 15, 20);
		
		downArrowRect.origin.y-=2;
		downArrowRect.size.height+=2;
		downArrowCopyRect = NSMakeRect(0, 55, 15, 18);
	} else {
		upArrowRect.size.height+=10;
		upArrowCopyRect = NSMakeRect(0, 0, 15, 26);
		
		downArrowRect.origin.y-=9;
		downArrowRect.size.height+=10;
		downArrowCopyRect = NSMakeRect(0, 48, 15, 26);
	}
	
	// Draw both scroll arrows
	
	[scrollArrows setFlipped: NO];
	[scrollArrows drawInRect:upArrowRect fromRect:upArrowCopyRect operation:NSCompositeSourceOver fraction:1.0];
	if (scrollBarsTogether!=1) [scrollArrows setFlipped: YES];
	[scrollArrows drawInRect:downArrowRect fromRect:downArrowCopyRect operation:NSCompositeSourceOver fraction:1.0];
	
	// The "up" arrow is being pressed
	// Draw the highlighted button
	
	if (flag==1) {
		[scrollArrowsActive setFlipped: NO];
		[scrollArrowsActive drawInRect:upArrowRect fromRect:upArrowCopyRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	// The "down" arrow is being pressed
	// Draw the highlighted button
	
	if (flag==0) {
		if (scrollBarsTogether!=1) [scrollArrowsActive setFlipped: YES];
		[scrollArrowsActive drawInRect:downArrowRect fromRect:downArrowCopyRect operation:NSCompositeSourceOver fraction:1.0];
	}
}

// Draws the knob background
- (void)drawKnobSlotInRect:(NSRect)rect highlight:(BOOL)highlight
{
	scrollTrack = [NSImage imageNamed:@"HUDScrollTrackFill"];
	
	[scrollTrack drawInRect:rect fromRect: NSMakeRect(0, 18, 15, 8) operation:NSCompositeSourceOver fraction:1.0];
	
	if ([self controlSize] == NSSmallControlSize) {
		[scrollTrack drawInRect:NSMakeRect(rect.origin.x, rect.origin.y-2, rect.size.width, 16) fromRect: NSMakeRect(0, 0, 15, 18) operation:NSCompositeSourceOver fraction:1.0];
	} else {
		[scrollTrack drawInRect:NSMakeRect(rect.origin.x, rect.origin.y-4, rect.size.width, 18) fromRect: NSMakeRect(0, 0, 15, 18) operation:NSCompositeSourceOver fraction:1.0];
	}
}

- (void)drawArrow:(int)arrow highlight:(BOOL)highlight
{
	[self drawArrow:arrow highlightPart:highlight ? 0 : -1];
}

- (BOOL)isOpaque
{
	return NO;
}

@end
