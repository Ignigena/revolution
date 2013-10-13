//
//  LibraryListing.m
//  iWorship
//
//  Created by Albert Martin on 1/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "LibraryListing.h"
#import "IWTableCellText.h"

#define IWPlaylistDataType @"IWPlaylistDataType"

@implementation LibraryListing

- (id)init
{
    self = [super init];
	
    if (self) {
		[self loadReloadLibraryList];
    }
	
    return self;
}

- (void)loadReloadLibraryList
{
	NSLog(@"loadReloadLibraryList");
	
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *library = @"~/Library/Application Support/ProWorship";
		
	libraryListing = [[NSMutableArray alloc] initWithArray: [manager directoryContentsAtPath:[library stringByExpandingTildeInPath]]];
	libraryListingText = [[NSMutableDictionary alloc] init];

	unsigned index;
	BOOL filterResults = NO;
	
	if ([librarySearchField stringValue] && ![[librarySearchField stringValue] isEqualToString:@""])
		filterResults = YES;
		
	NSLog(@"%i", filterResults);
	NSLog(@"%@", [librarySearchField stringValue]);
	
	if ([libraryListing count] <= 1) {
		if (!gettingStartedAddButton) {
			NSPoint buttonPoint = NSMakePoint(NSMidX([addButton frame])+7, NSMidY([addButton frame]));
			
			gettingStartedAddButton = [[MAAttachedWindow alloc] initWithView: addButtonHelpText
																			  attachedToPoint: buttonPoint
																			  inWindow: [addButton window] 
																			  onSide: 9 
																			  atDistance: 3.0f];
		
			[gettingStartedAddButton setBorderColor: [NSColor whiteColor]];
			[gettingStartedAddButton setBackgroundColor: [NSColor blackColor]];
			[gettingStartedAddButton setBorderWidth: 1.0f];
			[gettingStartedAddButton setCornerRadius: 7.0f];
			[gettingStartedAddButton setArrowBaseWidth: 15.0f];
			[gettingStartedAddButton setArrowHeight: 10.0f];
	
			[[addButton window] addChildWindow:gettingStartedAddButton ordered:NSWindowAbove];
		}
	} else {
		[[addButton window] removeChildWindow:gettingStartedAddButton];
        [gettingStartedAddButton orderOut:self];
        gettingStartedAddButton = nil;
	}
	
	for (index = 0; index <= [libraryListing count]-1; index++) {
		BOOL isDir;
		NSString *currentPath = [NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@", [libraryListing objectAtIndex:index]];
		
		NSArray *songLibrarySplitter = [[NSArray alloc] initWithArray: [[libraryListing objectAtIndex:index] componentsSeparatedByString:@"."]];
		//NSString *actualLibraryListing = [[NSString alloc] initWithString: [songLibrarySplitter objectAtIndex: 0]];
		NSString *actualLibraryListing = [libraryListing objectAtIndex:index];
			
		if ([manager fileExistsAtPath:[currentPath stringByExpandingTildeInPath] isDirectory:&isDir] && isDir && ![[libraryListing objectAtIndex:index] isEqualToString: @"Thumbnails"]) {
			NSMutableArray *subLibraryListing = [[NSMutableArray alloc] initWithArray: [manager directoryContentsAtPath:[currentPath stringByExpandingTildeInPath]]];
			
			if ([subLibraryListing count]!=0) {
				unsigned subIndex;
				
				for (subIndex = 0; subIndex <= [subLibraryListing count]-1; subIndex++) {
					if ([[subLibraryListing objectAtIndex:subIndex] isEqualToString:@".DS_Store"]) {
						[subLibraryListing removeObjectAtIndex:subIndex];
					} else {
						//NSString *subActualLibraryListing = [[NSString alloc] initWithString: [NSString stringWithFormat: @"%@/%@", [libraryListing objectAtIndex:index], [[[subLibraryListing objectAtIndex:subIndex] componentsSeparatedByString:@"."] objectAtIndex: 0]]];
						NSString *subActualLibraryListing = [[NSString alloc] initWithString: [NSString stringWithFormat: @"%@/%@", [libraryListing objectAtIndex:index], [subLibraryListing objectAtIndex:subIndex]]];
						//[subLibraryListing replaceObjectAtIndex:subIndex withObject: ];
						[subLibraryListing replaceObjectAtIndex:subIndex withObject:subActualLibraryListing];
					
						if (filterResults) {
							if ([self containsString:[librarySearchField stringValue] inString:[NSString stringWithFormat: @"%@", [[[NSArray alloc] initWithArray: [[subLibraryListing objectAtIndex:subIndex] componentsSeparatedByString:@"/"]] objectAtIndex: 1]]])
								[libraryListingText setObject:[NSNull null] forKey:subActualLibraryListing];
						}
					}
				}
			} else {
				[subLibraryListing addObject: @"[empty]"];
			}
			
			// Only create folders if not searching the Library
			if (!filterResults)
				[libraryListingText setObject:subLibraryListing forKey:actualLibraryListing];
		} else {
			if (![[libraryListing objectAtIndex:index] isEqualToString: @"Thumbnails"]) {
				if (filterResults) {
					if ([self containsString:[librarySearchField stringValue] inString:actualLibraryListing])
						[libraryListingText setObject:[NSNull null] forKey:actualLibraryListing];
				} else {
					if (![[libraryListing objectAtIndex:index] isEqualToString:@".DS_Store"])
					[libraryListingText setObject:[NSNull null] forKey:actualLibraryListing];
				}
			}
		}
	}
}

- (BOOL)containsString:(NSString *)searchString inString:(NSString *)sourceString
{
    NSRange range = [sourceString rangeOfString:searchString options:NSCaseInsensitiveSearch];
    return (range.length > 0);
}

/* Required method for the NSOutlineViewDataSource protocol. */
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item==nil) {
		return [[libraryListingText allKeys] count];
	} else {
		return [[libraryListingText objectForKey:item] count];
	}
}

