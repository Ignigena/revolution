#import "NetworkNodeController.h"

@implementation NetworkNodeController

- (void)drawRect:(NSRect)rect
{
	NSImage *background = [NSImage imageNamed: @"NodeSettingsBackground"];
	[background setFlipped: YES];
	[background drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
}

@end
