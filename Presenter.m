//
//  Presenter.m
//  ProWorship
//
//  Created by Albert Martin on 1/3/07.
//  Copyright 2007-2008 Renovatio Software. All rights reserved.
//
//  The parent view containing all layers comprising the presentation screen.
//  Transitioning to CALayers so that everything is all contained in this view for ultimate portability.
//

#import "Presenter.h"
#import "MyDocument.h"

@implementation Presenter

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		NSLog(@" ");
		NSLog(@"----------------------------------------");
		NSLog(@"PRESENTATION WINDOW SETUP/INITIALIZATION");
		
		CALayer *masterLayer = [CALayer layer];
		presentationTextLayer = [CATextLayer layer];
		presentationTextLayerOutgoing = [CATextLayer layer];
		
		[self setLayer:masterLayer]; 
		[self setWantsLayer:YES];
		
		[self layer].layoutManager = [CAConstraintLayoutManager layoutManager];
		
		NSLog(@"PRESENTATION: Live video layer initializing");
		liveCameraView = [QTCaptureLayer layer];
		liveCameraView.frame = CGRectMake(0, 0, frameRect.size.width, frameRect.size.height);
		
		[[self layer] addSublayer: liveCameraView];
		
		/*presentationVideoLayer = [[[QTMovieLayer alloc] initWithMovie: nil] retain];
		presentationVideoLayer.frame = CGRectMake(0, 0, frameRect.size.width, frameRect.size.height);
		presentationVideoLayer.opacity = 0.0;
		
		[[self layer] addSublayer: presentationVideoLayer];
		
		presentationVideoLayer2 = [[QTMovieLayer alloc] initWithMovie: nil];
		presentationVideoLayer2.frame = CGRectMake(0, 0, frameRect.size.width, frameRect.size.height);
		presentationVideoLayer.opacity = 0.0;
		
		[[self layer] addSublayer: presentationVideoLayer2];*/
		
		NSLog(@"PRESENTATION: Text layer initializing");
		//presentationTextLayer.wrapped = YES;
		presentationTextLayer.frame = CGRectMake(0, 0, frameRect.size.width, frameRect.size.height);
		presentationTextLayerOutgoing.frame = CGRectMake(0, 0, frameRect.size.width, frameRect.size.height);
		
		[[self layer] addSublayer: presentationTextLayer];
		[[self layer] addSublayer: presentationTextLayerOutgoing];
		
		NSLog(@"PRESENTATION: CCLI licensing layer initializing");
		ccliLayer = [CALayer layer];
		ccliLayer.cornerRadius = 8;
		ccliLayer.borderWidth = 1;
		ccliLayer.borderColor = kCGColorWhite;
		ccliLayer.backgroundColor = kCGColorBlack;
		ccliLayer.opacity = 0.8;
		ccliLayer.frame = CGRectMake(0, 0, frameRect.size.width-[[NSUserDefaults standardUserDefaults] integerForKey:@"BoundsW"], frameRect.size.height-[[NSUserDefaults standardUserDefaults] integerForKey:@"BoundsH"]);
		[ccliLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
		ccliLayer.position = CGPointMake(ccliLayer.position.x+[[NSUserDefaults standardUserDefaults] integerForKey:@"BoundsX"], ccliLayer.position.y+[[NSUserDefaults standardUserDefaults] integerForKey:@"BoundsY"]);
		
		ccliLayerTextMain = [CATextLayer layer];
		ccliLayerTextMain.alignmentMode = kCAAlignmentCenter;
		ccliLayerTextMain.font = (__bridge CFTypeRef)(@"Helvetica Neue Light");
		ccliLayerTextMain.fontSize = 16.0;
		
		[[self layer] addSublayer: ccliLayer];
		
		NSLog(@"PRESENTATION: Registering defaults");
		presentationText = @" ";
		outgoingPresentationText = @" ";
		
		presentationTextAlpha = 1.0;
		outgoingPresentationTextAlpha = 0.0;
		transitionTime = 0.5;
		
		presenterSlideTextPara = [[NSMutableParagraphStyle alloc] init];
		[presenterSlideTextPara setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
		[presenterSlideTextPara setAlignment:NSCenterTextAlignment];
	
		presenterSlideTextAttrs = [[NSMutableDictionary alloc] init];
		outgoingPresenterSlideTextAttrs = [[NSMutableDictionary alloc] init];
		
		presenterSlideLayout = 1;
		
		NSLog(@"----------------------------------------");
	}
	
	return self;
}

