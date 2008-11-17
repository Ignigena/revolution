#import "LaunchWindow.h"

@implementation LaunchWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)style backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	id window = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
	
	if (window)
	{
		[window setOpaque: NO];
		[window setBackgroundColor: [NSColor colorWithDeviceWhite:1.0 alpha:0.0]];
		[window center];
	}
	
	return window;
}

@end
