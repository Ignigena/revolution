//
//  Playlist.h
//  Revolution
//
//  Created by Albert Martin on 10/13/13.
//
//

#import <Foundation/Foundation.h>

@interface Playlist : NSObject <NSCoding> {
@private
    NSString *playlistTitle;
    NSString *type;
}

@property (copy) NSString *playlistTitle;
@property (copy) NSString *type;

- (id)initWithTitle:(NSString *)title andType:(NSString *)t;

@end
