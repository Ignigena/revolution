/* IWMediaBox */

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "MAAttachedWindow.h"

@interface IWMediaBox : NSView
{
	IBOutlet id videosTab;
	
	IBOutlet id loopingButton;
	IBOutlet id audioButton;
	IBOutlet id assignToSlideButton;
	IBOutlet id goToBlackButton;
	
	IBOutlet id mediaThumbnailBrowser;
	IBOutlet id scriptureView;
	
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

	IBOutlet QTMovieView *moviePreview1;
	IBOutlet QTMovieView *moviePreview2;
}

- (IBAction)setMediaTransitionSpeed:(id)sender;

- (IBAction)selectMediaTab:(NSButton *)sender;

- (IBAction)toggleLooping:(id)sender;
- (IBAction)toggleAudio:(id)sender;

- (IBAction)juiceGoToBlack:(id)sender;

- (IBAction)goToWebsite:(id)sender;
- (IBAction)toggleSearchPopup:(id)sender;
- (IBAction)lookupScripture:(id)sender;

@end
