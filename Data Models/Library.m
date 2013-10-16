//
//  Library.m
//  
//
//  Created by Albert Martin on 10/16/13.
//
//

#import "Library.h"

#define PlaylistDataType @"RevolutionPlaylist"

@implementation Library

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return (item == nil) ? [[LibraryItem rootItem] numberOfChildren] : [item numberOfChildren];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return (item == nil) ? ([[LibraryItem rootItem] numberOfChildren] != -1) : ([item numberOfChildren] != -1);
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    
    return (item == nil) ? [[LibraryItem rootItem] childAtIndex:index] : [(LibraryItem *)item childAtIndex:index];
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return (item == nil) ? [[LibraryItem rootItem] relativePath] : [item relativePath];
}

// Copies table row to pasteboard when it is determined a drag should begin
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
	// Make sure we can't drag an expandable item in the list
	if ([outlineView isExpandable:[outlineView itemAtRow:[outlineView rowForItem:items[0]]]])
		return NO;
	
    [pboard declareTypes:@[PlaylistDataType] owner:self];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:items] forType:PlaylistDataType];
    
    return YES;
}

@end

@implementation LibraryItem

static NSString *libraryPath = @"~/Library/Application Support/Revolution/";
static LibraryItem *rootItem = nil;
static NSMutableArray *leafNode = nil;

@synthesize parent, relativePath;

+ (void)initialize {
    if (self == [LibraryItem class]) {
        leafNode = [[NSMutableArray alloc] init];
    }
}

- (id)initWithPath:(NSString *)path parent:(LibraryItem *)parentItem {
    if (self = [super init]) {
        relativePath = [path copy];
        parent = parentItem;
    }
    return self;
}

+ (LibraryItem *)rootItem {
    if (rootItem == nil) {
        rootItem = [[LibraryItem alloc] initWithPath:[libraryPath stringByExpandingTildeInPath] parent:nil];
    }
    return rootItem;
}

- (NSArray *)children {
    if (children == nil) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fullPath = [self fullPath];
        BOOL isDir, valid;
        
        valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
        
        if (valid && isDir) {
            NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
            
            NSUInteger numChildren, i;
            
            numChildren = [array count];
            children = [[NSMutableArray alloc] initWithCapacity:numChildren];
            
            for (i = 0; i < numChildren; i++) {
                if (![[array objectAtIndex:i] isEqualToString:@".DS_Store"] && ![[array objectAtIndex:i] isEqualToString:@"Thumbnails"]) {
                    LibraryItem *newChild = [[LibraryItem alloc]
                                            initWithPath:[array objectAtIndex:i] parent:self];
                    [children addObject:newChild];
                }
            }
        }
        else {
            children = leafNode;
        }
    }
    return children;
}

- (NSString *)fullPath {
    if (parent == nil) {
        return relativePath;
    }
    return [[parent fullPath] stringByAppendingPathComponent:relativePath];
}

- (LibraryItem *)childAtIndex:(NSUInteger)n {
    return [[self children] objectAtIndex:n];
}

- (NSInteger)numberOfChildren {
    NSArray *tmp = [self children];
    return (tmp == leafNode) ? (-1) : [tmp count];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        parent = [aDecoder decodeObjectForKey:@"parent"];
		children = [aDecoder decodeObjectForKey:@"children"];
        relativePath = [aDecoder decodeObjectForKey:@"relativePath"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:parent forKey:@"parent"];
    [aCoder encodeObject:children forKey:@"children"];
    [aCoder encodeObject:relativePath forKey:@"relativePath"];
}

@end