//
//  MyDocument.m
//  iWorship
//
//  Created by Albert Martin on 12/25/06.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.
//

#import "MyDocument.h"
#import "Controller.h"
#import "IWSplitView.h"
#import "MediaThumbnailBrowser.h"
#import "ToolbarMain.h"
#import "RSDarkScroller.h"
#import "IWTableCellText.h"
#import "LibraryListing.h"

#define IWPlaylistDataType @"IWPlaylistDataType"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
		worshipPlaylist = [NSMutableArray new];
		
		NSNotificationCenter *center = [[NSWorkspace sharedWorkspace] notificationCenter];
		[center addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:NULL];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	NSLog(@"creating new document ...");
	[[[NSApp delegate] splasher] orderOut: nil];
	
	RSDarkScroller *darkScrollerPlaylist = [[RSDarkScroller alloc] init];
	[playlistTable registerForDraggedTypes: @[IWPlaylistDataType]];
	[[playlistTable enclosingScrollView] setVerticalScroller: darkScrollerPlaylist];
	[playlistTable reloadData];
	
	RSDarkScroller *darkScrollerLibrary = [[RSDarkScroller alloc] init];
	[[libraryListing enclosingScrollView] setVerticalScroller: darkScrollerLibrary];
	[libraryListing reloadData];
	[[libraryListing enclosingScrollView] reflectScrolledClipView:[[libraryListing enclosingScrollView] contentView]];
	
	RSDarkScroller *darkScrollerSlides = [[RSDarkScroller alloc] init];
	[[docSlideViewer enclosingScrollView] setVerticalScroller: darkScrollerSlides];
	
	[super windowControllerDidLoadNib:aController];
	
	draggingTableRowStart = -1;
	
	[documentWindow makeFirstResponder: [docSlideViewer enclosingScrollView]];
	
	// Set up the split view that will open up the media panel
	// Fix the Interface Builder mess
	[rightSplitterView setFrame: NSMakeRect(250,20,893,671)];
	[[rightSplitterView subviews][0] addSubview: mediaBoxContent];
	//[worshipTitleBarContainer setOrigin: NSMakePoint(0, 452)
	[worshipTitleBarContainer setFrame: NSMakeRect(0, 452, [worshipTitleBarContainer bounds].size.width, [worshipTitleBarContainer bounds].size.height+1)];
	[docSlideScroller setFrame: NSMakeRect(0, [docSlideScroller frame].origin.y, [docSlideScroller frame].size.width, 413)];
	
	// 
	[thumbnailScroller setMovieListing: [[NSApp delegate] moviesMediaListing]];
	[thumbnailScroller setPictureListing: [[NSApp delegate] picturesMediaListing]];
	[thumbnailScroller setMediaListing: 0];
	
	[self performSelector: @selector(checkEmptyLibrary) withObject: nil afterDelay: 0.1];
	NSLog(@"done ...");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    if (![receiverList containsObject:aNetService]) {
        [self willChangeValueForKey:@"receiverList"];
        [receiverList addObject:aNetService];
        [self didChangeValueForKey:@"receiverList"];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    if ([receiverList containsObject:aNetService]) {
        [self willChangeValueForKey:@"receiverList"];
        [receiverList removeObject:aNetService];
        [self didChangeValueForKey:@"receiverList"];
    }
}

- (void)checkEmptyLibrary
{
	[(LibraryListing *)[libraryListing dataSource] loadReloadLibraryList];
}

- (void)windowWillClose:(NSNotification *)notification
{
	if ([[[NSDocumentController sharedDocumentController] documents] count] == 1)
		[[[NSApp delegate] splasher] makeKeyAndOrderFront: nil];
		
	[[NSApp delegate] presentationGoToBlack: nil];
}

- (void)splitView:(IWSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
	// Don't interfere with animation.
       if ([sender isSplitterAnimating]) {
               // I got infinite recursion when I used plain old -display.
               [sender setNeedsDisplay:YES];
               return;
       } else {
       // Do whatever else you want to do in this delegate.
	// how to resize a horizontal split view so that the left frame stays a constant size
    NSView *top = [sender subviews][0];      // get the two sub views
    NSView *bottom = [sender subviews][1];
    //float dividerThickness = [sender dividerThickness];         // and the divider thickness
    NSRect newFrame = [sender frame];                           // get the new size of the whole splitView
    NSRect topFrame = [top frame];                            // current size of the left subview
    NSRect bottomFrame = [bottom frame];                          // ...and the right
    if([top frame].size.height > 0)
		topFrame.size.height = 182;               // resize the height of the left
     // the rest of the width...
    bottomFrame.size.width = newFrame.size.width;
	bottomFrame.size.height = newFrame.size.height - topFrame.size.height;              // the whole height
	//bottomFrame.origin.y = 173;
    [top setFrame:topFrame];
    [bottom setFrame:bottomFrame];
	
	[sender adjustSubviews];
	}
}

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview
{
    if ([sender subviews][1] == subview)
       return NO;

    return YES;
}

- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
	return 182;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset
{
	return 182;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	NSMutableData *data;
	NSKeyedArchiver *archiver;

	data = [NSMutableData data];
	archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];

	// Archive the playlist file
	[archiver encodeObject:worshipPlaylist forKey:@"PlaylistSongFiles"];
	[archiver finishEncoding];

	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	NSKeyedUnarchiver *unarchiver;
	unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];

	// Unarchive the playlist file
	[worshipPlaylist setArray: [unarchiver decodeObjectForKey:@"PlaylistSongFiles"]];
	
	[unarchiver finishDecoding];
	
	NSUserDefaults  *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSString stringWithFormat: @"%@", [self fileURL]] forKey:@"LastOpenedDocument"];
	
	return YES;
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError
{
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];

    // Construct the print operation and setup Print panel
    NSPrintOperation *printJob = [NSPrintOperation printOperationWithView:docSlideViewer printInfo: printInfo];

    return printJob;
}

/* Required method for the NSTableDataSource protocol. */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [worshipPlaylist count];
}

/* Required method for the NSTableDataSource protocol. */
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex
{
    return worshipPlaylist[rowIndex];
}

// Copies table row to pasteboard when it is determined a drag should begin
- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	[docSlideViewer setEditor: NO];
	
	NSArray *songTitle = @[worshipPlaylist[[rowIndexes firstIndex]]];
	draggingTableRowStart = [rowIndexes firstIndex];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:songTitle];

    [pboard declareTypes:@[IWPlaylistDataType] owner:self];
    [pboard setData:data forType:IWPlaylistDataType];

    return YES;
}

// Determines where the drop should be
- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	NSDragOperation dragOp = NSDragOperationCopy;
    
    // if drag source is self, it's a move
    if ([info draggingSource] == aTableView) {
		dragOp =  NSDragOperationMove;
    }
    // we want to put the object at, not over,
    // the current row (contrast NSTableViewDropOn) 
    [aTableView setDropRow:row dropOperation:NSTableViewDropAbove];
	
    return dragOp;
}

// Drag is finished, update the table data
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:IWPlaylistDataType];
    NSArray* songTitle = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	
	if (row <= 0) row = 0;
	
	[worshipPlaylist insertObject:songTitle[[songTitle count]-1] atIndex:row];
	
	if (draggingTableRowStart!=-1 && draggingTableRowStart!=row) {
		if (draggingTableRowStart>=row) { draggingTableRowStart++; }
		else { row--; }
		[worshipPlaylist removeObjectAtIndex:draggingTableRowStart];
		draggingTableRowStart = -1;
	}
	
	[playlistTable reloadData];
	[playlistTable selectRow:row byExtendingSelection:NO];
	
	[self updateChangeCount: 0];
	
	return YES;
}

