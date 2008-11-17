#import "ProScrollView.h"
#import "ProScroller.h"

@implementation ProScrollView

- (id) initWithCoder: (NSCoder *) decoder
{
   BOOL useSetClass = NO;
   BOOL useDecodeClassName = NO;
   
   if ([decoder respondsToSelector: @selector(setClass:forClassName:)]) {
       useSetClass = YES;
       [(NSKeyedUnarchiver *) decoder setClass: [ProScroller class] forClassName: @"NSScroller"];
   } else if ([decoder respondsToSelector: @selector(decodeClassName:asClassName:)]) {
       useDecodeClassName = YES;
       [(NSUnarchiver *) decoder decodeClassName: @"NSScroller" asClassName: @"ProScroller"];
   }

   self = [super initWithCoder: decoder];

   if ( useSetClass ) {
       [(NSKeyedUnarchiver *) decoder setClass: [NSScroller class] forClassName: @"NSScroller"];
   } else if ( useDecodeClassName ) {
       [(NSUnarchiver *) decoder decodeClassName: @"NSScroller" asClassName: @"NSScroller"];
   }
   
   return self;
}

@end
