#import "IWMediaTabButtonCell.h"

@implementation IWMediaTabButtonCell

- (NSAttributedString *)attributedTitle {
	NSFont *smallFont = [NSFont systemFontOfSize: 12];

	NSMutableDictionary *attributes = [[NSDictionary dictionaryWithObjectsAndKeys:
		smallFont, NSFontAttributeName,
		[NSColor whiteColor] , NSForegroundColorAttributeName,
		nil] mutableCopy];

	NSMutableParagraphStyle *pStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		
	[pStyle setAlignment: [self alignment]];
	[attributes setValue: pStyle forKey: NSParagraphStyleAttributeName];
	[pStyle release];
	[attributes autorelease];
		
	return [[[NSAttributedString alloc] initWithString: [self title] attributes: attributes] autorelease];
}

- (void)drawInteriorWithFrame:(NSRect)rect inView:(NSView *)controlView {
	NSLog(@"%i", isActive);
	
	NSImage *backgroundImage;
	
	if (isActive == YES) {
		backgroundImage = [NSImage imageNamed: @"MediaTabBGActive"];
	} else {
		backgroundImage = [NSImage imageNamed: @"MediaTabBG"];
	}

	[backgroundImage setFlipped: YES];
	[backgroundImage drawInRect: rect fromRect: NSMakeRect(0, 0, 10, 40) operation: NSCompositeSourceOver fraction: 1.0];
	
	[[self attributedTitle] drawInRect: [self titleRectForBounds: rect]];
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
}

- (BOOL)isBordered
{
	return NO;
}

- (BOOL)isActive
{
	return isActive;
}

- (void)setIsActive:(BOOL)active
{
	NSLog(@"setIsActive");
	isActive = active;
}

@end
