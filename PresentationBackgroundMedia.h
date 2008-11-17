//
//  PresentationBackgroundMedia.h
//  iWorship
//
//  Created by Albert Martin on 3/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTMovie.h>
#import <QTKit/QTMovieView.h>

#import "IWSlideViewer.h"
#import "Presenter.h"

@interface PresentationBackgroundMedia : NSObject {
	QTMovie *moviePreview;
	QTMovie *movieActual;
	
	QTMovieView *backgroundMedia;
	NSWindow *presentationBackgroundWindow;
	
	IBOutlet id BackgroundPlayer;
	IBOutlet id SlideController;
}

- (IBAction) toggleVideoLoop:(id)sender;
- (IBAction) toggleVideoLive:(id)sender;

- (void) killAll;

@end