// Called whenever the table selection changes
- (void)tableViewSelectionDidChange:(NSNotification *) notification
{
	// Blank out the presenter screen
	[[[NSApp delegate] mainPresenterViewConnect] setPresentationText: @" "];
	
	if ([[docSlideViewer worshipSlides] count] > 0)
		[docSlideViewer saveAllSlidesForSong: previousSelectedPlaylist];
		
	// Just make sure that the user is clicking on an actual row
	if ([[notification object] selectedRow] < 0 || [[notification object] selectedRow] >= [worshipPlaylist count]) {
		NSLog(@"User is clicking on empty row");
		
		// Empty the slide viewer
		[docSlideViewer setWorshipSlides:nil notesSlides:nil mediaRefs:nil];
		
		// Reset the title bar
		[worshipTitleBar setStringValue: @""];
		
		// Hide the CCLI bar and button
		[worshipCCLIBar setHidden: YES];
		[worshipCCLIButton setHidden: YES];
		
		// Disable the toolbar buttons
		[toolbarNewSlide setEnabled: NO];
		[toolbarNextSlide setEnabled: NO];
		[toolbarPrevSlide setEnabled: NO];
		
		return;
	}
	
	previousSelectedPlaylist = worshipPlaylist[[[notification object] selectedRow]];
	
	// Use the name of the song as the location of the song file
	NSString *worshipSlideFile = [NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@", worshipPlaylist[[[notification object] selectedRow]]];
	
	//[self sendDataToAllNodes: [[worshipPlaylist objectAtIndex: [[notification object] selectedRow]] dataUsingEncoding: NSUTF8StringEncoding]];
	
	// Check to see if the song file exists or not
	if ([[NSFileManager defaultManager] fileExistsAtPath: [worshipSlideFile stringByExpandingTildeInPath]]) {
		NSLog(@"The song in the playlist has a valid file");
		[docSlideViewer setWorshipSlides: nil notesSlides: nil mediaRefs: nil];
	
		// The song file exists, process the file
		[docSlideViewer setEditor: NO];
		NSArray *songDisplaySplitter = [[NSArray alloc] initWithArray: [worshipPlaylist[[[notification object] selectedRow]] componentsSeparatedByString:@"/"]];
		NSString *songDisplayText = songDisplaySplitter[[songDisplaySplitter count]-1];
		[worshipTitleBar setStringValue: [songDisplayText componentsSeparatedByString:@"."][0]];
		
		NSDictionary *readSlideFileContents = [[NSDictionary alloc] initWithContentsOfFile: [worshipSlideFile stringByExpandingTildeInPath]];
		
		[docSlideViewer setWorshipSlides:readSlideFileContents[@"Slides"] notesSlides:readSlideFileContents[@"Flags"] mediaRefs:readSlideFileContents[@"Media"]];
		
		NSLog(@"READ: CCLI information");
		
		// Read CCLI information
		NSString *ccliOverviewText = @"";
			
		if (readSlideFileContents[@"CCLI Copyright Year"]) {
			[songCopyright setStringValue: readSlideFileContents[@"CCLI Copyright Year"]];
			ccliOverviewText = [ccliOverviewText stringByAppendingString: [NSString stringWithFormat:@"© %@", readSlideFileContents[@"CCLI Copyright Year"]]];
		} else {
			[songCopyright setStringValue: @""];
		}
		
		if (readSlideFileContents[@"CCLI Artist"]) {
			[songArtist setStringValue: readSlideFileContents[@"CCLI Artist"]];
			ccliOverviewText = [ccliOverviewText stringByAppendingString: [NSString stringWithFormat:@" %@", readSlideFileContents[@"CCLI Artist"]]];
		} else {
			[songArtist setStringValue: @""];
		}
			
		if (readSlideFileContents[@"CCLI Publisher"]) {
			[songPublisher setStringValue: readSlideFileContents[@"CCLI Publisher"]];
			ccliOverviewText = [ccliOverviewText stringByAppendingString: [NSString stringWithFormat:@", %@", readSlideFileContents[@"CCLI Publisher"]]];
		} else {
			[songPublisher setStringValue: @""];
		}
			
		if (readSlideFileContents[@"CCLI Song Number"]) {
			[songNumber setStringValue: readSlideFileContents[@"CCLI Song Number"]];
		} else {
			[songNumber setStringValue: @""];
		}
		
		[worshipCCLIBar setStringValue: ccliOverviewText];
		
		// Autosize and reposition the title bar and CCLI information
		[worshipTitleBar setFrame:NSMakeRect([worshipTitleBar frame].origin.x, [worshipTitleBar frame].origin.y, [[worshipTitleBar cell] cellSize].width, [worshipTitleBar frame].size.height)];
		[worshipCCLIBar setFrameOrigin:NSMakePoint([worshipTitleBar frame].origin.x+[[[NSNumber alloc] initWithFloat: [[worshipTitleBar cell] cellSize].width] intValue], [worshipCCLIBar frame].origin.y)];
		[worshipCCLIBar setFrame:NSMakeRect([worshipCCLIBar frame].origin.x, [worshipCCLIBar frame].origin.y, [[worshipCCLIBar cell] cellSize].width, [worshipCCLIBar frame].size.height)];
		[worshipCCLIButton setFrameOrigin:NSMakePoint([worshipCCLIBar frame].origin.x+[[[NSNumber alloc] initWithFloat: [worshipCCLIBar frame].size.width] intValue]+8, [worshipCCLIButton frame].origin.y)];
		
		[worshipCCLIBar setHidden: NO];
		[worshipCCLIButton setHidden: NO];
		
		[[worshipTitleBar superview] setNeedsDisplay: YES];
		
		// Set up the slide viewer pane
		[docSlideScroller setHasVerticalScroller: YES];
		[docSlideViewer setClickedSlideAtIndex: -1];
		
		// Enable the toolbar buttons
		[toolbarNewSlide setEnabled: YES];
		[toolbarNextSlide setEnabled: YES];
		[toolbarPrevSlide setEnabled: YES];
		
		// Reset the undo manager
		[[self undoManager] removeAllActions];
		
		if ([[NSString stringWithFormat:@"%@", readSlideFileContents[@"Presenter Layout"]] isEqualToString: @"0"]) {
			[formatterToolbar placeTop: self];
		} else if ([[NSString stringWithFormat:@"%@", readSlideFileContents[@"Presenter Layout"]] isEqualToString: @"2"]) {
			[formatterToolbar placeBottom: self];
		} else {
			[formatterToolbar placeCentre: self];
		}
		
		if ([[NSString stringWithFormat:@"%@", readSlideFileContents[@"Presenter Alignment"]] isEqualToString: @"0"]) {
			[formatterToolbar alignLeft: self];
		} else if ([[NSString stringWithFormat:@"%@", readSlideFileContents[@"Presenter Alignment"]] isEqualToString: @"1"]) {
			[formatterToolbar alignRight: self];
		} else {
			[formatterToolbar alignCentre: self];
		}
		
		// Try to read the transition speed
		// If not set, apply a default
		if (!readSlideFileContents[@"Transition Speed"]) {
			[formatterToolbar transitionSpeed: 1.0];
		} else {
			[formatterToolbar transitionSpeed: [readSlideFileContents[@"Transition Speed"] floatValue]];
		}
			
		if (!readSlideFileContents[@"Font Family"]) {
			[formatterToolbar fontFamily: @"default"];
		} else {
			[formatterToolbar fontFamily: [NSString stringWithFormat: @"%@", readSlideFileContents[@"Font Family"]]];
		}
		
		if (!readSlideFileContents[@"Font Size"]) {
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Text Size"]!=nil)
				[formatterToolbar setFormatFontSize: [[[NSUserDefaults standardUserDefaults] objectForKey:@"Text Size"] floatValue]];
			else
				[formatterToolbar setFormatFontSize: 72.0];
		} else {
			[formatterToolbar setFormatFontSize: [readSlideFileContents[@"Font Size"] floatValue]];
		}
			
		//[songDisplaySplitter release];
		//[readSlideFileContents release];
	} else {
		// The song file does not exist
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:[NSString stringWithFormat: @"\"%@\" Not Found", worshipPlaylist[[[notification object] selectedRow]]]];
		[alert setInformativeText:@"The song could not be found in the library.  This could be because the song has been deleted or renamed since you last loaded this playlist."];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert beginSheetModalForWindow:documentWindow modalDelegate:nil didEndSelector:nil contextInfo: nil];
	}
	
}

