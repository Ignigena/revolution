//
//  LibraryListing.h
//  iWorship
//
//  Created by Albert Martin on 1/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MAAttachedWindow.h"

@interface LibraryListing : NSObject {
	NSMutableArray *libraryListing;
	
	NSArray *subpath;
	NSMutableDictionary *libraryListingText;
	
	BOOL isSub;
	
	MAAttachedWindow *gettingStartedAddButton;
	
	IBOutlet id addButton;
	IBOutlet id addButtonHelpText;
	IBOutlet id chooseButton;
	IBOutlet id librarySearchField;
}

- (void)loadReloadLibraryList;
- (BOOL)containsString:(NSString *)searchString inString:(NSString *)sourceString;

@end
