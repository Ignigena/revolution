#import <QTKit/QTMovie.h>
#import <DVDPlayback/DVDPlayback.h>

#import "MyDocument.h"
#import "Controller.h"
#import "MediaThumbnailBrowser.h"
#import "EWSLib.h"
#import "validateLib.h"
#import "PreferencesController.h"
#import "NSImage+QuickLook.h"
#import "IPAddress.h"

@interface DVDEvent : NSObject
{
	DVDEventCode mEventCode;
	UInt32 mEventData1, mEventData2;
}

- (id) initWithData:(DVDEventCode)eventCode 
	data1:(UInt32)eventData1 
	data2:(UInt32)eventData2;

- (DVDEventCode) eventCode;
- (UInt32) eventData1;
- (UInt32) eventData2;

@end

@implementation DVDEvent

- (id) initWithData: (DVDEventCode)eventCode 
	data1:(UInt32)eventData1 
	data2:(UInt32)eventData2 
{
	[super init];
	mEventCode = eventCode;
	mEventData1 = eventData1;
	mEventData2 = eventData2;
	return self;
}


- (DVDEventCode) eventCode { return mEventCode; }
- (UInt32) eventData1 { return mEventData1; }
- (UInt32) eventData2 { return mEventData2; }

@end

@interface Controller (InternalMethods)
	void MyDVDEventHandler (
		DVDEventCode inEventCode, 
		UInt32 inEventData1, 
		UInt32 inEventData2, 
		UInt32 inRefCon);
@end

@implementation Controller

@synthesize serviceList=_serviceList;

