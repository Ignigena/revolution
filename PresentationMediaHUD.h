/* HUDPanel */

#import <Cocoa/Cocoa.h>
#import "IWSlideViewer.h"

@interface PresentationMediaHUD : NSPanel
{
    BOOL forceDisplay;
	
	NSWindow *presentationBackgroundWindow;
	
	IBOutlet id BackgroundPlayer;
	IBOutlet id SlideController;
}

- (NSColor *)sizedHUDBackground;
- (void)addCloseWidget;

@end
