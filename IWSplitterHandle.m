#import "IWSplitterHandle.h"

@implementation IWSplitterHandle

- (void)mouseDown:(NSEvent *)theEvent
{
	//NSLog(@"mouseDown in sliderImage");
	[[[self superview] superview] mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	//NSLog(@"mouseDragged in sliderImage");
	[[[self superview] superview] mouseDragged:theEvent];
}

@end
