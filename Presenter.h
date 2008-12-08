//
//  Presenter.h
//  ProWorship
//
//  Created by Albert Martin on 1/3/07.
//  Copyright 2007-2008 Renovatio Software. All rights reserved.
//
//  The parent view containing all layers comprising the presentation screen.
//  Transitioning to CALayers so that everything is all contained in this view for ultimate portability.
//

#import <QuartzCore/CoreAnimation.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <QTKit/QTKit.h>

@interface Presenter : NSView {
	CALayer *presentationTextLayer;
	CALayer *presentationTextLayerOutgoing;
	QTCaptureLayer *liveCameraView;
	CALayer *ccliLayer;
	CATextLayer *ccliLayerTextMain;
	CATextLayer *unregisteredOverlayText;
	
	CALayer *videoLayer;
	
	/*QTMovie *presentationVideoFile;
	QTMovieLayer *presentationVideoLayer;
	QTMovie *presentationVideoFile2;
	QTMovieLayer *presentationVideoLayer2;*/
	
	int secTrack;
	float transitionTime;
	
	// CCLI rendering
	BOOL renderCCLI;
	NSRect maskingRectCCLI;
	float radius;
	NSRect roundRect;
	NSBezierPath *bgPath;
	NSMutableDictionary *ccliMainTextAttributes;
	NSMutableDictionary *ccliUBPTextAttributes;
	
	NSTimer *crossFadeTimer;
	
	NSString *presentationText;
	float presentationTextAlpha;
	NSString *outgoingPresentationText;
	float outgoingPresentationTextAlpha;
	
	NSNumber *stroke;
	NSNumber *textKnocksOutStroke;
	int presentationFontSize;
	NSString *presentationFontFamily;
	NSColor *presentationTextColour;
	NSColor *presentationTextBorderColour;
	
	NSMutableParagraphStyle *presenterSlideTextPara;
	NSMutableDictionary *genericPresenterSlideTextAttrs;
	NSMutableDictionary *presenterSlideTextAttrs;
	NSMutableDictionary *outgoingPresenterSlideTextAttrs;
	
	NSView *currentSlideView;
	NSView *outgoingSlideView;
	
	int presenterSlideLayout;
	int presenterSlideAlignment;
	
	float pvl1_opacity, pvl2_opacity, pvl_release;
	
	NSAnimation *crossFadeAnimation;
}

- (QTCaptureLayer *)liveCameraView;

- (void)setPresentationText:(NSString *)newPresentationText;

- (void)setRenderCCLI:(BOOL)renderCCLIYesNo;

- (CGImageRef)drawPresentationText;

//- (void)releaseVideo;

- (NSDictionary *)presenterSlideTextAttrs;
- (NSDictionary *)outgoingPresenterSlideTextAttrs;
- (NSString *)presentationText;
- (NSString *)outgoingPresentationText;
- (float)presentationTextAlpha;
- (float)outgoingPresentationTextAlpha;

- (void)setAlignment:(unsigned)alignment;
- (void)setLayout:(int)layout;
- (void)setTransitionSpeed:(float)speed;
- (void)setStrokeWeight:(int)strokeWeight;
- (void)setFontSize:(int)size;
- (void)setFontFamily:(NSString *)font;
- (void)setTextColour:(NSColor *)textColor;
- (void)setTextBorderColour:(NSColor *)borderColor;
- (void)setTextKnocksOutBorder:(int)textKnockout;

- (NSSize)presentationWindowSize;

- (NSString *)presentationFontFamily;
- (int)presentationFontSize;
- (int)presenterSlideLayout;
- (int)presenterSlideAlignment;

@end
