#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <QTKit/QTKit.h>
#import "Presenter.h"
#import "PresenterWindow.h"

@class eSellerateObject;

@interface Controller : NSObject
{	
	IBOutlet NSWindow *splasher;
	
	NSNetServiceBrowser *_serviceBrowser;
    NSMutableArray *_serviceList;
	IBOutlet id networkNodeContent;
	IBOutlet id networkNodeServices;
	IBOutlet id networkNodeReceiverToggle;
	IBOutlet id networkNodeReceiverListener;
	
	Presenter *mainPresenterView;
	NSWindow *presentationWindow;
	NSWindow *presentationBGWindow;
	NSWindow *videoPlaybackGLWindow;
	NSWindow *videoPlaybackGLIncomingWindow;
	
	BOOL willGoToBlack;
	BOOL incomingOnTop;
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
	
}

@property (readonly) NSMutableArray *serviceList;

- (IBAction)toggleNetworkNodeSettings:(id)sender;
- (IBAction)toggleNetworkNodeReceiver:(id)sender;

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

- (NSWindow *)splasher;

- (IBAction)openPreferences:(id)sender;

@end