float heightForStringDrawingPresenter(NSAttributedString *myString, float desiredWidth)
{
	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:myString];
	NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize: NSMakeSize(desiredWidth, FLT_MAX)];
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

	[textContainer setLineFragmentPadding: 0.0];

	[layoutManager addTextContainer: textContainer];
	[textStorage addLayoutManager: layoutManager];
	
	[layoutManager setTypesetterBehavior:NSTypesetterBehavior_10_2_WithCompatibility];
	
	(void)[layoutManager glyphRangeForTextContainer: textContainer]; // force layout
	return [layoutManager usedRectForTextContainer: textContainer].size.height;
}

- (BOOL)isFlipped
{
	return YES;
}

- (QTCaptureLayer *)liveCameraView
{
	return liveCameraView;
}

/*- (NSImage *)drawLegacyPresentation:(NSSize)size
{
	NSImage *legacyPresentationImage = [[NSImage alloc] initWithSize:size];
	
	[legacyPresentationImage lockFocus];
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	// Draw the CCLI copyright information
	if (renderCCLI && ![presentationText isEqualToString:@" "]) {
		bgPath = [NSBezierPath bezierPath];
		[bgPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(roundRect), NSMinY(roundRect)) radius:radius startAngle:180.0 endAngle:270.0];
		[bgPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(roundRect), NSMinY(roundRect)) radius:radius startAngle:270.0 endAngle:360.0];
		[bgPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(roundRect), NSMaxY(roundRect)) radius:radius startAngle:0.0 endAngle:90.0];
		[bgPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(roundRect), NSMaxY(roundRect)) radius:radius startAngle:90.0 endAngle:180.0];
		[bgPath closePath];
		[[NSColor colorWithDeviceWhite:0.0 alpha:0.8] set];
		[bgPath fill];
		[[NSColor whiteColor] set];
		[bgPath setLineWidth:0.5];
		[bgPath stroke];
	
		NSString *ccliTextDisplay = @"";
	
		if ([[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"Song Title"])
			ccliTextDisplay = [ccliTextDisplay stringByAppendingString: [NSString stringWithFormat:@"\"%@\"", [[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"Song Title"]]];
	
		if ([[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Artist"])
			ccliTextDisplay = [ccliTextDisplay stringByAppendingString: [NSString stringWithFormat:@" words and music by %@.", [[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Artist"]]];
		
		if ([[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Copyright Year"] || [[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Publisher"])
			ccliTextDisplay = [ccliTextDisplay stringByAppendingString: @" © "];
		
		if ([[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Copyright Year"])
			ccliTextDisplay = [ccliTextDisplay stringByAppendingString: [NSString stringWithFormat:@"%@ ", [[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Copyright Year"]]];
		
		if ([[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Publisher"])
			ccliTextDisplay = [ccliTextDisplay stringByAppendingString: [NSString stringWithFormat:@"%@.", [[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Publisher"]]];
		
		ccliTextDisplay = [ccliTextDisplay stringByAppendingString: [NSString stringWithFormat: @" Lyrics used by permission. CCLI license #%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"CCLI License"]]];
		
		NSAttributedString *ccliMainText = [[[NSAttributedString alloc] initWithString:ccliTextDisplay attributes:ccliMainTextAttributes] autorelease];
		
		NSTextStorage *ccliMainTextStorage = [[[NSTextStorage alloc] initWithAttributedString:ccliMainText] autorelease];

		NSTextContainer *ccliMainTextContainer = [[NSTextContainer alloc] initWithContainerSize: NSMakeSize([self bounds].size.width, FLT_MAX)];
		NSLayoutManager *ccliMainLayoutManager = [[NSLayoutManager alloc] init];
		[ccliMainLayoutManager addTextContainer: ccliMainTextContainer];
		[ccliMainTextStorage addLayoutManager: ccliMainLayoutManager];
	
		(void)[ccliMainLayoutManager glyphRangeForTextContainer: ccliMainTextContainer];
		
		[ccliMainLayoutManager drawGlyphsForGlyphRange:NSMakeRange(0, [ccliMainTextStorage length]) atPoint: NSMakePoint(107, size.height-54)];
		
		rect = NSMakeRect([standardUserDefaults integerForKey:@"BoundsX"], [standardUserDefaults integerForKey:@"BoundsY"], size.width-[standardUserDefaults integerForKey:@"BoundsW"], size.height-100-[standardUserDefaults integerForKey:@"BoundsH"]);
	} else {
		rect = NSMakeRect([standardUserDefaults integerForKey:@"BoundsX"], [standardUserDefaults integerForKey:@"BoundsY"], size.width-[standardUserDefaults integerForKey:@"BoundsW"], size.height-[standardUserDefaults integerForKey:@"BoundsH"]);
	}

	// Proceed to draw the presentation text
	stroke = nil;
	presentationTextColour = nil;
	
	if (standardUserDefaults) {
		stroke = [standardUserDefaults objectForKey:@"Text Stroke"];
		
		if ([standardUserDefaults objectForKey:@"Text Colour"] != nil)
			presentationTextColour = [NSUnarchiver unarchiveObjectWithData:[standardUserDefaults objectForKey:@"Text Colour"]];
		if ([standardUserDefaults objectForKey:@"Text Border Colour"] != nil)
			presentationTextBorderColour = [NSUnarchiver unarchiveObjectWithData:[standardUserDefaults objectForKey:@"Text Border Colour"]];
	}
	
	if (stroke == nil) {
		[standardUserDefaults setObject:@"-6" forKey:@"Text Stroke"];
		[standardUserDefaults synchronize];
		stroke = [NSNumber numberWithInt: -6];
	} if (presentationFontSize == nil) {
		presentationFontSize = [standardUserDefaults objectForKey:@"Text Size"];
		if (presentationFontSize == nil) {
			[standardUserDefaults setObject:@"72" forKey:@"Text Size"];
			[standardUserDefaults synchronize];
			presentationFontSize = 72;
		}
	} if (presentationFontFamily == nil) {
		presentationFontFamily = [standardUserDefaults objectForKey:@"Font Family"];
		if (presentationFontFamily == nil) {
			[standardUserDefaults setObject:@"Lucida Grande" forKey:@"Font Family"];
			[standardUserDefaults synchronize];
			presentationFontFamily = @"Lucida Grande";
		}
	} if (presentationTextColour == nil) {
		[standardUserDefaults setObject:[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:@"Text Colour"];
		[standardUserDefaults synchronize];
		presentationTextColour = [NSColor whiteColor];
	} if (presentationTextBorderColour == nil) {
		[standardUserDefaults setObject:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite: 0.27 alpha: 1.0]] forKey:@"Text Border Colour"];
		[standardUserDefaults synchronize];
		presentationTextBorderColour = [NSColor colorWithCalibratedWhite: 0.27 alpha: 1.0];
	} if (textKnocksOutStroke == nil) {
		NSLog(@"textKnocksOutStroke has not been set");
		if ([standardUserDefaults objectForKey:@"Text Knocks Out Stroke"] == nil) {
			NSLog(@"textKnocksOutStroke not set in preferences");
			[standardUserDefaults setObject:[NSArchiver archivedDataWithRootObject:[NSNumber numberWithInt:1]] forKey:@"Text Knocks Out Stroke"];
			[standardUserDefaults synchronize];
			textKnocksOutStroke = [NSNumber numberWithInt: 1];
		} else {
			NSLog(@"textKnocksOutStroke reading from preferences");
			textKnocksOutStroke = [NSUnarchiver unarchiveObjectWithData: [standardUserDefaults objectForKey:@"Text Knocks Out Stroke"]];
		}
	}
		
	genericPresenterSlideTextAttrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSFont fontWithName:presentationFontFamily size:presentationFontSize], NSFontAttributeName,
			stroke, NSStrokeWidthAttributeName,
			presenterSlideTextPara, NSParagraphStyleAttributeName,
			nil];
			
	[presenterSlideTextAttrs addEntriesFromDictionary: genericPresenterSlideTextAttrs];
	[outgoingPresenterSlideTextAttrs addEntriesFromDictionary: genericPresenterSlideTextAttrs];
			
	[presenterSlideTextAttrs setValue: [presentationTextColour colorWithAlphaComponent: presentationTextAlpha] forKey: NSForegroundColorAttributeName];
	[presenterSlideTextAttrs setValue: [presentationTextBorderColour colorWithAlphaComponent: presentationTextAlpha] forKey: NSStrokeColorAttributeName];
		
	[outgoingPresenterSlideTextAttrs setValue: [presentationTextColour colorWithAlphaComponent: outgoingPresentationTextAlpha] forKey: NSForegroundColorAttributeName];
	[outgoingPresenterSlideTextAttrs setValue: [presentationTextBorderColour colorWithAlphaComponent: outgoingPresentationTextAlpha] forKey: NSStrokeColorAttributeName];
	
	// Set up the text storage and layout containers
	
	// Standard container
	NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithAttributedString: [[NSAttributedString alloc] initWithString: [self presentationText] attributes:presenterSlideTextAttrs]] autorelease];
	NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize: NSMakeSize(rect.size.width, FLT_MAX)] autorelease];
	NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init] autorelease];
	
	[layoutManager addTextContainer: textContainer];
	[textStorage addLayoutManager: layoutManager];
	
	(void)[layoutManager glyphRangeForTextContainer: textContainer];
	
	// Standard overlay container
	[presenterSlideTextAttrs setValue: [presentationTextBorderColour colorWithAlphaComponent: 0] forKey: NSStrokeColorAttributeName];
	
	NSTextStorage *textOverlayStorage = [[[NSTextStorage alloc] initWithAttributedString: [[NSAttributedString alloc] initWithString: [self presentationText] attributes:presenterSlideTextAttrs]] autorelease];
	NSTextContainer *textOverlayContainer = [[[NSTextContainer alloc] initWithContainerSize: NSMakeSize(rect.size.width, FLT_MAX)] autorelease];
	NSLayoutManager *layoutOverlayManager = [[[NSLayoutManager alloc] init] autorelease];

	[layoutOverlayManager addTextContainer: textOverlayContainer];
	[textOverlayStorage addLayoutManager: layoutOverlayManager];
	
	(void)[layoutOverlayManager glyphRangeForTextContainer: textOverlayContainer];
	
	// Outgoing container
	NSTextStorage *outgoingTextStorage = [[[NSTextStorage alloc] initWithAttributedString: [[NSAttributedString alloc] initWithString: [self outgoingPresentationText] attributes:outgoingPresenterSlideTextAttrs]] autorelease];
	NSTextContainer *outgoingTextContainer = [[[NSTextContainer alloc] initWithContainerSize: NSMakeSize(rect.size.width, FLT_MAX)] autorelease];
	NSLayoutManager *outgoingLayoutManager = [[[NSLayoutManager alloc] init] autorelease];

	[outgoingLayoutManager addTextContainer: outgoingTextContainer];
	[outgoingTextStorage addLayoutManager: outgoingLayoutManager];
	
	(void)[outgoingLayoutManager glyphRangeForTextContainer: outgoingTextContainer];
	
	// Outgoing overlay container
	[outgoingPresenterSlideTextAttrs setValue: [presentationTextBorderColour colorWithAlphaComponent: 0] forKey: NSStrokeColorAttributeName];
	
	NSTextStorage *outgoingOverlayTextStorage = [[[NSTextStorage alloc] initWithAttributedString: [[NSAttributedString alloc] initWithString: [self outgoingPresentationText] attributes:outgoingPresenterSlideTextAttrs]] autorelease];
	NSTextContainer *outgoingOverlayTextContainer = [[[NSTextContainer alloc] initWithContainerSize: NSMakeSize(rect.size.width, FLT_MAX)] autorelease];
	NSLayoutManager *outgoingOverlayLayoutManager = [[[NSLayoutManager alloc] init] autorelease];

	[outgoingOverlayLayoutManager addTextContainer: outgoingOverlayTextContainer];
	[outgoingOverlayTextStorage addLayoutManager: outgoingOverlayLayoutManager];
	
	(void)[outgoingOverlayLayoutManager glyphRangeForTextContainer: outgoingOverlayTextContainer];
	
	// Calculate the height needed to draw the text
	float slideTextHeight = [layoutManager usedRectForTextContainer: textContainer].size.height;
	NSRect slideTextView;
	float slideTextOverlayHeight = [layoutOverlayManager usedRectForTextContainer: textOverlayContainer].size.height;
	NSRect slideTextOverlayView;
	
	float outgoingSlideTextHeight = [outgoingLayoutManager usedRectForTextContainer: outgoingTextContainer].size.height;
	NSRect outgoingSlideTextView;
	float outgoingOverlaySlideTextHeight = [outgoingOverlayLayoutManager usedRectForTextContainer: outgoingOverlayTextContainer].size.height;
	NSRect outgoingOverlaySlideTextView;
	
	// Calculate the layout co-ordinants based on the selected layout
	if (presenterSlideLayout==2) { // Bottom slide layout
		slideTextView = NSMakeRect(0, rect.size.height-slideTextHeight-5, rect.size.width, slideTextHeight);
		slideTextOverlayView = NSMakeRect(0, rect.size.height-slideTextOverlayHeight-5, rect.size.width, slideTextOverlayHeight);
		
		outgoingSlideTextView = NSMakeRect(0, rect.size.height-outgoingSlideTextHeight-5, rect.size.width, outgoingSlideTextHeight);
		outgoingOverlaySlideTextView = NSMakeRect(0, rect.size.height-outgoingOverlaySlideTextHeight-5, rect.size.width, outgoingOverlaySlideTextHeight);
	} else if (presenterSlideLayout==0) { // Top slide layout
		slideTextView = NSMakeRect(0, rect.origin.y, rect.size.width, slideTextHeight);
		slideTextOverlayView = NSMakeRect(0, rect.origin.y, rect.size.width, slideTextOverlayHeight);
		
		outgoingSlideTextView = NSMakeRect(0, rect.origin.y, rect.size.width, outgoingSlideTextHeight);
		outgoingOverlaySlideTextView = NSMakeRect(0, rect.origin.y, rect.size.width, outgoingOverlaySlideTextHeight);
	} else { // Centered slide layout
		slideTextView = NSMakeRect(0, (rect.size.height-slideTextHeight)/2, rect.size.width, slideTextHeight);
		slideTextOverlayView = NSMakeRect(0, (rect.size.height-slideTextOverlayHeight)/2, rect.size.width, slideTextOverlayHeight);
		
		outgoingSlideTextView = NSMakeRect(0, (rect.size.height-outgoingSlideTextHeight)/2, rect.size.width, outgoingSlideTextHeight);
		outgoingOverlaySlideTextView = NSMakeRect(0, (rect.size.height-outgoingOverlaySlideTextHeight)/2, rect.size.width, outgoingOverlaySlideTextHeight);
	}
	
	[layoutManager drawGlyphsForGlyphRange:NSMakeRange(0, [textStorage length]) atPoint: NSMakePoint(slideTextView.origin.x, slideTextView.origin.y)];
	if ([textKnocksOutStroke isEqualToNumber: [NSNumber numberWithInt: 1]])
		[layoutOverlayManager drawGlyphsForGlyphRange:NSMakeRange(0, [textOverlayStorage length]) atPoint: NSMakePoint(slideTextOverlayView.origin.x, slideTextOverlayView.origin.y)];
	
	[outgoingLayoutManager drawGlyphsForGlyphRange:NSMakeRange(0, [outgoingTextStorage length]) atPoint: NSMakePoint(outgoingSlideTextView.origin.x, outgoingSlideTextView.origin.y)];
	if ([textKnocksOutStroke isEqualToNumber: [NSNumber numberWithInt: 1]])
		[outgoingOverlayLayoutManager drawGlyphsForGlyphRange:NSMakeRange(0, [outgoingOverlayTextStorage length]) atPoint: NSMakePoint(outgoingOverlaySlideTextView.origin.x, outgoingOverlaySlideTextView.origin.y)];
	
	[legacyPresentationImage unlockFocus];
	
	return legacyPresentationImage;
}*/

