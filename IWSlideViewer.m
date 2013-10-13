#import "IWSlideViewer.h"
#import "Controller.h"
#import "CTGradient.h"
#import "MyDocument.h"

@implementation IWSlideViewer

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		clickedSlideAtIndex = -1;
		editSlideAtIndex = -1;
		drawDropperForIndex = -1;
		
		// Register the delete widget image
		deleteWidget = [NSImage imageNamed:@"DeleteWidget"];
		[deleteWidget setFlipped:YES];
		
		// Generate the slide backgrounds
		slideGradientNormal = [self generateSlideWithState: 0];
		slideGradientActive = [self generateSlideWithState: 1];
		slideGradientBlank = [self generateSlideWithState: 2];
		
		// Build the bottom rounded corners for the text box
		NSImage *slideEditorCornersBack = [[NSImage alloc] initWithSize:maskingRect.size];
		[slideEditorCornersBack lockFocus];
		[NSBezierPath fillRect:maskingRect]; 
		[slideEditorCornersBack unlockFocus];
		
		slideEditorCorners = [[NSImage alloc] initWithSize:maskingRect.size];
		[slideEditorCorners lockFocus];
		[[NSColor blackColor] set];
		[bgPath fill];
		[slideEditorCornersBack compositeToPoint: NSMakePoint(0,0) operation: NSCompositeSourceOut];
		[slideEditorCorners unlockFocus];
		
		// Build the background image for slides being edited
		/*slideGradientEditor = [[NSImage alloc] initWithSize:maskingRect.size];
		[slideGradientEditor lockFocus];
		[[NSColor whiteColor] set];
		[bgPath fill];
		[slideTopperImage compositeToPoint:NSMakePoint(0,0) operation: NSCompositeSourceIn];
		[slideGradientEditor unlockFocus];
		
		[backgroundGradientImage release];
		[backgroundGradientImageActive release];*/
		
		// Images required for slide bevel effect
		slideSelectedCUL = [NSImage imageNamed:@"SlideSelected-CUL"];
		[slideSelectedCUL setFlipped:YES];
		slideSelectedCUR = [NSImage imageNamed:@"SlideSelected-CUR"];
		[slideSelectedCUR setFlipped:YES];
		slideSelectedCLL = [NSImage imageNamed:@"SlideSelected-CLL"];
		[slideSelectedCLL setFlipped:YES];
		slideSelectedCLR = [NSImage imageNamed:@"SlideSelected-CLR"];
		[slideSelectedCLR setFlipped:YES];
		
		slideSelectedST = [NSImage imageNamed:@"SlideSelected-ST"];
		[slideSelectedST setFlipped:YES];
		slideSelectedSB = [NSImage imageNamed:@"SlideSelected-SB"];
		[slideSelectedSB setFlipped:YES];
		slideSelectedSL = [NSImage imageNamed:@"SlideSelected-SL"];
		[slideSelectedSL setFlipped:YES];
		slideSelectedSR = [NSImage imageNamed:@"SlideSelected-SR"];
		[slideSelectedSR setFlipped:YES];
			
		// Text styles for the slides
		worshipSlideTextPara = [[NSMutableParagraphStyle alloc] init];
			[worshipSlideTextPara setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
			[worshipSlideTextPara setAlignment:NSCenterTextAlignment];
		
		// Get the preview font size from the preferences
		worshipSlideFontSize = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Preview Font Size"] intValue];
		
		if (!worshipSlideFontSize) {
			[[NSUserDefaults standardUserDefaults] setObject:@"12" forKey:@"Preview Font Size"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			worshipSlideFontSize = 12;
		}
		
		worshipSlideTextAttrs = [[NSMutableDictionary alloc] initWithCapacity: 3];
		worshipSlideTextAttrs[NSFontAttributeName] = [NSFont boldSystemFontOfSize:worshipSlideFontSize];
		worshipSlideTextAttrs[NSParagraphStyleAttributeName] = worshipSlideTextPara;
		
		inslideTextEditor = [IWSlideEditor alloc];
		inslideTextScroller = [NSScrollView alloc];
		scrollerOverlay = [NSWindow alloc];
		
		// Text styles for the flag widgets
		flagTextAttrs = [[NSMutableDictionary alloc] initWithCapacity: 3];
		flagTextAttrs[NSFontAttributeName] = [NSFont systemFontOfSize:11];
		flagTextAttrs[NSForegroundColorAttributeName] = [NSColor whiteColor];
		
		// Shadow style for selected slide text
		textShadow = [NSShadow alloc];
		[textShadow setShadowOffset: NSMakeSize(0, 1)];
		[textShadow setShadowColor: [NSColor blackColor]];
		[textShadow setShadowBlurRadius: 1.0];
		
		// Set up the flag selection popup menu
		flagMenu = [[NSMenu alloc] initWithTitle:@"Flag Choices"];
		[flagMenu addItemWithTitle:@"None" action:@selector(setFlag:) keyEquivalent:@""];
		[flagMenu addItem:[NSMenuItem separatorItem]];
		[flagMenu addItemWithTitle:@"Skip" action:@selector(setFlag:) keyEquivalent:@""];
		[flagMenu addItemWithTitle:@"Pause" action:@selector(setFlag:) keyEquivalent:@""];
		[flagMenu addItemWithTitle:@"Intro" action:@selector(setFlag:) keyEquivalent:@""];
		[flagMenu addItemWithTitle:@"Verse" action:@selector(setFlag:) keyEquivalent:@""];
		[flagMenu addItemWithTitle:@"Chorus" action:@selector(setFlag:) keyEquivalent:@""];
		[flagMenu addItemWithTitle:@"Solo" action:@selector(setFlag:) keyEquivalent:@""];
		[flagMenu addItemWithTitle:@"Bridge" action:@selector(setFlag:) keyEquivalent:@""];
		[flagMenu addItemWithTitle:@"Refrain" action:@selector(setFlag:) keyEquivalent:@""];
		[flagMenu addItem:[NSMenuItem separatorItem]];
		[flagMenu addItemWithTitle:@"Custom..." action:@selector(customFlag:) keyEquivalent:@""];
		
		// Display the presenter window
		[presentationWindow orderFront:nil];
	}
	return self;
}

