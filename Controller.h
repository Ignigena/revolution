#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <QTKit/QTKit.h>
#import "Presenter.h"
#import <iLifeControls/NFIWindow.h>
#import "PresenterWindow.h"
#import "DVDPlayerWindow.h"
#import "IWVideoView.h"
#import "BLIPConnection.h"
#import "BLIP.h"
#import "RemoteControlContainer.h"
#import "AppleRemote.h"
#import "KeyspanFrontRowControl.h"

@class eSellerateObject;

@interface Controller : NSObject <TCPListenerDelegate, BLIPConnectionDelegate>
{	
	IBOutlet NSWindow *splasher;
	
	RemoteControlContainer* remoteControl;
	
	NSNetServiceBrowser *_serviceBrowser;
    NSMutableArray *_serviceList;
	BLIPListener *_receiver_listener;
	BLIPConnection *connectedListener;
	IBOutlet id networkNodeContent;
	IBOutlet id networkNodeServices;
	IBOutlet id networkNodeReceiverToggle;
	IBOutlet id networkNodeReceiverListener;
	int overrideFormatting;
	int overrideLayout;
	
	Presenter *mainPresenterView;
	NSWindow *presentationWindow;
	NSWindow *presentationBGWindow;
	IBOutlet IWVideoView *videoPlaybackGLView;
	NSWindow *videoPlaybackGLWindow;
	IBOutlet IWVideoView *videoPlaybackGLIncomingView;
	NSWindow *videoPlaybackGLIncomingWindow;
	DVDPlayerWindow *dvdPlayerWindow;
	IBOutlet NSButton *dvdPlayerPauseButton;
	
	BOOL didComeFromBlack;
	BOOL willGoToBlack;
	BOOL incomingOnTop;
	BOOL isPhoto;
	NSTimer *crossFadeTimer;
	float mediaWindowAlpha;
	
	UInt32 mEventCallBackID;
	
	NSArray *picturesMediaListing;
	NSArray *moviesMediaListing;
	
	QCView *qcPresentationBackground;
	QTMovie *masterMovie;
	IBOutlet id qcPreviewPresentation;
	double videoLength;
	double videoCurrentPosition;
	BOOL looping;
	BOOL killTimer;
	IBOutlet id goLiveButton;
	
	IBOutlet id welcomeRegisterSheet;
	IBOutlet id registrationName;
	IBOutlet id registrationNumber;
	IBOutlet id serialDisplay;
	IBOutlet id serialDisplayS;
	BOOL registered;
    NSString *ESDSerialNumber;
	
	IBOutlet id backgroundMediaMixer;
	
	BOOL presenterShouldShowText;
	BOOL presenterShouldShowVideo;
}

@property (readonly) NSMutableArray *serviceList;

- (IBAction)toggleNetworkNodeSettings:(id)sender;
- (IBAction)toggleNetworkNodeReceiver:(id)sender;
- (IBAction)setNodeDrawsBackground:(id)sender;
- (IBAction)setNodeOverrideFormatting:(id)sender;
- (IBAction)setNodeOverrideLayout:(id)sender;

- (void)runDVDSetup;
- (void)deviceDidMount:(NSNotification *)notification;
- (BOOL)searchMountedDVD;
- (BOOL)openMedia:(NSString *)media isVolume:(BOOL)isVolume;
- (BOOL)isValidMedia:(NSString *)inPath folder:(FSRef *)fileRefP;
- (void)logMediaInfo;
- (void)closeMedia;
- (BOOL)hasMedia;
- (void)runDVDPlay;
- (void)runDVDStop;
- (void)runDVDScanForward;
- (void)runDVDScanBackward;
- (void)runDVDJumpForward;
- (void)runDVDJumpBackward;
- (void)runDVDBackToMenu;

- (void)applyPresentationMode:(int)mode;
- (BOOL)presenterShouldShowText;
- (BOOL)presenterShouldShowVideo;
- (IBAction)switchToModeBlack:(id)sender;
- (IBAction)switchToModeText:(id)sender;
- (IBAction)switchToModeVideo:(id)sender;
- (IBAction)switchToModeBoth:(id)sender;

- (void)runThumbnailSetup;

- (IBAction)newPlaylist:(id)sender;
- (IBAction)loadRecent:(id)sender;

- (NSArray *)moviesMediaListing;
- (NSArray *)picturesMediaListing;

- (Presenter *)mainPresenterViewConnect;

- (IBAction)presentationGoToBlack:(id)sender;
- (IBAction)presentationVideoGoToBlack:(id)sender;
- (IBAction)presentationTextGoToBlack:(id)sender;

- (IBAction)juiceGoToBlack:(id)sender;
- (void)presentJuice:(NSString *)path;
- (void)playPauseToggle;
- (BOOL)isJuicePlaying;
- (IBAction)makeBackgroundLive:(id)sender;
- (IBAction)toggleLooping:(id)sender;
- (IBAction)toggleAudio:(id)sender;

- (void)crossFadeMedia:(NSTimer *)timer;

- (IBAction)buyOnline:(id)sender;
- (IBAction)runDemo:(id)sender;
- (IBAction)validateRegistration:(id)sender;

- (void)setRegistered:(BOOL)yn;
- (BOOL)registered;
- (void)updateSN;

- (NSWindow *)splasher;

- (IBAction)openPreferences:(id)sender;

@end