- (void)setRenderCCLI:(BOOL)renderCCLIYesNo
{
	renderCCLI = renderCCLIYesNo;
}

- (void)setTextFormatting
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	// Proceed to draw the presentation text
	stroke = nil;
	presentationTextColour = nil;
	
	if (standardUserDefaults) {
		stroke = [standardUserDefaults objectForKey:@"Text Stroke"];
		
		if ([standardUserDefaults objectForKey:@"Text Colour"] != nil)
			presentationTextColour = [NSUnarchiver unarchiveObjectWithData:[standardUserDefaults objectForKey:@"Text Colour"]];
		if ([standardUserDefaults objectForKey:@"Text Border Colour"] != nil)
			presentationTextBorderColour = [NSUnarchiver unarchiveObjectWithData:[standardUserDefaults objectForKey:@"Text Border Colour"]];
	}
	
	if (!stroke) {
		[standardUserDefaults setObject:@"-6" forKey:@"Text Stroke"];
		[standardUserDefaults synchronize];
		stroke = [NSNumber numberWithInt: -6];
	} if (!presentationFontSize) {
		presentationFontSize = [[standardUserDefaults objectForKey:@"Text Size"] intValue];
		if (!presentationFontSize) {
			[standardUserDefaults setObject:@"72" forKey:@"Text Size"];
			[standardUserDefaults synchronize];
			presentationFontSize = 72;
		}
	} if (!presentationFontFamily) {
		presentationFontFamily = [standardUserDefaults objectForKey:@"Font Family"];
		if (!presentationFontFamily) {
			[standardUserDefaults setObject:@"Lucida Grande" forKey:@"Font Family"];
			[standardUserDefaults synchronize];
			presentationFontFamily = @"Lucida Grande";
		}
	} if (!presentationTextColour) {
		[standardUserDefaults setObject:[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]] forKey:@"Text Colour"];
		[standardUserDefaults synchronize];
		presentationTextColour = [NSColor whiteColor];
	} if (!presentationTextBorderColour) {
		[standardUserDefaults setObject:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite: 0.27 alpha: 1.0]] forKey:@"Text Border Colour"];
		[standardUserDefaults synchronize];
		presentationTextBorderColour = [NSColor colorWithCalibratedWhite: 0.27 alpha: 1.0];
	} if (!textKnocksOutStroke) {
		if (![standardUserDefaults objectForKey:@"Text Knocks Out Stroke"]) {
			[standardUserDefaults setObject:[NSArchiver archivedDataWithRootObject:[NSNumber numberWithInt:1]] forKey:@"Text Knocks Out Stroke"];
			[standardUserDefaults synchronize];
			textKnocksOutStroke = [NSNumber numberWithInt: 1];
		} else {
			textKnocksOutStroke = [NSUnarchiver unarchiveObjectWithData: [standardUserDefaults objectForKey:@"Text Knocks Out Stroke"]];
		}
	}
	
	genericPresenterSlideTextAttrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									  [NSFont fontWithName:presentationFontFamily size:presentationFontSize], NSFontAttributeName,
									  stroke, NSStrokeWidthAttributeName,
									  nil];
	
	[presenterSlideTextAttrs addEntriesFromDictionary: genericPresenterSlideTextAttrs];
	[outgoingPresenterSlideTextAttrs addEntriesFromDictionary: genericPresenterSlideTextAttrs];
	
	presentationTextBorderColour = [NSColor greenColor];
	
	[presenterSlideTextAttrs setValue: [presentationTextColour colorWithAlphaComponent: presentationTextAlpha] forKey: NSForegroundColorAttributeName];
	//[presenterSlideTextAttrs setValue: presentationTextBorderColour forKey: NSStrokeColorAttributeName];
	
	[outgoingPresenterSlideTextAttrs setValue: [presentationTextColour colorWithAlphaComponent: outgoingPresentationTextAlpha] forKey: NSForegroundColorAttributeName];
	//[outgoingPresenterSlideTextAttrs setValue: presentationTextBorderColour forKey: NSStrokeColorAttributeName];
}

