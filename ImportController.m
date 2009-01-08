//
//  ImportController.m
//  Revolution
//
//  Created by Albert Martin on 11/5/08.
//  Copyright 2008 Renovatio Software. All rights reserved.
//

#import "ImportController.h"
#import "MyDocument.h"
#import "LibraryListing.h"
#import "XMLTree.h"

@implementation ImportController

+ (void)importScriptureToDocumentFromURL:(NSURL *)url reference:(NSString *)ref split:(BOOL)split
{
	NSMutableDictionary *scriptureFile = [[NSMutableDictionary alloc] init];
	NSMutableArray *scriptureSlides = [[NSMutableArray alloc] init];
	NSMutableString *scriptureText = [[NSMutableString alloc] init];
	
	XMLTree *scriptureLookupXML = [[XMLTree alloc] initWithURL:url];
	
	unsigned i;
	
	for (i = 2; i <= [[scriptureLookupXML descendentNamed:@"query"] count]-1; i++) {
		NSString *scriptureVerse = [[NSString stringWithFormat: @"%@", [[[scriptureLookupXML descendentNamed:@"query"] childAtIndex: i] descendentNamed:@"text"]] stringByReplacingOccurrencesOfString:@"quot;" withString:@"\""];
		
		if (split) {
			[scriptureSlides addObject: scriptureVerse];
		} else {
			[scriptureText appendString: scriptureVerse];
			[scriptureText appendString: @" "];
		}
	}
	
	if (split) {
		[scriptureSlides addObject: ref];
	} else {
		[scriptureText appendString: @"\n"];
		[scriptureText appendString: ref];
		[scriptureSlides addObject: scriptureText];
	}
	
	[scriptureFile setObject:ref forKey:@"Song Title"];
	[scriptureFile setObject:scriptureSlides forKey:@"Slides"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath: [[NSString stringWithString: @"~/Library/Application Support/ProWorship/Scripture/"] stringByExpandingTildeInPath]] == NO) { [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString stringWithString: @"~/Library/Application Support/ProWorship/Scripture/"] stringByExpandingTildeInPath] attributes: nil]; }
	
	NSString *saveSongFile = [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/Scripture/%@.iwsf", ref] stringByExpandingTildeInPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath: saveSongFile]) [[NSWorkspace sharedWorkspace] performFileOperation: NSWorkspaceRecycleOperation source: [@"~/Library/Application Support/ProWorship/Scripture/" stringByExpandingTildeInPath] destination: @"" files: [NSArray arrayWithObject: [NSString stringWithFormat:@"%@.iwsf", ref]] tag: 0];
	[scriptureFile writeToFile:saveSongFile atomically:TRUE];
		
	[[[[[NSDocumentController sharedDocumentController] currentDocument] libraryListing] dataSource] loadReloadLibraryList];
	[[[[NSDocumentController sharedDocumentController] currentDocument] libraryListing] reloadData];
	
	[[[[NSDocumentController sharedDocumentController] currentDocument] worshipPlaylist] addObject: [NSString stringWithFormat: @"Scripture/%@.iwsf", ref]];
	
	[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] reloadData];
	[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] selectRow:[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] numberOfRows]-1 byExtendingSelection:NO];
}

+ (void)importScriptureToSlideFromURL:(NSURL *)url reference:(NSString *)ref split:(BOOL)split
{
	NSMutableString *scriptureText = [[NSMutableString alloc] init];
	XMLTree *scriptureLookupXML = [[XMLTree alloc] initWithURL:url];
	
	int currentlySelectedSlide = [[[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] clickedSlideAtIndex];
	unsigned i;
	
	for (i = 2; i <= [[scriptureLookupXML descendentNamed:@"query"] count]-1; i++) {
		NSString *scriptureVerse = [[NSString stringWithFormat: @"%@", [[[scriptureLookupXML descendentNamed:@"query"] childAtIndex: i] descendentNamed:@"text"]] stringByReplacingOccurrencesOfString:@"quot;" withString:@"\""];
		
		if (split) {
			[[[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] insertNewSlide:scriptureVerse slideFlag:@"" slideMedia:@"" slideIndex:currentlySelectedSlide+i-1];
		} else {
			[scriptureText appendString: scriptureVerse];
			[scriptureText appendString: @" "];
		}
	}
	
	if (split) {
		[[[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] insertNewSlide:ref slideFlag:@"" slideMedia:@"" slideIndex:currentlySelectedSlide+i];
	} else {
		[scriptureText appendString: @"\n"];
		[scriptureText appendString: ref];
		[[[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] insertNewSlide:scriptureText slideFlag:@"" slideMedia:@"" slideIndex:currentlySelectedSlide+1];
	}
}

@end
