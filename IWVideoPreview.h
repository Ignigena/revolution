//
//  IWVideoPreview.h
//  iWorship
//
//  Created by Albert Martin on 1/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IWVideoPreview : NSView {
	float timeCode;
	BOOL showSliderFill;
	NSImage *lyricPreview;
	NSImage *mediaPreview;
	NSImage *playPauseButton;
}

- (void)refresh;
- (void)setTimeCode:(float)timeCode;
- (void)updateLyricPreview;
- (void)setVideoPreview:(NSString *)previewImagePath;

@end