- (void)setPresentationText:(NSString *)newPresentationText
{
	if (![newPresentationText isEqualToString: presentationText]) {		
		[self setTextFormatting];
		
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:0.0f] forKey:kCATransactionAnimationDuration];
		
		presentationTextLayerOutgoing.string = [[NSAttributedString alloc] initWithString: [self presentationText] attributes:presenterSlideTextAttrs];
		presentationTextLayerOutgoing.opacity = 1.0;
		
		presentationText = newPresentationText;
		
		presentationTextLayer.opacity = 0.0;
		presentationTextLayer.string = [[NSAttributedString alloc] initWithString: newPresentationText attributes:presenterSlideTextAttrs];
		
		// Resize the height of the layer ... not being done automatically with wrapping
		presentationTextLayer.frame = CGRectMake(0, 0, [self layer].frame.size.width, heightForStringDrawingPresenter([presentationTextLayer string], [self layer].frame.size.width));
		presentationTextLayerOutgoing.frame = CGRectMake(0, 0, [self layer].frame.size.width, heightForStringDrawingPresenter([presentationTextLayer string], [self layer].frame.size.width));
		
		[CATransaction commit];
		
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:transitionTime] forKey:kCATransactionAnimationDuration];
		
		presentationTextLayerOutgoing.opacity = 0.0;
		presentationTextLayer.opacity = 1.0;
		
		[CATransaction commit];
		
		/*if (renderCCLI && ![presentationText isEqualToString:nil] && ![presentationText isEqualToString:@" "]) {
			NSString *ccliSongTitle = [[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"Song Title"];
			NSString *ccliArtist = [[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Artist"];
			NSString *ccliCopyrightYear = [[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Copyright Year"];
			NSString *ccliCopyrightPublisher = [[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI Publisher"];
			NSString *ccliLicense = [[[NSDocumentController sharedDocumentController] currentDocument] songDetailsWithKey: @"CCLI License"];
			
			[CATransaction begin];
			[CATransaction setValue:[NSNumber numberWithFloat:0.0f] forKey:kCATransactionAnimationDuration];
			
			if (ccliSongTitle)
				ccliLayerTextMain.string = [ccliLayerTextMain.string stringByAppendingString: [NSString stringWithFormat:@"\"%@\"", ccliSongTitle]];
			
			if (ccliArtist)
				ccliLayerTextMain.string = [ccliLayerTextMain.string stringByAppendingString: [NSString stringWithFormat:@" words and music by %@.", ccliArtist]];
			
			if (ccliCopyrightYear || ccliCopyrightPublisher)
				ccliLayerTextMain.string = [ccliLayerTextMain.string stringByAppendingString: @" © "];
			
			if (ccliCopyrightYear)
				ccliLayerTextMain.string = [ccliLayerTextMain.string stringByAppendingString: [NSString stringWithFormat:@"%@ ", ccliCopyrightYear]];
			
			if (ccliCopyrightPublisher)
				ccliLayerTextMain.string = [ccliLayerTextMain.string stringByAppendingString: [NSString stringWithFormat:@"%@.", ccliCopyrightPublisher]];
			
			ccliLayerTextMain.string = [ccliLayerTextMain.string stringByAppendingString: [NSString stringWithFormat: @" Lyrics used by permission. CCLI license #%@", ccliLicense]];
			
			[CATransaction commit];
			
			[CATransaction setValue:[NSNumber numberWithFloat:transitionTime] forKey:kCATransactionAnimationDuration];
			
			ccliLayerTextMain.opacity = 1.0;
			ccliLayer.opacity = 0.6;
			
			[CATransaction commit];
		} else if (ccliLayer.opacity = 0.6) {
			[CATransaction setValue:[NSNumber numberWithFloat:transitionTime] forKey:kCATransactionAnimationDuration];
			
			ccliLayerTextMain.opacity = 0.0;
			ccliLayer.opacity = 0.0;
			
			[CATransaction commit];
		}*/
	}
}

