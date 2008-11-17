//
//  ToolbarMain.h
//  iWorship
//
//  Created by Albert Martin on 1/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IWSlideViewer.h"


@interface ToolbarMain : NSObject {
	IBOutlet id toolbarWindow;
	IBOutlet id slideViewer;
	IBOutlet id leftSplitSide;
	IBOutlet id fullScreenWindow;
	
	IBOutlet id stretcherView;
	
	NSMutableDictionary *toolbarItems;
}

//Required NSToolbar delegate methods
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;    
- (NSToolbarItem *)itemForItemIdentifier:(NSString *)itemIdentifier;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;

@end
