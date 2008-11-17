//
//  PresentationBackgroundMedia.m
//  iWorship
//
//  Created by Albert Martin on 3/1/07.
//  Copyright 2007 Renovatio Software. All rights reserved.
//

#import "PresentationBackgroundMedia.h"

@implementation PresentationBackgroundMedia

- (void) awakeFromNib {
	moviePreview = [[QTMovie alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"juicetester" ofType:@"mov"] error:NULL];
	movieActual = [[QTMovie alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"juicetester" ofType:@"mov"] error:NULL];
	
	[moviePreview setAttribute:[NSNumber numberWithBool:YES] forKey:@"QTMovieLoopsAttribute"];
	[movieActual setAttribute:[NSNumber numberWithBool:YES] forKey:@"QTMovieLoopsAttribute"];
	
	[moviePreview setMuted: YES];
	[movieActual setMuted: YES];
	
	NSScreen* secondaryDisplay = [[NSScreen screens] objectAtIndex:1]; 
	NSRect screenArea = [secondaryDisplay frame];
	backgroundMedia = [[QTMovieView alloc] initWithFrame:screenArea];
	[backgroundMedia setControllerVisible: NO];
	[backgroundMedia setFillColor: [NSColor blackColor]];
	
	// Set up the presenter window
	presentationBackgroundWindow = [[NSWindow alloc] initWithContentRect:screenArea styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];;
	[presentationBackgroundWindow setLevel:NSScreenSaverWindowLevel+1];
	[presentationBackgroundWindow setOpaque:NO];
	[presentationBackgroundWindow setBackgroundColor:[NSColor clearColor]];
		
	[presentationBackgroundWindow setContentView: backgroundMedia];
		
	// Display the presenter window
	[presentationBackgroundWindow orderFront:nil];
	
	[BackgroundPlayer setMovie: moviePreview];
	[moviePreview play];
}

- (IBAction) toggleVideoLoop:(id)sender {
	if ([moviePreview attributeForKey:@"QTMovieLoopsAttribute"]==[NSNumber numberWithBool:YES]) {
		[moviePreview setAttribute:[NSNumber numberWithBool:NO] forKey:@"QTMovieLoopsAttribute"];
		[movieActual setAttribute:[NSNumber numberWithBool:NO] forKey:@"QTMovieLoopsAttribute"];
	} else {
		[moviePreview setAttribute:[NSNumber numberWithBool:YES] forKey:@"QTMovieLoopsAttribute"];
		[movieActual setAttribute:[NSNumber numberWithBool:YES] forKey:@"QTMovieLoopsAttribute"];
	}
}

- (IBAction) toggleVideoLive:(id)sender
{
	if ([backgroundMedia movie]) {
		[movieActual stop];
		[backgroundMedia setMovie: nil];
	} else {
		[backgroundMedia setMovie: movieActual];
		
		if ([movieActual rate]==0.0) {
			[moviePreview play];
			[movieActual play];
		}
	}
}

- (void)killAll
{
	[moviePreview stop];
	[movieActual stop];
	
	[moviePreview release];
	[movieActual release];
}

@end
