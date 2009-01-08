//
//  PreferencesController.h
//  Simple Preferences
//
//  Created by John Devor on 12/24/06.
//

#import <Cocoa/Cocoa.h>
#import "Presenter.h"


@interface PreferencesController : NSWindowController 
{
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *personalPreferenceView;
	IBOutlet NSView *updatePreferenceView;
	IBOutlet NSView *displayPreferenceView;
	IBOutlet NSView *ccliPreferenceView;
	IBOutlet NSView *networkPreferenceView;
	
	IBOutlet NSView *activeContentView;
	
	// General tab
	IBOutlet NSPopUpButton *importSplitTextBy;
	IBOutlet NSButton *overrideFadeBlack;
	IBOutlet NSTextField *overrideFadeBlackSpeed;
	
	// Formatting tab
	IBOutlet NSPopUpButton *formattingFontFamily;
	IBOutlet NSComboBox *formattingFontSize;
	IBOutlet NSColorWell *formattingFontColour;
	IBOutlet NSColorWell *formattingFontBorderColour;
	IBOutlet Presenter *presenterPreviewView;
	IBOutlet NSTextField *formattingFontBorder;
	IBOutlet NSButton *formattingTextKnockout;
	
	// CCLI tab
	IBOutlet id ccliDisplay;
	IBOutlet NSTextField *ccliLicense;
	
	IBOutlet NSTextField *boundsX;
	IBOutlet NSTextField *boundsY;
	IBOutlet NSTextField *boundsW;
	IBOutlet NSTextField *boundsH;
}

+ (PreferencesController *)sharedPreferencesController;

- (void)toggleActivePreferenceView:(id)sender;
- (void)setActiveView:(NSView *)view animate:(BOOL)flag;

- (IBAction)setGeneralDefaults:(id)sender;
- (IBAction)setFormattingDefaults:(id)sender;
- (IBAction)setBoundariesDefaults:(id)sender;
- (IBAction)setCCLIDefaults:(id)sender;

@end