/*- (void)setVideoFile:(QTMovie *)video
{
	SetMoviePlayHints([video quickTimeMovie], hintsHighQuality, hintsHighQuality);
	[video gotoBeginning];
	MoviesTask([video quickTimeMovie], 0);
	
	if ([presentationVideoLayer.movie rate] > 0.0f) {
		presentationVideoFile2 = video;
		presentationVideoLayer2.movie = presentationVideoFile2;
		
		if ([presentationVideoLayer2.movie rate] < 1.0f)
			[presentationVideoLayer2.movie play];
		
		pvl_release = 1.0;
		
		pvl1_opacity = 0.0;
		pvl2_opacity = 1.0;
	} else {
		presentationVideoFile = video;
		presentationVideoLayer.movie = presentationVideoFile;
	
		if ([presentationVideoLayer.movie rate] < 1.0f)
			[presentationVideoLayer.movie play];
		
		pvl_release = 2.0;
		
		pvl1_opacity = 1.0;
		pvl2_opacity = 0.0;
	}
	
	if (video == nil) {
		pvl1_opacity = 0.0;
		pvl2_opacity = 0.0;
	}
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:1.0] forKey:kCATransactionAnimationDuration];
	
	presentationVideoLayer.opacity = pvl1_opacity;
	presentationVideoLayer2.opacity = pvl2_opacity;
	
	[CATransaction commit];
	
	[self performSelector: @selector(releaseVideo) withObject: nil afterDelay: 1.0];
}

- (void)releaseVideo
{
	if (pvl_release == 1.0 && [presentationVideoLayer.movie rate] > 0.0f) {
		[presentationVideoLayer.movie stop];
		[presentationVideoLayer.movie release];
	} if (pvl_release == 2.0 && [presentationVideoLayer2.movie rate] > 0.0f) {
		[presentationVideoLayer2.movie stop];
		[presentationVideoLayer2.movie release];
	}
}*/

