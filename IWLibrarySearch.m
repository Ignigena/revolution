#import "IWLibrarySearch.h"
#import "LibraryListing.h"

@implementation IWLibrarySearch

- (void)textDidChange:(NSNotification *)aNotification
{
	NSLog(@"SEARCHING");
	[[libraryListingView dataSource] loadReloadLibraryList];
	[libraryListingView reloadData];
	[super textDidChange:aNotification];
}

@end
