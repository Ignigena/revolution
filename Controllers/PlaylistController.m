//
//  PlaylistArrayController.m
//  Revolution
//
//  Created by Albert Martin on 10/13/13.
//
//

#import "MyDocument.h"
#import "Controller.h"
#import "Playlist.h"
#import "PlaylistController.h"
#import "Library.h"

#define PlaylistDataType @"RevolutionPlaylist"

@implementation PlaylistController

- (void) awakeFromNib
{
	[playlistTableView registerForDraggedTypes:[NSArray arrayWithObjects:PlaylistDataType, LibraryDataType, nil]];
}

// Called whenever the table selection changes
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    MyDocument *sharedDocument = [[NSDocumentController sharedDocumentController] currentDocument];
    int selectedRow = [[notification object] selectedRow];
    
    // Just make sure that the user is clicking on an actual row
    if (selectedRow < 0 || selectedRow >= [self.arrangedObjects count]) {
        [[sharedDocument slidesController] loadSongFromPlaylist: nil];
    } else {
        [[sharedDocument slidesController] loadSongFromPlaylist: [[self arrangedObjects] objectAtIndex: selectedRow]];
    }
}

- (BOOL)tableView:(NSTableView *)aTableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard*)pboard
{
    [pboard declareTypes:@[PlaylistDataType] owner:self];
    [pboard setPropertyList:rows forType:PlaylistDataType];
	
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op
{
    NSDragOperation dragOp = NSDragOperationMove;
	
    [aTableView setDropRow:row dropOperation:NSTableViewDropAbove];
	
    return dragOp;
}

- (BOOL)tableView:(NSTableView*)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)op
{
    if (row < 0) row = 0;
    
    if ([info draggingSource] == aTableView) {
		NSArray *rows = [[info draggingPasteboard] propertyListForType:PlaylistDataType];
		NSIndexSet *indexSet = [self indexSetFromRows:rows];
		NSInteger rowsAbove = 0;
		
		[self moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:row];
        rowsAbove = [self rowsAboveRow:row inIndexSet:indexSet];
		
		NSRange range = NSMakeRange(row - rowsAbove, [indexSet count]);
		indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
		[self setSelectionIndexes:indexSet];
		
		return YES;
    } else {
        NSArray *rows = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:LibraryDataType]];
        
        for (int i = 0; i <= [rows count]-1; i++) {
            LibraryItem *draggedItem = rows[i];
            Playlist *droppedItem = [[Playlist alloc] initWithTitle:[draggedItem relativePath] andType:nil];
            [self insertObject:droppedItem atArrangedObjectIndex:row];
        }
    }
	
    return NO;
}

-(void) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)indexSet toIndex:(NSUInteger)insertIndex
{
    NSArray	*objects = [self arrangedObjects];
	NSUInteger thisIndex = [indexSet lastIndex];
	
    NSInteger aboveInsertIndexCount = 0;
    id object;
    NSInteger removeIndex;
	
    while (NSNotFound != thisIndex) {
		if (thisIndex >= insertIndex) {
			removeIndex = thisIndex + aboveInsertIndexCount;
			aboveInsertIndexCount += 1;
		} else {
			removeIndex = thisIndex;
			insertIndex -= 1;
		}
		
		// Get the object we're moving
		object = [objects objectAtIndex:removeIndex];
        
		// In case nobody else is retaining the object, we need to keep it alive while we move it
		[self removeObjectAtArrangedObjectIndex:removeIndex];
		[self insertObject:object atArrangedObjectIndex:insertIndex];
		
		thisIndex = [indexSet indexLessThanIndex:thisIndex];
    }
}

- (NSIndexSet *)indexSetFromRows:(NSArray *)rows
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSEnumerator *rowEnumerator = [rows objectEnumerator];
    NSNumber *idx;
    while (idx = [rowEnumerator nextObject]) {
		[indexSet addIndex:[idx intValue]];
    }
    return indexSet;
}

- (NSUInteger)rowsAboveRow:(NSUInteger)row inIndexSet:(NSIndexSet *)indexSet
{
    NSUInteger currentIndex = [indexSet firstIndex];
    NSInteger i = 0;
    while (currentIndex != NSNotFound)
    {
		if (currentIndex < row) { i++; }
		currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
    }
    return i;
}

@end