-(void)awakeFromNib
{
	// First and most importantly is check to see if there is a secondary monitor
	if ([[NSScreen screens] count] < 2) {
		NSRunCriticalAlertPanel(@"Secondary Monitor Required", @"ProWorship requires a secondary monitor, or projector connected to your graphics card, in order to present lyrics.  Without a secondary monitor, you will only be able to manage your library and playlist.", @"OK", nil, nil);
		[NSApp requestUserAttention: 0];
	}
	
	// User preferences initiation
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    NSUserDefaults *defaults;
	
	// Initiate the eSellerate framework    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaultValues setObject:@"" forKey:@"iWorshipRegistration"];
    [defaults registerDefaults: defaultValues];
    [self updateSN];
	
	NSRect screenArea = NSMakeRect(50,[[[NSScreen screens] objectAtIndex:0] frame].size.height/2,800,600);
	
	// Setup presentation windows if more than one screen is present
	if ([[NSScreen screens] count] > 1) {
		screenArea = [[[NSScreen screens] objectAtIndex:1] frame];
		presentationWindow = [[NSWindow alloc] initWithContentRect:screenArea styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	//} else {
	//	presentationWindow = [[NSWindow alloc] initWithContentRect:screenArea styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	//}
	
		mainPresenterView = [[Presenter alloc] initWithFrame: screenArea];
	
		// Initialize the window containing the text layer
		[presentationWindow setLevel:NSScreenSaverWindowLevel+4];
		[presentationWindow setOpaque:NO];
		[presentationWindow setBackgroundColor:[NSColor clearColor]];
		[presentationWindow setContentView: mainPresenterView];
		[presentationWindow orderFront:nil];
		
		// Initialize the window containing the video layer
		/*presentationBGWindow = [[NSWindow alloc] initWithContentRect:screenArea styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];;
		[presentationBGWindow setLevel:NSScreenSaverWindowLevel];
		[presentationBGWindow setOpaque:NO];
		[presentationBGWindow setBackgroundColor:[NSColor clearColor]];
		[presentationBGWindow setContentView: qcPresentationBackground];
		[presentationBGWindow orderFront:nil];*/
		
		videoPlaybackGLWindow = [[NSWindow alloc] initWithContentRect:screenArea styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];;
		[videoPlaybackGLWindow setLevel:NSScreenSaverWindowLevel+3];
		[videoPlaybackGLWindow setOpaque:NO];
		[videoPlaybackGLWindow setBackgroundColor:[NSColor blackColor]];
		[videoPlaybackGLWindow setContentView: videoPlaybackGLView];
		[videoPlaybackGLWindow orderFront:nil];
		
		[videoPlaybackGLView update];
		
		videoPlaybackGLIncomingWindow = [[NSWindow alloc] initWithContentRect:screenArea styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];;
		[videoPlaybackGLIncomingWindow setLevel:NSScreenSaverWindowLevel+2];
		[videoPlaybackGLIncomingWindow setOpaque:NO];
		[videoPlaybackGLIncomingWindow setBackgroundColor:[NSColor blackColor]];
		[videoPlaybackGLIncomingWindow setContentView: videoPlaybackGLIncomingView];
		[videoPlaybackGLIncomingWindow orderFront:nil];
		
		[videoPlaybackGLIncomingView update];
		
		incomingOnTop = NO;
		mediaWindowAlpha = 1.0;
		
		// Initialize the window containing the DVD layer
		dvdPlayerWindow = [[DVDPlayerWindow alloc] initWithContentRect:screenArea styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];;
		[dvdPlayerWindow setLevel:NSScreenSaverWindowLevel+1];
		[dvdPlayerWindow setBackgroundColor:[NSColor blackColor]];
		[dvdPlayerWindow orderFront:nil];
		
		// Setup the DVD playback and hide the window
		[self runDVDSetup];
		[dvdPlayerWindow setLevel:NSScreenSaverWindowLevel-1];
	}
	
	// Register for notifications
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(deviceDidMount:) name:NSWorkspaceDidMountNotification object:NULL];
	
	presenterShouldShowText = YES;
	presenterShouldShowVideo = YES;
	
	// Beta expiration code ... REMOVE IN FINAL RELEASE!
	/*NSDate * today = [NSDate date];
	NSDate * targetDate = [NSDate dateWithString:@"2007-12-04 00:00:00 -0500"];
	
	if (![[today laterDate:targetDate] isEqualToDate:targetDate]){
		NSRunCriticalAlertPanel(@"Beta Expired", @"This beta copy of iWorship has expired.  Please download the latest build.", nil, nil, nil);
		[NSApp requestUserAttention: 0];
		[NSApp terminate: self];
	} else {
		NSRunAlertPanel(@"Public Beta", @"This is a public beta of iWorship -- use at your own risk.  This version will expire on December 4th.", nil, nil, nil);
	}*/
	
	// Create all the necessary application support directories
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if (![manager fileExistsAtPath: [[NSString stringWithString: @"~/Library/Application Support/ProWorship/"] stringByExpandingTildeInPath]]) {
		[manager createDirectoryAtPath:[[NSString stringWithString: @"~/Library/Application Support/ProWorship/"] stringByExpandingTildeInPath] attributes: nil];
		[manager copyItemAtPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources/Song Library"] toPath: [@"~/Library/Application Support/ProWorship/Song Library" stringByExpandingTildeInPath] error:nil];
	}
	if ([manager fileExistsAtPath: [@"~/Movies/ProWorship/" stringByExpandingTildeInPath]] == NO) { [manager createDirectoryAtPath:[@"~/Movies/ProWorship/" stringByExpandingTildeInPath] attributes: nil]; }
	if ([manager fileExistsAtPath: [@"~/Pictures/ProWorship/" stringByExpandingTildeInPath]] == NO) { [manager createDirectoryAtPath:[@"~/Pictures/ProWorship/" stringByExpandingTildeInPath] attributes: nil]; }
	
	// Fill in the registration info on the splash screen
	
	if (![self registered]) {
		[serialDisplay setStringValue: @"Unregistered Demo"];
	} else {
		[serialDisplay setStringValue: [defaults objectForKey:@"iWorshipRegistrationName"]];
		[serialDisplayS setStringValue: [[defaults objectForKey:@"iWorshipRegistration"] substringWithRange:NSMakeRange(11,24)]];
	}
	
	[networkNodeContent setFrameOrigin: NSMakePoint(660, 25)];
	
	// Open up the splash screen window
	[splasher setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
	[splasher setContentBorderThickness:26.0 forEdge:NSMinYEdge];
	[splasher center];
	[splasher makeKeyAndOrderFront: nil];
	
	_serviceBrowser = [[NSNetServiceBrowser alloc] init];
    _serviceList = [[NSMutableArray alloc] init];
    [_serviceBrowser setDelegate:self];
    
    [_serviceBrowser searchForServicesOfType:@"_revolution_broadcast._tcp." inDomain:@""];
	
	_receiver_listener = [[BLIPListener alloc] initWithPort: 1776];
	_receiver_listener.delegate = self;
	_receiver_listener.pickAvailablePort = YES;
	_receiver_listener.bonjourServiceType = @"_revolution_receiver._tcp";
	
	// Setup thumbnails for the media browser
	[self runThumbnailSetup];
	
	remoteControl = [[RemoteControlContainer alloc] initWithDelegate: self];
	[remoteControl instantiateAndAddRemoteControlDeviceWithClass: [AppleRemote class]];
	[remoteControl instantiateAndAddRemoteControlDeviceWithClass: [KeyspanFrontRowControl class]];
	[remoteControl startListening: self];
	
	if (![self registered]) {
		[NSApp beginSheet:welcomeRegisterSheet modalForWindow:splasher modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
}

/*- (void)dealloc
{
	[ESDSerialNumber release];
	[remoteControl stopListening: self];
	[remoteControl release];
	[super dealloc];
}*/

/////////////////////////////////////
#pragma mark Remote Control Functions
/////////////////////////////////////

- (void)applicationWillBecomeActive:(NSNotification *)aNotification {
    NSLog(@"Application will become active - Using remote controls");
    [remoteControl startListening: self];
}
- (void)applicationWillResignActive:(NSNotification *)aNotification {
    NSLog(@"Application will resign active - Releasing remote controls");
    [remoteControl stopListening: self];
}

- (void) sendRemoteButtonEvent: (RemoteControlEventIdentifier) event pressedDown: (BOOL) pressedDown  remoteControl: (RemoteControl*) remoteControl 
{
	int currentSlide = [[[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] clickedSlideAtIndex];
	int currentSong = [[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] selectedRow];
	
	if (event == kRemoteButtonRight && pressedDown == 1) {
		[[[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] presentSlideAtIndex: currentSlide+1];
	} if (event == kRemoteButtonLeft && pressedDown == 1) {
		[[[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] presentSlideAtIndex: currentSlide-1];
	} if (event == kRemoteButtonMinus && pressedDown == 1) {
		[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] selectRow:currentSong+1 byExtendingSelection:NO];
	} if (event == kRemoteButtonPlus && pressedDown == 1) {
		[[[[NSDocumentController sharedDocumentController] currentDocument] playlistTable] selectRow:currentSong-1 byExtendingSelection:NO];
	}
	
    NSLog(@"Button %d pressed down %d", event, pressedDown);
}

- (void)runThumbnailSetup
{
	NSLog(@" ");
	NSLog(@"----------------------------");
	NSLog(@"THUMBNAIL SETUP AND CREATION");
	
	NSString *currentPath;
	unsigned index;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath: [[NSString stringWithString: @"~/Library/Application Support/ProWorship/Thumbnails/"] stringByExpandingTildeInPath]]) { [[NSFileManager defaultManager] removeItemAtPath:[[NSString stringWithString: @"~/Library/Application Support/ProWorship/Thumbnails/"] stringByExpandingTildeInPath] error: nil]; }
	
	if (![[NSFileManager defaultManager] fileExistsAtPath: [[NSString stringWithString: @"~/Library/Application Support/ProWorship/cache/"] stringByExpandingTildeInPath]]) { [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString stringWithString: @"~/Library/Application Support/ProWorship/cache/"] stringByExpandingTildeInPath] attributes: nil]; }
	if (![[NSFileManager defaultManager] fileExistsAtPath: [[NSString stringWithString: @"~/Library/Application Support/ProWorship/cache/Movies/"] stringByExpandingTildeInPath]]) { [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString stringWithString: @"~/Library/Application Support/ProWorship/cache/Movies/"] stringByExpandingTildeInPath] attributes: nil]; }
	if (![[NSFileManager defaultManager] fileExistsAtPath: [[NSString stringWithString: @"~/Library/Application Support/ProWorship/cache/Pictures/"] stringByExpandingTildeInPath]]) { [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString stringWithString: @"~/Library/Application Support/ProWorship/cache/Pictures/"] stringByExpandingTildeInPath] attributes: nil]; }	
	
	// Build all the thumbnails for movies in the users Movies directory
	NSMutableArray *moviesListing = [NSMutableArray arrayWithArray: [[NSFileManager defaultManager] directoryContentsAtPath:[[NSString stringWithString: @"~/Movies/ProWorship"] stringByExpandingTildeInPath]]];
	NSMutableArray *moviesPathListing = [NSMutableArray arrayWithCapacity: [moviesListing count]];
	
	NSLog(@"THUMBNAILS: Movie files");
	
	if ([moviesListing count] >= 1) {
		for (index = 0; index <= [moviesListing count]-1; index++) {
			currentPath = [NSString stringWithFormat: @"~/Movies/ProWorship/%@", [moviesListing objectAtIndex:index]];
			NSString *movieType = [[currentPath pathExtension] lowercaseString];
			
			if ([movieType isEqualToString: @"mov"] || [movieType isEqualToString: @"avi"] || [movieType isEqualToString: @"mpg"] || [movieType isEqualToString: @"mpeg"] || [movieType isEqualToString: @"mp4"] || [movieType isEqualToString: @"qtz"]) {
				if (![[NSFileManager defaultManager] fileExistsAtPath: [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/cache/Movies/%@.tiff", [[moviesListing objectAtIndex:index] stringByDeletingPathExtension]] stringByExpandingTildeInPath]]) {
					[[[NSImage imageWithPreviewOfFileAtPath:[currentPath stringByExpandingTildeInPath] ofSize:NSMakeSize(70, 70) asIcon:YES] TIFFRepresentation]
					 writeToFile: [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/cache/Movies/%@.tiff", [[moviesListing objectAtIndex:index] stringByDeletingPathExtension]] stringByExpandingTildeInPath] atomically:YES];
					[[[NSImage imageWithPreviewOfFileAtPath:[currentPath stringByExpandingTildeInPath] ofSize:NSMakeSize(288, 163) asIcon:NO] TIFFRepresentation]
					 writeToFile: [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/cache/%@-PREVIEW.tiff", [[moviesListing objectAtIndex:index] stringByDeletingPathExtension]] stringByExpandingTildeInPath] atomically:YES];
				}
				
				[moviesPathListing addObject: currentPath];
			}
		}
	}
	
	moviesMediaListing = [[NSArray arrayWithArray: moviesPathListing] retain];
	
	// Build all the thumbnails for pictures in the users Pictures directory
	NSMutableArray *picturesListing = [NSMutableArray arrayWithArray: [[NSFileManager defaultManager] directoryContentsAtPath:[[NSString stringWithString: @"~/Pictures/ProWorship"] stringByExpandingTildeInPath]]];
	NSMutableArray *picturesPathListing = [NSMutableArray arrayWithCapacity: [picturesListing count]];
	
	NSLog(@"THUMBNAILS: Picture files");
	
	if ([picturesListing count] >= 1) {
		for (index = 0; index <= [picturesListing count]-1; index++) {
			currentPath = [NSString stringWithFormat: @"~/Pictures/ProWorship/%@", [picturesListing objectAtIndex:index]];
			NSString *pictureType = [[currentPath pathExtension] lowercaseString];
			
			if ([pictureType isEqualToString: @"tiff"] || [pictureType isEqualToString: @"tif"] || [pictureType isEqualToString: @"jpg"] || [pictureType isEqualToString: @"jpeg"] || [pictureType isEqualToString: @"png"]) {
				if (![[NSFileManager defaultManager] fileExistsAtPath: [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/cache/Pictures/%@.tiff", [[picturesListing objectAtIndex:index] stringByDeletingPathExtension]] stringByExpandingTildeInPath]]) {
					[[[NSImage imageWithPreviewOfFileAtPath:[currentPath stringByExpandingTildeInPath] ofSize:NSMakeSize(70, 70) asIcon:YES] TIFFRepresentation]
					 writeToFile: [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/cache/Pictures/%@.tiff", [[picturesListing objectAtIndex:index] stringByDeletingPathExtension]] stringByExpandingTildeInPath] atomically:YES];
					[[[NSImage imageWithPreviewOfFileAtPath:[currentPath stringByExpandingTildeInPath] ofSize:NSMakeSize(288, 163) asIcon:NO] TIFFRepresentation]
					 writeToFile: [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/cache/%@-PREVIEW.tiff", [[picturesListing objectAtIndex:index] stringByDeletingPathExtension]] stringByExpandingTildeInPath] atomically:YES];
				}
				
				[picturesPathListing addObject: currentPath];
			}
		}
	}
	
	picturesMediaListing = [[NSArray arrayWithArray: picturesPathListing] retain];
	
	NSLog(@"----------------------------");
}


#pragma mark Network Node Methods
	
- (IBAction)toggleNetworkNodeSettings:(id)sender
{
	if ([networkNodeContent frame].origin.x != 501) {
		[[networkNodeContent animator] setFrameOrigin: NSMakePoint(501, 25)];
	} else {
		[[networkNodeContent animator] setFrameOrigin: NSMakePoint(660, 25)];
	}
}

- (IBAction)toggleNetworkNodeReceiver:(id)sender
{
	if ([[sender title] isEqualToString: @"Turn On Node"]) {
        [_receiver_listener open];
		
		connectedListener = [[BLIPConnection alloc] initToNetService: [_serviceList objectAtIndex:[networkNodeReceiverListener indexOfSelectedItem]]];
		[connectedListener open];
		
		
		[sender setTitle: @"Turn Off Node"];
	} else {
		[_receiver_listener close];
		
		[connectedListener close];
		
		[[self mainPresenterViewConnect] setPresentationText: @" "];
		
		[sender setTitle: @"Turn On Node"];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    if (![_serviceList containsObject:aNetService]) {
        [self willChangeValueForKey:@"serviceList"];
        [_serviceList addObject:aNetService];
        [self didChangeValueForKey:@"serviceList"];
    }
	
	if ([_serviceList count] >= 1) {
		[networkNodeReceiverToggle setEnabled: YES];
	} else {
		[networkNodeReceiverToggle setEnabled: NO];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    if ([_serviceList containsObject:aNetService]) {
        [self willChangeValueForKey:@"serviceList"];
        [_serviceList removeObject:aNetService];
        [self didChangeValueForKey:@"serviceList"];
    }
	
	if ([_serviceList count] >= 1) {
		[networkNodeReceiverToggle setEnabled: YES];
	} else {
		[networkNodeReceiverToggle setEnabled: NO];
	}
}

- (void)listener: (TCPListener*)listener didAcceptConnection: (TCPConnection*)connection
{
    connection.delegate = self;
}

- (void) connection: (BLIPConnection*)connection receivedRequest: (BLIPRequest*)request
{
    NSLog(@" ");
	NSLog(@"-----------------------------");
	NSLog(@"NETWORK NODE :: DATA RECEIVED");
	NSLog(@"NETWORK: Received connection from %@", connection.address.hostname);
	NSLog(@"NETWORK: Accepting connections from %@", connectedListener.address.ipv4name);
	
	if ([connection.address.hostname isEqualToString: connectedListener.address.ipv4name]) {
		NSLog(@"NETWORK: Connection **accepted**");
		[request respondWithData: [@"REVOLUTION: Connection **accepted**" dataUsingEncoding: NSUTF8StringEncoding] contentType: request.contentType];
		
		NSDictionary *presentationNodeDataReceived = [NSUnarchiver unarchiveObjectWithData: request.body];
		
		if (overrideFormatting == 0 && ![[self mainPresenterViewConnect] presenterSlideAlignment] == [[presentationNodeDataReceived objectForKey: @"Alignment"] intValue]) { [[self mainPresenterViewConnect] setAlignment: [[presentationNodeDataReceived objectForKey: @"Alignment"] intValue]]; }
		else if (![[self mainPresenterViewConnect] presenterSlideAlignment] == overrideFormatting-1) { [[self mainPresenterViewConnect] setAlignment: overrideFormatting-1]; }
		
		if (overrideLayout == 0 && ![[self mainPresenterViewConnect] presenterSlideLayout] == [[presentationNodeDataReceived objectForKey: @"Layout"] intValue]) { [[self mainPresenterViewConnect] setLayout: [[presentationNodeDataReceived objectForKey: @"Layout"] intValue]]; }
		else if (![[self mainPresenterViewConnect] presenterSlideLayout] == overrideLayout-1) { [[self mainPresenterViewConnect] setLayout: overrideLayout-1]; }
		
		if (![[self mainPresenterViewConnect] presentationFontSize] == [[presentationNodeDataReceived objectForKey: @"Size"] intValue]) { [[self mainPresenterViewConnect] setFontSize: [[presentationNodeDataReceived objectForKey: @"Size"] floatValue]]; }
		if (![[[self mainPresenterViewConnect] presentationFontFamily] isEqualToString: [presentationNodeDataReceived objectForKey: @"Font"]]) { [[self mainPresenterViewConnect] setFontFamily: [presentationNodeDataReceived objectForKey: @"Font"]]; }
		[[self mainPresenterViewConnect] setTransitionSpeed: [[presentationNodeDataReceived objectForKey: @"Transition"] floatValue]];
		[[self mainPresenterViewConnect] setPresentationText: [presentationNodeDataReceived objectForKey: @"Slide Text"]];
	} else {
		NSLog(@"NETWORK: Connection **denied**");
		[request respondWithData: [@"REVOLUTION: Connection **denied**" dataUsingEncoding: NSUTF8StringEncoding] contentType: request.contentType];
	}
	
	NSLog(@"-----------------------------");
}

- (IBAction)setNodeDrawsBackground:(id)sender
{
	if ([sender state]==NSOnState) {
		[videoPlaybackGLWindow setAlphaValue: 1.0];
		[videoPlaybackGLIncomingWindow setAlphaValue: 1.0];
		[dvdPlayerWindow setAlphaValue: 1.0];
	} else {
		[videoPlaybackGLWindow setAlphaValue: 0.0];
		[videoPlaybackGLIncomingWindow setAlphaValue: 0.0];
		[dvdPlayerWindow setAlphaValue: 0.0];
	}
}

- (IBAction)setNodeOverrideFormatting:(id)sender
{
	overrideFormatting = [sender selectedSegment];
	[[self mainPresenterViewConnect] setAlignment: [sender indexOfSelectedItem]-1];
}

- (IBAction)setNodeOverrideLayout:(id)sender
{
	overrideLayout = [sender selectedSegment];
	[[self mainPresenterViewConnect] setLayout: [sender indexOfSelectedItem]-1];
}

#pragma mark DVD Playback Controller

- (void)runDVDSetup
{
	// Intialize the DVD player
	NSLog(@" ");
	NSLog(@"-------------------------");
	NSLog(@"DVD PLAYER INITIALIZATION");
	OSStatus errInit = DVDInitialize();

	if (errInit != noErr)
		NSLog(@"DVD: Error %d", errInit);
	
	// Register for playback events
	DVDEventCode eventCodes[] = {
		kDVDEventDisplayMode, 
		kDVDEventError,
		kDVDEventPlayback, 
		kDVDEventPTT, 
		kDVDEventTitle, 
		kDVDEventTitleTime,
		kDVDEventVideoStandard, 
	};

	errInit = DVDRegisterEventCallBack(MyDVDEventHandler, eventCodes, sizeof(eventCodes)/sizeof(DVDEventCode), (UInt32)self, &mEventCallBackID);

	NSAssert1(!errInit, @"DVD: RegisterEventCallBack %d", errInit);
			
	// Connect the DVD player to the correct window
	OSStatus errWindow = DVDSetVideoWindowID([dvdPlayerWindow windowNumber]);
	
	if (errWindow != noErr)
		NSLog(@"DVD: SetVideoWindowID %d", errWindow);
		
	// Connect the DVD player to the correct monitor
	CGDirectDisplayID display = (CGDirectDisplayID)
	
    [[[[dvdPlayerWindow screen] deviceDescription] valueForKey:@"NSScreenNumber"] intValue];
	Boolean isSupported;

	OSStatus errDisplay = DVDSwitchToDisplay(display, &isSupported);
	
	if (errDisplay != noErr)
		NSLog(@"DVD: SwitchToDisplay %d", errDisplay);
		
	// Setup the DVD display bounds
	CGRect qdRect = CGRectMake(0, 0, [dvdPlayerWindow frame].size.width, [dvdPlayerWindow frame].size.height);
	OSStatus errBounds = DVDSetVideoCGBounds(&qdRect);
	
	if (errBounds != noErr)
		NSLog(@"DVD: SetVideoBounds %d", errBounds);
		
	if ([self searchMountedDVD] && [self hasMedia] == NO)
		return;
	
	NSLog(@"-------------------------");
}

- (void)deviceDidMount:(NSNotification *)notification 
{
	NSString *devicePath = [[notification userInfo] objectForKey:@"NSDevicePath"];
	NSLog(@"Device did mount: %@", devicePath);
	
	OSStatus isDVDPlaying;
	DVDGetState(&isDVDPlaying);
	
	// Make sure the DVD isn't currently playing
	if (isDVDPlaying != kDVDStatePlaying) {
		NSString *mediaPath = [devicePath stringByAppendingString:@"/VIDEO_TS"];
		[self openMedia:mediaPath isVolume:YES];
	}
}

/////////////////////////
// DVD Control Methods //
/////////////////////////

- (void)runDVDPlay
{
	[self presentationGoToBlack: nil];
	[dvdPlayerWindow setLevel:NSScreenSaverWindowLevel+4];
	
	OSStatus isDVDPlaying;
	DVDGetState(&isDVDPlaying);
	
	if (isDVDPlaying == kDVDStatePlaying) {
		DVDPause();
	} else {
		DVDPlay();
	}
}

- (void)runDVDStop
{
	// Hide the DVD playback window
	[dvdPlayerWindow setLevel:NSScreenSaverWindowLevel-1];
	
	OSStatus isDVDPlaying;
	DVDGetState(&isDVDPlaying);
	
	if (isDVDPlaying == kDVDStatePlaying) {
		DVDPause();
		[[[[[NSDocumentController sharedDocumentController] currentDocument] mediaBox] dvdPlayPauseButton] setImage: [NSImage imageNamed:@"DVDPlay"]];
		[[[[[NSDocumentController sharedDocumentController] currentDocument] mediaBox] dvdPlayPauseButton] setAlternateImage: [NSImage imageNamed:@"DVDPlay-P"]];
	}
}

- (void)runDVDScanForward
{
	DVDScan (kDVDScanRate4x, kDVDScanDirectionForward);
}

- (void)runDVDScanBackward
{
	DVDScan (kDVDScanRate4x, kDVDScanDirectionBackward);
}

- (void)runDVDJumpForward
{
	DVDNextChapter();
}

- (void)runDVDJumpBackward
{
	DVDPreviousChapter();
}

- (void)runDVDBackToMenu
{
	DVDGoToMenu(kDVDMenuRoot);
}


//

- (BOOL)searchMountedDVD
{
	BOOL foundDVD = NO;

	/* get an array of strings containing the full pathnames of all
	currently mounted removable media */
	NSArray *volumes = [[NSWorkspace sharedWorkspace] mountedRemovableMedia];

	int i, count = [volumes count];
	for (i = 0; i < count; i++)
	{
		/* get the next volume path, and append the standard name for the
		media folder on a DVD-Video volume */
		NSString *path = [[volumes objectAtIndex:i] stringByAppendingString:@"/VIDEO_TS"];

		foundDVD = [self openMedia:path isVolume:YES];

		if (foundDVD) {
			/* we just opened a DVD volume */
			break;
		}
	}

	return foundDVD;
}

- (BOOL)openMedia:(NSString *)inPath isVolume:(BOOL)isVolume
{
	FSRef fileRef;
	BOOL mediaIsOpen = NO;

	if ([self isValidMedia:inPath folder:&fileRef])
	{
		OSStatus result;

		if ([self hasMedia] == YES) {
			[self closeMedia];
		}

		result = DVDOpenMediaVolume (&fileRef);
		NSAssert1 (!result, @"DVDOpenMediaVolume returned %d", result);
		
		if (result == noErr) {
			NSLog(@"Step 5: Open Media");
			NSLog(@"Media Folder: %@", inPath);
			mediaIsOpen = YES;
			[self logMediaInfo];
		}

		if (result == kDVDErrordRegionCodeUninitialized) {
			/* The drive region code has not been initialized. Refer to the
			readme file for information on handling this situation. */
			//[self displayAlertWithMessage:@"noRegionCode" withInfo:@"noRegionCodeInfo"];
		}
	}

	return mediaIsOpen;
}

- (BOOL) isValidMedia:(NSString *)inPath folder:(FSRef *)fileRefP
{
	BOOL isDir;
	Boolean isValid = false;
	NSFileManager *manager = [NSFileManager defaultManager];
	if ([manager fileExistsAtPath:inPath isDirectory:&isDir] && isDir)
	{
		const char *cPath = [inPath cStringUsingEncoding:NSASCIIStringEncoding];
		// NSLog(@"checking %@", inPath);
		OSStatus result = FSPathMakeRef ((UInt8*)cPath, fileRefP, NULL);
		if (result == noErr) {
			DVDIsValidMediaRef (fileRefP, &isValid);
		}
	}

	return isValid;
}


- (void)logMediaInfo 
{
	if ([self hasMedia] == NO)
		return;

	/* retrieve and display the 64-bit media ID */

	DVDDiscID id;
	DVDGetMediaUniqueID (id);
	unsigned x1 = *(unsigned *)&id[0];
	unsigned x2 = *(unsigned *)&id[4];
	NSLog(@"Media ID: %#.8x%.8x", x1, x2);

	/* retrieve and display region code information */

	DVDRegionCode discRegions = kDVDRegionCodeUninitialized;
	DVDRegionCode driveRegion = kDVDRegionCodeUninitialized;
	SInt16 numChangesLeft = -1;
	DVDGetDiscRegionCode (&discRegions); 
	DVDGetDriveRegionCode (&driveRegion, &numChangesLeft);
	NSLog(@"Disc Regions: 0x%x", discRegions);
	NSLog(@"Drive Region: 0x%x", driveRegion);
	NSLog(@"Changes Left: %d", numChangesLeft);

	/* DVD Playback Services checks for a region match whenever you open
	media, so this code is redundant. The code is included here to show how
	it's done. */

	if ((~driveRegion & ~discRegions) != ~driveRegion) {
		NSLog(@"Warning: region code mismatch");
	}
} 

- (void)closeMedia 
{
	if ([self hasMedia] == NO)
		return;

	OSStatus result = DVDCloseMediaVolume();
	NSAssert1 (!result, @"DVDCloseMediaVolume returned %d", result);
}

- (BOOL)hasMedia 
{
	Boolean hasMedia = FALSE;
	
	OSStatus result = DVDHasMedia (&hasMedia);
	NSAssert1 (!result, @"DVDHasMedia returned %d", result);
	
	return hasMedia;
} 

/* This is our DVD event callback function. It's always called in a thread other
than the main thread. We need to handle the event in the main thread because we
may want to update the UI, which involves drawing. Therefore we pass the event
information to the handleDVDEvent method, which runs in the main thread and
actually does the work. Cocoa requires that we package the information inside an
object. */

void MyDVDEventHandler (
	DVDEventCode inEventCode, 
	UInt32 inEventData1, 
	UInt32 inEventData2, 
	UInt32 inRefCon
) 
{
	Controller *controller = (Controller *)inRefCon;

	/* decouple the event from the callback thread */
	DVDEvent *dvdEvent = [[DVDEvent alloc] initWithData:inEventCode 
		data1:inEventData1 
		data2:inEventData2];

	[controller performSelectorOnMainThread:@selector(handleDVDEvent:) 
		withObject:dvdEvent 
		waitUntilDone:FALSE];

	[dvdEvent release];
}

/* This method does the work of handling the DVD events that we registered to
receive in the beginSession method. */

- (void) handleDVDEvent:(DVDEvent *)event 
{
	[event retain];

	switch ([event eventCode]) {
		case kDVDEventTitleTime: {
			//[mTimeText setTimeElapsed: [event eventData1] 
			//	timeRemaining: ([event eventData2] - [event eventData1])];
			break;
		}
		case kDVDEventTitle: {
			//[mTitleText setIntValue:[event eventData1]];
			//[mVideoWindow setWindowSize:kVideoSizeCurrent];
			break;
		}
		case kDVDEventPTT: {
			//[mSceneText setIntValue:[event eventData1]];
			// NSLog(@"Scene changed to %d", [event eventData1]);
			break;
		}
		case kDVDEventError:
			//[self handleDVDError:[event eventData1]];
			break;

		case kDVDEventPlayback: {
			//mDVDState = [event eventData1];
			// NSLog(@"DVD state changed to %d", mDVDState);
			break;
		}
		case kDVDEventVideoStandard:
		case kDVDEventDisplayMode: {
			//[mVideoWindow setWindowSize:kVideoSizeCurrent];
			break;
		}
	}

	[event release];
}

#pragma mark Presentation Mode Switcher

- (void)applyPresentationMode:(int)mode
{
	if (mode == 0) { // BLACK
		[self presentationGoToBlack: nil];
		presenterShouldShowText = NO;
		presenterShouldShowVideo = NO;
	} else if (mode == 1) { // TEXT
		[self presentationVideoGoToBlack: nil];
		presenterShouldShowText = YES;
		presenterShouldShowVideo = NO;
	} else if (mode == 2) { // VIDEO
		[self presentationTextGoToBlack: nil];
		presenterShouldShowText = NO;
		presenterShouldShowVideo = YES;
	} else if (mode == 3) { // BOTH
		presenterShouldShowText = YES;
		presenterShouldShowVideo = YES;
	}
}

- (BOOL)presenterShouldShowText
{
	return presenterShouldShowText;
}

- (BOOL)presenterShouldShowVideo
{
	return presenterShouldShowVideo;
}

- (IBAction)switchToModeBlack:(id)sender
{
	[self applyPresentationMode: 0];
	[[[[NSDocumentController sharedDocumentController] currentDocument] presentationModeSwitcher] setSelectedSegment: 0];
}

- (IBAction)switchToModeText:(id)sender
{
	[self applyPresentationMode: 1];
	[[[[NSDocumentController sharedDocumentController] currentDocument] presentationModeSwitcher] setSelectedSegment: 1];
}

- (IBAction)switchToModeVideo:(id)sender
{
	[self applyPresentationMode: 2];
	[[[[NSDocumentController sharedDocumentController] currentDocument] presentationModeSwitcher] setSelectedSegment: 2];
}

- (IBAction)switchToModeBoth:(id)sender
{
	[self applyPresentationMode: 3];
	[[[[NSDocumentController sharedDocumentController] currentDocument] presentationModeSwitcher] setSelectedSegment: 3];
}

#pragma mark <#label#>

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
	[[[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] setClickedSlideAtIndex: -1];
	
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
	[[[[NSDocumentController sharedDocumentController] currentDocument] docSlideViewer] setClickedSlideAtIndex: -1];
}

//////////////////////////////////
// Background media controllers //
//////////////////////////////////

- (IBAction)juiceGoToBlack:(id)sender
{
	[self presentJuice: @""];
	[[[[NSDocumentController sharedDocumentController] currentDocument] thumbnailScroller] removeFocus: self];
	
	// Hide the DVD playback window
	[self runDVDStop];
}

- (void)presentJuice:(NSString *)path
{
	if (!presenterShouldShowVideo)
		return;
	
	[videoPlaybackGLWindow setLevel:NSScreenSaverWindowLevel+2];
	
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
		
		float transitionSpeedPhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Override Fade to Black Speed"] floatValue];
		if (transitionSpeedPhoto == 0) transitionSpeedPhoto = 1.0;
		
		[[self mainPresenterViewConnect] setPresentationPhotoBG:[NSImage imageNamed: nil] withSpeed:transitionSpeedPhoto];
		
		[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewImageArea] setHidden: YES];
		[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController] setFrameOrigin: NSMakePoint(1, -20)];
		[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController2] setFrameOrigin: NSMakePoint(1, -20)];
		
		crossFadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(crossFadeMedia:) userInfo:nil repeats:YES];
	} else {
		willGoToBlack = NO;
		
		NSMutableDictionary *qtMovieAttributes = [[NSMutableDictionary alloc] initWithCapacity: 2];
		[qtMovieAttributes setObject:path forKey:QTMovieFileNameAttribute];
		[qtMovieAttributes setObject:[NSNumber numberWithBool: looping] forKey:QTMovieLoopsAttribute];
		
		NSError	*error;
        
		QTMovie	*qtMovie = [QTMovie movieWithAttributes:qtMovieAttributes error:&error];
		
		isPhoto = NO;
		
		if ([qtMovie duration].timeValue <= 40) {
			isPhoto = YES;
			
			float transitionSpeedPhoto = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Video Transition Speed"] floatValue];
			if (transitionSpeedPhoto == 0) transitionSpeedPhoto = 1.0;
			
			NSImage *presentationPhotoBG = [[NSImage alloc] initWithContentsOfFile:path];
			
			[[self mainPresenterViewConnect] setPresentationPhotoBG:presentationPhotoBG withSpeed:transitionSpeedPhoto];
			
			[presentationPhotoBG release];
			
			return;
		}
		
		if(qtMovie) {
			NSArray *moviePathSplitter = [[NSArray alloc] initWithArray: [path componentsSeparatedByString:@"/"]];
			NSArray *movieNameSplitter = [[NSArray alloc] initWithArray: [[moviePathSplitter objectAtIndex:[moviePathSplitter count]-1] componentsSeparatedByString:@"."]];
			NSImage *moviePreviewImage = [[NSImage alloc] initWithContentsOfFile: [[NSString stringWithFormat: @"~/Library/Application Support/ProWorship/cache/%@-PREVIEW.tiff", [movieNameSplitter objectAtIndex: 0]] stringByExpandingTildeInPath]];
			
			[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewImageArea] setHidden: NO];
			[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewImageArea] setImage: moviePreviewImage];
			
			if (!isPhoto) {
				[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewImageArea] setFrame: NSMakeRect(1, 15, 288, 166)];
			}
			
			didComeFromBlack = NO;
			
			if (incomingOnTop) {
				if (!isPhoto) {
					[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController] setFrameOrigin: NSMakePoint(1, -1)];
					[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController2] setFrameOrigin: NSMakePoint(1, -20)];
				}
				
				[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController] setMovie: qtMovie];
				
				[videoPlaybackGLView setQTMovie: qtMovie];
				[videoPlaybackGLView togglePlay: self];
				
				if ([[[videoPlaybackGLIncomingView qtMovie] tracks] count] < 1)
					didComeFromBlack = YES;
				
				incomingOnTop = NO;
			} else {
				if (!isPhoto) {
					[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController2] setFrameOrigin: NSMakePoint(1, -1)];
					[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController] setFrameOrigin: NSMakePoint(1, -20)];
				}
				
				[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController2] setMovie: qtMovie];
				
				[videoPlaybackGLIncomingView setQTMovie: qtMovie];
				[videoPlaybackGLIncomingView togglePlay: self];
				
				if ([[[videoPlaybackGLView qtMovie] tracks] count] < 1)
					didComeFromBlack = YES;
				
				incomingOnTop = YES;
			}
			
			NSLog(@"didComeFromBlack %i", didComeFromBlack);
			
			if (isPhoto) {
				[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController] setFrameOrigin: NSMakePoint(1, -20)];
				[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewController2] setFrameOrigin: NSMakePoint(1, -20)];
				[[[[NSDocumentController sharedDocumentController] currentDocument] videoPreviewImageArea] setFrame: NSMakeRect(1, 0, 288, 181)];
			}
			
			crossFadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(crossFadeMedia:) userInfo:nil repeats:YES];
		}
		
		[goLiveButton setState: NSOffState];
	}
}

