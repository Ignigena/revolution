#import "IWVideoView.h"
#import "IWVideoPreview.h"
#import "VideoController.h"
#import "MyDocument.h"
#include <mach/mach_time.h>

@interface IWVideoView (private)

- (CVReturn)renderTime:(const CVTimeStamp *)timeStamp;
- (GLenum)readbackFrameIntoBuffer:(void*)buffer alignment:(int)alignment width:(int)width height:(int)height offsetX:(int)offsetX offsetY:(int)offsetY;
- (OSErr)exportFrame:(MovieExportGetDataParams *)theParams;

@end

#pragma mark--callbacks--

static CVReturn renderCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime,  CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext)
{
    return [(IWVideoView*)displayLinkContext renderTime:inOutputTime];
}

//--------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------

// Provide the output audio data.
static OSErr QTMoovProcs_VideoTrackDataProc(void *theRefcon, MovieExportGetDataParams *theParams)
{	
    return [(IWVideoView*)theRefcon exportFrame:theParams];
}



#pragma mark-
						
@implementation IWVideoView

- (BOOL)isOpaque
{
	// Background is not opaque, required for clean cross dissolves
    return NO;
}

- (void)updateCIContext
{
    [ciContext release];
    
	// Create CIContext
	ciContext = [[CIContext contextWithCGLContext:(CGLContextObj)[[self openGLContext] CGLContextObj]
                                      pixelFormat:(CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj]
                                      options:[NSDictionary dictionaryWithObjectsAndKeys:
                                              (id)displayColorSpace, kCIContextOutputColorSpace,
                                              (id)displayColorSpace, kCIContextWorkingColorSpace, nil]] retain];

}

- (void)setDisplayColorSpace:(CGColorSpaceRef)inDisplayColorSpace
{
	CGColorSpaceRetain(inDisplayColorSpace);
    CGColorSpaceRelease(displayColorSpace);
	displayColorSpace = inDisplayColorSpace;
}

- (void)updateColorProfile:(CGDirectDisplayID)did
{
	CMProfileRef profile;

	[self setDisplayColorSpace:NULL];

    if ([delegate useTrickProfile] == NSOnState) {
        CMProfileLocation loc = { cmPathBasedProfile };
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"TrickGRBProfile" ofType:@"icc"];
    
        // Copy the path the profile into the CMProfileLocation structure
        strcpy(loc.u.pathLoc.path, [path cStringUsingEncoding:NSMacOSRomanStringEncoding]);
        
        CMOpenProfile(&profile, &loc);
    
    } else {

        CMGetProfileByAVID((CMDisplayIDType)did, &profile);
    }
    
    if (NULL != profile) {

        CGColorSpaceRef theDisplayColorSpace = CGColorSpaceCreateWithPlatformColorSpace(profile);
		
        [self setDisplayColorSpace:theDisplayColorSpace];
		
        CGColorSpaceRelease(theDisplayColorSpace);
		
        CMCloseProfile(profile);
	}

	if (NULL != qtVisualContext) {
        // Update the visual context output color space - if this attribute is not set, images may be in any color space
        QTVisualContextSetAttribute(qtVisualContext, kQTVisualContextOutputColorSpaceKey, displayColorSpace);
    }

	[lock lock];
		[self updateCIContext];
	[lock unlock];
	
    [self setNeedsDisplay:YES];
}