- (NSImage *)generateSlideWithState:(int)state
{
	///////////////////////////////////////////////
	// Setup the size information for the slides //
	maskingRect = NSMakeRect(0, 0, 292, 276);
	bgPath = [NSBezierPath bezierPath];
	float radius = 18;
	radius = MIN(radius, 0.5f * MIN(NSWidth(maskingRect), NSHeight(maskingRect)));
	NSRect roundRect = NSInsetRect(maskingRect, radius, radius);
	///////////////////////////////////////////////
	
	/////////////////////////////////////
	// Setup the gradients for drawing //
	NSGradient *slideNormalGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.86 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.58 alpha:1.0]];
	NSGradient *slideActiveGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.45 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.21 alpha:1.0]];
	NSGradient *slideHeaderGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.42] endingColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.0]];
	/////////////////////////////////////
	
	///////////////////////////////////////////////////////////////////
	// Draw the curved outline of the slide to use as a drawing mask //
	[bgPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(roundRect)+16, NSMinY(roundRect)+16) radius:radius startAngle:180.0 endAngle:270.0];
	[bgPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(roundRect)-16, NSMinY(roundRect)+16) radius:radius startAngle:270.0 endAngle:360.0];
	[bgPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(roundRect)-16, NSMaxY(roundRect)-16) radius:radius startAngle:  0.0 endAngle: 90.0];
	[bgPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(roundRect)+16, NSMaxY(roundRect)-16) radius:radius startAngle: 90.0 endAngle:180.0];
	[bgPath closePath];
	///////////////////////////////////////////////////////////////////
	
	////////////////////////////////////////////
	// Draw the basic background of the slide //
	NSImage *backgroundGradientImage = [[NSImage alloc] initWithSize:maskingRect.size];
	[backgroundGradientImage lockFocus];
	
	// Determine the state and draw the appropriate gradient
	if (state==0) { [slideNormalGradient drawInRect:maskingRect angle:90.0f]; }
	else if (state==1) { [slideActiveGradient drawInRect:maskingRect angle:90.0f]; }
	
	// Create the glossy slide header area
	[[NSColor blackColor] set];
	[[NSBezierPath bezierPathWithRect:NSMakeRect(14, 14, 276, 36)] fill];
	
	[slideHeaderGradient drawInRect:NSMakeRect(14, 14, 276, 40) angle:90.0f];
	[[NSColor colorWithDeviceWhite:1.0 alpha:0.15] set];
	[[NSBezierPath bezierPathWithRect:NSMakeRect(14, 14, 276, 16)] fill];
	
	[backgroundGradientImage unlockFocus];
	////////////////////////////////////////////
	
	///////////////////////////////////////////////////////////////
	// Trim everything using the drawing mask we created earlier //
	NSImage *backgroundMask = [[NSImage alloc] initWithSize:maskingRect.size];
	[backgroundMask lockFocus];
	[[NSColor blackColor] set];
	[bgPath fill];
	[backgroundGradientImage compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceIn];
	[backgroundMask unlockFocus];
	///////////////////////////////////////////////////////////////
	
	///////////////////////////////////////////////////////////////////////////////////////
	// Composite together the slide background along with the bevel and selection border //
	NSImage *slideBevel = [NSImage imageNamed:@"SlideBevel"];
	[slideBevel setFlipped:YES];
	NSImage *slideSelection = [NSImage imageNamed:@"SlideSelection"];
	[slideSelection setFlipped:YES];
	
	NSImage *slideImage = [[NSImage alloc] initWithSize:maskingRect.size];
	[slideImage lockFocus];
	[backgroundMask compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
	[slideBevel compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
	//if (state==1) { [slideSelection compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver]; }
	[slideImage unlockFocus];
	///////////////////////////////////////////////////////////////////////////////////////
	
	return slideImage;
}

// Make slides read top to bottom
- (BOOL)isFlipped
{
	return YES;
}

// Calculate the height of a string for positioning
float heightForStringDrawing(NSString *myString, NSFont *desiredFont, float desiredWidth)
{
	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:myString];
	NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize: NSMakeSize(desiredWidth, 1e7)];
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

	[textStorage addAttribute: NSFontAttributeName value: desiredFont range: NSMakeRange(0, [textStorage length])];
	[textContainer setLineFragmentPadding: 0.0]; // padding usually is not appropriate for string drawing

	[layoutManager addTextContainer: textContainer];
	[textStorage addLayoutManager: layoutManager];

	(void)[layoutManager glyphRangeForTextContainer: textContainer]; // force layout
	return [layoutManager usedRectForTextContainer: textContainer].size.height;
}

