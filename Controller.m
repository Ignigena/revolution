#import <QTKit/QTMovie.h>

#import "MyDocument.h"
#import "Controller.h"
#import "MediaThumbnailBrowser.h"
#import "PreferencesController.h"
#import "NSImage+QuickLook.h"

@implementation Controller

static NSString *pathMovies = @"~/Movies/Revolution/";
static NSString *pathPictures = @"~/Pictures/Revolution/";
static NSString *thumbnailsPathMovies = @"~/Library/Application Support/Revolution/Thumbnails/Movies/";
static NSString *thumbnailsPathPictures = @"~/Library/Application Support/Revolution/Thumbnails/Pictures/";

-(void)awakeFromNib
{
	// Setup presentation windows if more than one screen is present.
	if ([[NSScreen screens] count] > 1) {
		NSRect screenArea = [[NSScreen screens][1] frame];
		presentationWindow = [[NSWindow alloc] initWithContentRect:screenArea styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];

		mainPresenterView = [[Presenter alloc] initWithFrame: screenArea];

		// Initialize the window containing the text layer.
		[presentationWindow setLevel:NSScreenSaverWindowLevel+4];
		[presentationWindow setOpaque:NO];
		[presentationWindow setBackgroundColor:[NSColor clearColor]];
		[presentationWindow setContentView: mainPresenterView];
		[presentationWindow orderFront:nil];

		incomingOnTop = NO;
		mediaWindowAlpha = 1.0;
    }

	[networkNodeContent setFrameOrigin: NSMakePoint(660, 25)];

	// Open up the splash screen window.
	[splasher center];
	[splasher makeKeyAndOrderFront: nil];
    
    // If there isn't a second screen attached, let the user know.
    if ([[NSScreen screens] count] < 2) {
        NSBeginAlertSheet(@"Secondary Monitor Required", @"OK", nil, nil, splasher, self, NULL, NULL, nil, @"ProWorship requires a secondary monitor, or projector connected to your graphics card, in order to present lyrics.  Without a secondary monitor, you will only be able to manage your library and playlist.");
    }

	// Setup thumbnails for the media browser.
	[self runThumbnailSetup];
}

