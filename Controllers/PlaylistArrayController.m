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
#import "PlaylistArrayController.h"

#define PlaylistDataType @"RevolutionPlaylist"

@implementation PlaylistArrayController

- (void) awakeFromNib
{
	[playlistTableView registerForDraggedTypes:[NSArray arrayWithObjects:PlaylistDataType, nil]];
}

// Called whenever the table selection changes
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    MyDocument *sharedDocument = [[NSDocumentController sharedDocumentController] currentDocument];
    
    // Just make sure that the user is clicking on an actual row
    if ([[notification object] selectedRow] < 0 ||
        [[notification object] selectedRow] >= [self.arrangedObjects count]) {
        [sharedDocument playlistSelectWithID: -1];
    } else {
        [sharedDocument playlistSelectWithID: [[notification object] selectedRow]];
    }	
}

- (BOOL)draggingEnabled
{
    return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard*)pboard
{
	if ([self draggingEnabled] == YES) {
		[pboard declareTypes:@[PlaylistDataType] owner:self];
		[pboard setPropertyList:rows forType:PlaylistDataType];
	}
	
    return [self draggingEnabled];
}

- (NSDragOperation)tableView:(NSTableView*)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op
{
    NSDragOperation dragOp = NSDragOperationNone;

    if ([info draggingSource] == aTableView) {
		dragOp =  NSDragOperationMove;
    }
	
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