- (void)drawRect:(NSRect)rect
{
	[libraryTable reloadData];
	
	if ( [NSGraphicsContext currentContextDrawingToScreen] ) {
		if ([inslideTextScroller superview]==self && editSlideAtIndex==-1) {
			[inslideTextEditor removeFromSuperview];
			[inslideTextScroller removeFromSuperview];
		}
		
		// Fill the background with a solid colour
		[[NSColor colorWithDeviceWhite:0.15 alpha:1.0] set];
		[NSBezierPath fillRect:rect];
		
		// Turn anti-aliasing off to draw 1px lines for shadow
		[[NSGraphicsContext currentContext] setShouldAntialias: NO];
		
		// Draw the shadow consisting of three 1px lines
		[[NSColor colorWithDeviceWhite:0.11 alpha:1.0] set];
		NSBezierPath *shadowLeft1 = [NSBezierPath bezierPath];
		[shadowLeft1 moveToPoint:NSMakePoint(1, 0)];
		[shadowLeft1 lineToPoint:NSMakePoint(1, [self bounds].size.height)];
		[shadowLeft1 setLineWidth:0.5];
		[shadowLeft1 stroke];
		[[NSColor colorWithDeviceWhite:0.13 alpha:1.0] set];
		NSBezierPath *shadowLeft2 = [NSBezierPath bezierPath];
		[shadowLeft2 moveToPoint:NSMakePoint(2, 0)];
		[shadowLeft2 lineToPoint:NSMakePoint(2, [self bounds].size.height)];
		[shadowLeft2 setLineWidth:0.5];
		[shadowLeft2 stroke];
		[[NSColor blackColor] set];
		NSBezierPath *shadowLeft0 = [NSBezierPath bezierPath];
		[shadowLeft0 moveToPoint:NSMakePoint(0, 0)];
		[shadowLeft0 lineToPoint:NSMakePoint(0, [self bounds].size.height)];
		[shadowLeft0 setLineWidth:0.5];
		[shadowLeft0 stroke];
		
		// Turn anti-aliasing back on for the rest of the drawing
		[[NSGraphicsContext currentContext] setShouldAntialias: YES];
		
		// If there are no slides, there is no use in continuing
		if (0 == [worshipSlides count])
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
			NSRect slideRect = [self rectCenteredInRect:gridRect withSize:NSMakeSize(160,140)];
			slideRect = [self centerScanRect:slideRect];
			NSRect backgroundRect = NSMakeRect(slideRect.origin.x-10, slideRect.origin.y-10, slideRect.size.width+20, slideRect.size.height+26);
			
			float slideOpacity;
			
			if ([slidesNotes[index] isEqualToString: @"Skip"])
				slideOpacity = 0.5;
			else
				slideOpacity = 1.0;
			
			unsigned worshipTextViewHeight = heightForStringDrawing(worshipSlides[index], [NSFont boldSystemFontOfSize:worshipSlideFontSize], 155.0)+5.0;
			if (worshipTextViewHeight >= slideRect.size.height-20)
				worshipTextViewHeight = slideRect.size.height-20;
			
			// Draw the backgrounds depending on whether the slide is selected or not
			if (clickedSlideAtIndex==index && [slidesNotes count]!=index && editSlideAtIndex!=index && [mediaReferences[index] isEqualToString: @""]) {
				[slideGradientActive drawInRect:NSMakeRect(backgroundRect.origin.x, backgroundRect.origin.y, 180, 170) fromRect:NSMakeRect(0, 0, 292, 276) operation:NSCompositeSourceOver fraction: slideOpacity];
			} else if (editSlideAtIndex!=index && [mediaReferences[index] isEqualToString: @""]) {
				[slideGradientNormal drawInRect:NSMakeRect(backgroundRect.origin.x, backgroundRect.origin.y, 180, 170) fromRect:NSMakeRect(0, 0, 292, 276) operation:NSCompositeSourceOver fraction: slideOpacity];
			} else if (editSlideAtIndex==index) {
				NSImage *mediaMask = [[NSImage alloc] initWithSize: NSMakeSize(292, 276)];
				[mediaMask lockFocus];
				[[NSColor whiteColor] set];
				[bgPath fill];
				[mediaMask unlockFocus];
				
				[mediaMask drawInRect:NSMakeRect(backgroundRect.origin.x, backgroundRect.origin.y, 180, 170) fromRect:NSMakeRect(0, 0, 292, 276) operation:NSCompositeSourceOver fraction: slideOpacity];
				[slideGradientBlank drawInRect:NSMakeRect(backgroundRect.origin.x, backgroundRect.origin.y, 180, 170) fromRect:NSMakeRect(0, 0, 292, 276) operation:NSCompositeSourceOver fraction: slideOpacity];
			} else {
				NSArray *previewPathSplitter = [[NSArray alloc] initWithArray: [mediaReferences[index] componentsSeparatedByString:@"/"]];
				NSArray *movieNameSplitter = [[NSArray alloc] initWithArray: [previewPathSplitter[[previewPathSplitter count]-1] componentsSeparatedByString:@"."]];
				NSImage *mediaFrame = [[NSImage alloc] initWithContentsOfFile: [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/Thumbnails/%@-PREVIEW.tiff", movieNameSplitter[0]] stringByExpandingTildeInPath]];
				NSImage *mediaMask = [[NSImage alloc] initWithSize: NSMakeSize(292, 276)];
				[mediaFrame setFlipped:YES];
				[mediaMask lockFocus];
				[[NSColor blackColor] set];
				[bgPath fill];
				[mediaFrame drawInRect:NSMakeRect(14,41,264,235) fromRect:NSMakeRect(0,0,[mediaFrame size].width,[mediaFrame size].height) operation:NSCompositeSourceIn fraction:1.0];
				
				[[NSGraphicsContext currentContext] setShouldAntialias: NO];
				[[NSColor colorWithDeviceWhite:1.0 alpha:0.1] set];
				NSBezierPath *titleBarShadowReflection = [NSBezierPath bezierPath];
				[titleBarShadowReflection moveToPoint:NSMakePoint(14, 55)];
				[titleBarShadowReflection lineToPoint:NSMakePoint(276, 55)];
				[titleBarShadowReflection setLineWidth:0.5];
				[titleBarShadowReflection stroke];
				[[NSGraphicsContext currentContext] setShouldAntialias: YES];
				
				[[NSColor colorWithDeviceWhite:0.0 alpha:0.7] set];
				[[NSBezierPath bezierPathWithRect: [self rectCenteredInRect:NSMakeRect(14,41,264,235) withSize:NSMakeSize(264, worshipTextViewHeight+10)]] fill];
				
				[mediaMask unlockFocus];
				
				[mediaMask drawInRect:NSMakeRect(backgroundRect.origin.x, backgroundRect.origin.y, 180, 170) fromRect:NSMakeRect(0, 0, [mediaMask size].width, [mediaMask size].height) operation:NSCompositeSourceOver fraction: slideOpacity];
				[slideGradientBlank drawInRect:NSMakeRect(backgroundRect.origin.x, backgroundRect.origin.y, 180, 170) fromRect:NSMakeRect(0, 0, 292, 276) operation:NSCompositeSourceOver fraction: slideOpacity];
			}
   			
			if (clickedSlideAtIndex==index && [slidesNotes count]!=index && editSlideAtIndex!=index) {
				// Draw the slide bevel and border
				[slideSelectedCUL drawInRect: NSMakeRect(backgroundRect.origin.x+6, backgroundRect.origin.y+6, 13, 13) fromRect: NSMakeRect(0, 0, 13, 13) operation: NSCompositeSourceOver fraction: slideOpacity];
				[slideSelectedCUR drawInRect: NSMakeRect(backgroundRect.origin.x+backgroundRect.size.width-19, backgroundRect.origin.y+6, 13, 13) fromRect: NSMakeRect(0, 0, 13, 13) operation: NSCompositeSourceOver fraction: slideOpacity];
				[slideSelectedCLL drawInRect: NSMakeRect(backgroundRect.origin.x+6, backgroundRect.origin.y+backgroundRect.size.height-18, 13, 13) fromRect: NSMakeRect(0, 0, 13, 13) operation: NSCompositeSourceOver fraction: slideOpacity];
				[slideSelectedCLR drawInRect: NSMakeRect(backgroundRect.origin.x+backgroundRect.size.width-19, backgroundRect.origin.y+backgroundRect.size.height-18, 13, 13) fromRect: NSMakeRect(0, 0, 13, 13) operation: NSCompositeSourceOver fraction: slideOpacity];
				[slideSelectedST drawInRect: NSMakeRect(backgroundRect.origin.x+19, backgroundRect.origin.y+6, backgroundRect.size.width-38, 13) fromRect: NSMakeRect(0, 0, 13, 13) operation: NSCompositeSourceOver fraction: slideOpacity];
				[slideSelectedSB drawInRect: NSMakeRect(backgroundRect.origin.x+19, backgroundRect.origin.y+backgroundRect.size.height-18, backgroundRect.size.width-38, 13) fromRect: NSMakeRect(0, 0, 13, 13) operation: NSCompositeSourceOver fraction: slideOpacity];
				[slideSelectedSL drawInRect: NSMakeRect(backgroundRect.origin.x+6, backgroundRect.origin.y+19, 13, backgroundRect.size.height-36) fromRect: NSMakeRect(0, 0, 13, 140) operation: NSCompositeSourceOver fraction: slideOpacity];
				[slideSelectedSR drawInRect: NSMakeRect(backgroundRect.origin.x+backgroundRect.size.width-19, backgroundRect.origin.y+19, 13, backgroundRect.size.height-36) fromRect: NSMakeRect(0, 0, 13, 140) operation: NSCompositeSourceOver fraction: slideOpacity];
			}
			
			if (drawDropperForIndex==index) {
				[[NSColor colorWithDeviceWhite:0.8 alpha:1.0] set];
				[NSBezierPath fillRect:NSMakeRect(gridRect.origin.x+(gridRect.size.width-2), gridRect.origin.y+11, 2, 144)];
			}
			
			if (editSlideAtIndex==-1 && [inslideTextScroller superview]==self) {
				[inslideTextScroller removeFromSuperview];
			}
			
			// Draw the in-slide editor if a slide is double-clicked
			if (editSlideAtIndex==index) {
				[worshipSlideTextAttrs setValue: [NSColor blackColor] forKey: NSForegroundColorAttributeName];
				[worshipSlideTextAttrs setValue: nil forKey: NSShadowAttributeName];
			
				// If the editor is already being displayed, update to the new coordinates
				if ([inslideTextScroller superview]==self) {
					[inslideTextScroller setFrameOrigin:NSMakePoint(slideRect.origin.x-2, slideRect.origin.y+18)];
				} else {
					[inslideTextScroller initWithFrame:NSMakeRect(slideRect.origin.x+1, slideRect.origin.y+21, slideRect.size.width-2, slideRect.size.height-20)];
					[inslideTextScroller setHasHorizontalScroller:NO];
					[inslideTextScroller setHasVerticalScroller:YES];
					[[inslideTextScroller verticalScroller] setControlSize: NSSmallControlSize];
					[[inslideTextScroller verticalScroller] setControlTint: NSGraphiteControlTint];
				
					[inslideTextEditor initWithFrame: NSMakeRect(0, 0, [inslideTextScroller contentSize].width-12, [inslideTextScroller contentSize].height)];
					[inslideTextEditor setContinuousSpellCheckingEnabled: YES];
					[inslideTextEditor setTypingAttributes: worshipSlideTextAttrs];
					[inslideTextEditor setRichText: NO];
				
					[inslideTextScroller setDocumentView:inslideTextEditor];
			
					[inslideTextEditor setString: worshipSlides[clickedSlideAtIndex]];
	
					[self addSubview: inslideTextScroller];
				
					[[self window] makeFirstResponder: inslideTextScroller];
				}
			} else {				
				// Draw the slide text
				if (clickedSlideAtIndex==index || ![mediaReferences[index] isEqualToString: @""]) {
					[worshipSlideTextAttrs setValue: [NSColor colorWithCalibratedWhite:1.0 alpha:slideOpacity] forKey: NSForegroundColorAttributeName];
					[worshipSlideTextAttrs setValue: textShadow forKey: NSShadowAttributeName];
				} else {
					[worshipSlideTextAttrs setValue: [NSColor colorWithCalibratedWhite:0.0 alpha:slideOpacity] forKey: NSForegroundColorAttributeName];
					[worshipSlideTextAttrs setValue: nil forKey: NSShadowAttributeName];
				}
			
				NSRect worshipTextView = [self rectCenteredInRect:NSMakeRect(slideRect.origin.x+1, slideRect.origin.y+21, slideRect.size.width-2, slideRect.size.height-10) withSize:NSMakeSize(slideRect.size.width-2, worshipTextViewHeight)];
				//NSRect worshipTextView = [self rectCenteredInRect:NSMakeRect(slideRect.origin.x, slideRect.origin.y+20, slideRect.size.width, slideRect.size.height-10) withSize:NSMakeSize(155, worshipTextViewHeight)];
			
				[worshipSlides[index] drawInRect:worshipTextView withAttributes: worshipSlideTextAttrs];
			}
		
			// Draw delete widget if the slide is being edited
			if (editSlideAtIndex==index)
				[deleteWidget drawInRect: NSMakeRect(slideRect.origin.x-17, slideRect.origin.y-16, 30, 30) fromRect: NSMakeRect(0, 0, 30, 30) operation: NSCompositeSourceOver fraction: 1.0];
		
			// Draw the flag text in the upper part of the slide
			if ([slidesNotes count] != 0 && [slidesNotes count] != index && ![slidesNotes[index] isEqualToString: @""])
				[slidesNotes[index] drawInRect:NSMakeRect(slideRect.origin.x+10, slideRect.origin.y+2, 135, 15) withAttributes: flagTextAttrs];
		}
		
		/*if (drawQuickCue==YES) {
			NSRect cueFrameRect = NSMakeRect(0, ([[self superview] frame].size.height/2)-73, [self frame].size.width, 73);
		
			[[NSColor colorWithDeviceWhite:0.58 alpha:0.8] set];
			[NSBezierPath fillRect: cueFrameRect];
			
			NSButton *closeQuickView = [[NSButton alloc] initWithFrame: NSMakeRect(cueFrameRect.origin.x+20, cueFrameRect.origin.y+20, 31, 33)];
			[closeQuickView setImage: [NSImage imageNamed:@"QuickCue-Close"]];
			[closeQuickView setBordered: NO];
			[self addSubview: closeQuickView];
		}*/
	} else {
		NSPrintInfo *info = [NSPrintInfo sharedPrintInfo];
		NSRect pb = [info imageablePageBounds];
		
		unsigned printSlideHeight = heightForStringDrawing(worshipSlides[1], [NSFont boldSystemFontOfSize:13], pb.size.width);
		NSRect printSlideRect = NSMakeRect(pb.origin.x, pb.origin.y, pb.size.width, printSlideHeight);
		
		NSString *printSlideText = [[NSString alloc] initWithString: worshipSlides[1]];
		[printSlideText drawInRect:printSlideRect withAttributes: worshipSlideTextAttrs];
		
		NSLog(@"We're printing ... woohoo!");
	}
}

- (BOOL) knowsPageRange: (NSRangePointer) range
{
	float pageCount = [worshipSlides count] / 15;
	pageCount = ceilf(pageCount);
	if (pageCount <= 0) { pageCount = 1; }
	
	NSLog(@"%f", pageCount);
	
    range->location = 1;
    range->length = pageCount;

    return YES;
}

- (void)updateGrid
{
	gridSize.width = 186;
	gridSize.height = 174;
	
	// Calculate the number of columns based on the current view width
	float viewWidth = [self frame].size.width;
	columns = viewWidth / gridSize.width;
	
	// There has to be at least one column
	if (1 > columns)
		columns = 1;
	
	// Add any extra pixel space to the column width
	gridSize.width += (viewWidth - (columns * gridSize.width)) / columns;
	
	// Calculate the number of rows based on the slide count
	int slideCount = [worshipSlides count];
	rows = slideCount / columns;
	
	// Any leftover slides get a new row for the scroll bar's sake
	if (0 < (slideCount % columns))
        rows++;
	
	// Calculate how high the view needs to be to enclose all rows
	float viewHeight = (rows * gridSize.height) + 20;
	
	// Generate a scroll bar as needed
	NSScrollView *scroll = [self enclosingScrollView];
	if ((nil != scroll) && (viewHeight < [[scroll contentView] frame].size.height))
        viewHeight = [[scroll contentView] frame].size.height;
	
	// Set the new frame size
	[self setFrameSize:NSMakeSize(viewWidth, viewHeight)];
}

- (void) mouseDown:(NSEvent *)theEvent
{
	mouseDown = YES;
	goAheadAndDrag = NO;
	iDidADrag = NO;
	mouseDownPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	mouseCurrentPoint = mouseDownPoint;

	clickedIndex = [self slideIndexForPoint:mouseDownPoint];
	
	NSLog(@"%i", clickedIndex);
	NSLog(@"%lu", (unsigned long)[worshipSlides count]);
	
	if (clickedIndex>=[worshipSlides count]) {
		if (editSlideAtIndex != -1) {
			worshipSlides[editSlideAtIndex] = [inslideTextEditor string];
			editSlideAtIndex = -1;
			[self saveAllSlidesForSong: nil];
			
			[self setNeedsDisplay: YES];
		}
		
		clickedSlideAtIndex = -1;
		[self setNeedsDisplay: YES];
		[self presentSlideAtIndex: -1];
		
		return;
	}
	
	NSRect					slideRect = [self rectCenteredInRect:[self gridRectForIndex:clickedIndex] withSize:NSMakeSize(166,144)];
	slideHit = NSPointInRect(mouseDownPoint, slideRect);
	
	BOOL presentSlide = YES;

	if ([self editorOn] || editSlideAtIndex==clickedIndex) {		
		float deleteX = slideRect.origin.x - 12;
		float deleteY = slideRect.origin.y - 10;
		NSRect deleteWidgetRect = NSMakeRect(deleteX, deleteY, 27, 27);
		
		BOOL deleteHit = NSPointInRect(mouseDownPoint, deleteWidgetRect);
		
		// User clicked the delete button ... take appropriate action
		if (deleteHit) {
			[self deleteSlideAtIndex:clickedIndex];
			
			// Make sure the user cannot trigger a slide hit as well
			slideHit = NO;
		}
		
		//NSRect slideToolsFlagRect = NSMakeRect((slideRect.origin.x + slideRect.size.width) - 19, slideRect.origin.y + 3, 16, 16);
		//NSMakeRect(slideToolsRect.origin.x+18, slideToolsRect.origin.y+1, 38, 17);
		//BOOL flagHit = NSPointInRect(mouseDownPoint, slideToolsFlagRect);
		
		//if (flagHit) {
		//	[NSMenu popUpContextMenu:flagMenu withEvent:theEvent forView:self];
		//	slideHit = NO;
		//}
	}
	
	saveHit = NO;
	editPrevSlide = -1;
	
	if (editSlideAtIndex==clickedIndex) {
		saveHit = NSPointInRect(mouseDownPoint, NSMakeRect(slideRect.origin.x+slideRect.size.width-46, slideRect.origin.y, 41, 15));
		
		clickedSlideAtIndex = clickedIndex; presentSlide = NO;
	}
	
	if (slideHit) {
		if (editSlideAtIndex != -1) {
			worshipSlides[editSlideAtIndex] = [inslideTextEditor string];
			editSlideAtIndex = -1;
			[self saveAllSlidesForSong: nil];
			
			[self setNeedsDisplay: YES];
		}
		
		if ([theEvent clickCount]==2 || [self editorOn]  || [theEvent modifierFlags] & NSAlternateKeyMask) {
			editPrevSlide = editSlideAtIndex;
			editSlideAtIndex = clickedIndex;
			[self setNeedsDisplay: YES];
			
			if ([theEvent modifierFlags] & NSAlternateKeyMask || [self editorOn]) { clickedSlideAtIndex = clickedIndex; presentSlide = NO; }
		}
		
		if (presentSlide)
			[self presentSlideAtIndex: clickedIndex];
			
		[editFlagField setStringValue: slidesNotes[clickedIndex]];
	} else {
		if (editSlideAtIndex != -1) {
			worshipSlides[editSlideAtIndex] = [inslideTextEditor string];
			editSlideAtIndex = -1;
			[self saveAllSlidesForSong: nil];
			
			[self setNeedsDisplay: YES];
		}

		[self presentSlideAtIndex: -1];
	}
	
	if (clickedIndex >= [worshipSlides count]) {
		if (editSlideAtIndex != -1) {
			worshipSlides[editSlideAtIndex] = [inslideTextEditor string];
			editSlideAtIndex = -1;
			[self saveAllSlidesForSong: nil];
			
			[self setNeedsDisplay: YES];
		}
	}
	
	if (goAheadAndDrag) {
		NSImage *clickedImage = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"SlideNormal" ofType:@"tiff"]];
		dragImage = [[NSImage alloc] initWithSize:[clickedImage size]];
		
		[dragImage lockFocus];
		
		[clickedImage drawInRect:NSMakeRect(0,0,[clickedImage size].width,[clickedImage size].height) fromRect:NSMakeRect(0,0,[clickedImage size].width,[clickedImage size].height) operation:NSCompositeCopy fraction:0.5];
		
		unsigned worshipTextViewHeight = heightForStringDrawing(worshipSlides[clickedIndex], [NSFont boldSystemFontOfSize:13], 155.0)+5.0;
		NSRect worshipTextView = [self rectCenteredInRect:NSMakeRect(0,0,[clickedImage size].width,[clickedImage size].height) withSize:NSMakeSize(155, worshipTextViewHeight)];
		
		NSString *worshipSlideText = [[NSString alloc] initWithString: worshipSlides[clickedIndex]];
		[worshipSlideTextAttrs setValue: [NSColor colorWithCalibratedWhite:0.0 alpha:0.5] forKey: NSForegroundColorAttributeName];
		[worshipSlideText drawInRect:worshipTextView withAttributes: worshipSlideTextAttrs];
		
		[dragImage unlockFocus];
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	if (0 == [worshipSlides count])
		return;
	
	mouseDown = NO;
	unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	
	if (![self editorOn] && editSlideAtIndex==-1) {
		// If the right or down arrow keys are pressed, move forward in viewer
		// Also responds to the "Space" key
		if ([[theEvent characters] isEqualToString: @" "] || key == NSRightArrowFunctionKey || key == NSDownArrowFunctionKey) {
			[self performAutoscroll: NSMakePoint([self gridRectForIndex: clickedSlideAtIndex+1].origin.x, [self gridRectForIndex: clickedSlideAtIndex+1].origin.y+[self gridRectForIndex: clickedSlideAtIndex+1].size.height)];
			[self presentSlideAtIndex:clickedSlideAtIndex+1];
		}
		
		// If the left or up arrow keys are pressed, move back in viewer
		if (key == NSLeftArrowFunctionKey || key == NSUpArrowFunctionKey) {
			[self performAutoscroll: NSMakePoint([self gridRectForIndex: clickedSlideAtIndex-1].origin.x, [self gridRectForIndex: clickedSlideAtIndex-1].origin.y+[self gridRectForIndex: clickedSlideAtIndex-1].size.height)];
			[self presentSlideAtIndex:clickedSlideAtIndex-1];
		}
		
		// Delete the slide ... ummm, duh!
		if (key == NSDeleteCharacter || key == NSDeleteFunctionKey)
			[self deleteSlideAtIndex:clickedSlideAtIndex];
			
		// Turn on the slide editor when the "Return" key is pressed
		if (key == NSCarriageReturnCharacter) {
			editSlideAtIndex = clickedSlideAtIndex;
			[self setNeedsDisplay: YES];
		}
		
		if (NSLocationInRange([theEvent keyCode], NSMakeRange(82,11))) {
			NSLog(@"Number key pressed!");
			drawQuickCue = YES;
			[self setNeedsDisplay: YES];
		}
		
		NSLog(@"Keypressed: %d, **%@**", [theEvent keyCode], [theEvent characters]);
	}
}

