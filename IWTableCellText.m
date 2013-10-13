//
//  IWTableCellText.m
//  iWorship
//
//  Created by Albert Martin on 1/16/07.
//  Copyright 2007 Renovatio. All rights reserved.
//
//  This class renders a custom table cell with an image as a selection highlight, taller than normal row height and centered text that draws a shadow on highlighting.
//

#import "IWTableCellText.h"


@implementation IWTableCellText

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSMutableDictionary *attrs;
	BOOL isDir;
	
	NSArray *songDisplaySplitter = [[NSArray alloc] initWithArray: [[self stringValue] componentsSeparatedByString:@"/"]];
	NSString *songDisplayText = [songDisplaySplitter objectAtIndex: [songDisplaySplitter count]-1];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@", [self stringValue]] stringByExpandingTildeInPath] isDirectory:&isDir] && isDir) {
		attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSFont boldSystemFontOfSize:11], NSFontAttributeName, nil];
		
		NSImage *smallIconFolder = [NSImage imageNamed:@"Icon-Folder"];
		[smallIconFolder setFlipped: YES];
			
		[smallIconFolder drawInRect: NSMakeRect(cellFrame.origin.x+4, cellFrame.origin.y+1, 16, 16) fromRect: NSMakeRect(0, 0, 16, 16) operation: NSCompositeSourceOver fraction: 1.0];
	} else {
		attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize:11], NSFontAttributeName, nil];
		
		if (![songDisplayText isEqualToString: @"[empty]"]) {
			NSImage *smallIconSongFile = [NSImage imageNamed:@"Icon-SongFile"];
			[smallIconSongFile setFlipped: YES];
			
			[smallIconSongFile drawInRect: NSMakeRect(cellFrame.origin.x+5, cellFrame.origin.y+1, 16, 16) fromRect: NSMakeRect(0, 0, 16, 16) operation: NSCompositeSourceOver fraction: 1.0];
		}
	}
	
	NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:[[songDisplayText componentsSeparatedByString:@"."] objectAtIndex: 0] attributes:attrs];

    [self setAttributedStringValue:attrStr];
	
	cellFrame.origin.x += 24;
	cellFrame.origin.y += 2;
	cellFrame.size.width -= 28;
	cellFrame.size.height -= 5;
	
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (NSLineBreakMode)lineBreakMode
{
	return NSLineBreakByTruncatingTail;
}

- (NSColor *)textColor
{
	return [NSColor colorWithCalibratedWhite:0.9 alpha:1.0];
}

@end
