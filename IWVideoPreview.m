//
//  IWVideoPreview.m
//  iWorship
//
//  Created by Albert Martin on 1/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IWVideoPreview.h"
#import "Controller.h"

@implementation IWVideoPreview

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		playPauseButton = [NSImage imageNamed:@"PreviewPlay"];
		
		//[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)refresh {
	[self display];
}

- (void)drawRect:(NSRect)rect {
	/*if (![self inLiveResize]) {
		CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, [[[[NSApp delegate] mainPresenterViewConnect] window] windowNumber], kCGWindowImageBoundsIgnoreFraming);
		NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage: windowImage];
		
		NSImage *image = [[NSImage alloc] init];
		[image addRepresentation:bitmapRep];
		[image drawInRect: [self frame] fromRect: NSMakeRect(0, 0, [image size].width, [image size].height) operation: NSCompositeSourceOver fraction: 1.0];
		
		CGImageRelease(windowImage);
		[bitmapRep release];
		[image release];
	}*/
	
	/*float timelineProgress = 258.0 * timeCode;
	//NSLog(@"%f - %f", timelineProgress, timeCode);
	
	timelineProgress = [[NSString stringWithFormat:@"%0.0f", timelineProgress] floatValue];

	[[NSColor colorWithDeviceWhite:0.4 alpha:1.0] set];
	[NSBezierPath fillRect: NSMakeRect(0, 0, 288, 18)];

	NSImage *timeSlider = [NSImage imageNamed:@"TimeSlider"];
    [timeSlider drawInRect: NSMakeRect(25, 5, 258, 8) fromRect: NSMakeRect(0, 0, 258, 8) operation: NSCompositeSourceOver fraction: 1.0];
	
	if (showSliderFill) {
		NSImage *timeSliderFill = [NSImage imageNamed:@"TimeSliderFill"];
		[timeSliderFill drawInRect: NSMakeRect(25, 5, timelineProgress, 8) fromRect: NSMakeRect(0, 0, timelineProgress, 8) operation: NSCompositeSourceOver fraction: 1.0];
	}
	
	if ([[NSApp delegate] isJuicePlaying]) {
		playPauseButton = [NSImage imageNamed:@"PreviewPause"];
	} else {
		playPauseButton = [NSImage imageNamed:@"PreviewPlay"];
	}
	
	[playPauseButton drawInRect: NSMakeRect(9, 4, 8, 10) fromRect: NSMakeRect(0, 0, 8, 10) operation: NSCompositeSourceOver fraction: 1.0];
	*/
	//[mediaPreview drawInRect: NSMakeRect(0, 18, [self bounds].size.width, [self bounds].size.height-18) fromRect: NSMakeRect(0, 0, [mediaPreview size].width, [mediaPreview size].height) operation: NSCompositeSourceOver fraction: 1.0];
	//[lyricPreview drawInRect: NSMakeRect(0, 18, [self bounds].size.width, [self bounds].size.height-18) fromRect: NSMakeRect(0, 0, [lyricPreview size].width, [lyricPreview size].height) operation: NSCompositeSourceOver fraction: 1.0];
}

- (void)setTimeCode:(float)newTimeCode
{
	timeCode = newTimeCode;
	[self setNeedsDisplay: YES];
}

- (void)setUpdateTimeCode:(BOOL)updateTimeCode
{
	showSliderFill = updateTimeCode;
	[self setNeedsDisplay: YES];
}

- (void)updateLyricPreview
{
	lyricPreview = [[NSImage alloc] initWithData: [[[NSApp delegate] mainPresenterViewConnect] dataWithPDFInsideRect: [[[NSApp delegate] mainPresenterViewConnect] bounds]]];
	[self setNeedsDisplay: YES];
}

- (void)setVideoPreview:(NSString *)previewImagePath
{
	if (![previewImagePath isEqualToString:@""]) {
		NSArray *previewPathSplitter = [[NSArray alloc] initWithArray: [previewImagePath componentsSeparatedByString:@"/"]];
		NSArray *movieNameSplitter = [[NSArray alloc] initWithArray: [[previewPathSplitter objectAtIndex: [previewPathSplitter count]-1] componentsSeparatedByString:@"."]];
		mediaPreview = [[NSImage alloc] initWithContentsOfFile: [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/Thumbnails/%@-PREVIEW.tiff", [movieNameSplitter objectAtIndex: 0]] stringByExpandingTildeInPath]];
		playPauseButton = [NSImage imageNamed:@"PreviewPause"];
	} else {
		mediaPreview = [[NSImage alloc] initWithSize: NSMakeSize(1, 1)];
	}
	
	[self setNeedsDisplay: YES];
}

- (void) mouseDown:(NSEvent *)theEvent
{
	// If we click on the play/pause button and there is a timecode
	if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], NSMakeRect(9, 4, 8, 10)) && timeCode > 0.0) {
		NSLog(@"play/pause trigger");
		[[NSApp delegate] playPauseToggle];
			
		[self setNeedsDisplay: YES];
	}
}

@end