/*- (void)crossFadeSlides:(NSTimer *)timer
{

	// 50 secTrack == 1 elapsed second	
	//secTrack += 1;
	
	//if (secTrack >= transitionTime*24) { [timer invalidate]; }
	//
	//presentationTextAlpha += (1/transitionTime)*0.06;
	//outgoingPresentationTextAlpha -= (1/transitionTime)*0.06;
	
	if (presentationTextAlpha < 1.0) {
		presentationTextAlpha += (1/(transitionTime*10));
		outgoingPresentationTextAlpha -= (1/(transitionTime*10));
	} else {
		[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] updateLyricPreview];
		[timer invalidate];
	}
	
	//if (secTrack >= transitionTime*12) { [timer invalidate]; }
	
	//presentationTextAlpha += (1/transitionTime)*0.12;
	//outgoingPresentationTextAlpha -= (1/transitionTime)*0.12;
	
	[self setNeedsDisplay: YES];
}*/


- (void)setAlignment:(unsigned)alignment
{
	// Left aligned
	if (alignment == 0) {
		presentationTextLayer.alignmentMode = kCAAlignmentLeft;
		presentationTextLayerOutgoing.alignmentMode = kCAAlignmentLeft;
	}
	
	// Center aligned
	if (alignment == 2) {
		presentationTextLayer.alignmentMode = kCAAlignmentCenter;
		presentationTextLayerOutgoing.alignmentMode = kCAAlignmentCenter;
	}
	
	// Right aligned
	if (alignment == 1) {
		presentationTextLayer.alignmentMode = kCAAlignmentRight;
		presentationTextLayerOutgoing.alignmentMode = kCAAlignmentRight;
	}
	
	[[self layer] setNeedsLayout];
}

