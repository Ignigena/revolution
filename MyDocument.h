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
	IBOutlet NSWindow *documentWindow;
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
	IBOutlet id videoPreviewImageArea;
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
	
	IBOutlet NSSegmentedControl *presentationModeSwitcher;
	
	NSString *previousSelectedPlaylist;
	
	IBOutlet id rightSplitterView;
	
	// Toolbar buttons (in song title bar)
	IBOutlet id toolbarNewSlide;
	IBOutlet id toolbarNextSlide;
	IBOutlet id toolbarPrevSlide;
	IBOutlet id toolbarMediaToggle;
	
	int draggingTableRowStart;
	
	IBOutlet id librarySearchPopupView;
	IBOutlet id librarySearchPopupButton;
	
	MAAttachedWindow *librarySearchPopup;
}

- (void)sendDataToAllNodes:(NSData *)data;
- (void)gotResponse:(BLIPResponse*)response;
- (void)listener:(TCPListener*)listener didAcceptConnection:(TCPConnection*)connection;

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
- (NSImageView *)videoPreviewImageArea;
- (MediaThumbnailBrowser *)thumbnailScroller;
- (IWSlideViewer *)docSlideViewer;
- (NSTableView *)playlistTable;
- (NSTableView *)libraryListing;

- (NSString *)songDetailsWithKey:(NSString *)key;

- (IBAction)toggleLibrarySearchPopup:(id)sender;

- (IBAction)setPresentationMode:(id)sender;
- (NSSegmentedControl *)presentationModeSwitcher;

@end
