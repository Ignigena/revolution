/* IWMediaBox */

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "MAAttachedWindow.h"

@interface IWMediaBox : NSView
{
	IBOutlet id videosTab;
	IBOutlet id photosTab;
	IBOutlet id dvdTab;
	IBOutlet id liveTab;
	IBOutlet id scriptureTab;
	
	IBOutlet id loopingButton;
	IBOutlet id audioButton;
	IBOutlet id assignToSlideButton;
	IBOutlet id goToBlackButton;
	
	IBOutlet id mediaThumbnailBrowser;
	IBOutlet id dvdPlaybackView;
	IBOutlet id livePlaybackView;
	IBOutlet id scriptureView;
	
	IBOutlet id dvdPlayPauseButton;
	IBOutlet id liveVideoToggleButton;
	
	IBOutlet id videoSpeedSlider;
	IBOutlet id videoSpeedArea;
	
	IBOutlet id searchPopupButton;
	IBOutlet id searchPopupView;
	IBOutlet id scriptureTranslation;
	IBOutlet id scriptureBook;
	IBOutlet id scriptureChapter;
	IBOutlet id scriptureVerses;
	IBOutlet id scripturePreviewView;
	MAAttachedWindow *searchPopup;
	
	QTCaptureSession *captureSession;
	QTCaptureDeviceInput *videoDeviceInput;
	IBOutlet id videoDeviceSelector;
	IBOutlet QTCaptureView *captureView;
	IBOutlet QTMovieView *moviePreview1;
	IBOutlet QTMovieView *moviePreview2;
	NSArray *videoDevices;
}

- (void)devicesDidChange:(NSNotification *)notification;
- (void)refreshVideoDevices;
- (NSArray *)videoDevices;
- (void)setSelectedVideoDevice:(QTCaptureDevice *)selectedVideoDevice;
- (QTCaptureDevice *)selectedVideoDevice;
- (NSString *)mediaFormatSummary;
- (QTCaptureDevice *)controllableDevice;
- (QTCaptureSession *)captureSession;

- (IBAction)setMediaTransitionSpeed:(id)sender;

- (IBAction)selectVideosTab:(id)sender;
- (IBAction)selectPhotosTab:(id)sender;
- (IBAction)selectDVDTab:(id)sender;
- (IBAction)selectLiveTab:(id)sender;
- (IBAction)selectScriptureTab:(id)sender;

- (IBAction)toggleLooping:(id)sender;
- (IBAction)toggleAudio:(id)sender;

- (IBAction)juiceGoToBlack:(id)sender;

- (IBAction)playDVDVideo:(id)sender;
- (IBAction)fastForwardDVDVideo:(id)sender;
- (IBAction)rewindDVDVideo:(id)sender;
- (IBAction)skipForwardDVDVideo:(id)sender;
- (IBAction)skipBackwardDVDVideo:(id)sender;
- (IBAction)returnToMenuDVDVideo:(id)sender;
- (IBAction)ejectMountedDVD:(id)sender;

- (IBAction)toggleLiveVideo:(id)sender;

- (IBAction)goToWebsite:(id)sender;
- (IBAction)toggleSearchPopup:(id)sender;
- (IBAction)lookupScripture:(id)sender;

@end
