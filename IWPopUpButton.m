#import "IWPopUpButton.h"

@implementation IWPopUpButton

- (void)drawWithFrame:(NSRect)rect inView:(NSView *)controlView {
	NSLog(@"HELLO");
	
	/*NSImage *backgroundImage;
	
	if (isActive == YES) {
		backgroundImage = [NSImage imageNamed: @"MediaTabBGActive"];
	} else {
		backgroundImage = [NSImage imageNamed: @"MediaTabBG"];
	}

	[backgroundImage setFlipped: YES];
	[backgroundImage drawInRect: rect fromRect: NSMakeRect(0, 0, 10, 40) operation: NSCompositeSourceOver fraction: 1.0];
	
	[[self attributedTitle] drawInRect: [self titleRectForBounds: rect]];*/
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
}

@end
