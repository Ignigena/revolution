//
//  PreferencesController.m
//  Simple Preferences
//
//  Created by John Devor on 12/24/06.
//

#import "PreferencesController.h"

#define WINDOW_TITLE_HEIGHT 78

static NSString *GeneralToolbarItemIdentifier				= @"General";
static NSString *FormattingToolbarItemIdentifier			= @"Formatting";
static NSString *DisplayToolbarItemIdentifier				= @"Display";
static NSString *DotMacToolbarItemIdentifier				= @".Mac";
static NSString *CCLIToolbarItemIdentifier					= @"CCLI";

static PreferencesController *sharedPreferencesController = nil;

@implementation PreferencesController

+ (PreferencesController *)sharedPreferencesController
{
	if (!sharedPreferencesController) {
		sharedPreferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
	}
	return sharedPreferencesController;
}

- (void)awakeFromNib
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	id toolbar = [[[NSToolbar alloc] initWithIdentifier:@"preferences toolbar"] autorelease];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:NO];
	[toolbar setSizeMode:NSToolbarSizeModeDefault];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	[toolbar setDelegate:self];
	[toolbar setSelectedItemIdentifier:GeneralToolbarItemIdentifier];
	[[self window] setToolbar:toolbar];
	
	[self setActiveView:generalPreferenceView animate:NO];
	[[self window] setTitle:GeneralToolbarItemIdentifier];
	
	// General Tab
	if ([standardUserDefaults objectForKey:@"Line Breaks"]==nil) {
		[importSplitTextBy selectItemWithTitle: @"Line"];
	} else {
		[importSplitTextBy selectItemWithTitle: [standardUserDefaults objectForKey:@"Line Breaks"]];
	}
	
	// Formatting Tab
	[formattingFontFamily removeAllItems];
	
	NSMutableArray *fontFamilies = [[NSMutableArray alloc] initWithArray: [[NSFontManager sharedFontManager] availableFontFamilies]];
	[fontFamilies sortUsingSelector:@selector(compare:)];
	unsigned index;
	
	for (index = 0; index <= [fontFamilies count]-1; index++)
		[formattingFontFamily addItemWithTitle:[fontFamilies objectAtIndex: index]];
	
	if ([standardUserDefaults objectForKey:@"Font Family"]==nil) {
		[formattingFontFamily selectItemWithTitle: @"Lucida Grande"];
	} else {
		[formattingFontFamily selectItemWithTitle: [standardUserDefaults objectForKey:@"Font Family"]];
	}
	
	if ([standardUserDefaults objectForKey:@"Text Size"]!=nil)
		[formattingFontSize setStringValue: [standardUserDefaults objectForKey:@"Text Size"]];
	
	if ([standardUserDefaults objectForKey:@"Text Colour"]!=nil)
		[formattingFontColour setColor: [NSUnarchiver unarchiveObjectWithData:[standardUserDefaults objectForKey:@"Text Colour"]]];
		
	if ([standardUserDefaults objectForKey:@"Text Border Colour"]!=nil)
		[formattingFontBorderColour setColor: [NSUnarchiver unarchiveObjectWithData:[standardUserDefaults objectForKey:@"Text Border Colour"]]];
	
	float textStroke = [[standardUserDefaults objectForKey:@"Text Stroke"] floatValue];
	textStroke = 0 - textStroke;
	
	//if ([standardUserDefaults objectForKey:@"Text Knocks Out Stroke"]!=nil)
	//	[formattingTextKnockout setState: (BOOL)[NSUnarchiver unarchiveObjectWithData:[standardUserDefaults objectForKey:@"Text Knocks Out Stroke"]]];
	
	if ([standardUserDefaults objectForKey:@"Text Stroke"]!=nil)
		[formattingFontBorder setFloatValue: textStroke];
	
	[presenterPreviewView setFontFamily: [formattingFontFamily titleOfSelectedItem]];
	[presenterPreviewView setFontSize: [formattingFontSize intValue]];
	[presenterPreviewView setTextColour: [formattingFontColour color]];
	[presenterPreviewView setTextBorderColour: [formattingFontBorderColour color]];
	[presenterPreviewView setStrokeWeight: [formattingFontBorder intValue]];
	[presenterPreviewView setPresentationText: @"Sample Text"];
	
	// Display Tab
	
	if ([standardUserDefaults objectForKey:@"BoundsX"]!=nil)
		[boundsX setStringValue: [standardUserDefaults objectForKey:@"BoundsX"]];
	if ([standardUserDefaults objectForKey:@"BoundsY"]!=nil)
		[boundsY setStringValue: [standardUserDefaults objectForKey:@"BoundsY"]];
	if ([standardUserDefaults objectForKey:@"BoundsW"]!=nil)
		[boundsW setStringValue: [standardUserDefaults objectForKey:@"BoundsW"]];
	if ([standardUserDefaults objectForKey:@"BoundsH"]!=nil)
		[boundsH setStringValue: [standardUserDefaults objectForKey:@"BoundsH"]];
	
	// CCLI Tab
	
	if ([standardUserDefaults objectForKey:@"CCLI License"]!=nil)
		[ccliLicense setStringValue: [standardUserDefaults objectForKey:@"CCLI License"]];
	
	if ([[standardUserDefaults objectForKey:@"CCLI Display"] isEqualToString: @"Beginning of Song"]) {
		[ccliDisplay selectCellAtRow: 1 column: 0];
	} else if ([[standardUserDefaults objectForKey:@"CCLI Display"] isEqualToString: @"End of Song"]) {
		[ccliDisplay selectCellAtRow: 2 column: 0];
	} else if ([[standardUserDefaults objectForKey:@"CCLI Display"] isEqualToString: @"Beginning and End"]) {
		[ccliDisplay selectCellAtRow: 3 column: 0];
	} else if ([[standardUserDefaults objectForKey:@"CCLI Display"] isEqualToString: @"Every Slide"]) {
		[ccliDisplay selectCellAtRow: 4 column: 0];
	}
}

