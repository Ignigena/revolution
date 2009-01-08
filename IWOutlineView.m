#import "IWOutlineView.h"
#import "IWTableCellText.h"
#import "MyDocument.h"
#import "LibraryListing.h"

@implementation IWOutlineView

- (void) awakeFromNib
{
	[self setRowHeight: 18];
	
	IWTableCellText *tableCellText = [[IWTableCellText alloc] init];
	[[[self tableColumns] objectAtIndex: 0] setDataCell: tableCellText];
	[tableCellText release];
}

- (id)_highlightColorForCell:(NSCell *)cell
{
	// Highlight selected row colour
	if ([[self window] firstResponder] == self) {
		return [NSColor colorWithDeviceRed:51/255.0 green:104/255.0 blue:192/255.0 alpha:1.0];
	}
	
	return [NSColor colorWithDeviceWhite:0.24 alpha:1.0];
}

- (void)keyDown:(NSEvent *)theEvent
{
	unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	
	// Delete the row ... ummm, duh!
	if (key == NSDeleteCharacter || key == NSDeleteFunctionKey) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle: @"OK"];
		[alert addButtonWithTitle: @"Cancel"];
		[alert setMessageText: @"Delete Song from Library"];
		[alert setInformativeText: @"The selected song will immediately be removed from your library and placed in the trash.  This can not be undone.  Are you sure you want to continue?"];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert beginSheetModalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo: nil];
	}
}

- (void)alertDidEnd:(NSAlert *)anAlert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode==1000) {
		NSLog(@"Delete it! %@", [self itemAtRow: [self selectedRow]]);
		NSString *worshipSongFile = [NSString stringWithFormat: @"%@", [self itemAtRow: [self selectedRow]]];
		NSString *worshipSongPath;
		NSArray *worshipSongFileSplit = [[NSArray alloc] initWithArray: [worshipSongFile componentsSeparatedByString:@"/"]];
		
		if ([worshipSongFileSplit count] > 1) {
			worshipSongFile = [worshipSongFileSplit objectAtIndex: 1];
			worshipSongPath = [NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@/", [worshipSongFileSplit objectAtIndex: 0]];
		} else {
			worshipSongFile = [worshipSongFileSplit objectAtIndex: 0];
			worshipSongPath = [NSString stringWithString: @"~/Library/Application Support/ProWorship/"];
		}
		
		[[NSWorkspace sharedWorkspace] performFileOperation: NSWorkspaceRecycleOperation source:[worshipSongPath stringByExpandingTildeInPath] destination:@"" files:[NSArray arrayWithObject: worshipSongFile] tag: 0];
		
		[[self delegate] loadReloadLibraryList];
		[self reloadData];
	}
		
	[anAlert autorelease];
}

@end
