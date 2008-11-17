#import "IWDarkSlider.h"
#import "DarkSlider.h"

@implementation IWDarkSlider

//- (void)awakeFromNib {
///	DarkSlider *darkSliderCell = [[DarkSlider alloc] init];
//	[darkSliderCell setControlSize:NSSmallControlSize];
//	[self setCell: darkSliderCell];
//	[darkSliderCell release];
//}

- (id)initWithCoder:(NSCoder *)decoder
{
	BOOL shouldUseSetClass = NO;
	BOOL shouldUseDecodeClassName = NO;
	if ([decoder respondsToSelector:@selector(setClass:forClassName:)]) {
		shouldUseSetClass = YES;
		[(NSKeyedUnarchiver *)decoder setClass:[DarkSlider class] forClassName:@"NSSliderCell"];
		
	} else if ([decoder respondsToSelector:@selector(decodeClassName:asClassName:)]) {
		shouldUseDecodeClassName = YES;
		[(NSUnarchiver *)decoder decodeClassName:@"NSSliderCell" asClassName:@"DarkSlider"];
	}

	self = [super initWithCoder:decoder];

	if (shouldUseSetClass) {
		[(NSKeyedUnarchiver *)decoder setClass:[NSSliderCell class] forClassName:@"NSSliderCell"];
	} else if (shouldUseDecodeClassName) {
		[(NSUnarchiver *)decoder decodeClassName:@"NSSliderCell" asClassName:@"NSSliderCell"];
	}
	
	return self;
}

@end
