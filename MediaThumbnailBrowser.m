#import "MediaThumbnailBrowser.h"
#import "NSImage+QuickLook.h"
#import "IWMediaTabButtonCell.h"
#import "Controller.h"

@implementation MediaThumbnailBrowser

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self registerForDraggedTypes:@[NSColorPboardType, NSFilenamesPboardType]];
		clickedSlideAtIndex = -1;
	}
	return self;
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)drawRect:(NSRect)rect
{
	if ([splitterView isSplitterAnimating])
		return;
		
	// If there are no thumbnails, there is no use in continuing
	int thumbCount = [mediaListing count];
	
	if (0 == thumbCount)
        return;
	
	// Make the slide grid calculations
	[self updateGrid];
	
	// Set how many slides to draw
	NSRange rangeToDraw = [self slideIndexRangeForRect:rect];
	unsigned index;
	unsigned lastIndex = rangeToDraw.location + rangeToDraw.length;
	
	// Start building the slides
	for (index = rangeToDraw.location; index <= lastIndex; index++) {
		NSRect gridRect = [self centerScanRect:[self gridRectForIndex:index]];
		NSRect thumbRect = [self rectCenteredInRect:gridRect withSize:NSMakeSize(70, 70)];
		thumbRect = [self centerScanRect:thumbRect];
		
		// Draw the thumbnail
		NSRect backgroundRect = NSMakeRect(thumbRect.origin.x, thumbRect.origin.y, 70, 70);
		NSString *thumbnailPath;
		NSArray *moviePathSplitter = [[NSArray alloc] initWithArray: [mediaListing[index] componentsSeparatedByString:@"/"]];
		NSArray *movieNameSplitter = [[NSArray alloc] initWithArray: [moviePathSplitter[[moviePathSplitter count]-1] componentsSeparatedByString:@"."]];
		
		if (mediaType==1) { thumbnailPath = [NSString stringWithFormat: @"~/Library/Application Support/ProWorship/Thumbnails/Pictures/%@.tiff", movieNameSplitter[0]]; }
		else { thumbnailPath = [NSString stringWithFormat: @"~/Library/Application Support/ProWorship/Thumbnails/Movies/%@.tiff", movieNameSplitter[0]]; }
		
		NSImage *mediaThumbnail = [[NSImage alloc] initWithContentsOfFile: [thumbnailPath stringByExpandingTildeInPath]];
		[mediaThumbnail setFlipped: YES];
		[mediaThumbnail drawInRect:[self rectCenteredInRect:backgroundRect withSize:NSMakeSize([mediaThumbnail size].width, [mediaThumbnail size].height)] fromRect: NSMakeRect(0.0, 0.0, [mediaThumbnail size].width, [mediaThumbnail size].height) operation:NSCompositeSourceOver fraction:1.0];
		
		if (clickedSlideAtIndex==index) {
			NSBezierPath *clickedSlideBorder = [NSBezierPath bezierPathWithRect:NSMakeRect(backgroundRect.origin.x+2, backgroundRect.origin.y+2, [mediaThumbnail size].width-3, [mediaThumbnail size].height-6)];
			[[NSColor redColor] set];
			[clickedSlideBorder setLineWidth: 2.0];
			[clickedSlideBorder stroke];
		}
	}
	
	//NSLog(@"%f", [[[self enclosingScrollView] verticalScroller] floatValue]);
	
	//[[NSColor colorWithDeviceWhite:0.0 alpha: 0.8] set];
	//[NSBezierPath fillRect: NSMakeRect(0, [[NSString stringWithFormat:@"%.0f", [[self enclosingScrollView] documentVisibleRect].size.height+(([self bounds].size.height*[[[self enclosingScrollView] verticalScroller] floatValue]) / 2)-25] floatValue], [self bounds].size.width, 25)];
}

- (void)updateGrid
{
	gridSize.width = 75;
	gridSize.height = 75;
	
	// Calculate the number of columns based on the current view width
	float viewWidth = [self frame].size.width - 6;
	columns = viewWidth / gridSize.width;
	
	// There has to be at least one column
	if (1 > columns)
		columns = 1;
	
	// Add any extra pixel space to the column width
	gridSize.width += (viewWidth - (columns * gridSize.width)) / columns;
	
	// Calculate the number of rows based on the slide count
	int thumbCount = [mediaListing count];
	rows = thumbCount / columns;
	
	// Any leftover slides get a new row for the scroll bar's sake
	if (0 < (thumbCount % columns))
        rows++;
	
	// Calculate how high the view needs to be to enclose all rows
	float viewHeight = (rows * gridSize.height)+6;
	
	// Generate a scroll bar as needed
	NSScrollView *scroll = [self enclosingScrollView];
	if ((nil != scroll) && (viewHeight < [[scroll contentView] frame].size.height))
        viewHeight = [[scroll contentView] frame].size.height;
	
	// Set the new frame size
	[self setFrameSize:NSMakeSize([[self enclosingScrollView] documentVisibleRect].size.width, viewHeight)];
	[self setFrameOrigin:NSMakePoint(0,0)];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	mouseDownPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	mouseCurrentPoint = mouseDownPoint;

	clickedIndex = [self slideIndexForPoint:mouseDownPoint];
	
	if (clickedIndex>=[mediaListing count])
		return;
	
	NSRect thumbRect = [self rectCenteredInRect:[self gridRectForIndex:clickedIndex] withSize:NSMakeSize(166,144)];
	thumbHit = NSPointInRect(mouseDownPoint, thumbRect);
	
	if (thumbHit) {
		clickedSlideAtIndex = clickedIndex;
		[self setNeedsDisplay: YES];
		
		//if (mediaType==1)
		//	[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] setUpdateTimeCode: NO];
		//else
		//	[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] setUpdateTimeCode: YES];
			
		[[NSApp delegate] presentJuice: [mediaListing[clickedIndex] stringByExpandingTildeInPath]];
		
		//[[[NSApp delegate] mainPresenterViewConnect] setVideoFile: [QTMovie movieWithFile:[[mediaListing objectAtIndex: clickedIndex] stringByExpandingTildeInPath] error:nil]];
	}
}

