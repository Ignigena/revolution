//
//  ImportSongFromFile.h
//  iWorship
//
//  Created by Albert Martin on 3/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ImportSongFromFile : NSObject
{
	IBOutlet id importerParentWindow;
	IBOutlet id importerLibraryView;
	IBOutlet id importerWizardView;
	IBOutlet id slideImporterPreview;
	
	IBOutlet id documentWindow;
	IBOutlet id documentPlaylistTable;
	IBOutlet id documentSlideViewer;
	IBOutlet id documentSongTitle;
	
	IBOutlet id addSongController;
	
	IBOutlet id songTitle;
	
	NSTask *conversion;
	NSString *conversionSave;
	
	NSMutableArray *slideImporterTemp;
}

- (IBAction)runImportFromFile:(id)sender;
- (void)finishedFileConversion:(NSNotification *)aNotification;
- (IBAction)doInsertIntoActiveDocument:(id)sender;
- (IBAction)closeImportWithoutSave:(id)sender;

@end