- (void)mouseDragged:(NSEvent*)theEvent
{
	if (performAutoScroll)
		mouseDownPoint.y = mouseDownPoint.y + 144;
		
	mouseCurrentPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	// If the mouse has moved less than 10px in either direction, don't register the drag yet
	// Helps to prevent accidental dragging of a slide when double clicking
    float xFromStart = fabs((mouseDownPoint.x - mouseCurrentPoint.x));
	float yFromStart = fabs((mouseDownPoint.y - mouseCurrentPoint.y));
	if ((xFromStart < 10) && (yFromStart < 10))
		return;
	
	if (editSlideAtIndex!=-1) {
		worshipSlides[editSlideAtIndex] = [inslideTextEditor string];
		editSlideAtIndex = -1;
		[self saveAllSlidesForSong: nil];
		
		[self setNeedsDisplay: YES];
	}
		
	// place the cursor in the center of the drag image
	NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	p.x = p.x - [dragImage size].width / 2;
	p.y = p.y + [dragImage size].height / 2;
	
	[self autoscroll:theEvent];
	
	//[dragImage drawAtPoint:p fromRect:NSMakeRect(0, 0, [dragImage size].width, [dragImage size].height) operation:NSCompositeSourceOver fraction:1.0];
	
	//[self dragImage:dragImage at:p offset:NSZeroSize event:theEvent pasteboard:nil source:self slideBack:NO];
	
	unsigned overGridIndex = [self slideIndexForPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
		
	NSRect slideRectTemp = [self rectCenteredInRect:[self gridRectForIndex:overGridIndex] withSize:NSMakeSize(166,144)];
	NSRect slideRectTempLeft = slideRectTemp;
	NSRect slideRectTempRight = slideRectTemp;
		
	slideRectTempLeft.size.width -= 83;
	slideRectTempRight.size.width -= 83;
	slideRectTempRight.origin.x += 83;
		
	BOOL slideHitLeft = NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], slideRectTempLeft);
	BOOL slideHitRight = NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], slideRectTempRight);
		
	if (slideHitLeft)
		drawDropperForIndex = overGridIndex-1;
	if (slideHitRight)
		drawDropperForIndex = overGridIndex;
		
	[self setNeedsDisplay: YES];
		
	iDidADrag = YES;
}

