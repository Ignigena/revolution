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
		stroke = @-6;
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
			[standardUserDefaults setObject:[NSArchiver archivedDataWithRootObject:@1] forKey:@"Text Knocks Out Stroke"];
			[standardUserDefaults synchronize];
			textKnocksOutStroke = @1;
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
		[CATransaction setValue:@0.0f forKey:kCATransactionAnimationDuration];
		
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
		[CATransaction setValue:@(transitionTime) forKey:kCATransactionAnimationDuration];
		
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
	stroke = @(strokeWeight);
	
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
	textKnocksOutStroke = @(textKnockout);
	
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