- (void)playPauseToggle {
	if (incomingOnTop) {
		[videoPlaybackGLIncomingView togglePlay: self];
	} else {
		[videoPlaybackGLView togglePlay: self];
	}
}

- (BOOL)isJuicePlaying {
	if (incomingOnTop) {
		return [videoPlaybackGLIncomingView playbackStatus];
	}
	
	return [videoPlaybackGLView playbackStatus];
}

- (void)crossFadeMedia:(NSTimer *)timer
{
	float transitionSpeedVideo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Video Transition Speed"] floatValue];
	
	if ((willGoToBlack || didComeFromBlack) && [[[NSUserDefaults standardUserDefaults] objectForKey:@"Override Fade to Black"] intValue] == 1)
		transitionSpeedVideo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Override Fade to Black Speed"] floatValue];
	
	if (transitionSpeedVideo == 0) transitionSpeedVideo = 1.0;
	
	if (incomingOnTop && mediaWindowAlpha > 0.0) {
		[videoPlaybackGLWindow setAlphaValue: mediaWindowAlpha -= (1/(transitionSpeedVideo*10))];
	} else if (!incomingOnTop && mediaWindowAlpha < 1.0) {
		[videoPlaybackGLWindow setAlphaValue: mediaWindowAlpha += (1/(transitionSpeedVideo*10))];
	} else {
		[timer invalidate];
		
		if (incomingOnTop) { [videoPlaybackGLView setQTMovie: [QTMovie movie]]; }
		else { [videoPlaybackGLIncomingView setQTMovie: [QTMovie movie]]; }
	}
}