- (IBAction)removeFromPlaylist:(id)sender
{
	NSLog(@"Deleting %li", (long)[playlistTable selectedRow]);
	
	// Just make sure that the user is clicking on an actual row
	if ([playlistTable selectedRow] < 0 || [playlistTable selectedRow] >= [worshipPlaylist count])
		return;
	
	[worshipPlaylist removeObjectAtIndex:[playlistTable selectedRow]];
	[playlistTable reloadData];
	[self updateChangeCount: 0];
}

- (IBAction)editCCLIDetails:(id)sender
{
	if ([playlistTable selectedRow]>=0)
		[NSApp beginSheet:ccliEditor modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)applyCCLIDetails:(id)sender
{
	[NSApp endSheet:ccliEditor];
	[ccliEditor orderOut: self];
	
	[docSlideViewer saveAllSlidesForSong: nil];
	
	NSString *worshipSlideFile = [NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@.iwsf", worshipPlaylist[[playlistTable selectedRow]]];
	NSDictionary *readSlideFileContents = [[NSDictionary alloc] initWithContentsOfFile: [worshipSlideFile stringByExpandingTildeInPath]];
	
	NSString *ccliOverviewText = @"";
			
		if (readSlideFileContents[@"CCLI Copyright Year"]) {
			[songCopyright setStringValue: readSlideFileContents[@"CCLI Copyright Year"]];
			ccliOverviewText = [ccliOverviewText stringByAppendingString: [NSString stringWithFormat:@"© %@", readSlideFileContents[@"CCLI Copyright Year"]]];
		} else {
			[songCopyright setStringValue: @""];
		}
		
		if (readSlideFileContents[@"CCLI Artist"]) {
			[songArtist setStringValue: readSlideFileContents[@"CCLI Artist"]];
			ccliOverviewText = [ccliOverviewText stringByAppendingString: [NSString stringWithFormat:@" %@", readSlideFileContents[@"CCLI Artist"]]];
		} else {
			[songArtist setStringValue: @""];
		}
			
		if (readSlideFileContents[@"CCLI Publisher"]) {
			[songPublisher setStringValue: readSlideFileContents[@"CCLI Publisher"]];
			ccliOverviewText = [ccliOverviewText stringByAppendingString: [NSString stringWithFormat:@", %@", readSlideFileContents[@"CCLI Publisher"]]];
		} else {
			[songPublisher setStringValue: @""];
		}
			
		if (readSlideFileContents[@"CCLI Song Number"]) {
			[songNumber setStringValue: readSlideFileContents[@"CCLI Song Number"]];
		} else {
			[songNumber setStringValue: @""];
		}
		
		[worshipCCLIBar setStringValue: ccliOverviewText];
		
		// Autosize and reposition the title bar and CCLI information
		[worshipTitleBar setFrame:NSMakeRect([worshipTitleBar frame].origin.x, [worshipTitleBar frame].origin.y, [[worshipTitleBar cell] cellSize].width, [worshipTitleBar frame].size.height)];
		[worshipCCLIBar setFrameOrigin:NSMakePoint([worshipTitleBar frame].origin.x+[[[NSNumber alloc] initWithFloat: [[worshipTitleBar cell] cellSize].width] intValue], [worshipCCLIBar frame].origin.y)];
		[worshipCCLIBar setFrame:NSMakeRect([worshipCCLIBar frame].origin.x, [worshipCCLIBar frame].origin.y, [[worshipCCLIBar cell] cellSize].width, [worshipCCLIBar frame].size.height)];
		[worshipCCLIButton setFrameOrigin:NSMakePoint([worshipCCLIBar frame].origin.x+[[[NSNumber alloc] initWithFloat: [worshipCCLIBar frame].size.width] intValue]+8, [worshipCCLIButton frame].origin.y)];
}

- (IBAction)closePlaylistSheet:(id)sender
{ 
    [NSApp endSheet:addSongSheet];
	[addSongSheet orderOut: self];
}

- (IBAction)closeFolderSheet:(id)sender
{ 
    [NSApp endSheet:addFolderSheet];
	[addFolderSheet orderOut: self];
}

- (IBAction)addSongToPlaylist:(id)sender
{
	[worshipPlaylist addObject: [libraryListing itemAtRow:[libraryListing selectedRow]]];
	[playlistTable reloadData];
    [NSApp endSheet:addSongSheet];
	[self updateChangeCount: 0];
}

- (IBAction)toggleMediaMixer:(id)sender
{
	if ([rightSplitterView splitterPosition] < 660) {
		[rightSplitterView setSplitterPosition:0 animate:YES];
	} else {
		[rightSplitterView setSplitterPosition:182 animate:YES];
	}
}

- (IBAction)docWindowGoToBlack:(id)sender
{
	[[NSApp delegate] presentationGoToBlack: self];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (NSMutableArray *)worshipPlaylist
{
	return worshipPlaylist;
}

- (IWVideoPreview *)videoPreviewDisplay
{
	return videoPreviewDisplay;
}

- (QTMovieView *)videoPreviewController
{
	return videoPreviewController;
}

- (QTMovieView *)videoPreviewController2
{
	return videoPreviewController2;
}

- (NSView *)thumbnailScroller
{
	return thumbnailScroller;
}

- (NSView *)docSlideViewer
{
	return docSlideViewer;
}

- (NSButton *)loopingToggle
{
	return loopingToggle;
}

- (IWMediaBox *)mediaBox
{
	return mediaBoxContent;
}

- (NSTableView *)playlistTable
{
	return playlistTable;
}

- (NSTableView *)libraryListing
{
	return libraryListing;
}


- (NSString *)songDetailsWithKey:(NSString *)key
{
	NSDictionary *readSlideFileContents = [[NSDictionary alloc] initWithContentsOfFile: [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@.iwsf", worshipPlaylist[[playlistTable selectedRow]]] stringByExpandingTildeInPath]];
	
	return readSlideFileContents[key];
}

@end
