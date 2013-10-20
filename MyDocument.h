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
#import "Playlist.h"
#import "SlidesController.h"

@interface MyDocument : NSDocument {
@private
    Playlist *selectedSong;
    NSMutableArray *playlist;
@public
    NSMutableArray * receiverList;
    
    IBOutlet SlidesController *slidesController;
    
	IBOutlet id mediaBoxContent;
	IBOutlet IWSlideViewer *docSlideViewer;
	IBOutlet id docSlideScroller;
	IBOutlet MediaThumbnailBrowser *thumbnailScroller;
	
	IBOutlet id formatterToolbar;
	
	IBOutlet id videoPreviewController;
	IBOutlet id videoPreviewController2;
	IBOutlet id videoPreviewDisplay;
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
	
	int draggingTableRowStart;
}

@property NSWindow *documentWindow;
@property (copy) NSMutableArray *playlist;
@property Playlist *selectedSong;
@property SlidesController *slidesController;

- (IBAction)closePlaylistSheet:(id)sender;
- (IBAction)closeFolderSheet:(id)sender;

- (IBAction)editCCLIDetails:(id)sender;
- (IBAction)applyCCLIDetails:(id)sender;

- (IBAction)toggleMediaMixer:(id)sender;
- (IBAction)docWindowGoToBlack:(id)sender;

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IWMediaBox *)mediaBox;

- (NSButton *)loopingToggle;

- (IWVideoPreview *)videoPreviewDisplay;
- (QTMovieView *)videoPreviewController;
- (QTMovieView *)videoPreviewController2;
- (MediaThumbnailBrowser *)thumbnailScroller;
- (IWSlideViewer *)docSlideViewer;
- (NSTableView *)libraryListing;

- (NSString *)songDetailsWithKey:(NSString *)key;

@end