- (NSRect)gridRectForIndex:(unsigned)index
{
	unsigned row = index / columns;
	unsigned column = index % columns;
	float x = column * gridSize.width;
	float y = row * gridSize.height;
	
	return NSMakeRect(x+4, y+4, gridSize.width, gridSize.height);
}

- (NSRect)rectCenteredInRect:(NSRect)rect withSize:(NSSize)size
{
    float x = rect.origin.x + ((rect.size.width - size.width) / 2);
    float y = rect.origin.y + ((rect.size.height - size.height) / 2);
    
    return NSMakeRect(x, y, size.width, size.height);
}

- (unsigned)slideIndexForPoint:(NSPoint)point
{
	unsigned column = point.x / gridSize.width;
	unsigned row = point.y / gridSize.height;
	
	return ((row * columns) + column);
}

- (NSRange)slideIndexRangeForRect:(NSRect)rect
{
    unsigned start = [self slideIndexForPoint:rect.origin];
	unsigned finish = [self slideIndexForPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
	
    if (finish >= [mediaListing count])
        finish = [mediaListing count] - 1;
    
	return NSMakeRange(start, finish-start);
    
}

- (void)setMediaListing:(int)type
{
	mediaType = type;
	
	if (type==1) { mediaListing = [[NSMutableArray alloc] initWithArray: backgroundPictureListing copyItems: YES]; }
	else { mediaListing = [[NSMutableArray alloc] initWithArray: backgroundMovieListing copyItems: YES]; }
	
	// update internal grid size, adjust height based on the new grid size
	[self updateGrid];
	
	[self setNeedsDisplay: YES];
}

- (void)setMovieListing:(NSArray *)aMovieListing
{
	backgroundMovieListing = [[NSMutableArray alloc] initWithArray: aMovieListing copyItems: YES];
}

- (void)setPictureListing:(NSArray *)aPictureListing
{
	backgroundPictureListing = [[NSMutableArray alloc] initWithArray: aPictureListing copyItems: YES];
}

///////////////////////////
// Drag and Drop Support //
///////////////////////////

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
	if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
	}
	
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType]) {
        NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
		unsigned filesIndex;
		
		for (filesIndex = 0; filesIndex <= [files count]-1; filesIndex++) {
			NSLog(@"%@", files[filesIndex] );
			
			// Make sure it is of type "MOV" and a thumbnail is not already saved
			if ([[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"mov"] ||
				[[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"avi"] ||
				[[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"mpg"] ||
				[[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"mpeg"] ||
				[[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"mp4"] ||
				[[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"qtz"]) {
				//Copy to the Movies folder
				NSLog(@"Movie file");
				if ([[NSFileManager defaultManager] copyPath:files[filesIndex] toPath:[[NSString stringWithFormat: @"~/Movies/ProWorship/%@", [files[filesIndex] lastPathComponent]] stringByExpandingTildeInPath] handler:nil]) {
					[[NSApp delegate] runThumbnailSetup];
					[self setMovieListing: [[NSApp delegate] moviesMediaListing]];
					[self setPictureListing: [[NSApp delegate] picturesMediaListing]];
					[self setMediaListing:mediaType];
					[[self enclosingScrollView] reflectScrolledClipView:[[self enclosingScrollView] contentView]];
				}
			} else if([[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"tiff"] ||
				[[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"tif"] ||
				[[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"jpeg"] ||
				[[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"jpg"] ||
				[[[files[filesIndex] pathExtension] lowercaseString] isEqualToString: @"png"]) {
				//Copy to the Pictures folder
				NSLog(@"Picture file");
				if ([[NSFileManager defaultManager] copyPath:files[filesIndex] toPath:[[NSString stringWithFormat: @"~/Pictures/ProWorship/%@", [files[filesIndex] lastPathComponent]] stringByExpandingTildeInPath] handler:nil]) {
					[[NSApp delegate] runThumbnailSetup];
					[self setMovieListing: [[NSApp delegate] moviesMediaListing]];
					[self setPictureListing: [[NSApp delegate] picturesMediaListing]];
					[self setMediaListing:mediaType];
					[[self enclosingScrollView] reflectScrolledClipView:[[self enclosingScrollView] contentView]];
				}
			}
		}
    }
    return YES;
}

///////////////////////////

- (NSMutableArray *) mediaListing
{
    return mediaListing;
}

- (NSMutableArray *) backgroundPictureListing
{
    return backgroundPictureListing;
}

- (NSMutableArray *) backgroundMovieListing
{
    return backgroundMovieListing;
}

- (void)removeFocus:(id)sender
{
	clickedSlideAtIndex = -1;
	[self setNeedsDisplay: YES];
}

- (int)mediaType
{
	return mediaType;
}

- (int)clickedSlideAtIndex
{
	return clickedSlideAtIndex;
}

@end