- (void)setStrokeWeight:(int)strokeWeight
{
	stroke = [NSNumber numberWithInt: strokeWeight];
	
	[self setNeedsDisplay: YES];
}


- (void)setLayout:(int)layout
{
	//presenterSlideLayout = layout;
	presentationTextLayer.constraints = nil;
	presentationTextLayerOutgoing.constraints = nil;
	
	if (layout==2) { // Bottom slide layout
		[presentationTextLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
		[presentationTextLayerOutgoing addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY  relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
	} else if (layout==0) { // Top slide layout
		[presentationTextLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY]];
		[presentationTextLayerOutgoing addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY]];
	} else { // Centered slide layout
		[presentationTextLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:@"superlayer" attribute:kCAConstraintMidY]];
		[presentationTextLayerOutgoing addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:@"superlayer" attribute:kCAConstraintMidY]];
	}
	
	[[self layer] setNeedsLayout];
}

- (void)setTransitionSpeed:(float)speed
{
	NSLog(@"SET TRANSITION SPEED: %f", speed);
	transitionTime = speed;
}

- (void)setFontSize:(int)size
{
	NSLog(@"SET FONT SIZE: %i", size);
	presentationFontSize = size;
	
	[self setNeedsDisplay: YES];
}

- (void)setFontFamily:(NSString *)font
{
	NSLog(@"Presenter: setFontFamily %@", font);
	presentationFontFamily = font;
	
	[self setNeedsDisplay: YES];
}

- (void)setTextColour:(NSColor *)textColor
{
	presentationTextColour = textColor;
	
	[self setNeedsDisplay: YES];
}

- (void)setTextBorderColour:(NSColor *)borderColor
{
	presentationTextBorderColour = borderColor;
	
	[self setNeedsDisplay: YES];
}

- (void)setTextKnocksOutBorder:(int)textKnockout
{
	textKnocksOutStroke = [NSNumber numberWithInt: textKnockout];
	
	[self setNeedsDisplay: YES];
}

- (NSString *)presentationText
{
    return presentationText;
}

- (float)presentationTextAlpha
{
    return presentationTextAlpha;
}

- (NSString *)outgoingPresentationText
{
    return outgoingPresentationText;
}

- (float)outgoingPresentationTextAlpha
{
    return presentationTextAlpha;
}

- (NSDictionary *)presenterSlideTextAttrs
{
    return presenterSlideTextAttrs;
}

- (NSDictionary *)outgoingPresenterSlideTextAttrs
{
    return outgoingPresenterSlideTextAttrs;
}

- (NSSize)presentationWindowSize
{
	return NSMakeSize([self frame].size.width, [self frame].size.height);
}

@end