/*- (void)draggedImage:(NSImage *)draggedImage movedTo:(NSPoint)screenPoint
{
	NSPoint windowPoint = [[self window] convertScreenToBase: screenPoint];
	NSPoint viewPoint = [self convertPoint:windowPoint fromView:nil];
	
	unsigned overGridIndex = [self slideIndexForPoint: viewPoint];

	NSLog(@"DRAGGED IMAGE %i", overGridIndex);
		
	NSRect slideRectTemp = [self rectCenteredInRect:[self gridRectForIndex:overGridIndex] withSize:NSMakeSize(166,144)];
	NSRect slideRectTempLeft = slideRectTemp;
	NSRect slideRectTempRight = slideRectTemp;
		
	slideRectTempLeft.size.width -= 83;
	slideRectTempRight.size.width -= 83;
	slideRectTempRight.origin.x += 83;
		
	BOOL slideHitLeft = NSPointInRect(viewPoint, slideRectTempLeft);
	BOOL slideHitRight = NSPointInRect(viewPoint, slideRectTempRight);
	
	NSLog(@"%i hitleft", slideHitLeft);
	NSLog(@"%i hitright", slideHitRight);
		
	if (slideHitLeft)
		drawDropperForIndex = overGridIndex-1;
	if (slideHitRight)
		drawDropperForIndex = overGridIndex;
		
	[self setNeedsDisplay: YES];
}*/

