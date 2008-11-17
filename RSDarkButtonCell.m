#import "RSDarkButtonCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation RSDarkButtonCell


/*-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	CIFilter *filter = [CIFilter filterWithName:@"CIPointillize"];
	[filter setDefaults];
	[filter setValue:[NSNumber numberWithFloat:4.0] forKey:@"inputRadius"];
	
	[controlView setContentFilters:[NSArray arrayWithObject:filter]];
	
	[self drawTitle: [self attributedTitle] withFrame: cellFrame inView: [self controlView]];
}*/

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
	NSMutableAttributedString *newTitle = [title mutableCopy];
	
	[newTitle beginEditing];
	[newTitle addAttribute: NSForegroundColorAttributeName value: [NSColor whiteColor] range: NSMakeRange(0, [title length])];
	[newTitle endEditing];

	[super drawTitle:newTitle withFrame:frame inView: controlView];
	
	return frame;
}
	
@end