/* Required method for the NSOutlineViewDataSource protocol. */
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	if (item==nil) {
		return [[[libraryListingText allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:index];
	} else {
		return [[libraryListingText objectForKey:item] objectAtIndex:index];
	}
}

/* Required method for the NSOutlineViewDataSource protocol. */
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	return item;
}

/* Required method for the NSOutlineViewDataSource protocol. */
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if ([libraryListingText objectForKey:item]!=[NSNull null] && [[libraryListingText objectForKey:item] count]>=1) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	if (![outlineView isExpandable:item] && ![item isEqualToString: @"[empty]"]) {
		return YES;
	}
	
	return NO;
}

/*- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	if ([[notification object] selectedRow]>=0 && ![[notification object] isExpandable:[[notification object] itemAtRow:[[notification object] selectedRow]]]) {
		NSLog(@"%@", [[notification object] itemAtRow:[[notification object] selectedRow]]);
		[chooseButton setEnabled: YES];
	} else {
		[chooseButton setEnabled: NO];
	}
}*/

// Copies table row to pasteboard when it is determined a drag should begin
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
	// Make sure we can't drag an expandable item in the list
	if ([outlineView isExpandable:[outlineView itemAtRow:[outlineView rowForItem:[items objectAtIndex:0]]]])
		return NO;
	
	if ([outlineView itemAtRow:[outlineView rowForItem:[items objectAtIndex:0]]]==@"[empty]")
		return NO;
	
	NSLog(@"%@", items);
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items];

    [pboard declareTypes:[NSArray arrayWithObject:IWPlaylistDataType] owner:self];

    [pboard setData:data forType:IWPlaylistDataType];

    return YES;
}

// Modify the row height
- (float)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
	return 18;
}

// Display the white disclosure triangles
- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(NSButtonCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  [cell setImage:[NSImage imageNamed:@"Disclosure"]];
  [cell setAlternateImage:[NSImage imageNamed:@"Disclosure-P"]];
}

@end
