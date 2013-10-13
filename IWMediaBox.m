#import "IWMediaBox.h"
#import "Controller.h"
#import "MediaThumbnailBrowser.h"
#import "XMLTree.h"

@implementation IWMediaBox

- (void)awakeFromNib
{
	[videoSpeedArea setStringValue: [NSString stringWithFormat:@"%.1fs", [[[NSUserDefaults standardUserDefaults] objectForKey:@"Video Transition Speed"] floatValue]]];
	[videoSpeedSlider setFloatValue: [[[NSUserDefaults standardUserDefaults] objectForKey:@"Video Transition Speed"] floatValue]];

    [self selectMediaTab:videosTab];
}

- (IBAction)setMediaTransitionSpeed:(id)sender
{
	float actualTransitionSpeed;
	
	if ([videoSpeedSlider floatValue] <= 0.5) { actualTransitionSpeed = 0.0; }
	else if ([videoSpeedSlider floatValue] <= 1.0) { actualTransitionSpeed = 0.5; }
	else if ([videoSpeedSlider floatValue] <= 1.5) { actualTransitionSpeed = 1.0; }
	else if ([videoSpeedSlider floatValue] <= 2.0) { actualTransitionSpeed = 1.5; }
	else if ([videoSpeedSlider floatValue] <= 2.5) { actualTransitionSpeed = 2.0; }
	else if ([videoSpeedSlider floatValue] <= 3.0) { actualTransitionSpeed = 2.5; }
	else if ([videoSpeedSlider floatValue] <= 3.5) { actualTransitionSpeed = 3.0; }
	else if ([videoSpeedSlider floatValue] <= 4.0) { actualTransitionSpeed = 3.5; }
	else if ([videoSpeedSlider floatValue] <= 4.5) { actualTransitionSpeed = 4.0; }
	else if ([videoSpeedSlider floatValue] <= 5.0) { actualTransitionSpeed = 4.5; }
	else { actualTransitionSpeed = 5.0; }
	
	[videoSpeedArea setStringValue: [NSString stringWithFormat: @"%.1fs", actualTransitionSpeed]];
	
	[[NSUserDefaults standardUserDefaults] setObject:[videoSpeedArea stringValue] forKey:@"Video Transition Speed"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:rect];
	
	[[NSColor colorWithDeviceWhite:0.31 alpha:1.0] set];
	[NSBezierPath fillRect:NSMakeRect(320, 0, [self bounds].size.width-320, [self bounds].size.height)];
	
	// Turn anti-aliasing off to draw 1px lines for shadow
	[[NSGraphicsContext currentContext] setShouldAntialias: NO];
	
	[[NSColor colorWithDeviceWhite:0.21 alpha:1.0] set];
	NSBezierPath *shadowLeft1 = [NSBezierPath bezierPath];
	[shadowLeft1 moveToPoint:NSMakePoint(320, 0)];
	[shadowLeft1 lineToPoint:NSMakePoint(320, [self bounds].size.height)];
	[shadowLeft1 setLineWidth:0.5];
	[shadowLeft1 stroke];
	[[NSColor colorWithDeviceWhite:0.28 alpha:1.0] set];
	NSBezierPath *shadowLeft2 = [NSBezierPath bezierPath];
	[shadowLeft2 moveToPoint:NSMakePoint(321, 0)];
	[shadowLeft2 lineToPoint:NSMakePoint(321, [self bounds].size.height)];
	[shadowLeft2 setLineWidth:0.5];
	[shadowLeft2 stroke];
	
	// Turn anti-aliasing back on for the rest of the drawing
	[[NSGraphicsContext currentContext] setShouldAntialias: YES];
	
	NSGradient *background = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.24 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.15 alpha:1.0]];
	[background drawInRect:NSMakeRect(321, 0, [self bounds].size.width-320, 26) angle:-90.0f];
	
	//NSImage *transitionSpeedBar = [NSImage imageNamed:@"TransitionSpeedBar"];
	//[transitionSpeedBar setFlipped: NO];
	//[transitionSpeedBar drawInRect: NSMakeRect([self bounds].size.width-144-160-13,3,144,20) fromRect: NSMakeRect(0,0,144,20) operation: NSCompositeSourceOver fraction: 1.0];
	
	[[NSColor colorWithDeviceWhite:0.11 alpha:1.0] set];
	
	// Turn anti-aliasing off to draw 1px lines for shadow
	[[NSGraphicsContext currentContext] setShouldAntialias: NO];
	
	NSBezierPath *bottomBorder = [NSBezierPath bezierPath];
	[bottomBorder moveToPoint:NSMakePoint(320, 26)];
	[bottomBorder lineToPoint:NSMakePoint(rect.size.width, 26)];
	[bottomBorder setLineWidth:0.5];
	[bottomBorder stroke];
	
	// Turn anti-aliasing back on for the rest of the drawing
	[[NSGraphicsContext currentContext] setShouldAntialias: YES];
}

