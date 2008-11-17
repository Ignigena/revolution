#import "SlideSplitBackground.h"

@implementation SlideSplitBackground

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	//[[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
	//[NSBezierPath fillRect:rect];
			
	[[NSImage imageNamed: @"SlidesBackground"] drawInRect:rect fromRect: NSMakeRect(0.0, 0.0, 300, 300) operation:NSCompositeSourceOver fraction:1.0];
	//[[NSImage imageNamed: @"SlideSplitterShadow"] drawInRect:NSMakeRect(rect.origin.x, rect.origin.y, 19, rect.size.height) fromRect:NSMakeRect(0,0,19,100) operation:NSCompositeSourceOver fraction:1.0];
}

@end
