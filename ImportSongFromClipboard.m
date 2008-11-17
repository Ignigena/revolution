//
//  ImportSongFromClipboard.m
//  iWorship
//
//  Created by Albert Martin on 3/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ImportSongFromClipboard.h"
#import "MyDocument.h"
#import "AddSongSheet.h"

@implementation ImportSongFromClipboard

- (id)init {
    self = [super init];
	
	if (self) {
		slideImporterTemp = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedFileConversion:) name:NSTaskDidTerminateNotification object:nil];
	}
	
	return self;
}

- (IBAction)runImportFromClipboard:(id)sender
{
	NSString *clipboard = [[NSPasteboard generalPasteboard] stringForType:NSStringPboardType];
	
	NSLog(@"%@", clipboard);
	
    if (clipboard) {
		NSArray *explodeFileToLine = [clipboard componentsSeparatedByString:@"\n"];
		[slideImporterTemp setArray: explodeFileToLine];
		[slideImporterPreview reloadData];
	
		[NSApp beginSheet:importerWizardView modalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
	}
}

/* Required method for the NSTableDataSource protocol. */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [slideImporterTemp count];
}

/* Required method for the NSTableDataSource protocol. */
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex
{
    return [slideImporterTemp objectAtIndex:rowIndex];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	[slideImporterTemp replaceObjectAtIndex:rowIndex withObject:anObject];
}

- (IBAction)doInsertIntoActiveDocument:(id)sender
{
	[[[[[documentPlaylistTable window] windowController] document] worshipPlaylist] addObject: [songTitle stringValue]];
	
	NSMutableDictionary *songFile = [[NSMutableDictionary alloc] init];
	NSMutableArray *blankNotes = [[NSMutableArray alloc] init];
	unsigned i;
	
	for (i = 0; i < [slideImporterTemp count]; i++)
		[blankNotes addObject: @""];
	
	[songFile setObject:[songTitle stringValue] forKey:@"Song Title"];
	[songFile setObject:slideImporterTemp forKey:@"Slides"];
	[songFile setObject:blankNotes forKey:@"Flags"];
	
	[songFile writeToFile:[[NSString stringWithFormat: @"~/Library/Application Support/iWorship/%@.iwsf", [songTitle stringValue]] stringByExpandingTildeInPath] atomically:TRUE];
	
	[[importerLibraryView dataSource] loadReloadLibraryList];
	[importerLibraryView reloadData];
	[documentPlaylistTable reloadData];
	
    [NSApp endSheet:importerWizardView];
	
	[documentPlaylistTable selectRow:[documentPlaylistTable selectedRow]+1 byExtendingSelection:NO];
}

- (IBAction)closeImportWithoutSave:(id)sender
{
	[NSApp endSheet:importerWizardView];
	
	[addSongController displayLibrarySelector: self];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

@end
