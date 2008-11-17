//
//  IWSlideEditScroller.m
//  iWorship
//
//  Created by Albert Martin on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "IWSlideEditScroller.h"


@implementation IWSlideEditScroller

- (void)drawRect:(NSRect)rect {
	[[[self subviews] objectAtIndex: 0] setFrame: rect];
}

@end