- (void)mouseUp:(NSEvent *)theEvent
{		
	if (iDidADrag) {
		NSString *slideText = [[NSString alloc] initWithString: worshipSlides[clickedIndex]];
		NSString *slideNoteText = [[NSString alloc] initWithString: slidesNotes[clickedIndex]];
		NSString *mediaReferencesText = [[NSString alloc] initWithString: mediaReferences[clickedIndex]];
		
		if (drawDropperForIndex!=clickedIndex) {
			// Fixes a problem where dragging a slide back moves it one space too far
			if (drawDropperForIndex<=clickedIndex)
				drawDropperForIndex++;
			
			// Makes sure we don't go out of bounds
			if (drawDropperForIndex==-1)
				drawDropperForIndex = 0;
			
			[worshipSlides removeObjectAtIndex: clickedIndex];
			[slidesNotes removeObjectAtIndex: clickedIndex];
			[mediaReferences removeObjectAtIndex: clickedIndex];
			
			if (drawDropperForIndex >= [worshipSlides count]) {
				[worshipSlides addObject: slideText];
				[slidesNotes addObject: slideNoteText];
				[mediaReferences addObject: mediaReferencesText];
			} else {
				[worshipSlides insertObject: slideText atIndex: drawDropperForIndex];
				[slidesNotes insertObject: slideNoteText atIndex: drawDropperForIndex];
				[mediaReferences insertObject: mediaReferencesText atIndex: drawDropperForIndex];
			}
			
			[self saveAllSlidesForSong: nil];
			
			clickedSlideAtIndex = drawDropperForIndex;
		}
		
		drawDropperForIndex = -1;
		iDidADrag = NO;
		[self setNeedsDisplay: YES];
	}
	
	if (slideHit && !iDidADrag)
		[self performAutoscroll: NSMakePoint([self gridRectForIndex: clickedIndex].origin.x, [self gridRectForIndex: clickedIndex].origin.y+[self gridRectForIndex: clickedIndex].size.height)];
}

//- (void)rightMouseDown:(NSEvent *)theEvent
//{
//	mouseDownPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
//	mouseCurrentPoint = mouseDownPoint;
//
//	clickedIndex = [self slideIndexForPoint:mouseDownPoint];
//	NSRect					slideRect = [self rectCenteredInRect:[self gridRectForIndex:clickedIndex] withSize:NSMakeSize(166,144)];
//	slideHit = NSPointInRect(mouseDownPoint, slideRect);
//}

- (void)performAutoscroll:(NSPoint)curSlideBottomRightPoint
{
	performAutoScroll = NO;
	
	NSRect boundsPaddingRect = NSMakeRect([[self superview] visibleRect].origin.x, [[self superview] visibleRect].origin.y, [[self superview] visibleRect].size.width, [[self superview] visibleRect].size.height);
	
	// If the bottom right point of the currently selected slide exceeds the viewable area, scroll to point
	if (!NSPointInRect(curSlideBottomRightPoint, boundsPaddingRect)) {
		NSPoint scrollTo = NSMakePoint([[self superview] visibleRect].origin.x, (curSlideBottomRightPoint.y-[[self superview] visibleRect].size.height)+150);
		NSPoint maxScrollTo = NSMakePoint([[self superview] visibleRect].origin.x, NSMaxY([[[self enclosingScrollView] documentView] frame])-NSHeight([[[self enclosingScrollView] contentView] bounds]));
		
		// Check to make sure we are not scrolling beyond the bounds of the slides
		if (scrollTo.y <= maxScrollTo.y) {
			// Scroll to point
			[[[self enclosingScrollView] contentView] scrollToPoint: scrollTo];
			[[self enclosingScrollView] reflectScrolledClipView:[[self enclosingScrollView] contentView]];
			performAutoScroll = YES;
		} else {
			// Scroll to end of slide view
			[[[self enclosingScrollView] contentView] scrollToPoint: maxScrollTo];
			[[self enclosingScrollView] reflectScrolledClipView:[[self enclosingScrollView] contentView]];
			performAutoScroll = YES;
		}
	}
}

- (NSRect)gridRectForIndex:(unsigned)index
{
	unsigned row = index / columns;
	unsigned column = index % columns;
	float x = column * gridSize.width;
	float y = (row * gridSize.height)+10;
	
	return NSMakeRect(x, y, gridSize.width, gridSize.height);
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
	
    if (finish >= [worshipSlides count])
        finish = [worshipSlides count] - 1;
    
	return NSMakeRange(start, finish-start);
    
}

- (void)setWorshipSlides:(NSArray *)aSlidesArray notesSlides:(NSArray *)aSlidesNotesArray mediaRefs:(NSArray *)aMediaRefsArray
{
	//if (worshipSlides) [worshipSlides release];
	//if (slidesNotes) [slidesNotes release];
	//if (mediaReferences) [mediaReferences release];
	
	worshipSlides = [[NSMutableArray alloc] initWithArray: aSlidesArray copyItems: YES];
	
	if (aSlidesNotesArray) { slidesNotes = [[NSMutableArray alloc] initWithArray: aSlidesNotesArray copyItems: YES]; }
	if (aMediaRefsArray) { mediaReferences = [[NSMutableArray alloc] initWithArray: aMediaRefsArray copyItems: YES]; }
	else {
		NSMutableArray *blankMediaRefs = [[NSMutableArray alloc] init];
		unsigned i;
	
		for (i = 0; i < [worshipSlides count]; i++)
			[blankMediaRefs addObject: @""];
		
		mediaReferences = blankMediaRefs;
	}
	
	// update internal grid size, adjust height based on the new grid size
	[self scrollPoint:([self frame].origin)];
	[self updateGrid];
	
	[self setNeedsDisplay: YES];
}

- (NSMutableArray *) worshipSlides
{
    return worshipSlides;
}

- (NSMutableArray *) slidesNotes
{
    return slidesNotes;
}

- (NSMutableArray *) mediaReferences
{
    return mediaReferences;
}

- (BOOL) editorOn
{
	return editorOn;
}

- (BOOL) acceptsFirstResponder
{
	[[self window] makeFirstResponder:self];
	return YES;
}

- (void) setEditor:(BOOL)editorState
{
	editorOn = editorState;
	
	if (editorState==NO) {
		if (editSlideAtIndex!=-1) {
			worshipSlides[editSlideAtIndex] = [inslideTextEditor string];
			editSlideAtIndex = -1;
			[self saveAllSlidesForSong: nil];
		}
	}
	
	[self setNeedsDisplay: YES];
}

- (void)swipeWithEvent:(NSEvent *)event {  
	if ([event deltaX] == 1.0)
		[self presentSlideAtIndex:clickedSlideAtIndex-1];
	
	if ([event deltaX] == -1.0)
		[self presentSlideAtIndex:clickedSlideAtIndex+1];
	
	if ([event deltaY] == 1.0) {
		editSlideAtIndex = clickedSlideAtIndex;
		[self setNeedsDisplay: YES];
	}
	
	if ([event deltaY] == -1.0)
		[self setEditor: NO];
}

- (void)setFlag:(id)sender
{
	if (![[sender title] isEqualToString: @"None"]) {
		slidesNotes[clickedIndex] = [sender title];
	} else {
		slidesNotes[clickedIndex] = @"";
	}
	
	[self saveAllSlidesForSong: nil];
	[self setNeedsDisplay: YES];
}

- (void) setClickedSlideAtIndex:(unsigned)slideIndex
{
	clickedSlideAtIndex = slideIndex;
	[self setNeedsDisplay: YES];
}

