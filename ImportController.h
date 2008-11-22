//
//  ImportController.h
//  _Revolution
//
//  Created by Albert Martin on 11/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ImportController : NSObject {

}

+ (void)importScriptureToDocumentFromURL:(NSURL *)url reference:(NSString *)ref split:(BOOL)split;
+ (void)importScriptureToSlideFromURL:(NSURL *)url reference:(NSString *)ref split:(BOOL)split;

@end
