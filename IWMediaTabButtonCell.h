/* IWMediaTabButtonCell */

#import <Cocoa/Cocoa.h>

@interface IWMediaTabButtonCell :  NSButtonCell
{
	BOOL isActive;
}

- (void)setIsActive:(BOOL)active;

@end
