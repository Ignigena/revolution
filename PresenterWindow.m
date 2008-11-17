#import "PresenterWindow.h"

@implementation PresenterWindow

typedef int CGSConnectionID;
typedef int CGSWindowID;
extern CGSConnectionID _CGSDefaultConnection();
extern OSStatus CGSGetWindowTags(const CGSConnectionID cid, const CGSWindowID wid, int *tags, int thirtyTwo);
extern OSStatus CGSSetWindowTags(const CGSConnectionID cid, const CGSWindowID wid, int *tags, int thirtyTwo);
extern OSStatus CGSClearWindowTags(const CGSConnectionID cid, const CGSWindowID wid, int *tags, int thirtyTwo);

- (void) setSticky:(BOOL)flag {
	CGSConnectionID cid;
	CGSWindowID wid;
 	
	wid = [self windowNumber];
	if (wid > 0) {
		cid = _CGSDefaultConnection();
		int tags[2] = { 0, 0 };
 	               
		if (!CGSGetWindowTags(cid, wid, tags, 32)) {
			tags[0] = flag ? (tags[0] | 0x00000800) : (tags[0] & ~0x00000800);
			CGSSetWindowTags(cid, wid, tags, 32);
		}
	}
}

@end
