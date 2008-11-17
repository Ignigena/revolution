/* IWSplitView */

#import <Cocoa/Cocoa.h>

@interface IWSplitView : NSSplitView
{
	IBOutlet id toolbarStretcher;
	IBOutlet id leftView;
	IBOutlet id resizeGrabber;
	
	BOOL inResizeMode;
	BOOL isSplitterAnimating;
}

- (void)setSplitterPosition:(float)newSplitterPosition animate:(BOOL)animate;
- (float)splitterPosition;
- (BOOL)isSplitterAnimating;

@end