///////////////////////////////////////////////////////////////
// Tab switching (wouldn't it be easier to do an NSTabView?) //
///////////////////////////////////////////////////////////////

- (IBAction)selectMediaTab:(id)sender
{
    NSString *clickedTab = [(NSButton *)sender identifier];
    NSArray *parentView = [self subviews];
    for (NSView *view in parentView) {
        if ([view isKindOfClass:[NSButton class]]) {
            [[view identifier] isEqualToString:clickedTab] ? [(NSButton *)view setState: NSOnState] : [(NSButton *)view setState: NSOffState];
        }
    }

    if ([clickedTab isEqualToString:@"videos"] || [clickedTab isEqualToString:@"photos"]) {
        [mediaThumbnailBrowser setMediaListing: [clickedTab isEqualToString:@"videos"] ? 0 : 1];
        [[mediaThumbnailBrowser enclosingScrollView] setHidden: NO];

        [loopingButton setHidden: [clickedTab isEqualToString:@"videos"] ? NO : YES];
        [audioButton setHidden: [clickedTab isEqualToString:@"videos"] ? NO : YES];
        [assignToSlideButton setHidden: NO];
        [goToBlackButton setHidden: NO];
    } else {
        [[mediaThumbnailBrowser enclosingScrollView] setHidden: YES];
        [loopingButton setHidden: YES];
        [audioButton setHidden: YES];
        [assignToSlideButton setHidden: YES];
        [goToBlackButton setHidden: YES];
    }

    if ([clickedTab isEqualToString:@"scripture"]) {
        if ([scriptureView superview]!=self)
            [self addSubview: scriptureView];
        [scriptureView setFrameOrigin: NSMakePoint(320,0)];
        [self toggleSearchPopup: nil];
    } else {
        if (searchPopup)
            [self toggleSearchPopup: nil];
        
        if ([scriptureView superview]==self)
            [scriptureView removeFromSuperview];
    }

    [self setNeedsDisplay: YES];
}

/////////////////////
// Global controls //
/////////////////////

- (IBAction)toggleLooping:(id)sender
{
	[[NSApp delegate] toggleLooping:sender];
}

- (IBAction)toggleAudio:(id)sender
{
	[[NSApp delegate] toggleAudio:sender];
}

- (IBAction)juiceGoToBlack:(id)sender
{
	[[NSApp delegate] juiceGoToBlack:sender];
}

////////////////////////
// Scripture Controls //
////////////////////////

- (IBAction)goToWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://www.iscripture.org/"]];
}

- (IBAction)toggleSearchPopup:(id)sender
{
	if (!searchPopup) {
		NSPoint searchPopupPoint = [self convertPointToBase: NSMakePoint(NSMidX([searchPopupButton frame])+323, NSMidY([searchPopupButton frame])-2)];
		
		searchPopup = [[MAAttachedWindow alloc] initWithView: searchPopupView
														 attachedToPoint: searchPopupPoint
																inWindow: [searchPopupButton window] 
																  onSide: 10 
															  atDistance: 3.0f];
		
		[searchPopup setBackgroundColor: [NSColor colorWithDeviceWhite:0.0 alpha:0.85]];
		[searchPopup setBorderWidth: 0.0f];
		[searchPopup setCornerRadius: 7.0f];
		[searchPopup setArrowBaseWidth: 15.0f];
		[searchPopup setArrowHeight: 10.0f];
		
		[[searchPopupButton window] addChildWindow:searchPopup ordered:NSWindowAbove];
	} else {
		[[searchPopupButton window] removeChildWindow:searchPopup];
		[searchPopup orderOut:self];
		searchPopup = nil;
	}
}

