#import "FormattingBar.h"
#import "IWPopUpButton.h"
#import "IWSlideViewer.h"

@implementation FormattingBar

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		alignmentLeftButtonState = 0;
		alignmentCentreButtonState = 1;
		alignmentRightButtonState = 0;
		
		layoutTopButtonState = 0;
		layoutCentreButtonState = 1;
		layoutBottomButtonState = 0;
	}
	return self;
}

- (void)awakeFromNib
{
	NSLog(@"Setting up font listing");
		
		// Set up the font family selector
		[formattingFontFamily removeAllItems];
	
		NSMutableArray *fontFamilies = [[NSMutableArray alloc] initWithArray: [[NSFontManager sharedFontManager] availableFontFamilies]];
		[fontFamilies sortUsingSelector:@selector(compare:)];
		unsigned index;
	
		for (index = 0; index <= [fontFamilies count]-1; index++)
			[formattingFontFamily addItemWithTitle:[fontFamilies objectAtIndex: index]];
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Font Family"]) {
			[formattingFontFamily selectItemWithTitle: @"Lucida Grande"];
		} else {
			[formattingFontFamily selectItemWithTitle: [[NSUserDefaults standardUserDefaults] objectForKey:@"Font Family"]];
		}
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Text Size"]!=nil)
				[fontSizeField setStringValue: [NSString stringWithFormat:@"%.0f", [[[NSUserDefaults standardUserDefaults] objectForKey:@"Text Size"] floatValue]]];
			else
				[fontSizeField setStringValue: @"72"];
}

- (void)drawRect:(NSRect)rect
{
	NSGradient *formattingBackground = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.24 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.15 alpha:1.0]];
	[formattingBackground drawInRect:[self bounds] angle:-90.0f];

	[[NSGraphicsContext currentContext] setShouldAntialias: NO];
		
	[[NSColor colorWithCalibratedWhite: 0.08 alpha: 1.0] set];
	
	NSBezierPath *borderLeft = [NSBezierPath bezierPath];
	[borderLeft moveToPoint:NSMakePoint(0, 0)];
	[borderLeft lineToPoint:NSMakePoint(0, [self bounds].size.height)];
	[borderLeft setLineWidth:0.5];
	[borderLeft stroke];
	
	NSBezierPath *borderTop = [NSBezierPath bezierPath];
	[borderTop moveToPoint:NSMakePoint(0, [self bounds].size.height-1)];
	[borderTop lineToPoint:NSMakePoint(rect.size.width, [self bounds].size.height-1)];
	[borderTop setLineWidth:0.5];
	[borderTop stroke];
		
	[[NSGraphicsContext currentContext] setShouldAntialias: YES];
	
	NSImage *transitionSpeedBar = [NSImage imageNamed:@"TransitionSpeedBar"];
	[transitionSpeedBar setFlipped: NO];
	[transitionSpeedBar drawInRect: NSMakeRect([self bounds].size.width-144-13,4,144,20) fromRect: NSMakeRect(0,0,144,20) operation: NSCompositeSourceOver fraction: 1.0];
	
	NSImage *flagSlideTextBox = [NSImage imageNamed:@"FlagSlide"];
	[flagSlideTextBox setFlipped: NO];
	[flagSlideTextBox drawInRect: NSMakeRect([self bounds].size.width-367,4,200,20) fromRect: NSMakeRect(0,0,200,20) operation: NSCompositeSourceOver fraction: 1.0];
	
	NSImage *fontSizeTextBox = [NSImage imageNamed:@"FontSize"];
	[fontSizeTextBox setFlipped: NO];
	[fontSizeTextBox drawInRect: NSMakeRect(379,4,61,20) fromRect: NSMakeRect(0,0,61,20) operation: NSCompositeSourceOver fraction: 1.0];
	
	[alignmentLeftButton setState: alignmentLeftButtonState];
	[alignmentCentreButton setState: alignmentCentreButtonState];
	[alignmentRightButton setState: alignmentRightButtonState];
	
	[layoutTopButton setState: layoutTopButtonState];
	[layoutCentreButton setState: layoutCentreButtonState];
	[layoutBottomButton setState: layoutBottomButtonState];
	
	[formattingBackground release];
	[transitionSpeedBar release];
}

- (IBAction)alignLeft:(id)sender
{
	alignmentLeftButtonState = 1;
	alignmentCentreButtonState = 0;
	alignmentRightButtonState = 0;
	
	[slideViewer setSlideAlignment: 0];
	
	[self setNeedsDisplay: YES];
}

- (IBAction)alignCentre:(id)sender
{
	alignmentLeftButtonState = 0;
	alignmentCentreButtonState = 1;
	alignmentRightButtonState = 0;
	
	[slideViewer setSlideAlignment: 2];
	
	[self setNeedsDisplay: YES];
}

- (IBAction)alignRight:(id)sender
{
	alignmentLeftButtonState = 0;
	alignmentCentreButtonState = 0;
	alignmentRightButtonState = 1;
	
	[slideViewer setSlideAlignment: 1];
	
	[self setNeedsDisplay: YES];
}

- (IBAction)placeTop:(id)sender
{
	layoutTopButtonState = 1;
	layoutCentreButtonState = 0;
	layoutBottomButtonState = 0;
	
	[slideViewer setSlideLayout: 0];
	
	[self setNeedsDisplay: YES];
}

- (IBAction)placeCentre:(id)sender
{
	layoutTopButtonState = 0;
	layoutCentreButtonState = 1;
	layoutBottomButtonState = 0;
	
	[slideViewer setSlideLayout: 1];
	
	[self setNeedsDisplay: YES];
}

- (IBAction)placeBottom:(id)sender
{
	layoutTopButtonState = 0;
	layoutCentreButtonState = 0;
	layoutBottomButtonState = 1;
	
	[slideViewer setSlideLayout: 2];
	
	[self setNeedsDisplay: YES];
}

- (IBAction)transitionSpeed:(float)speed
{	
	[speedArea setStringValue: [NSString stringWithFormat:@"%.1fs", speed]];
	[speedSlider setFloatValue: speed];
	[slideViewer setTransitionSpeed: speed];
}

- (void)fontFamily:(NSString *)font
{
	if ([font isEqualToString: @"default"]) {
		if ([[NSUserDefaults standardUserDefaults] stringForKey:@"Font Family"]==nil) {
			[slideViewer setFontFamily: @"Lucida Grande"];
			[formattingFontFamily selectItemWithTitle: @"Lucida Grande"];
		} else {
			[slideViewer setFontFamily: [[NSUserDefaults standardUserDefaults] stringForKey:@"Font Family"]];
			[formattingFontFamily selectItemWithTitle: [[NSUserDefaults standardUserDefaults] stringForKey:@"Font Family"]];
		}
	} else {
		[slideViewer setFontFamily: font];
		[formattingFontFamily selectItemWithTitle: font];
	}
}

- (IBAction)fontSize:(id)sender
{
	NSLog(@"set font size from text field %f", [fontSizeField floatValue]);
	[slideViewer setFontFamilySize: [fontSizeField floatValue]];
}

- (void)setFormatFontSize:(float)size
{
	NSLog(@"programatically set font size %f", size);
	[fontSizeField setStringValue: [NSString stringWithFormat: @"%.0f", size]];
	[slideViewer setFontFamilySize: size];
}


- (IBAction)setFontFamily:(id)sender
{
	[self fontFamily:[sender titleOfSelectedItem]];
}

@end
