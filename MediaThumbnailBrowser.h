/* MediaThumbnailBrowser */

#import <Cocoa/Cocoa.h>
#import "IWSplitView.h"
#import "IWVideoView.h"

@interface MediaThumbnailBrowser : NSView
{
	NSSize gridSize;
	unsigned columns;
	unsigned rows;
	
	NSMutableArray *mediaListing;
	NSMutableArray *backgroundPictureListing;
	NSMutableArray *backgroundMovieListing;
	
	BOOL thumbHit;
	unsigned clickedIndex;
	unsigned clickedSlideAtIndex;
	NSPoint mouseDownPoint;
	NSPoint mouseCurrentPoint;
	
	IBOutlet id juiceController;
	
	int mediaType;
	
	IBOutlet id previewArea;
	IBOutlet id photosTabButton;
	IBOutlet id moviesTabButton;
	IBOutlet id liveTabButton;
	IBOutlet id liveTabAction;
	IBOutlet id liveTabText;
	
	IBOutlet IWSplitView *splitterView;
	
	IBOutlet IWVideoView* videoPreviewDisplayGL;
}

- (void)updateGrid;
- (NSRect)gridRectForIndex:(unsigned)index;
- (NSRect)rectCenteredInRect:(NSRect)rect withSize:(NSSize)size;
- (unsigned)slideIndexForPoint:(NSPoint)point;
- (NSRange)slideIndexRangeForRect:(NSRect)rect;

- (void)setMediaListing:(int)type;
- (void)setMovieListing:(NSArray *)aMovieListing;
- (void)setPictureListing:(NSArray *)aPictureListing;

- (NSMutableArray *) mediaListing;
- (NSMutableArray *) backgroundPictureListing;
- (NSMutableArray *) backgroundMovieListing;

- (int)mediaType;

- (void)removeFocus:(id)sender;

- (int)clickedSlideAtIndex;

@end