- (IBAction)makeBackgroundLive:(id)sender
{
	if ([sender state]==NSOnState) {
		[qcPresentationBackground setValue:[NSNumber numberWithBool:YES] forInputKey:@"LiveEnable"];
		[videoPlaybackGLWindow setLevel:NSScreenSaverWindowLevel-1];
		[videoPlaybackGLIncomingWindow setLevel:NSScreenSaverWindowLevel-1];
	} else {
		[qcPresentationBackground setValue:[NSNumber numberWithBool:NO] forInputKey:@"LiveEnable"];
		[videoPlaybackGLWindow setLevel:NSScreenSaverWindowLevel+3];
		[videoPlaybackGLIncomingWindow setLevel:NSScreenSaverWindowLevel+2];
	}
}

- (IBAction)toggleLooping:(id)sender
{
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
	}
}

- (IBAction)toggleAudio:(id)sender
{
	if ([sender state] == NSOnState) {
		if (incomingOnTop)
			[[videoPlaybackGLIncomingView qtMovie] setAttribute:[NSNumber numberWithFloat: 0.0] forKey: QTMovieVolumeAttribute];
		else
			[[videoPlaybackGLView qtMovie] setAttribute:[NSNumber numberWithFloat: 0.0] forKey: QTMovieVolumeAttribute];
	} else {
		if (incomingOnTop)
			[[videoPlaybackGLIncomingView qtMovie] setAttribute:[NSNumber numberWithFloat: 1.0] forKey: QTMovieVolumeAttribute];
		else
			[[videoPlaybackGLView qtMovie] setAttribute:[NSNumber numberWithFloat: 1.0] forKey: QTMovieVolumeAttribute];
	}
}

