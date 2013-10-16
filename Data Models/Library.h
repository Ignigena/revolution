//
//  Library.h
//  
//
//  Created by Albert Martin on 10/16/13.
//
//

#import <Cocoa/Cocoa.h>

@interface Library : NSObject

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

@end

@interface LibraryItem : NSObject
{
    NSMutableArray *children;
}

@property (strong) LibraryItem *parent;
@property (strong) NSString *relativePath;

+ (LibraryItem *)rootItem;
- (NSInteger)numberOfChildren;
- (LibraryItem *)childAtIndex:(NSUInteger)n;
- (NSString *)fullPath;
- (NSString *)relativePath;

@end