- (void)presentSlideAtIndex:(unsigned)slideIndex
{
	NSMutableDictionary *presentationNodeData = [[NSMutableDictionary alloc] init];
	
	if (slideIndex == -1 || slideIndex > [worshipSlides count]-1) {
		[[[NSApp delegate] mainPresenterViewConnect] setPresentationText: @" "];
		
		presentationNodeData[@"Slide Text"] = @" ";
		
		clickedSlideAtIndex = -1;
	} else {
		if ([slidesNotes[slideIndex] isEqualToString: @"Skip"] && !mouseDown) {
			[self presentSlideAtIndex: slideIndex+1];
			return;
		}
		
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CCLI Display"] isEqualToString: @"Beginning of Song"] && slideIndex == 0) {
			[[[NSApp delegate] mainPresenterViewConnect] setRenderCCLI: YES];
		} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CCLI Display"] isEqualToString: @"End of Song"] && slideIndex == [worshipSlides count]-1) {
			[[[NSApp delegate] mainPresenterViewConnect] setRenderCCLI: YES];
		} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CCLI Display"] isEqualToString: @"Beginning and End"] && (slideIndex == 0 || slideIndex == [worshipSlides count]-1)) {
			[[[NSApp delegate] mainPresenterViewConnect] setRenderCCLI: YES];
		} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CCLI Display"] isEqualToString: @"Every Slide"]) {
			[[[NSApp delegate] mainPresenterViewConnect] setRenderCCLI: YES];
		} else {
			[[[NSApp delegate] mainPresenterViewConnect] setRenderCCLI: NO];
		}
	
		if ([[NSString stringWithString: worshipSlides[slideIndex]] length] != 0) {
			[[[NSApp delegate] mainPresenterViewConnect] setPresentationText: [NSString stringWithString: worshipSlides[slideIndex]]];
			presentationNodeData[@"Slide Text"] = [NSString stringWithString: worshipSlides[slideIndex]];
		} else {
			[[[NSApp delegate] mainPresenterViewConnect] setPresentationText: @" "];
			presentationNodeData[@"Slide Text"] = @" ";
		}
		
		if ([[NSString stringWithString: mediaReferences[slideIndex]] length] != 0) {
			[[NSApp delegate] presentJuice: [mediaReferences[slideIndex] stringByExpandingTildeInPath]];
		}
		
		clickedSlideAtIndex = slideIndex;
	}
	
	presentationNodeData[@"Layout"] = [NSString stringWithFormat:@"%i", layoutValue];
	presentationNodeData[@"Alignment"] = [NSString stringWithFormat:@"%i", alignmentValue];
	presentationNodeData[@"Transition"] = [NSString stringWithFormat:@"%f", speedValue];
	presentationNodeData[@"Size"] = [NSString stringWithFormat:@"%f", fontSizeValue];
	
	if (fontFamily)
		presentationNodeData[@"Font"] = fontFamily;
	
	[self setNeedsDisplay: YES];
}

- (void)deleteSlideAtIndex:(unsigned)slideIndex
{
	if (!slideIndex)
		slideIndex = clickedSlideAtIndex;
		
	if (editSlideAtIndex!=-1) {
		worshipSlides[editSlideAtIndex] = [inslideTextEditor string];
		editSlideAtIndex = -1;
		[self saveAllSlidesForSong: nil];
			
		[self setNeedsDisplay: YES];
	}

	NSRect slideRect = [self rectCenteredInRect:[self gridRectForIndex:slideIndex] withSize:NSMakeSize(166,144)];
	
	NSPoint windowPoint = [self convertPoint:NSMakePoint(NSMidX(slideRect), NSMidY(slideRect)) toView:nil];
	NSPoint screenPoint = [[self window] convertBaseToScreen:windowPoint];
	
	NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault, screenPoint, NSMakeSize(100, 100), nil, nil, nil);
	
	[[[(MyDocument *)[[super window] delegate] undoManager] prepareWithInvocationTarget:self] insertNewSlide:worshipSlides[slideIndex] slideFlag:slidesNotes[slideIndex] slideMedia:mediaReferences[slideIndex] slideIndex:slideIndex];
	
	// Remove the slide and refresh the view
	[worshipSlides removeObjectAtIndex: slideIndex];
	[slidesNotes removeObjectAtIndex: slideIndex];
	[mediaReferences removeObjectAtIndex: slideIndex];
	
	if (clickedSlideAtIndex==slideIndex) { clickedSlideAtIndex = -1; }
	else { clickedSlideAtIndex -= 1; }
	
	[self saveAllSlidesForSong: nil];
	
	[self setNeedsDisplay: YES];
}

- (void)duplicateSlide:(unsigned)index
{
	if (!index)
		index = clickedSlideAtIndex;
		
	[[[(MyDocument *)[[super window] delegate] undoManager] prepareWithInvocationTarget:self] deleteSlideAtIndex:index+1];
	
	[worshipSlides insertObject:worshipSlides[index] atIndex: index+1];
	[slidesNotes insertObject:slidesNotes[index] atIndex: index+1];
	
	clickedSlideAtIndex = index+1;
	[self saveAllSlidesForSong: nil];
	
	[self setNeedsDisplay: YES];
}

