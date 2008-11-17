#import "IWTableHeaderTextField.h"

@implementation IWTableHeaderTextField

- (void)drawRect:(NSRect)rect
{
	NSGradient *background = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.47 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.29 alpha:1.0]];
	[background drawInRect:[self bounds] angle:90.0f];
	
	[[NSColor colorWithDeviceWhite:0.18 alpha:1.0] set];
	
	[[NSGraphicsContext currentContext] setShouldAntialias: NO];
	
	NSBezierPath *topBorder = [NSBezierPath bezierPath];
	[topBorder moveToPoint:NSMakePoint(0, 1)];
	[topBorder lineToPoint:NSMakePoint([self bounds].size.width, 1)];
	[topBorder setLineWidth:0.5];
	[topBorder stroke];
	
	NSBezierPath *bottomBorder = [NSBezierPath bezierPath];
	[bottomBorder moveToPoint:NSMakePoint(0, 24)];
	[bottomBorder lineToPoint:NSMakePoint([self bounds].size.width, 24)];
	[bottomBorder setLineWidth:0.5];
	[bottomBorder stroke];
	
	[[NSGraphicsContext currentContext] setShouldAntialias: YES];
	
	NSShadow *textShadow = [NSShadow alloc];
	[textShadow setShadowOffset: NSMakeSize(0, -1)];
	[textShadow setShadowColor: [NSColor colorWithCalibratedWhite: 0 alpha: 0.5]];
	[textShadow setShadowBlurRadius: 1];
	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSFont boldSystemFontOfSize:11], NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, textShadow, NSShadowAttributeName, nil];
	[[self stringValue] drawInRect:NSMakeRect(10, 4, rect.size.width, rect.size.height-4) withAttributes: attrs];
}

@end
