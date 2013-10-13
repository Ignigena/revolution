#import "DarkSlider.h"

@implementation DarkSlider

- (double)knobThickness
{
	return 13;
}

// Draws the knob
- (void)drawKnob:(NSRect)knobRect
{
	NSImage *knob = [NSImage imageNamed:@"DarkSliderKnob"];
	[knob setFlipped: YES];
	
	[[self controlView] lockFocus];
	[knob drawInRect: NSMakeRect(knobRect.origin.x,knobRect.origin.y,knobRect.size.width,15) fromRect: NSMakeRect(0,0,13,15) operation: NSCompositeSourceOver fraction: 1.0];
	[[self controlView] unlockFocus];
}

// Draws the tracking bar
- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
	NSImage *track = [NSImage imageNamed:@"DarkSliderTrack"];
	NSImage *transitionSpeedBar = [NSImage imageNamed:@"TransitionSpeedBar"];
	[track setFlipped: YES];
	[transitionSpeedBar setFlipped: YES];
	
	[[self controlView] lockFocus];
	[transitionSpeedBar drawInRect: [[self controlView] bounds] fromRect: NSMakeRect(3,0,101,18) operation: NSCompositeSourceOver fraction: 1.0];
	[track drawInRect: NSMakeRect(0,9,[[self controlView] bounds].size.width,5) fromRect: NSMakeRect(0,0,101,5) operation: NSCompositeSourceOver fraction: 1.0];
	[[self controlView] unlockFocus];
}

@end