- (IBAction)lookupScripture:(id)sender
{
	NSLog(@" ");
	NSLog(@"------------------------------------------");
	NSLog(@"SCRIPTURE LOOKUP POWERED BY ISCRIPTURE.ORG");
	
	unsigned i;
	
	NSURL *scriptureLookupURL = [NSURL URLWithString:[[NSString stringWithFormat:@"http://iscripture.org/api/search.php?s=%@+%@:%@&v=%@&t=passage", [scriptureBook titleOfSelectedItem], [scriptureChapter stringValue], [scriptureVerses stringValue], [scriptureTranslation titleOfSelectedItem]] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
	XMLTree *scriptureLookupXML = [[XMLTree alloc] initWithURL:scriptureLookupURL];
	//NSXMLDocument *scriptureLookupXMLdoc = [[[NSXMLDocument alloc] initWithContentsOfURL:scriptureLookupURL options:NSXMLDocumentTidyXML error:nil] retain];
	
	if ([[NSString stringWithFormat: @"%@", [scriptureLookupXML descendentNamed:@"found"]] isEqualToString: @"true"]) {
		[self toggleSearchPopup: nil];
		
		NSString *scripturePreviewText = @"{\\rtf1\\ansi\\ansicpg1252\\cocoartf949\\cocoasubrtf420{\\fonttbl\\f0\\fswiss\\fcharset0 Helvetica;}{\\colortbl;\\red229\\green229\\blue229;}\\vieww9000\\viewh8400\\viewkind0 \\pard\\tx560\\tx1120\\tx1680\\tx2240\\tx2800\\tx3360\\tx3920\\tx4480\\tx5040\\tx5600\\tx6160\\tx6720\\qj\\pardirnatural \\f0 \\cf1";
		
		NSLog(@"ISCRIPTURE.ORG: Match found!");
		NSLog(@"ISCRIPTURE.ORG: %i matching verses.", [[scriptureLookupXML descendentNamed:@"query"] count]-2);
		
		for (i = 2; i <= [[scriptureLookupXML descendentNamed:@"query"] count]-1; i++)
			scripturePreviewText = [scripturePreviewText stringByAppendingString: [[NSString stringWithFormat: @"\\fs16 \\super %@\\fs24 \\nosupersub %@ ", [[[scriptureLookupXML descendentNamed:@"query"] childAtIndex: i] descendentNamed:@"verse"], [[[scriptureLookupXML descendentNamed:@"query"] childAtIndex: i] descendentNamed:@"text"]] stringByReplacingOccurrencesOfString:@"quot;" withString:@"\""]];
		
		scripturePreviewText = [scripturePreviewText stringByAppendingString: [NSString stringWithFormat: @"\\\n\\pard\\tx720\\tx1440\\tx2160\\tx2880\\tx3600\\tx4320\\tx5040\\tx5760\\tx6480\\tx7200\\tx7920\\tx8640\\sl312\\slmult1\\pardirnatural \\fs26 \\cf1 \\'97 %@ %@", [scriptureBook titleOfSelectedItem], [scriptureChapter stringValue]]];
		
		if (![[scriptureVerses stringValue] isEqualToString: @""])
			scripturePreviewText = [scripturePreviewText stringByAppendingString: [NSString stringWithFormat: @":%@", [scriptureVerses stringValue]]];
		
		scripturePreviewText = [scripturePreviewText stringByAppendingString: @"}"];
		
		NSAttributedString *scripturePreviewTextRich = [[NSAttributedString alloc] initWithRTF:[scripturePreviewText dataUsingEncoding:NSASCIIStringEncoding] documentAttributes:nil];
		
		//[scripturePreviewTextRich stringByReplacingOccurrencesOfString:@"quot;" withString:@"\""];
		
		[scripturePreviewView setString: @""];
		[scripturePreviewView insertText: scripturePreviewTextRich];
		[scripturePreviewView setTextContainerInset: NSMakeSize(10.0,10.0)];
		
		[[[scripturePreviewView enclosingScrollView] contentView] scrollToPoint:NSMakePoint(0,0)];
		[[scripturePreviewView enclosingScrollView] reflectScrolledClipView: [[scripturePreviewView enclosingScrollView] contentView]];
	} else {
		NSLog(@"ISCRIPTURE.ORG: No results found");
	}
	
	NSLog(@"------------------------------------------");
}

@end
