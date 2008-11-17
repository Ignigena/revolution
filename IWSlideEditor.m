#import "IWSlideEditor.h"

@implementation IWSlideEditor

- (NSMenu *)menuForEvent:(NSEvent *)event {
	NSMenu *menu = [super menuForEvent:event];
	[menu addItem: [NSMenuItem separatorItem]];
	
	NSMenuItem *splitSlide = [menu addItemWithTitle:@"Split Slide at Cursor" action:nil keyEquivalent: @"\n"];
	[splitSlide setKeyEquivalentModifierMask: NSCommandKeyMask + NSShiftKeyMask];
	
	return menu;
}

@end
