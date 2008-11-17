#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TimeCodeOverlay.h"

@interface IWVideoView : NSOpenGLView
{
    // view related
    NSRecursiveLock		*lock;			    // thread lock to protect the OpenGL rendering from multiple threads
    id					delegate;

    // movie and visual context
    QTMovie				*qtMovie;           // the movie in its QTKit representation
    QTTime				movieDuration;      // cached duration of the movie - just for convenience
    QTVisualContextRef  qtVisualContext;	// the context the movie is playing in
    CVImageBufferRef	currentFrame;		// the current frame from the movie
	
	QTMovie				*qtMovieL2;           // the movie in its QTKit representation
    QTTime				movieDurationL2;      // cached duration of the movie - just for convenience
    QTVisualContextRef  qtVisualContextL2;	// the context the movie is playing in
    CVImageBufferRef	currentFrameL2;		// the current frame from the movie
    
    // display link
    CVDisplayLinkRef	displayLink;		// the displayLink that runs the show
    CGDirectDisplayID	viewDisplayID;
    
    // color space
    CGColorSpaceRef     displayColorSpace;

    // filters for CI rendering
    CIFilter			*colorCorrectionFilter;	// hue saturation brightness control through one CI filter
    CIFilter			*effectFilter;		    // zoom blur filter
    CIFilter			*compositeFilter;	    // composites the timecode over the video
	CIFilter			*transitionFilter;
    CIContext			*ciContext;
	
	CIImage *sharedImage;
	
	// transition
	float mediaTransition;
	NSTimer *crossFadeTimer;
    
    // timecode overlay
    TimeCodeOverlay     *timeCodeOverlay;    
    
    // for movie export
    BOOL				isExporting;
    BOOL				cancelExport;
    char				*contextPixels;             // readback buffer for the compression
    char				*flippedContextPixels;	    // another buffer to flip the pixels as we read from the screen
    UInt32				contextRowBytes;
    int					outputWidth;
    int					outputHeight;
    int					outputAlignment;
    ImageDescriptionHandle outputImageDescription;	    // describes our compression
	
	float transitionCompletion;
}

- (void)updateColorProfile:(CGDirectDisplayID)did;
- (void)setQTMovie:(QTMovie*)inMovie;

- (IBAction)setMovieTime:(id)sender;
- (IBAction)nextFrame:(id)sender;
- (IBAction)prevFrame:(id)sender;
- (IBAction)scrub:(id)sender;

- (IBAction)togglePlay:(id)sender;
- (IBAction)stopMovie:(id)sender;

- (IBAction)setFilterParameter:(id)sender;

- (void)updateCurrentFrame;
- (void)renderCurrentFrame;

- (void)setTransitionCompletion:(float)newTransitionCompletion;

- (QTTime)movieDuration;
- (QTTime)currentTime;
- (void)setTime:(QTTime)inTime;
- (CGDirectDisplayID)viewDisplayID;

- (QTMovie *)qtMovie;
- (BOOL)playbackStatus;

@end