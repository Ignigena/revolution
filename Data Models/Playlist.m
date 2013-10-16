//
//  Playlist.m
//  Revolution
//
//  Created by Albert Martin on 10/13/13.
//
//

#import "Playlist.h"

@implementation Playlist

@synthesize playlistTitle, type;

- (id)init
{
    self = [super init];
    if (self) {
		playlistTitle = @"";
    }
    return self;
}

- (id)initWithTitle:(NSString *)title andType:(NSString *)t
{
    self = [super init];
    if (self) {
		playlistTitle = title;
        type = t;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
		playlistTitle = [aDecoder decodeObjectForKey:@"title"];
        type = [aDecoder decodeObjectForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:playlistTitle forKey:@"title"];
    [aCoder encodeObject:type forKey:@"type"];
}

@end
