//
//  ImportController.m
//  Revolution
//
//  Created by Albert Martin on 11/5/08.
//  Copyright 2008 Renovatio Software. All rights reserved.
//

#import "ImportController.h"
#import "MyDocument.h"

@implementation ImportController

+ (void)importScriptureToDocumentFromURL:(NSURL *)url reference:(NSString *)ref split:(BOOL)split
{
	NSMutableDictionary *scriptureFile = [[NSMutableDictionary alloc] init];
	NSMutableArray *scriptureSlides = [[NSMutableArray alloc] init];
		
	scriptureFile[@"Song Title"] = ref;
	scriptureFile[@"Slides"] = scriptureSlides;
		
	NSMutableArray *blankNotes = [NSMutableArray arrayWithCapacity: [scriptureSlides count]];
	scriptureFile[@"Flags"] = blankNotes;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath: [@"~/Library/Application Support/ProWorship/Scripture/" stringByExpandingTildeInPath]] == NO) { [[NSFileManager defaultManager] createDirectoryAtPath:[@"~/Library/Application Support/ProWorship/Scripture/" stringByExpandingTildeInPath] attributes: nil]; }
		
	[scriptureFile writeToFile:[[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/Scripture/%@.iwsf", ref] stringByExpandingTildeInPath] atomically:TRUE];
	
	[[[[NSDocumentController sharedDocumentController] currentDocument] worshipPlaylist] addObject: [NSString stringWithFormat: @"Scripture/%@.iwsf", ref]];
	
	[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] reloadData];
	[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] selectRow:[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] numberOfRows]-1 byExtendingSelection:NO];
}

@end
