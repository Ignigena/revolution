#import "SlideTitleBar.h"

@implementation SlideTitleBar

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSGradient *titleBackground = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.86 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.58 alpha:1.0]];
	[titleBackground drawInRect:[self bounds] angle:-90.0f];
	
	NSGradient *titleBackgroundDark = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.55 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.31 alpha:1.0]];
	[titleBackgroundDark drawInRect:NSMakeRect([self bounds].size.width-74, 0, 74, [self bounds].size.height) angle:-90.0f];
	
	[[NSColor colorWithDeviceWhite:0.27 alpha:1.0] set];
	[[NSGraphicsContext currentContext] setShouldAntialias: NO];
	
	NSBezierPath *darkSeparator = [NSBezierPath bezierPath];
	[darkSeparator moveToPoint:NSMakePoint([self bounds].size.width-75, 0)];
	[darkSeparator lineToPoint:NSMakePoint([self bounds].size.width-75, 36)];
	[darkSeparator setLineWidth:0.5];
	[darkSeparator stroke];
	
	[[NSColor colorWithDeviceWhite:0.02 alpha:1.0] set];
	NSBezierPath *leftBorder = [NSBezierPath bezierPath];
	[leftBorder moveToPoint:NSMakePoint(0, 0)];
	[leftBorder lineToPoint:NSMakePoint(0, 36)];
	[leftBorder setLineWidth:0.5];
	[leftBorder stroke];
	
	[[NSColor blackColor] set];
	
	NSBezierPath *bottomBorder = [NSBezierPath bezierPath];
	[bottomBorder moveToPoint:NSMakePoint(0, 0)];
	[bottomBorder lineToPoint:NSMakePoint(rect.size.width, 0)];
	[bottomBorder setLineWidth:0.5];
	[bottomBorder stroke];
}

@end
