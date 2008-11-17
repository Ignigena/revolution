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

@implementation ImportController

+ (void)importScriptureToDocumentFromURL:(NSURL *)url reference:(NSString *)ref split:(BOOL)split
{
	NSMutableDictionary *scriptureFile = [[NSMutableDictionary alloc] init];
	NSMutableArray *scriptureSlides = [[NSMutableArray alloc] init];
		
	[scriptureFile setObject:ref forKey:@"Song Title"];
	[scriptureFile setObject:scriptureSlides forKey:@"Slides"];
		
	NSMutableArray *blankNotes = [NSMutableArray arrayWithCapacity: [scriptureSlides count]];
	[scriptureFile setObject:blankNotes forKey:@"Flags"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath: [[NSString stringWithString: @"~/Library/Application Support/ProWorship/Scripture/"] stringByExpandingTildeInPath]] == NO) { [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString stringWithString: @"~/Library/Application Support/ProWorship/Scripture/"] stringByExpandingTildeInPath] attributes: nil]; }
		
	[scriptureFile writeToFile:[[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/Scripture/%@.iwsf", ref] stringByExpandingTildeInPath] atomically:TRUE];
		
	[[[[[NSDocumentController sharedDocumentController] currentDocument] libraryListing] dataSource] loadReloadLibraryList];
	[[[[NSDocumentController sharedDocumentController] currentDocument] libraryListing] reloadData];
	
	[[[[NSDocumentController sharedDocumentController] currentDocument] worshipPlaylist] addObject: [NSString stringWithFormat: @"Scripture/%@.iwsf", ref]];
	
	[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] reloadData];
	[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] selectRow:[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] numberOfRows]-1 byExtendingSelection:NO];
}

@end
