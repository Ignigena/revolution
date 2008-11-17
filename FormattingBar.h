/* FormattingBar */

#import <Cocoa/Cocoa.h>
#import "IWSlideViewer.h"

@interface FormattingBar : NSView
{
	IBOutlet id alignmentLeftButton;
	IBOutlet id alignmentCentreButton;
	IBOutlet id alignmentRightButton;
	
	IBOutlet id layoutTopButton;
	IBOutlet id layoutCentreButton;
	IBOutlet id layoutBottomButton;
	
	IBOutlet id speedArea;
	IBOutlet id speedSlider;
	
	IBOutlet id fontSizeField;
	
	IBOutlet id slideViewer;
	
	int alignmentLeftButtonState;
	int alignmentCentreButtonState;
	int alignmentRightButtonState;
	
	int layoutTopButtonState;
	int layoutCentreButtonState;
	int layoutBottomButtonState;
	
	IBOutlet id formattingFontFamily;
}

- (IBAction)alignLeft:(id)sender;
- (IBAction)alignCentre:(id)sender;
- (IBAction)alignRight:(id)sender;

- (IBAction)placeTop:(id)sender;
- (IBAction)placeCentre:(id)sender;
- (IBAction)placeBottom:(id)sender;

- (void)fontFamily:(NSString *)font;
- (IBAction)setFontFamily:(id)sender;

- (IBAction)fontSize:(id)sender;
- (void)setFormatFontSize:(float)size;

- (IBAction)transitionSpeed:(float)speed;

@end
