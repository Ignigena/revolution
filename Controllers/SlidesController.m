//
//  SlidesController.m
//  Revolution
//
//  Created by Albert Martin on 10/16/13.
//
//

#import "MyDocument.h"
#import "SlidesController.h"

@implementation SlidesController

static NSString *baseLocation = @"~/Library/Application Support/Revolution/";

@synthesize buttonsEnabled, songTitle, ccliDetails, ccliDisplayLine, defaultFormatting;

- (id)init
{
    self = [super init];
    if (self) {
        self.songTitle = @"";
        self.buttonsEnabled = FALSE;
    }
    return self;
}

- (void)loadSongFromPlaylist:(Playlist *)song
{
    NSString *worshipSlideFile = [[NSString stringWithFormat: @"%@/%@", baseLocation, song.playlistTitle] stringByExpandingTildeInPath];
    BOOL worshipSlideFileExists = [[NSFileManager defaultManager] fileExistsAtPath: worshipSlideFile];
    
    self.songTitle = [[song.playlistTitle componentsSeparatedByString:@".iwsf"] objectAtIndex:0];
    self.buttonsEnabled = worshipSlideFileExists;
    
    // If the file doesn't exist, notify the user.
    if (!worshipSlideFileExists && self.songTitle) {
        NSBeginAlertSheet([NSString stringWithFormat: @"\"%@\" Not Found", self.songTitle], @"OK", nil, nil, [[[NSDocumentController sharedDocumentController] currentDocument] documentWindow], self, NULL, NULL, nil, @"The song could not be found in the library.  This could be because the song has been deleted or renamed since you last loaded this playlist.");
    } else {
        NSDictionary *readSlideFileContents = [[NSDictionary alloc] initWithContentsOfFile: worshipSlideFile];
        
        #warning Needs to be updated to support bindings.
        /*[docSlideViewer setWorshipSlides:readSlideFileContents[@"Slides"] notesSlides:readSlideFileContents[@"Flags"] mediaRefs:readSlideFileContents[@"Media"]];
        // Set up the slide viewer pane
        [docSlideScroller setHasVerticalScroller: YES];
        [docSlideViewer setClickedSlideAtIndex: -1];
        
        // Reset the undo manager
        [[self undoManager] removeAllActions];*/
        
        // Read CCLI information.
        self.ccliDetails[@"year"] = readSlideFileContents[@"CCLI Copyright Year"];
        self.ccliDetails[@"artist"] = readSlideFileContents[@"CCLI Artist"];
        self.ccliDetails[@"publisher"] = readSlideFileContents[@"CCLI Publisher"];
        self.ccliDetails[@"number"] = readSlideFileContents[@"CCLI Song Number"];
        
        if (self.ccliDetails[@"year"]) {
            self.ccliDisplayLine = [NSString stringWithFormat:@"© %@ %@, %@", ccliDetails[@"year"], ccliDetails[@"artist"], ccliDetails[@"publisher"]];
        }
        
        // Read default slide formatting.
        self.defaultFormatting[@"layout"] = readSlideFileContents[@"Presenter Layout"]; // 0=top, 2=bottom, 1=centre
        self.defaultFormatting[@"alignment"] = readSlideFileContents[@"Presenter Alignment"]; // 0=left, 1=right, 2=centre
        self.defaultFormatting[@"transition"] = readSlideFileContents[@"Transition Speed"];
        self.defaultFormatting[@"font"] = readSlideFileContents[@"Font Family"];
        self.defaultFormatting[@"size"] = readSlideFileContents[@"Font Size"];
    }
}

@end