- (IBAction)showWindow:(id)sender 
{
	[[self window] center];
	[super showWindow:sender];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:
		GeneralToolbarItemIdentifier,
		FormattingToolbarItemIdentifier,
		DisplayToolbarItemIdentifier,
		CCLIToolbarItemIdentifier,
		nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar 
{
	return [NSArray arrayWithObjects:
		GeneralToolbarItemIdentifier,
		FormattingToolbarItemIdentifier,
		DisplayToolbarItemIdentifier,
		CCLIToolbarItemIdentifier,
		nil];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
		GeneralToolbarItemIdentifier,
		FormattingToolbarItemIdentifier,
		DisplayToolbarItemIdentifier,
		CCLIToolbarItemIdentifier,
		nil];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)willBeInserted 
{
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
	if ([identifier isEqualToString:GeneralToolbarItemIdentifier]) {
		[item setLabel:GeneralToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"GeneralPreferences"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else if ([identifier isEqualToString:FormattingToolbarItemIdentifier]) {
		[item setLabel:FormattingToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"FormattingPreferences"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else if ([identifier isEqualToString:DisplayToolbarItemIdentifier]) {
		[item setLabel:DisplayToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"DisplayPreferences"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else if ([identifier isEqualToString:CCLIToolbarItemIdentifier]) {
		[item setLabel:CCLIToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"CCLIPreferences"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	/*} else if ([identifier isEqualToString:DotMacToolbarItemIdentifier]) {
		[item setLabel:DotMacToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"DotMacPreferences"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];*/
	} else
		item = nil;
	return item; 
}

- (void)toggleActivePreferenceView:(id)sender
{
	NSView *view;
	
	if ([[sender itemIdentifier] isEqualToString:GeneralToolbarItemIdentifier])
		view = generalPreferenceView;
	else if ([[sender itemIdentifier] isEqualToString:FormattingToolbarItemIdentifier])
		view = personalPreferenceView;
	else if ([[sender itemIdentifier] isEqualToString:DisplayToolbarItemIdentifier])
		view = displayPreferenceView;
	else if ([[sender itemIdentifier] isEqualToString:CCLIToolbarItemIdentifier])
		view = ccliPreferenceView;
	else if ([[sender itemIdentifier] isEqualToString:DotMacToolbarItemIdentifier])
		view = networkPreferenceView;
	
	[self setActiveView:view animate:YES];
	[[self window] setTitle:[sender itemIdentifier]];
}

- (void)setActiveView:(NSView *)view animate:(BOOL)flag
{
	// set the new frame and animate the change
	NSRect windowFrame = [[self window] frame];
	windowFrame.size.height = [view frame].size.height + WINDOW_TITLE_HEIGHT;
	windowFrame.size.width = [view frame].size.width;
	windowFrame.origin.y = NSMaxY([[self window] frame]) - ([view frame].size.height + WINDOW_TITLE_HEIGHT);
	
	if ([[activeContentView subviews] count] != 0)
		[[[activeContentView subviews] objectAtIndex:0] removeFromSuperview];
	[[self window] setFrame:windowFrame display:YES animate:flag];
	
	[activeContentView setFrame:[view frame]];
	[activeContentView addSubview:view];
}

- (IBAction)setGeneralDefaults:(id)sender
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

	[standardUserDefaults setObject:[importSplitTextBy titleOfSelectedItem] forKey:@"Line Breaks"];
}

- (IBAction)setFormattingDefaults:(id)sender
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	[standardUserDefaults setObject:[formattingFontFamily titleOfSelectedItem] forKey:@"Font Family"];
	[presenterPreviewView setFontFamily: [formattingFontFamily titleOfSelectedItem]];
	[standardUserDefaults setObject:[formattingFontSize stringValue] forKey:@"Text Size"];
	[presenterPreviewView setFontSize: [formattingFontSize intValue]];
	[presenterPreviewView setTextColour: [formattingFontColour color]];
	[standardUserDefaults setObject:[NSArchiver archivedDataWithRootObject: [formattingFontColour color]] forKey:@"Text Colour"];
	[presenterPreviewView setTextBorderColour: [formattingFontBorderColour color]];
	[standardUserDefaults setObject:[NSArchiver archivedDataWithRootObject: [formattingFontBorderColour color]] forKey:@"Text Border Colour"];
	
	[presenterPreviewView setTextKnocksOutBorder: [formattingTextKnockout state]];
	[standardUserDefaults setObject:[NSArchiver archivedDataWithRootObject: [NSNumber numberWithInt:[formattingTextKnockout state]]] forKey:@"Text Knocks Out Stroke"];
	
	
	float textStroke = [formattingFontBorder floatValue];
	textStroke = 0 - textStroke;
	[presenterPreviewView setStrokeWeight: textStroke];
	[standardUserDefaults setObject:[NSString stringWithFormat: @"%f", textStroke] forKey:@"Text Stroke"];
	
	[standardUserDefaults synchronize];
}

- (IBAction)setBoundariesDefaults:(id)sender
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	[standardUserDefaults setObject:[boundsX stringValue] forKey:@"BoundsX"];
	[standardUserDefaults setObject:[boundsY stringValue] forKey:@"BoundsY"];
	[standardUserDefaults setObject:[boundsW stringValue] forKey:@"BoundsW"];
	[standardUserDefaults setObject:[boundsH stringValue] forKey:@"BoundsH"];
	
	[standardUserDefaults synchronize];
}

- (IBAction)setCCLIDefaults:(id)sender
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	[standardUserDefaults setObject:[[ccliDisplay selectedCell] title] forKey:@"CCLI Display"];
	[standardUserDefaults setObject:[ccliLicense stringValue] forKey:@"CCLI License"];
	
	[standardUserDefaults synchronize];
}

- (IBAction)setInternalCameraEnabledDefaults:(id)sender
{	
	NSAppleEventDescriptor* returnDescriptor = NULL;
	
	if (floor(NSAppKitVersionNumber) <= 824.0) {
		if ([[[sender selectedCell] title] isEqualToString: @"Enabled"]) {
			NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource: @"do shell script \"/bin/chmod a+r /System/Library/QuickTime/QuickTimeUSBVDCDigitizer.component/Contents/MacOS/QuickTimeUSBVDCDigitizer; /bin/chmod u+rx /System/Library/QuickTime/QuickTimeUSBVDCDigitizer.component/Contents/MacOS/QuickTimeUSBVDCDigitizer\" with administrator privileges"];
			returnDescriptor = [scriptObject executeAndReturnError: nil];
			[scriptObject release];
		} else {
			NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource: @"do shell script \"/bin/chmod a-rwx /System/Library/QuickTime/QuickTimeUSBVDCDigitizer.component/Contents/MacOS/QuickTimeUSBVDCDigitizer\" with administrator privileges"];
			returnDescriptor = [scriptObject executeAndReturnError: nil];
			[scriptObject release];
		}
	} else {
		if ([[[sender selectedCell] title] isEqualToString: @"Enabled"]) {
			NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource: @"do shell script \"/bin/chmod a+r /System/Library/QuickTime/QuickTimeUSBVDCDigitizer.component/Contents/MacOS/QuickTimeUSBVDCDigitizer /System/Library/PrivateFrameworks/CoreMediaIOServicesPrivate.framework/Versions/A/Resources/VDC.plugin/Contents/MacOS/VDC; /bin/chmod u+rx /System/Library/QuickTime/QuickTimeUSBVDCDigitizer.component/Contents/MacOS/QuickTimeUSBVDCDigitizer /System/Library/PrivateFrameworks/CoreMediaIOServicesPrivate.framework/Versions/A/Resources/VDC.plugin/Contents/MacOS/VDC\" with administrator privileges"];
			returnDescriptor = [scriptObject executeAndReturnError: nil];
			[scriptObject release];
		} else {
			NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource: @"do shell script \"/bin/chmod a-rwx /System/Library/QuickTime/QuickTimeUSBVDCDigitizer.component/Contents/MacOS/QuickTimeUSBVDCDigitizer /System/Library/PrivateFrameworks/CoreMediaIOServicesPrivate.framework/Versions/A/Resources/VDC.plugin/Contents/MacOS/VDC\" with administrator privileges"];
			returnDescriptor = [scriptObject executeAndReturnError: nil];
			[scriptObject release];
		}
	}
	
	if (returnDescriptor != NULL) {
        if (kAENullEvent != [returnDescriptor descriptorType]) {
			NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
			[standardUserDefaults setObject:[[sender selectedCell] title] forKey:@"InternalCameraEnable"];
			[standardUserDefaults synchronize];
	
			if ([[[sender selectedCell] title] isEqualToString: @"Enabled"]) {
				NSAlert *alert = [[NSAlert alloc] init];
				[alert addButtonWithTitle: @"OK"];
				[alert setMessageText: @"Built-in iSight Enabled"];
				[alert setInformativeText: @"You must restart any program currently running that you wish to use your iSight camera with (iChat, Photobooth, etc.)"];
				[alert setAlertStyle: NSInformationalAlertStyle];
				[alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo: nil];
				[alert release];
			} else {
				NSAlert *alert = [[NSAlert alloc] init];
				[alert addButtonWithTitle: @"OK"];
				[alert setMessageText: @"Built-in iSight Disabled"];
				[alert setInformativeText: @"You must restart ProWorship for the changes to take effect. Your iSight has been temporarily disabled and will not be accessable from iChat, Photobooth, etc until you enable it again."];
				[alert setAlertStyle: NSCriticalAlertStyle];
				[alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo: nil];
				[alert release];
			}
		}
	}
}


@end
