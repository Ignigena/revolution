#import "PresentationMediaHUD.h"
#import "MediaThumbnailBrowser.h"

@implementation PresentationMediaHUD

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{
    if (self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag]) {
        [self setBackgroundColor: [NSColor clearColor]];
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
        [self setMovableByWindowBackground:YES];
		[self setDelegate:self];
		[self setFloatingPanel: YES];
        forceDisplay = NO;
        [self setBackgroundColor:[self sizedHUDBackground]];
        
        [self addCloseWidget];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self];
		
        return self;
    }
    return nil;
}

- (void)awakeFromNib
{
    [self addCloseWidget];
}

- (void)windowDidResize:(NSNotification *)aNotification
{
    [self setBackgroundColor:[self sizedHUDBackground]];
    if (forceDisplay) {
        [self display];
    }
}

- (void)addCloseWidget
{
    NSButton *closeButton = [[NSButton alloc] initWithFrame:NSMakeRect(10.0, [self frame].size.height - 18.0, 13.0, 13.0)];
    
    [[self contentView] addSubview:closeButton];
    [closeButton setBezelStyle:NSRoundedBezelStyle];
    [closeButton setButtonType:NSMomentaryChangeButton];
    [closeButton setBordered:NO];
    [closeButton setImage:[NSImage imageNamed:@"HUDTitlebarClose"]];
    [closeButton setTitle:@""];
    [closeButton setImagePosition:NSImageBelow];
    [closeButton setTarget:self];
    [closeButton setFocusRingType:NSFocusRingTypeNone];
    [closeButton setAction:@selector(close)];
    [closeButton release];
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animationFlag
{
    forceDisplay = YES;
    [super setFrame:frameRect display:displayFlag animate:animationFlag];
    forceDisplay = NO;
}

- (NSColor *)sizedHUDBackground
{
    //float alpha = 1.0;
    float titlebarHeight = 22.0;
    NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];
    [bg lockFocus];
	
	[[NSImage imageNamed:@"MediaPresenterPanel"] drawInRect:NSMakeRect(0, 0, 300, 600) fromRect:NSMakeRect(0, 0, 300, 600) operation: NSCompositeSourceOver fraction: 1.0];
	[[NSImage imageNamed: @"MediaTabBG"] drawInRect:NSMakeRect(6,370,23,40) fromRect: NSMakeRect(0, 0, 10, 40) operation: NSCompositeSourceOver fraction: 1.0];
	[[NSImage imageNamed: @"MediaTabBG"] drawInRect:NSMakeRect(270,370,24,40) fromRect: NSMakeRect(0, 0, 10, 40) operation: NSCompositeSourceOver fraction: 1.0];
	
	NSRect previewBoard = NSMakeRect(6, [self frame].size.height - titlebarHeight - 178, 288, 178);
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:previewBoard];
	
	/*
	// Make background path
    NSRect bgRect = NSMakeRect(0, 0, [bg size].width, [bg size].height - titlebarHeight);
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    float radius = 8.0;
    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:radius];
    
    [bgPath lineToPoint:NSMakePoint(maxX, maxY)];
    [bgPath lineToPoint:NSMakePoint(minX, maxY)];
    
    // Top edge and top-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:radius];
    
    // Left edge and bottom-left curve
    [bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];
    
    // Composite background color into bg
    [[NSColor colorWithCalibratedWhite:0.05 alpha:alpha] set];
    [bgPath fill];
    
    // Make titlebar
    NSRect titlebarRect = NSMakeRect(0, [bg size].height - titlebarHeight, [bg size].width, titlebarHeight);
	
	[[NSImage imageNamed:@"HUDTitlebarL"] drawInRect:NSMakeRect(titlebarRect.origin.x, titlebarRect.origin.y, 11, 22) fromRect:NSMakeRect(0, 0, 11, 22) operation:NSCompositeSourceOver fraction:1.0];
	[[NSImage imageNamed:@"HUDTitlebarR"] drawInRect:NSMakeRect(titlebarRect.origin.x+titlebarRect.size.width-11, titlebarRect.origin.y, 11, 22) fromRect:NSMakeRect(0, 0, 11, 22) operation:NSCompositeSourceOver fraction:1.0];
	[[NSImage imageNamed:@"HUDTitlebar"] drawInRect:NSMakeRect(titlebarRect.origin.x+11, titlebarRect.origin.y, titlebarRect.size.width-22, 22) fromRect:NSMakeRect(0, 0, 22, 22) operation:NSCompositeSourceOver fraction:1.0];
	*/
	NSRect titlebarRect = NSMakeRect(0, [bg size].height - titlebarHeight, [bg size].width, titlebarHeight);
	
    // Title
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
		[paraStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
		[paraStyle setAlignment:NSCenterTextAlignment];
		[paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	NSShadow *textShadow = [NSShadow alloc];
		[textShadow setShadowOffset: NSMakeSize(0, -1)];
		[textShadow setShadowColor: [NSColor colorWithDeviceWhite:0.0 alpha:0.8]];
		[textShadow setShadowBlurRadius: 0.5];
	
    NSMutableDictionary *titleAttrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSFont systemFontOfSize:11], NSFontAttributeName,
        [NSColor whiteColor], NSForegroundColorAttributeName,
        [[paraStyle copy] autorelease], NSParagraphStyleAttributeName,
		textShadow, NSShadowAttributeName,
        nil];
    
    NSSize titleSize = [[self title] sizeWithAttributes:titleAttrs];
    // We vertically centre the title in the titlbar area, and we also horizontally 
    // inset the title by 19px, to allow for the 3px space from window's edge to close-widget, 
    // plus 13px for the close widget itself, plus another 3px space on the other side of 
    // the widget.
    NSRect titleRect = NSInsetRect(titlebarRect, 19.0, (titlebarRect.size.height - titleSize.height) / 2.0);
    [[self title] drawInRect:titleRect withAttributes:titleAttrs];
	
    [bg unlockFocus];
    
    return [NSColor colorWithPatternImage:[bg autorelease]];
}

- (void)setTitle:(NSString *)value {
    [super setTitle:value];
    [self windowDidResize:nil];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end
