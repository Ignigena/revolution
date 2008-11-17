/* ProScroller */

#import <Cocoa/Cocoa.h>
#include <AppKit/AppKit.h>

@interface HUDScroller : NSScroller
{
	NSImage *scrollArrows;
	NSImage *scrollArrowsActive;
	NSImage *scrollTrack;
	
	NSRect upArrowCopyRect;
	NSRect downArrowCopyRect;
}

@end
