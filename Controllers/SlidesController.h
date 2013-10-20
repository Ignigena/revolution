//
//  SlidesController.h
//  Revolution
//
//  Created by Albert Martin on 10/16/13.
//
//

#import "Playlist.h"
#import <Foundation/Foundation.h>

@interface SlidesController : NSObject

@property BOOL buttonsEnabled;
@property (copy) NSString *songTitle;
@property (copy) NSMutableDictionary *ccliDetails;
@property (copy) NSString *ccliDisplayLine;
@property (copy) NSMutableDictionary *defaultFormatting;

- (void)loadSongFromPlaylist:(Playlist *)song;

@end
