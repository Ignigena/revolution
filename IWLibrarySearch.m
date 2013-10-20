#import "IWLibrarySearch.h"

@implementation IWLibrarySearch

- (void)textDidChange:(NSNotification *)aNotification
{
	NSLog(@"SEARCHING");
	[libraryListingView reloadData];
	[super textDidChange:aNotification];
}

@end