//////////////////////////
// Registration methods //
//////////////////////////

- (IBAction)buyOnline:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://store.eSellerate.net/s.aspx?s=STR7426194760"]];
}

- (IBAction)runDemo:(id)sender
{
	[welcomeRegisterSheet orderOut: self];
    [NSApp endSheet:welcomeRegisterSheet];
}

- (IBAction)validateRegistration:(id)sender
{
	if (eWeb_ValidateSerialNumber([[registrationNumber stringValue] UTF8String], nil, nil, "10804")) {
		NSUserDefaults  *defaults = [NSUserDefaults standardUserDefaults];
		
		[defaults setObject:[registrationName stringValue] forKey:@"iWorshipRegistrationName"];
		[defaults setObject:[registrationNumber stringValue] forKey:@"iWorshipRegistration"];
		[self updateSN];
		
		[welcomeRegisterSheet orderOut: self];
		[NSApp endSheet:welcomeRegisterSheet];
		
		NSRunAlertPanel(@"Thank you for purchasing ProWorship!", @"We hope you enjoy your experience. Please contact us if we can be of assistance!", @"OK", nil, nil);
	} else {
		NSRunAlertPanel(@"Invalid Serial Number", @"Your serial number is invalid. Please try again.", @"OK", nil, nil);
	}
}

- (void)setRegistered:(BOOL)yn
{
	[[self mainPresenterViewConnect] setPresentationText: @" "];
    registered = yn;
}

- (BOOL)registered
{
    return registered;
}

- (void)updateSN
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// We set the application to unregistered while we perform the validation of the serial number.
    [self setRegistered:NO];
    
    ESDSerialNumber = [defaults objectForKey:@"iWorshipRegistration"];
        
    if(![ESDSerialNumber isEqualToString:@""]) {
		// EWS SDK Validate Serial Number Function
		if (eWeb_ValidateSerialNumber([ESDSerialNumber UTF8String], nil, nil, "10804")) {
			[self setRegistered:YES];
			
			[serialDisplay setStringValue: [defaults objectForKey:@"iWorshipRegistrationName"]];
			[serialDisplayS setStringValue: [ESDSerialNumber substringWithRange:NSMakeRange(11,24)]];
		}
    }    
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