- (void)windowChangedScreen:(NSNotification*)inNotification
{
    NSWindow *window = [inNotification object]; 
    CGDirectDisplayID displayID = (CGDirectDisplayID)[[[[window screen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
	
    if  ((displayID) && (viewDisplayID != displayID)) {
	//if  ((displayID != NULL) && (viewDisplayID != displayID)) {
    
        [self updateColorProfile:displayID];
        
        if (NULL != displayLink) {
            CVDisplayLinkSetCurrentCGDisplay(displayLink, displayID);
        }
        
        viewDisplayID = displayID;
    }
}

//--------------------------------------------------------------------------------------------------
- (void)prepareOpenGL
{
	CVReturn ret;

	lock = [[NSRecursiveLock alloc] init];
    
    // OpenGL setup
    long swapInterval = 1;
    
    // sync with screen refresh to avoid tearing
    [[self openGLContext] setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
	
	// Create CIFilters 
	colorCorrectionFilter = [[CIFilter filterWithName:@"CIColorControls"] retain];	    // Color filter	
	[colorCorrectionFilter setDefaults];                                                // set the filter to its default values
    
	transitionFilter = [[CIFilter filterWithName:@"CIDissolveTransition"] retain];	    // Transition filter	
	[transitionFilter setDefaults];
	
	effectFilter = [[CIFilter filterWithName:@"CIZoomBlur"] retain];                    // Effect filter	
	[effectFilter setDefaults];                                                         // set the filter to its default values
    [effectFilter setValue:[NSNumber numberWithFloat:0.0] forKey:@"inputAmount"];       // set inputAmount to 0 our slider default
    
	compositeFilter = [[CIFilter filterWithName:@"CISourceOverCompositing"] retain];    // Composite filter
	  	    		
	// Create display link 
	CGOpenGLDisplayMask	totalDisplayMask = 0;
	int     virtualScreen;
	long    displayMask, accelerated;
	NSOpenGLPixelFormat	*openGLPixelFormat = [self pixelFormat];
    	
	// build up list of displays from OpenGL's pixel format
	for (virtualScreen = 0; virtualScreen < [openGLPixelFormat  numberOfVirtualScreens]; virtualScreen++) {
		[openGLPixelFormat getValues:&displayMask forAttribute:NSOpenGLPFAScreenMask forVirtualScreen:virtualScreen];
        [openGLPixelFormat getValues:&accelerated forAttribute:NSOpenGLPFAAccelerated forVirtualScreen:virtualScreen];
        
        if (accelerated) {
            totalDisplayMask |= displayMask;
        }
	}
    
	ret = CVDisplayLinkCreateWithOpenGLDisplayMask(totalDisplayMask, &displayLink);
	
    // Set up display link callbacks 
	CVDisplayLinkSetOutputCallback(displayLink, renderCallback, self);
		
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowChangedScreen:) name:NSWindowDidMoveNotification object:[self window]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [qtMovie release];
	[qtMovieL2 release];
    [colorCorrectionFilter release];
    [effectFilter release];
    [compositeFilter release];
    [timeCodeOverlay release];
    
    CVOpenGLTextureRelease(currentFrame);
    
    if (qtVisualContext) QTVisualContextRelease(qtVisualContext);
    
    [ciContext release];
    
    [super dealloc];
}

- (void)update
{
    [lock lock];
        [super update];
    [lock unlock];
}

- (void)reshape
{
    NSRect frame = [self frame];
    NSRect bounds = [self bounds];
    
    GLfloat minX, minY, maxX, maxY;

    minX = NSMinX(bounds);
    minY = NSMinY(bounds);
    maxX = NSMaxX(bounds);
    maxY = NSMaxY(bounds);

    [self update]; 

    if(NSIsEmptyRect([self visibleRect])) {
        glViewport(0, 0, 1, 1);
    } else {
        glViewport(0, 0,  frame.size.width ,frame.size.height);
    }
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glOrtho(minX, maxX, minY, maxY, -1.0, 1.0);
	
    // if we are not playing, force an immediate draw otherwise it will update with the next frame 
    // coming through. This makes the resize performance better as it reduces the number of redraws
    // espcially on the main thread
    if(!CVDisplayLinkIsRunning(displayLink)){
        [self display];
    }
}

//--------------------------------------------------------------------------------------------------

- (void)drawRect:(NSRect)theRect
{
    [lock lock];
    
    [[self openGLContext] makeCurrentContext];
            
    // clean the OpenGL context - not so important here but very important when you deal with transparency
    glClearColor(0.0, 0.0, 0.0, 0.0);	     
    glClear(GL_COLOR_BUFFER_BIT);
	
	// make sure we have a frame to render    
    if(!currentFrame) [self updateCurrentFrame];
    
    // render the frame
    [self renderCurrentFrame];
    
    // flush our output to the screen - this will render with the next beamsync
    glFlush();
    
    [lock unlock];
}

- (void)setQTMovie:(QTMovie*)inMovie
{
	if (CVDisplayLinkIsRunning(displayLink)) [self togglePlay:nil];
    [inMovie retain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowDidMoveNotification object:[self window]];
	
	NSDictionary *targetDimensions =	[NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithFloat: [self frame].size.width], kQTVisualContextTargetDimensions_WidthKey, 
										[NSNumber numberWithFloat: [self frame].size.height], kQTVisualContextTargetDimensions_HeightKey, nil];
										
	NSDictionary *attributes =			[NSDictionary dictionaryWithObjectsAndKeys:
										targetDimensions,  kQTVisualContextTargetDimensionsKey,
										displayColorSpace, kQTVisualContextOutputColorSpaceKey, nil];
	
		[qtMovie release];
		
		if (NULL != currentFrame) {
			CVOpenGLTextureRelease(currentFrame);
			currentFrame = NULL;
		}
		
		qtMovie = inMovie;
		
		if (NULL == qtVisualContext) {
			OSStatus error;
			error =		QTOpenGLTextureContextCreate(kCFAllocatorDefault, (CGLContextObj)[[self openGLContext] CGLContextObj],
							(CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj],
							(CFDictionaryRef)attributes,
							&qtVisualContext);

		}
		
		if (qtMovie) {
			OSStatus error;
			NSSize movieSize;
        
			error = SetMovieVisualContext([qtMovie quickTimeMovie], qtVisualContext);
        
			SetMoviePlayHints([qtMovie quickTimeMovie], hintsHighQuality, hintsHighQuality);
        
			[[qtMovie attributeForKey: QTMovieCurrentSizeAttribute] getValue: &movieSize];
		
			[qtMovie gotoBeginning];
		
			MoviesTask([qtMovie quickTimeMovie], 0);	// QTKit is not doing this automatically
		
			movieDuration = [[[qtMovie movieAttributes] objectForKey:QTMovieDurationAttribute] QTTimeValue];
			movieSize = [[qtMovie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
		}
	
    [self setNeedsDisplay:YES];
}

//--------------------------------------------------------------------------------------------------

- (QTTime)currentTime
{
    return [qtMovie currentTime];
}

- (QTTime)currentTimeL2
{
    return [qtMovieL2 currentTime];
}

- (QTTime)movieDuration
{
    return movieDuration;
}

- (QTTime)movieDurationL2
{
    return movieDurationL2;
}

//--------------------------------------------------------------------------------------------------

- (void)setTime:(QTTime)inTime
{
    [qtMovie setCurrentTime:inTime];
	[qtMovieL2 setCurrentTime:inTime];
    if(CVDisplayLinkIsRunning(displayLink))
		[self togglePlay:nil];
    [self updateCurrentFrame];
    [self display];
}

- (CGDirectDisplayID)viewDisplayID
{
    return viewDisplayID;
}

//--------------------------------------------------------------------------------------------------

- (IBAction)setMovieTime:(id)sender
{
    [self setTime:QTTimeFromString([sender stringValue])];
}

//--------------------------------------------------------------------------------------------------

- (IBAction)nextFrame:(id)sender
{
    if(CVDisplayLinkIsRunning(displayLink))
		[self togglePlay:nil];
		
    [qtMovie stepForward];
    [self updateCurrentFrame];
    [self display];
}

//--------------------------------------------------------------------------------------------------

- (IBAction)prevFrame:(id)sender
{
    if(CVDisplayLinkIsRunning(displayLink))
		[self togglePlay:nil];
		
    [qtMovie stepBackward];
    [self updateCurrentFrame];
    [self display];
}

//--------------------------------------------------------------------------------------------------

- (IBAction)scrub:(id)sender
{
    if (CVDisplayLinkIsRunning(displayLink)) [self togglePlay:nil];

    // Get movie time, duration
    QTTime currentTime;
    NSTimeInterval sliderTime = [sender floatValue];
    //TimeValue tv;
        
    currentTime.timeValue = movieDuration.timeValue * sliderTime;
    currentTime.timeScale = movieDuration.timeScale;
    currentTime.flags = 0;
        
    [qtMovie setCurrentTime:currentTime];
    MoviesTask([qtMovie quickTimeMovie], 0);	// QTKit is not doing this automatically
     
    [self updateCurrentFrame];
    [self display];
}

#pragma mark QuickTime Controllers

- (IBAction)togglePlay:(id)sender
{
    if (CVDisplayLinkIsRunning(displayLink)) {
		CVDisplayLinkStop(displayLink);
		[qtMovie stop];
		[qtMovieL2 stop];
    } else {
		[qtMovie play];
		[qtMovieL2 play];
		CVDisplayLinkStart(displayLink);
	}
}

- (IBAction)stopMovie:(id)sender
{
	if (CVDisplayLinkIsRunning(displayLink))
		CVDisplayLinkStop(displayLink);
	
	[qtMovie stop];
}

#pragma mark -


- (IBAction)setFilterParameter:(id)sender
{
    [lock lock];
    switch([sender tag])
    {
	case 0:
	    [colorCorrectionFilter setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:@"inputContrast"];
	    break;

	case 1:
	    [colorCorrectionFilter setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:@"inputBrightness"];
	    break;

	case 2:
	    [colorCorrectionFilter setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:@"inputSaturation"];
	    break;
	    
	case 3:
	    [effectFilter setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:@"inputAmount"];
	    break;
	    
	default:
	    break;
	    
    }
    [lock unlock];
    if(!CVDisplayLinkIsRunning(displayLink))
	[self display];
}

//--------------------------------------------------------------------------------------------------

- (void)renderCurrentFrame
{
	if (currentFrame) {
        CGRect	    imageRect;
		CGRect	    imageRectL2;
		
        CIImage	    *inputImage;
		inputImage = [CIImage imageWithCVImageBuffer:currentFrame];
		
		CIImage	    *inputImageL2;
		inputImageL2 = [CIImage imageWithCVImageBuffer:currentFrameL2];

        imageRect = [inputImage extent];
		imageRectL2 = [inputImageL2 extent];
                
        //[colorCorrectionFilter setValue:inputImage forKey:@"inputImage"];
        //[effectFilter setValue:[colorCorrectionFilter valueForKey:@"outputImage"] forKey:@"inputImage"];
        //[compositeFilter setValue:[effectFilter valueForKey:@"outputImage"] forKey:@"inputBackgroundImage"];
        //[compositeFilter setValue:timecodeImage forKey:@"inputImage"];
		
		//[transitionFilter setValue:inputImageL2 forKey:@"inputImage"];
		//[transitionFilter setValue:inputImage forKey:@"inputTargetImage"];
		//[transitionFilter setValue:[NSNumber numberWithFloat:transitionCompletion] forKey:@"inputTime"];
		
		//sharedImage = [effectFilter valueForKey:@"outputImage"];
		
		[ciContext drawImage:inputImage inRect:CGRectMake(0, 0, [self frame].size.width, [self frame].size.height) fromRect:imageRect];
		
		//[self updatePreviewWindow];
    }
    
    // housekeeping on the visual context
    QTVisualContextTask(qtVisualContext);
}

- (float)transitionCompletion
{
	return transitionCompletion;
}

- (void)setTransitionCompletion:(float)newTransitionCompletion
{
	transitionCompletion = newTransitionCompletion;
	NSLog(@"%f", transitionCompletion);
}

//--------------------------------------------------------------------------------------------------

- (BOOL)getFrameForTime:(const CVTimeStamp *)timeStamp
{
    OSStatus error = noErr;
	int returnYes;

    // See if a new frame is available

    if (qtVisualContext && QTVisualContextIsNewImageAvailable(qtVisualContext, timeStamp)) {
    	    
	    CVOpenGLTextureRelease(currentFrame);
	    error = QTVisualContextCopyImageForTime(qtVisualContext, NULL, timeStamp, &currentFrame);
			    
	    // In general this shouldn't happen, but just in case...
	    if(error != noErr && !currentFrame) {
		    NSLog(@"QTVisualContextCopyImageForTime: %ld\n",error);
		    //return NO;
	    }
	    
        [delegate performSelectorOnMainThread:@selector(movieTimeChanged:) withObject:self waitUntilDone:NO];
        
		returnYes = 1;
	    //return YES;
    }
	
	if (qtVisualContextL2 && QTVisualContextIsNewImageAvailable(qtVisualContextL2, timeStamp)) {
    	    
	    CVOpenGLTextureRelease(currentFrameL2);
	    error = QTVisualContextCopyImageForTime(qtVisualContextL2, NULL, timeStamp, &currentFrameL2);
			    
	    // In general this shouldn't happen, but just in case...
	    if(error != noErr && !currentFrameL2) {
		    NSLog(@"QTVisualContextCopyImageForTime: %ld\n",error);
		    //return NO;
	    }
	    
        [delegate performSelectorOnMainThread:@selector(movieTimeChanged:) withObject:self waitUntilDone:NO];
        
		returnYes = 1;
	    //return YES;
    }
	
	if (returnYes == 1) {
		return YES;
	} else {
		return NO;
	}
}

//--------------------------------------------------------------------------------------------------

- (void)updateCurrentFrame
{
    [self getFrameForTime:nil];    
}

#pragma mark --private methods--

- (CVReturn)renderTime:(const CVTimeStamp *)timeStamp
{
    CVReturn rv = kCVReturnError;
    NSAutoreleasePool *pool;
    //CFDataRef movieTimeData;
    
    pool = [[NSAutoreleasePool alloc] init];
    
    if([self getFrameForTime:timeStamp]) {
        [self drawRect:NSZeroRect];     // refresh the whole view
        rv = kCVReturnSuccess;
    } else {
        rv = kCVReturnError;
    }
    
    [pool release];
    
    return rv;
}

- (void)updatePreviewWindow
{
	//if  (timeString) [timecodeField setStringValue:timeString];
	float timeValue =  [qtMovie currentTime].timeValue;
	float timeDuration = [qtMovie duration].timeValue;
	float timeCode = timeValue / timeDuration;
	
	//if  (timeString) NSLog(@"%0.2f - %f / %f", timeCode, timeDuration, timeValue);
	
	//NSLog(@"%f", [[NSString stringWithFormat:@"%0.2f", timeCode] floatValue]);
	
	[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewDisplay] setTimeCode: [[NSString stringWithFormat:@"%0.2f", timeCode] floatValue]];
    
    //[videoPreviewWindow setTimecode:(double)[qtMovie currentTime].timeValue duration:(double)[qtMovie movieDuration].timeValue];
}

- (QTMovie *)qtMovie
{
	return qtMovie;
}

- (BOOL)playbackStatus {
	if (CVDisplayLinkIsRunning(displayLink)) {
		return YES;
    }
	
	return NO;
}

@end