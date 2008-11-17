/* RSDarkScroller */

#import <Cocoa/Cocoa.h>
#include <AppKit/AppKit.h>

@interface RSDarkScroller : NSScroller
{
	NSImage *scrollArrows;
	NSImage *scrollArrowsActive;
	NSImage *scrollTrack;
	
	NSRect upArrowCopyRect;
	NSRect downArrowCopyRect;
}

@end
