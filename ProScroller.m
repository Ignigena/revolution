#import "ProScroller.h"

@implementation ProScroller

// Draws the knob
- (void)drawKnob
{
	NSRect knobRect = [self rectForPart:NSScrollerKnob];
   
	NSRect knobRectTop = NSMakeRect(knobRect.origin.x, knobRect.origin.y, knobRect.size.width, 11);
	NSRect knobRectBottom = NSMakeRect(knobRect.origin.x, knobRect.origin.y+knobRect.size.height-10, knobRect.size.width, 10);
	NSRect knobRectFill = NSMakeRect(knobRect.origin.x, knobRect.origin.y+11, knobRect.size.width, knobRect.size.height-21);
	
	NSImage *knobImage;
	
	if ([[super window] isMainWindow] && [[super window] isKeyWindow]) {
		knobImage = [NSImage imageNamed:@"ScrollKnob"];
	} else {
		knobImage = [NSImage imageNamed:@"ScrollKnobInactive"];
	}
	
	[knobImage drawInRect:knobRectTop fromRect: NSMakeRect(0, 0, 15, 11) operation:NSCompositeSourceAtop fraction:1.0];
	[knobImage drawInRect:knobRectBottom fromRect: NSMakeRect(0, 21, 15, 10) operation:NSCompositeSourceAtop fraction:1.0];
	[knobImage drawInRect:knobRectFill fromRect: NSMakeRect(0, 11, 15, 10) operation:NSCompositeSourceAtop fraction:1.0];
}

// Draw the scroll bar arrows
- (void)drawArrow:(NSScrollerArrow)arrow highlightPart:(int)flag
{
	BOOL scrollBarsTogether = YES;
	NSRect upArrowRect = [self rectForPart:NSScrollerDecrementLine];
	NSRect downArrowRect = [self rectForPart:NSScrollerIncrementLine];
	
	scrollArrowsActive = [NSImage imageNamed:@"ScrollArrowsActive"];
	
	if ([[super window] isMainWindow] && [[super window] isKeyWindow]) {
		scrollArrows = [NSImage imageNamed:@"ScrollArrows"];
	} else {
		scrollArrows = [NSImage imageNamed:@"ScrollArrowsInactive"];
	}
	
	// Check to see if scroll arrows are positioned either:
	//    0: At top and bottom
	//    1: Together
	
	if (upArrowRect.origin.y==0.0)
		scrollBarsTogether = NO;
		
	// Calculate where to copy from the source images
	// based on the scroll arrow positions
	
	if (scrollBarsTogether==1) {
		upArrowRect.origin.y-=14;
		upArrowRect.size.height+=15;
		upArrowCopyRect = NSMakeRect(0, 29, 15, 29);
		
		downArrowRect.size.height+=1;
		downArrowCopyRect = NSMakeRect(0, 57, 15, 17);
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
	scrollTrack = [NSImage imageNamed:@"ScrollTrackFill"];
	
	[scrollTrack drawInRect:rect fromRect: NSMakeRect(0, 18, 15, 8) operation:NSCompositeSourceOver fraction:1.0];
	[scrollTrack drawInRect:NSMakeRect(rect.origin.x, rect.origin.y-4, rect.size.width, 18) fromRect: NSMakeRect(0, 0, 15, 18) operation:NSCompositeSourceOver fraction:1.0];
	//[scrollTrack drawInRect:NSMakeRect(rect.origin.x, rect.origin.y+rect.size.height-13, rect.size.width, 18) fromRect:NSMakeRect(0, 26, 15, 18) operation:NSCompositeSourceOver fraction:1.0];
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
