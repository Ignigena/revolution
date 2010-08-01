//
//  MyDocument.h
//  iWorship
//
//  Created by Albert Martin on 12/25/06.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.
//

#import <QTKit/QTKit.h>
#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "IWSlideViewer.h"
#import "Controller.h"
#import "FormattingBar.h"
#import "MediaThumbnailBrowser.h"
#import "IWVideoPreview.h"
#import "IWMediaBox.h"
#import "BLIPConnection.h"

@interface MyDocument : NSDocument <TCPListenerDelegate, BLIPConnectionDelegate>
{
	NSMutableArray *worshipPlaylist;
	
	BLIPListener *_listener;
	NSNetServiceBrowser * receiverBrowser;
    NSMutableArray * receiverList;
	
    IBOutlet id playlistTable;
	IBOutlet NFIWindow *documentWindow;
	IBOutlet id worshipTitleBar;
	IBOutlet id worshipCCLIBar;
	IBOutlet id worshipCCLIButton;
	IBOutlet id worshipTitleBarContainer;
	IBOutlet id mediaBoxContent;
	IBOutlet IWSlideViewer *docSlideViewer;
	IBOutlet id docSlideScroller;
	IBOutlet MediaThumbnailBrowser *thumbnailScroller;
	
	IBOutlet id formatterToolbar;
	
	IBOutlet id videoPreviewController;
	IBOutlet id videoPreviewController2;
	IBOutlet id videoPreviewDisplay;
	IBOutlet IWVideoView* videoPreviewDisplayGL;
	IBOutlet id loopingToggle;
	
	IBOutlet id addSongSheet;
	IBOutlet id addFolderSheet;
	IBOutlet id addSongPanel;
	IBOutlet id libraryListing;
	
	IBOutlet id ccliEditor;
	IBOutlet id songArtist;
	IBOutlet id songCopyright;
	IBOutlet id songPublisher;
	IBOutlet id songNumber;
	
	NSString *previousSelectedPlaylist;
	
	IBOutlet id rightSplitterView;
	
	// Toolbar buttons (in song title bar)
	IBOutlet id toolbarNewSlide;
	IBOutlet id toolbarNextSlide;
	IBOutlet id toolbarPrevSlide;
	
	int draggingTableRowStart;
}

- (void)sendDataToAllNodes:(NSData *)data;
- (void) gotResponse: (BLIPResponse*)response;

- (void)checkEmptyLibrary;
- (IBAction)removeFromPlaylist:(id)sender;
- (IBAction)closePlaylistSheet:(id)sender;
- (IBAction)closeFolderSheet:(id)sender;
- (IBAction)addSongToPlaylist:(id)sender;

- (IBAction)editCCLIDetails:(id)sender;
- (IBAction)applyCCLIDetails:(id)sender;

- (IBAction)toggleMediaMixer:(id)sender;
- (IBAction)docWindowGoToBlack:(id)sender;

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (NSMutableArray *)worshipPlaylist;

- (IWMediaBox *)mediaBox;

- (NSButton *)loopingToggle;

- (IWVideoPreview *)videoPreviewDisplay;
- (QTMovieView *)videoPreviewController;
- (QTMovieView *)videoPreviewController2;
- (MediaThumbnailBrowser *)thumbnailScroller;
- (IWSlideViewer *)docSlideViewer;
- (NSTableView *)playlistTable;
- (NSTableView *)libraryListing;

- (NSString *)songDetailsWithKey:(NSString *)key;

@end
