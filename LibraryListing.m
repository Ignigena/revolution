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
		
	libraryListing = [[NSMutableArray alloc] initWithArray: [manager contentsOfDirectoryAtPath:[library stringByExpandingTildeInPath] error:nil]];
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
		NSString *currentPath = [NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@", libraryListing[index]];
		
		NSString *actualLibraryListing = libraryListing[index];
			
		if ([manager fileExistsAtPath:[currentPath stringByExpandingTildeInPath] isDirectory:&isDir] && isDir && ![libraryListing[index] isEqualToString: @"Thumbnails"]) {
			NSMutableArray *subLibraryListing = [[NSMutableArray alloc] initWithArray: [manager contentsOfDirectoryAtPath:[currentPath stringByExpandingTildeInPath] error:nil]];
			
			if ([subLibraryListing count]!=0) {
				unsigned subIndex;
				
				for (subIndex = 0; subIndex <= [subLibraryListing count]-1; subIndex++) {
					if ([subLibraryListing[subIndex] isEqualToString:@".DS_Store"]) {
						[subLibraryListing removeObjectAtIndex:subIndex];
					} else {
						NSString *subActualLibraryListing = [[NSString alloc] initWithString: [NSString stringWithFormat: @"%@/%@", libraryListing[index], subLibraryListing[subIndex]]];
						subLibraryListing[subIndex] = subActualLibraryListing;
					
						if (filterResults) {
							if ([self containsString:[librarySearchField stringValue] inString:[NSString stringWithFormat: @"%@", [[NSArray alloc] initWithArray: [subLibraryListing[subIndex] componentsSeparatedByString:@"/"]][1]]])
								libraryListingText[subActualLibraryListing] = [NSNull null];
						}
					}
				}
			} else {
				[subLibraryListing addObject: @"[empty]"];
			}
			
			// Only create folders if not searching the Library
			if (!filterResults)
				libraryListingText[actualLibraryListing] = subLibraryListing;
		} else {
			if (![libraryListing[index] isEqualToString: @"Thumbnails"]) {
				if (filterResults) {
					if ([self containsString:[librarySearchField stringValue] inString:actualLibraryListing])
						libraryListingText[actualLibraryListing] = [NSNull null];
				} else {
					if (![libraryListing[index] isEqualToString:@".DS_Store"])
					libraryListingText[actualLibraryListing] = [NSNull null];
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
		return [libraryListingText[item] count];
	}
}

/* Required method for the NSOutlineViewDataSource protocol. */
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	if (item==nil) {
		return [[libraryListingText allKeys] sortedArrayUsingSelector:@selector(compare:)][index];
	} else {
		return libraryListingText[item][index];
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
	if (libraryListingText[item]!=[NSNull null] && [libraryListingText[item] count]>=1) {
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

// Copies table row to pasteboard when it is determined a drag should begin
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
	// Make sure we can't drag an expandable item in the list
	if ([outlineView isExpandable:[outlineView itemAtRow:[outlineView rowForItem:items[0]]]])
		return NO;
	
	if ([[outlineView itemAtRow:[outlineView rowForItem:items[0]]] isEqual:@"[empty]"])
		return NO;
	
	NSLog(@"%@", items);
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items];

    [pboard declareTypes:@[IWPlaylistDataType] owner:self];

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