- (void)runThumbnailSetup
{
	NSString *currentPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	unsigned index;
	
	if (![fileManager fileExistsAtPath: [thumbnailsPathMovies stringByExpandingTildeInPath]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[thumbnailsPathMovies stringByExpandingTildeInPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath: [thumbnailsPathPictures stringByExpandingTildeInPath]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[thumbnailsPathPictures stringByExpandingTildeInPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
	// Build all the thumbnails for movies in the users Movies directory
	NSMutableArray *moviesListing = [NSMutableArray arrayWithArray: [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[pathMovies stringByExpandingTildeInPath] error:nil]];
	NSMutableArray *moviesPathListing = [NSMutableArray arrayWithCapacity: [moviesListing count]];
	
	if ([moviesListing count] >= 1) {
		for (index = 0; index <= [moviesListing count]-1; index++) {
			currentPath = [NSString stringWithFormat: @"%@%@", pathMovies, moviesListing[index]];
			NSString *movieType = [[currentPath pathExtension] lowercaseString];
			
			if ([movieType isEqualToString: @"mov"] || [movieType isEqualToString: @"avi"] || [movieType isEqualToString: @"mpg"] || [movieType isEqualToString: @"mpeg"] || [movieType isEqualToString: @"mp4"] || [movieType isEqualToString: @"qtz"]) {
				if (![[NSFileManager defaultManager] fileExistsAtPath: [[NSString stringWithFormat: @"%@%@.tiff", thumbnailsPathMovies, [moviesListing[index] stringByDeletingPathExtension]] stringByExpandingTildeInPath]]) {
					[[[NSImage imageWithPreviewOfFileAtPath:[currentPath stringByExpandingTildeInPath] ofSize:NSMakeSize(70, 70) asIcon:YES] TIFFRepresentation]
					 writeToFile: [[NSString stringWithFormat: @"%@%@.tiff", thumbnailsPathMovies, [moviesListing[index] stringByDeletingPathExtension]] stringByExpandingTildeInPath] atomically:YES];
					[[[NSImage imageWithPreviewOfFileAtPath:[currentPath stringByExpandingTildeInPath] ofSize:NSMakeSize(288, 163) asIcon:NO] TIFFRepresentation]
					 writeToFile: [[NSString stringWithFormat: @"~/Library/Application Support/Revolution/Thumbnails/%@-PREVIEW.tiff", [moviesListing[index] stringByDeletingPathExtension]] stringByExpandingTildeInPath] atomically:YES];
				}
				
				[moviesPathListing addObject: currentPath];
			}
		}
	}
	
	moviesMediaListing = [NSArray arrayWithArray: moviesPathListing];
	
	// Build all the thumbnails for pictures in the users Pictures directory
	NSMutableArray *picturesListing = [NSMutableArray arrayWithArray: [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[pathPictures stringByExpandingTildeInPath] error:nil]];
	NSMutableArray *picturesPathListing = [NSMutableArray arrayWithCapacity: [picturesListing count]];
	
	if ([picturesListing count] >= 1) {
		for (index = 0; index <= [picturesListing count]-1; index++) {
			currentPath = [NSString stringWithFormat: @"%@%@", pathPictures, picturesListing[index]];
			NSString *pictureType = [[currentPath pathExtension] lowercaseString];
			
			if ([pictureType isEqualToString: @"tiff"] || [pictureType isEqualToString: @"tif"] || [pictureType isEqualToString: @"jpg"] || [pictureType isEqualToString: @"jpeg"] || [pictureType isEqualToString: @"png"]) {
				if (![[NSFileManager defaultManager] fileExistsAtPath: [[NSString stringWithFormat: @"%@%@.tiff", thumbnailsPathPictures, [picturesListing[index] stringByDeletingPathExtension]] stringByExpandingTildeInPath]]) {
					[[[NSImage imageWithPreviewOfFileAtPath:[currentPath stringByExpandingTildeInPath] ofSize:NSMakeSize(70, 70) asIcon:YES] TIFFRepresentation]
					 writeToFile: [[NSString stringWithFormat: @"%@%@.tiff", thumbnailsPathMovies, [picturesListing[index] stringByDeletingPathExtension]] stringByExpandingTildeInPath] atomically:YES];
					[[[NSImage imageWithPreviewOfFileAtPath:[currentPath stringByExpandingTildeInPath] ofSize:NSMakeSize(288, 163) asIcon:NO] TIFFRepresentation]
					 writeToFile: [[NSString stringWithFormat: @"~/Library/Application Support/Revolution/Thumbnails/%@-PREVIEW.tiff", [picturesListing[index] stringByDeletingPathExtension]] stringByExpandingTildeInPath] atomically:YES];
				}
				
				[picturesPathListing addObject: currentPath];
			}
		}
	}
	
	picturesMediaListing = [NSArray arrayWithArray: picturesPathListing];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

- (IBAction)newPlaylist:(id)sender
{
	[[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:nil];
}

- (IBAction)loadRecent:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL URLWithString: [defaults objectForKey:@"LastOpenedDocument"]] display:YES error:nil];
}

//////////////////////////////////////////////////
// Data source for picture and video thumbnails //
//////////////////////////////////////////////////

- (NSArray *)moviesMediaListing
{
	return moviesMediaListing;
}

- (NSArray *)picturesMediaListing
{
	return picturesMediaListing;
}

//////////////////////////////////////////
// Generic presenter window controllers //
//////////////////////////////////////////

- (Presenter *)mainPresenterViewConnect
{
	return mainPresenterView;
}

- (IBAction)presentationGoToBlack:(id)sender
{
	// Fade out any text on the display
	[[self mainPresenterViewConnect] setPresentationText: @" "];
	[[(MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] setClickedSlideAtIndex: -1];
	
	// Remove any photo/video backdrop
	[self juiceGoToBlack: self];
}

- (IBAction)presentationVideoGoToBlack:(id)sender
{
	// Remove any photo/video backdrop
	[self juiceGoToBlack: self];
}

- (IBAction)presentationTextGoToBlack:(id)sender
{
	// Fade out any text on the display
	[[self mainPresenterViewConnect] setPresentationText: @" "];
	[[(MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] setClickedSlideAtIndex: -1];
}

//////////////////////////////////
// Background media controllers //
//////////////////////////////////

- (IBAction)juiceGoToBlack:(id)sender
{
	[self presentJuice: @""];
	[[(MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument] thumbnailScroller] removeFocus: self];
	
	// Turn off the live camera view
	[qcPresentationBackground setValue:@NO forInputKey:@"LiveEnable"];
}

- (void)presentJuice:(NSString *)path
{
    /*[videoPlaybackGLWindow setLevel:NSScreenSaverWindowLevel+2];
	
	if ([[[[NSDocumentController sharedDocumentController] currentDocument] loopingToggle] state] == NSOnState)
		looping = NO;
	else
		looping = YES;
						
	if ([path isEqualToString:@""]) {
		//NSLog(@"GO TO BLACK");
		//[masterMovie stop];
		//killTimer = YES;
		willGoToBlack = YES;
		
		// Give the preview display an empty movie object to go to black
		if (incomingOnTop) {
			NSLog(@"putting movie in videoPlaybackGLView");
			[videoPlaybackGLView setQTMovie: [QTMovie movie]];
			[videoPlaybackGLView togglePlay: self];
			incomingOnTop = NO;
		} else {
			NSLog(@"putting movie in videoPlaybackGLIncomingView");
			[videoPlaybackGLIncomingView setQTMovie: [QTMovie movie]];
			[videoPlaybackGLIncomingView togglePlay: self];
			incomingOnTop = YES;
		}
		
		crossFadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(crossFadeMedia:) userInfo:nil repeats:YES];
	} else {
		willGoToBlack = NO;
		
		NSMutableDictionary *qtMovieAttributes = [[NSMutableDictionary alloc] initWithCapacity: 2];
		[qtMovieAttributes setObject:path forKey:QTMovieFileNameAttribute];
		[qtMovieAttributes setObject:[NSNumber numberWithBool: looping] forKey:QTMovieLoopsAttribute];
		
		//QTMovie	*qtMovie = nil;
		NSError	*error;
        
		QTMovie	*qtMovie = [QTMovie movieWithAttributes:qtMovieAttributes error:&error];
		
		if(qtMovie) {
			if (incomingOnTop) {
				[[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController] animator] setAlphaValue: 1.0];
				[[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController2] animator] setAlphaValue: 0.0];
				
				[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController] setMovie: qtMovie];
				[videoPlaybackGLView setQTMovie: qtMovie];
				[videoPlaybackGLView togglePlay: self];
				
				incomingOnTop = NO;
			} else {
				[[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController] animator] setAlphaValue: 0.0];
				[[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController2] animator] setAlphaValue: 1.0];
				
				[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController2] setMovie: qtMovie];
				[videoPlaybackGLIncomingView setQTMovie: qtMovie];
				[videoPlaybackGLIncomingView togglePlay: self];
				
				incomingOnTop = YES;
			}
			
			//if (incomingOnTop) {
			///	[[videoPlaybackGLWindow animator] setAlphaValue: 0.0];
			//} else if (!incomingOnTop) {
			//	[[videoPlaybackGLWindow animator] setAlphaValue: 1.0];
			//}
			
			crossFadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(crossFadeMedia:) userInfo:nil repeats:YES];
		}
		
		NSLog(@"GO TO JUICE: %@", path);
		
		[qcPresentationBackground setValue:[NSNumber numberWithBool:NO] forInputKey:@"LiveEnable"];
		[goLiveButton setState: NSOffState];
	}*/
}

- (void)playPauseToggle {
    /*
	if (incomingOnTop) {
		[videoPlaybackGLIncomingView togglePlay: self];
	} else {
		[videoPlaybackGLView togglePlay: self];
	}*/
}

- (BOOL)isJuicePlaying {
	/*if (incomingOnTop) {
		return [videoPlaybackGLIncomingView playbackStatus];
	}
	
	return [videoPlaybackGLView playbackStatus];*/
}

- (void)crossFadeMedia:(NSTimer *)timer
{
	//float transitionSpeedVideo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Video Transition Speed"] floatValue];
	float transitionSpeedVideo = 1.0;
	
	if (incomingOnTop && mediaWindowAlpha > 0.0) {
		NSLog(@"incomingOnTop %f", mediaWindowAlpha);
		[videoPlaybackGLWindow setAlphaValue: mediaWindowAlpha -= (1/(transitionSpeedVideo*10))];
		//[videoPlaybackGLView setTransitionCompletion: mediaWindowAlpha -= (1/(1.0*10))];
		//[videoPlaybackGLIncomingView setTransitionCompletion: mediaWindowAlpha];
		//[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] setUpdateTimeCode: NO];
	} else if (!incomingOnTop && mediaWindowAlpha < 1.0) {
		NSLog(@"!incomingOnTop %f", mediaWindowAlpha);
		[videoPlaybackGLWindow setAlphaValue: mediaWindowAlpha += (1/(transitionSpeedVideo*10))];
		//[videoPlaybackGLView setTransitionCompletion: mediaWindowAlpha += (1/(1.0*10))];
		//[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] setUpdateTimeCode: NO];
	} else {
		if ([[(MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument] thumbnailScroller] mediaType] == 0)
			//[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] setUpdateTimeCode: YES];
		
		[timer invalidate];
		
		/*if (incomingOnTop) {
			[videoPlaybackGLView setQTMovie: [QTMovie movie]];
			if (!willGoToBlack)
				[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] setVideoPreview: [[videoPlaybackGLView qtMovie] attributeForKey: @"QTMovieFileNameAttribute"]];
		} else {
			[videoPlaybackGLIncomingView setQTMovie: [QTMovie movie]];
			if (!willGoToBlack)
				[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] setVideoPreview: [[videoPlaybackGLView qtMovie] attributeForKey: @"QTMovieFileNameAttribute"]];
		}*/
			
		if (willGoToBlack) {
			NSLog(@"willGoToBlack");
			[[(MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] setTimeCode: 0.0];
			[[(MyDocument *)[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] setVideoPreview: @""];
		}
	}
}

- (IBAction)makeBackgroundLive:(NSButton *)sender
{
	if ([sender state] == NSOnState) {
		[qcPresentationBackground setValue:@YES forInputKey:@"LiveEnable"];
		[videoPlaybackGLWindow setLevel:NSScreenSaverWindowLevel-1];
		[videoPlaybackGLIncomingWindow setLevel:NSScreenSaverWindowLevel-1];
	} else {
		[qcPresentationBackground setValue:@NO forInputKey:@"LiveEnable"];
		[videoPlaybackGLWindow setLevel:NSScreenSaverWindowLevel+3];
		[videoPlaybackGLIncomingWindow setLevel:NSScreenSaverWindowLevel+2];
	}
}

- (IBAction)toggleLooping:(NSButton *)sender
{
    /*
	if ([sender state] == NSOnState) {
		looping = NO;
		if (incomingOnTop)
			[[videoPlaybackGLIncomingView qtMovie] setAttribute:[NSNumber numberWithBool: NO] forKey:QTMovieLoopsAttribute];
		else
			[[videoPlaybackGLView qtMovie] setAttribute:[NSNumber numberWithBool: NO] forKey:QTMovieLoopsAttribute];
	} else {
		looping = YES;
		if (incomingOnTop)
			[[videoPlaybackGLIncomingView qtMovie] setAttribute:[NSNumber numberWithBool: YES] forKey:QTMovieLoopsAttribute];
		else
			[[videoPlaybackGLView qtMovie] setAttribute:[NSNumber numberWithBool: YES] forKey:QTMovieLoopsAttribute];
	}*/
}

- (IBAction)toggleAudio:(id)sender
{
	/*if ([sender state] == NSOnState) {
		if (incomingOnTop)
			[[videoPlaybackGLIncomingView qtMovie] setAttribute:[NSNumber numberWithFloat: 0.0] forKey: QTMovieVolumeAttribute];
		else
			[[videoPlaybackGLView qtMovie] setAttribute:[NSNumber numberWithFloat: 0.0] forKey: QTMovieVolumeAttribute];
	} else {
		if (incomingOnTop)
			[[videoPlaybackGLIncomingView qtMovie] setAttribute:[NSNumber numberWithFloat: 1.0] forKey: QTMovieVolumeAttribute];
		else
			[[videoPlaybackGLView qtMovie] setAttribute:[NSNumber numberWithFloat: 1.0] forKey: QTMovieVolumeAttribute];
	}*/
}

////

- (NSWindow *)splasher
{
	return splasher;
}

- (IBAction)openPreferences:(id)sender
{
	[[PreferencesController sharedPreferencesController] showWindow:nil];
}

@end