- (void)saveAllSlidesForSong:(NSString *)slideFile
{
	NSLog(@"saveAllSlidesForSong");
	
	if (editSlideAtIndex!=-1) {
		worshipSlides[editSlideAtIndex] = [inslideTextEditor string];
		editSlideAtIndex = -1;
		[self setNeedsDisplay: YES];
	}
	
	NSMutableDictionary *songFile = [[NSMutableDictionary alloc] init];
	
	songFile[@"Song Title"] = [songTitle stringValue];
	
	if (![[songArtist stringValue] isEqualToString: @""])
		songFile[@"CCLI Artist"] = [songArtist stringValue];
	if (![[songCopyright stringValue] isEqualToString: @""])
		songFile[@"CCLI Copyright Year"] = [songCopyright stringValue];
	if (![[songPublisher stringValue] isEqualToString: @""])
		songFile[@"CCLI Publisher"] = [songPublisher stringValue];
	if (![[songNumber stringValue] isEqualToString: @""])
		songFile[@"CCLI Song Number"] = [songNumber stringValue];
	
	songFile[@"Slides"] = worshipSlides;
	songFile[@"Flags"] = slidesNotes;
	songFile[@"Media"] = mediaReferences;
	songFile[@"Presenter Layout"] = [NSString stringWithFormat:@"%i", layoutValue];
	songFile[@"Presenter Alignment"] = [NSString stringWithFormat:@"%i", alignmentValue];
	songFile[@"Transition Speed"] = [NSString stringWithFormat:@"%f", speedValue];
	songFile[@"Font Size"] = [NSString stringWithFormat:@"%f", fontSizeValue];
	
	if (fontFamily)
		songFile[@"Font Family"] = fontFamily;
	
	if (slideFile)
		[songFile writeToFile:[[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@", slideFile] stringByExpandingTildeInPath] atomically:TRUE];
	else
		[songFile writeToFile:[[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/%@", [(MyDocument *)[playlistTable dataSource] worshipPlaylist][[playlistTable selectedRow]]] stringByExpandingTildeInPath] atomically:TRUE];
}

//////////////////////////
// Undo manager support //
//////////////////////////

-(void)insertFlagIntoData:(NSString *)flagText
{
	
}

//////////////////////////
// Presentation support //
//////////////////////////

- (IBAction)presentSlideNext:(id)sender
{
	[self presentSlideAtIndex:clickedSlideAtIndex+1];
}

- (IBAction)presentSlidePrevious:(id)sender
{
	[self presentSlideAtIndex:clickedSlideAtIndex-1];
}

- (Presenter *)mainPresenterViewCommunicate
{
	return mainPresenterView;
}

//////////////////////////////
// Slide management support //
//////////////////////////////

- (IBAction)newSlide:(id)sender
{
	if (clickedSlideAtIndex!=-1) {
		[self insertNewSlide:@"" slideFlag:@"" slideMedia:@"" slideIndex:clickedSlideAtIndex+1];
	} else {
		[self insertNewSlide:@"" slideFlag:@"" slideMedia:@"" slideIndex:[worshipSlides count]];
		
		NSPoint maxScrollTo = NSMakePoint([[self superview] visibleRect].origin.x, NSMaxY([[[self enclosingScrollView] documentView] frame])-NSHeight([[[self enclosingScrollView] contentView] bounds]));
		[[[self enclosingScrollView] contentView] scrollToPoint: maxScrollTo];
		[[self enclosingScrollView] reflectScrolledClipView:[[self enclosingScrollView] contentView]];
	}
}

- (void)insertNewSlide:(NSString *)slideText slideFlag:(NSString *)slideFlag slideMedia:(NSString *)slideMedia slideIndex:(unsigned)index
{
	if (editSlideAtIndex!=-1) {
		NSLog(@"Insert slide, editor on");
		worshipSlides[editSlideAtIndex] = [inslideTextEditor string];
		editSlideAtIndex = -1;
		[self saveAllSlidesForSong: nil];
		
		if ([inslideTextScroller superview]==self)
			[inslideTextScroller removeFromSuperview];
		
		[self setNeedsDisplay: YES];
	}
	
	[[[(MyDocument *)[[super window] delegate] undoManager] prepareWithInvocationTarget:self] deleteSlideAtIndex:index];
	
	[worshipSlides insertObject: slideText atIndex: index];
	[slidesNotes insertObject: slideFlag atIndex: index];
	[mediaReferences insertObject: slideMedia atIndex: index];
	
	[self saveAllSlidesForSong: nil];
	
	clickedSlideAtIndex = index;
	editSlideAtIndex = index;
	
	[self setNeedsDisplay: YES];
}

- (IBAction)editFlagWithText:(id)sender
{
	slidesNotes[clickedSlideAtIndex] = [sender stringValue];
	[self setNeedsDisplay: YES];
	[self saveAllSlidesForSong: nil];
}

- (IBAction)assignMediaToSlide:(id)sender
{
	mediaReferences[clickedSlideAtIndex] = [mediaBrowser mediaListing][[mediaBrowser clickedSlideAtIndex]];
	[self setNeedsDisplay: YES];
	[self saveAllSlidesForSong: nil];
}

- (IBAction)applySkipSlide:(id)sender
{
	if ([slidesNotes[clickedSlideAtIndex] isEqualToString: @"Skip"]) {
		slidesNotes[clickedSlideAtIndex] = @"";
	} else {
		slidesNotes[clickedSlideAtIndex] = @"Skip";
	}
	
	[self setNeedsDisplay: YES];
	[self saveAllSlidesForSong: nil];
}

- (IBAction)removeMediaTrigger:(id)sender
{
	mediaReferences[clickedSlideAtIndex] = @"";
	
	[self setNeedsDisplay: YES];
	[self saveAllSlidesForSong: nil];
}

/////////////////////////////
// Song management support //
/////////////////////////////

- (void)setSlideAlignment:(int)alignment
{
	[[[(MyDocument *)[[super window] delegate] undoManager] prepareWithInvocationTarget:self] setSlideAlignment:alignmentValue];
	[[(MyDocument *)[[super window] delegate] undoManager] setActionName:@"Change Slide Alignment"];
	
	[[[NSApp delegate] mainPresenterViewConnect] setAlignment:alignment];
	alignmentValue = alignment;
	[self saveAllSlidesForSong:nil];
}

- (void)setSlideLayout:(int)layout
{
	[[[(MyDocument *)[[super window] delegate] undoManager] prepareWithInvocationTarget:self] setSlideLayout:layoutValue];
	[[(MyDocument *)[[super window] delegate] undoManager] setActionName:@"Change Slide Layout"];
	
	[[[NSApp delegate] mainPresenterViewConnect] setLayout:layout];
	layoutValue = layout;
	[self saveAllSlidesForSong:nil];
}

- (IBAction)setSlidesTransitionSpeed:(id)sender
{
	float actualTransitionSpeed;
	
	if ([speedSlider floatValue] <= 0.5) { actualTransitionSpeed = 0.0; }
	else if ([speedSlider floatValue] <= 1.0) { actualTransitionSpeed = 0.5; }
	else if ([speedSlider floatValue] <= 1.5) { actualTransitionSpeed = 1.0; }
	else if ([speedSlider floatValue] <= 2.0) { actualTransitionSpeed = 1.5; }
	else if ([speedSlider floatValue] <= 2.5) { actualTransitionSpeed = 2.0; }
	else if ([speedSlider floatValue] <= 3.0) { actualTransitionSpeed = 2.5; }
	else if ([speedSlider floatValue] <= 3.5) { actualTransitionSpeed = 3.0; }
	else if ([speedSlider floatValue] <= 4.0) { actualTransitionSpeed = 3.5; }
	else if ([speedSlider floatValue] <= 4.5) { actualTransitionSpeed = 4.0; }
	else if ([speedSlider floatValue] <= 5.0) { actualTransitionSpeed = 4.5; }
	else { actualTransitionSpeed = 5.0; }
	
	[speedArea setStringValue: [NSString stringWithFormat: @"%.1fs", actualTransitionSpeed]];
	[[[NSApp delegate] mainPresenterViewConnect] setTransitionSpeed: actualTransitionSpeed];
	speedValue = actualTransitionSpeed;
	[self saveAllSlidesForSong:nil];
}

- (void)setFontFamilySize:(float)fontSize
{
	[[[NSApp delegate] mainPresenterViewConnect] setFontSize: [@(fontSize) intValue]];
	fontSizeValue = fontSize;
	[self saveAllSlidesForSong:nil];
}


- (void)setFontFamily:(NSString *)font
{
	[[[NSApp delegate] mainPresenterViewConnect] setFontFamily:font];
	fontFamily = font;
	[self saveAllSlidesForSong:nil];
}

////////////////////////////
// Copy and Paste support //
////////////////////////////

- (void)copy:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types = @[NSStringPboardType];
	[pb declareTypes:types owner:self];
	
	[pb setString:worshipSlides[clickedSlideAtIndex] forType:NSStringPboardType];
}

- (void)paste:(id)sender
{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *pasteTypes = @[NSStringPboardType];
	NSString *bestType = [pb availableTypeFromArray:pasteTypes];
	
	if (bestType != nil) {
		[self insertNewSlide:[pb stringForType: NSStringPboardType] slideFlag:@"" slideMedia:@"" slideIndex:clickedSlideAtIndex+1];
	}
}

- (IBAction)cut:(id)sender
{
    [self copy: nil];
    [self deleteSlideAtIndex: clickedSlideAtIndex];
}

/////////////////////////////
// Contextual menu support //
/////////////////////////////

-(NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSRect slideRect = [self rectCenteredInRect:[self gridRectForIndex:[self slideIndexForPoint: [self convertPoint:[theEvent locationInWindow] fromView:nil]]] withSize:NSMakeSize(166,144)];
	
	if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], slideRect)) {
		clickedSlideAtIndex = [self slideIndexForPoint: [self convertPoint:[theEvent locationInWindow] fromView:nil]];
		[self setNeedsDisplay: YES];
		
		NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
		
		if ([slidesNotes[clickedSlideAtIndex] isEqualToString: @"Skip"]) {
			[theMenu insertItemWithTitle:@"Remove Skip" action:@selector(applySkipSlide:) keyEquivalent: @"" atIndex:0];
		} else {
			[theMenu insertItemWithTitle:@"Skip Slide" action:@selector(applySkipSlide:) keyEquivalent: @"" atIndex:0];
		}
		
		if (![mediaReferences[clickedSlideAtIndex] isEqualToString: @""]) {
			[theMenu insertItemWithTitle:@"Remove Media Trigger" action:@selector(removeMediaTrigger:) keyEquivalent: @"" atIndex:1];
		}
	
		return theMenu;
	}
	
	return [[self class] defaultMenu];
}

@end
