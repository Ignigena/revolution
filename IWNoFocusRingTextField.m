#import "IWNoFocusRingTextField.h"

@implementation IWNoFocusRingTextField

- (void) awakeFromNib
{
	[self setFocusRingType: NSFocusRingTypeNone];
}

@end
