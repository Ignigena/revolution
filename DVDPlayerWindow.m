#import <DVDPlayback/DVDPlayback.h>
#import "DVDPlayerWindow.h"
#import "Controller.h"

@implementation DVDPlayerWindow

- (void) awakeFromNib 
{
	// Set the window up to respond to mouse events
	[self setAcceptsMouseMovedEvents:YES];
}


/*- (void) keyDown:(NSEvent *)theEvent 
{
	BOOL eventHandled = [[self delegate] onKeyDown:theEvent];

	if (eventHandled == NO) {
		[super keyDown:theEvent];
	} else {
		[self flushBufferedKeyEvents];
	}
}*/


/* This method overrides NSWindow to handle button mouse-overs and mouse-clicks
in the window. */

- (void) sendEvent:(NSEvent *)theEvent 
{
	/* index of selected button in DVD menu */
	SInt32 index = kDVDButtonIndexNone;

	// Convert the mouse location to a CGPoint
	CGPoint mousePoint = CGPointMake([theEvent locationInWindow].x,[self frame].size.height - [theEvent locationInWindow].y);
	
	/* notify DVD Playback */
	switch ([theEvent type])
	{
		OSStatus err;
		case NSMouseMoved:
			err = DVDDoMenuCGMouseOver (&mousePoint, &index);
			break;
		case NSLeftMouseDown:
			err = DVDDoMenuCGClick(&mousePoint, &index);
			break;
		default:
			break;
	}

	/* sync the cursor */
	NSCursor *cursor;
	if (index != kDVDButtonIndexNone) {
		cursor = [NSCursor pointingHandCursor];
	} else {
		cursor = [NSCursor arrowCursor];
	}
	[cursor set];

	/* pass the event back to NSWindow for additional handling */
	[super sendEvent:theEvent];
}

@end
