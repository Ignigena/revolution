//
//  ImportSongFromFile.m
//  iWorship
//
//  Created by Albert Martin on 3/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ImportSongFromFile.h"
#import "MyDocument.h"
#import "AddSongSheet.h"

@implementation ImportSongFromFile

- (id)init {
    self = [super init];
	
	if (self) {
		slideImporterTemp = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedFileConversion:) name:NSTaskDidTerminateNotification object:nil];
	}
	
	return self;
}

- (IBAction)runImportFromFile:(id)sender
{
	NSOpenPanel* importFileSelector = [NSOpenPanel openPanel];
	
	[importFileSelector setAllowedFileTypes: @[@"doc", @"txt", @"ttxt", @"text", @"rtf"]];
	[importFileSelector setAllowsOtherFileTypes: NO];
	[importFileSelector setCanChooseDirectories: NO];
	[importFileSelector setAllowsMultipleSelection: NO];

	if ([importFileSelector runModalForDirectory:nil file:nil types:@[@"doc", @"txt", @"ttxt", @"text", @"rtf"]] == NSOKButton)
	{			
		NSString *filePath = [importFileSelector filenames][0];
		conversionSave = [NSString stringWithFormat: @"%@/%@.txt", NSTemporaryDirectory(), [filePath lastPathComponent]];
		
		conversion = [[NSTask alloc] init];
		[conversion setLaunchPath:@"/usr/bin/textutil"];
		[conversion setArguments: @[@"-convert", @"txt",
			@"-output", conversionSave,
			filePath]];
		[conversion launch];
	}
}

- (void)finishedFileConversion:(NSNotification *)aNotification
{	
	NSString *fileContents = [NSString stringWithContentsOfFile:conversionSave encoding: NSUTF8StringEncoding error:nil];
	
	if (fileContents) {
		// Convert line breaks into new slides
		unsigned length = [fileContents length];
		unsigned paraStart = 0, doubleParaStart = 0, paraEnd = 0, contentsEnd = 0;
		NSRange currentRange, doubleParaRange;
		NSMutableArray *explodeFileToLine = [NSMutableArray array];
		
		while (paraEnd < length) {
			[fileContents getParagraphStart:&paraStart end:&paraEnd contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
			currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
			
			//NSLog(@"%@", [fileContents substringWithRange:currentRange]);
			
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Line Breaks"] isEqualToString: @"Paragraph"]) {
				// Split the file based on paragraph
				if ([[fileContents substringWithRange:currentRange] isEqualToString: @""] || paraEnd == length) {
					if (paraEnd == length) doubleParaRange = NSMakeRange(doubleParaStart, contentsEnd - doubleParaStart);
					else doubleParaRange = NSMakeRange(doubleParaStart, contentsEnd - doubleParaStart - 1);
					[explodeFileToLine addObject:[fileContents substringWithRange:doubleParaRange]];
					doubleParaStart = contentsEnd + 1;
				}
			} else {
				// Split the file based on line
				[explodeFileToLine addObject:[fileContents substringWithRange:currentRange]];
			}
		}
	
		[slideImporterTemp setArray: explodeFileToLine];
		[slideImporterPreview reloadData];
	
		[self doInsertIntoActiveDocument: nil];
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
    return slideImporterTemp[rowIndex];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	slideImporterTemp[rowIndex] = anObject;
}

- (IBAction)doInsertIntoActiveDocument:(id)sender
{
    [[[[[documentPlaylistTable window] windowController] document] playlist] addObject: [songTitle stringValue]];
	
	NSMutableDictionary *songFile = [[NSMutableDictionary alloc] init];
	NSMutableArray *blankNotes = [[NSMutableArray alloc] init];
	unsigned i;
	
	for (i = 0; i < [slideImporterTemp count]; i++)
		[blankNotes addObject: @""];
	
	songFile[@"Song Title"] = [songTitle stringValue];
	songFile[@"Slides"] = slideImporterTemp;
	songFile[@"Flags"] = blankNotes;
	
	[songFile writeToFile:[[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@.iwsf", [songTitle stringValue]] stringByExpandingTildeInPath] atomically:TRUE];

	[importerLibraryView reloadData];
	[documentPlaylistTable reloadData];
	
	[documentPlaylistTable selectRow:[documentPlaylistTable numberOfRows]-1 byExtendingSelection:NO];
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
