/* AddSongSheet */

#import <Cocoa/Cocoa.h>

@interface AddSongSheet : NSWindow
{
	IBOutlet id importerController;
	
	IBOutlet id songTitleField;
	IBOutlet id storeInPopup;
	IBOutlet id folderTitleField;
	IBOutlet id createSongButton;
	IBOutlet id createFolderButton;
	
	IBOutlet id importSourceClipboard;
	IBOutlet id importSourceDocument;
	IBOutlet id importSourceEmpty;
	
	IBOutlet id documentPlaylistTable;
	IBOutlet id importerLibraryView;
	
	IBOutlet id newFolderSheet;
}

- (IBAction)displayLibrarySelector:(id)sender;
- (IBAction)displayNewFolder:(id)sender;
- (IBAction)closeFolderSheet:(id)sender;
- (IBAction)newImportFromFile:(id)sender;

- (IBAction)addSong:(id)sender;
- (IBAction)addFolder:(id)sender;

- (NSArray *)runCleanupScript:(NSString *)stringToClean;

@end
