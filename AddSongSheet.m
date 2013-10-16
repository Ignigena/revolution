#import "AddSongSheet.h"
#import "MyDocument.h"
#import "ImportSongFromFile.h"

@implementation AddSongSheet

- (IBAction)displayLibrarySelector:(id)sender
{
	[songTitleField setStringValue: @""];
	[createSongButton setEnabled: NO];
	
	// Set up the "Store In" menu
	NSMenu *storeInMenu = [[NSMenu alloc] initWithTitle:@"Store In Folder"];
	[storeInMenu addItemWithTitle:@"Library" action:nil keyEquivalent:@""];
	[storeInMenu addItem:[NSMenuItem separatorItem]];
	
	// Scan the song library for a listing of all folders
	NSString *libraryPath = @"~/Library/Application Support/ProWorship";
	NSMutableArray *libraryListing = [[NSMutableArray alloc] initWithArray: [[NSFileManager defaultManager] directoryContentsAtPath:[libraryPath stringByExpandingTildeInPath]]];
	int index;
		
	for (index = 1; index <= [libraryListing count]-1; index++) {
		BOOL isDir;
		NSString *currentPath = [NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@", libraryListing[index]];
			
		if ([[NSFileManager defaultManager] fileExistsAtPath:[currentPath stringByExpandingTildeInPath] isDirectory:&isDir] && isDir && ![libraryListing[index] isEqualToString: @"Thumbnails"]) {
			[storeInMenu addItemWithTitle:libraryListing[index] action:nil keyEquivalent:@""];
		}
	}
	
	// Attach the menu to the pop up selector
	[storeInPopup setMenu: storeInMenu];
	
	// Launch the sheet
	[NSApp beginSheet:self modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)displayNewFolder:(id)sender
{
	[folderTitleField setStringValue: @""];
	[createFolderButton setEnabled: NO];
	[NSApp beginSheet:newFolderSheet modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)closeFolderSheet:(id)sender
{ 
    [NSApp endSheet:newFolderSheet];
	[newFolderSheet orderOut: self];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)newImportFromFile:(id)sender
{
	[NSApp endSheet:self];
	[self close];
	
	[importerController runImportFromFile: self];
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    [createSongButton setEnabled: YES];
	[createFolderButton setEnabled: YES];
}

- (IBAction)addFolder:(id)sender
{
	[[NSFileManager defaultManager] createDirectoryAtPath:[[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@", [folderTitleField stringValue]] stringByExpandingTildeInPath] attributes:nil];
	
	[importerLibraryView reloadData];
	
	[NSApp endSheet:newFolderSheet];
	[newFolderSheet close];
}

- (IBAction)addSong:(id)sender
{
	NSString *saveSongFolder = [NSString stringWithFormat: @"%@/", [storeInPopup titleOfSelectedItem]];
	
	if ([saveSongFolder isEqualToString: @"Library/"])
		saveSongFolder = @"";
		
	if ([importSourceClipboard intValue]==1) {
		NSString *clipboard = [[NSPasteboard generalPasteboard] stringForType:NSStringPboardType];
	
		if (clipboard) {
			[[[[[documentPlaylistTable window] windowController] document] worshipPlaylist] addObject: [NSString stringWithFormat: @"%@%@.iwsf", saveSongFolder, [songTitleField stringValue]]];
			
			NSMutableDictionary *songFile = [[NSMutableDictionary alloc] init];
			NSArray *songSlides = [self runCleanupScript: clipboard];
			
			songFile[@"Song Title"] = [songTitleField stringValue];
			songFile[@"Slides"] = songSlides;
			
			NSMutableArray *blankNotes = [[NSMutableArray alloc] init];
			unsigned i;
	
			for (i = 0; i < [songSlides count]; i++)
				[blankNotes addObject: @""];
	
			songFile[@"Flags"] = blankNotes;
			
			[songFile writeToFile:[[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@%@.iwsf", saveSongFolder, [songTitleField stringValue]] stringByExpandingTildeInPath] atomically:TRUE];

			[importerLibraryView reloadData];
			[documentPlaylistTable reloadData];
			
			[NSApp endSheet:self];
			[self close];
			
			[documentPlaylistTable selectRow:[documentPlaylistTable numberOfRows]-1 byExtendingSelection:NO];
		} else {
			NSRunCriticalAlertPanel(@"No Usable Data Found", @"ProWorship was unable to find usable data on the clipboard.  Copy text to the clipboard and try again.", @"OK", nil, nil);
			[NSApp requestUserAttention: 0];
		}
	} else if ([importSourceDocument intValue]==1) {
		[NSApp endSheet:self];
		[self close];
	
		[importerController runImportFromFile: self];
	} else {
		[[[[[documentPlaylistTable window] windowController] document] worshipPlaylist] addObject: [NSString stringWithFormat: @"%@%@.iwsf", saveSongFolder, [songTitleField stringValue]]];
	
		NSMutableDictionary *songFile = [[NSMutableDictionary alloc] init];
		NSArray *blankArray = @[@""];
	
		songFile[@"Song Title"] = [songTitleField stringValue];
		songFile[@"Slides"] = blankArray;
		songFile[@"Flags"] = blankArray;
	
		[songFile writeToFile:[[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@%@.iwsf", saveSongFolder, [songTitleField stringValue]] stringByExpandingTildeInPath] atomically:TRUE];
		
		[importerLibraryView reloadData];
		[documentPlaylistTable reloadData];
	
		[NSApp endSheet:self];
		[self close];
	
		[documentPlaylistTable selectRow:[documentPlaylistTable numberOfRows]-1 byExtendingSelection:NO];
	}
}

- (NSArray *)runCleanupScript:(NSString *)stringToClean
{
	NSMutableArray *cleanStringArray = [NSMutableArray array];
	
	// Convert line breaks
	unsigned length = [stringToClean length];
	unsigned paraStart = 0, doubleParaStart = 0, paraEnd = 0, contentsEnd = 0;
	NSRange currentRange, doubleParaRange;

	while (paraEnd < length) {
		[stringToClean getParagraphStart:&paraStart end:&paraEnd contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
		currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
		
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Line Breaks"] isEqualToString: @"Paragraph"]) {
			// Split the file based on paragraph
			if ([[stringToClean substringWithRange:currentRange] isEqualToString: @""] || paraEnd == length) {
				if (paraEnd == length) doubleParaRange = NSMakeRange(doubleParaStart, contentsEnd - doubleParaStart);
				else doubleParaRange = NSMakeRange(doubleParaStart, contentsEnd - doubleParaStart - 1);
				[cleanStringArray addObject:[stringToClean substringWithRange:doubleParaRange]];
				doubleParaStart = contentsEnd + 1;
			}
		} else {
			// Split the file based on line
			[cleanStringArray addObject:[stringToClean substringWithRange:currentRange]];
		}
	}
	
	// PROPRESENTER X: Convert %r to in-slide line breaks
	//int ppLineBreak;
	
	//for (ppLineBreak = 0; ppLineBreak < [cleanStringArray count]; ppLineBreak++) {
	//	NSMutableString *ppLineBreakText = [NSMutableString stringWithString: [cleanStringArray objectAtIndex: ppLineBreak]];
	//	NSString *ppLineBreakClean = [ppLineBreakText replaceOccurrencesOfString:@"%r" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[ppLineBreakText length])];
	//	[cleanStringArray replaceObjectAtIndex:ppLineBreak withObject:ppLineBreakClean];
	//}
	
	return cleanStringArray;
}

@end
