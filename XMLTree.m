#import "XMLTree.h"

@interface XMLTree (PrivateAPI)


@end // End Private API



@implementation XMLTree



+(XMLTree *)treeWithURL:(NSURL *)url
{
    return [[[XMLTree alloc] initWithURL:url] autorelease];
}   // end treeWithURL




+(XMLTree *)treeWithCFXMLTreeRef:(CFXMLTreeRef)ref
{
    return [[[XMLTree alloc] initWithCFXMLTreeRef:ref] autorelease];
}   // end treeWithCFXMLTreeRef


+(XMLTree *)treeWithData:(NSData *)data
{
    return [[[XMLTree alloc] initWithData:data] autorelease];
}   // end treeWithData




-(XMLTree *)init
{
    if( (self = [super init]) == nil )
        return nil;

    _tree = NULL;
    _node = NULL;

    return self;
}   // end init




-(XMLTree *)initWithCFXMLTreeRef:(CFXMLTreeRef)ref
{
    if( [self init] == nil )
        return nil;

    // Clean up?
    if( _tree != NULL )
        CFRelease( _tree );
    if( _node != NULL )
        CFRelease( _node );

    // Make sure ref is something
    if( ref ){
        _tree = ref;
        _node = CFXMLTreeGetNode( _tree );
        
        CFRetain( _tree );
        CFRetain( _node );
    }	// end if: valid ref
    else{
        [self release];
        self = nil;
    }	// end else: no good
    
    return self;
}	// end initWithCFXMLTreeRef:






-(XMLTree *)initWithURL:(NSURL *)url
{
    CFXMLTreeRef tree;

    if( !url )
        return nil;
    
    tree = CFXMLTreeCreateWithDataFromURL(
                                           kCFAllocatorDefault,
                                           (CFURLRef)url,
                                           kCFXMLParserSkipWhitespace, 
                                           NULL ); //CFIndex
    // Defer to the ...with tree... init
    XMLTree *new = [self initWithCFXMLTreeRef:tree];
    if( tree != NULL )		//because it is retained by us after creating it with
        CFRelease(tree); 	//CFXMLTreeCreateWithDataFromURL() and we're finished with it -TWB
    return new;

}   // end initWithURL



- (XMLTree *)initWithData:(NSData *)inData
{
    return [self initWithData:inData withResolvingURL:nil];
}	// end initWithData



- (XMLTree *)initWithData:(NSData *)inData withResolvingURL:(NSURL *)url
{

    CFXMLTreeRef tree;

    if( !inData )
        return nil;
    
    tree = CFXMLTreeCreateFromData(
                                   kCFAllocatorDefault,
                                    (CFDataRef)inData,
                                    (CFURLRef)url,
                                    kCFXMLParserSkipWhitespace,
                                    NULL);

    // Defer to the ...with tree... init
    XMLTree *new = [self initWithCFXMLTreeRef:tree];
    if( tree != NULL )		//because it is retained by us after creating it with
        CFRelease(tree); 	//CFXMLTreeCreateFromData() and we're finished with it - TWB
    return new;

}   // end initWithData:withResolvingURL:








-(void)dealloc
{
    //NSLog( @"dealloc %@", self );

    if( _tree != NULL )
        CFRelease( _tree );

    if( _node != NULL )
        CFRelease( _node );

    _tree = NULL;
    _node = NULL;
    [super dealloc]; //added TWB

}	// end dealloc





/* ********  A B O U T   P A R E N T  ******** */



-(XMLTree *)parent
{
    CFTreeRef  parent;
    XMLTree   *returnVal;
    
    if( _tree == NULL )
        return nil;

    parent    = CFTreeGetParent( _tree );
    returnVal = nil;

    if( parent ){
        CFRetain( parent );
        returnVal = [XMLTree treeWithCFXMLTreeRef:parent];
        CFRelease( parent );
        parent = NULL;
    }	// end if: got parent

    return returnVal;
}	// end parent





/* ********  A B O U T   C H I L D R E N  ******** */




-(id)xpath:(NSString *)xpath
{
    CFTypeRef resultRef;
    CFTypeID  resultID;
    id        result;
    
    NSLog(@"The path function is still being developed. It doesn't work yet. Sorry.");
    return nil;
    


    // Call C-code
    resultRef = XMLTreeXPath( (CFMutableStringRef)[xpath mutableCopy], _tree );

    // Not null?
    if( resultRef != NULL ){

        // What kind of object was returned?
        resultID  = CFGetTypeID( resultRef );

        // String?
        if( resultID == CFStringGetTypeID()  ){
    
            result = [NSString stringWithString:(NSString *)resultRef];
        }	// end if: string
    
        // Else, tree?
        else if( resultID == CFTreeGetTypeID() ){
    
            result = [XMLTree treeWithCFXMLTreeRef:(CFXMLTreeRef)resultRef];
        }	// end else: tree
    
        // Else error
        else{
            NSLog(@"Error. Expected tree or string. Contact developer (rob@iharder.net)");
        }	// end else

        // Release result ref (part of contract with XMLTreeXPath function)
        CFRelease( resultRef );
        
    }	// end if: not null

    return result;
}	// end xpath:








-(int)count
{
    if( _tree == NULL )
        return -1;
    
    return CFTreeGetChildCount( _tree );
}	// end count





-(XMLTree *)childAtIndex:(int)index
{
    CFXMLTreeRef child;
    
    if( _tree == NULL )
        return nil;

    if( index >= CFTreeGetChildCount( _tree ) )
        return nil;

    child = CFTreeGetChildAtIndex(_tree, index);
    // Don't need to retain or release child. I think.
    // In keeping with your policy on interpreting "No assumptions can be made about how long the reference is valid"
    // in the CF docs, we should retain then release it, but it works without, so let's not :) TWB
    
    return [XMLTree treeWithCFXMLTreeRef:child];    
}	// end childAtIndex:







-(XMLTree *)childNamed:(NSString *)name
{
    CFXMLTreeRef  childTree;
    CFXMLNodeRef  childNode;
    CFStringRef   childName;
    XMLTree      *returnVal;
    int           childCount;
    int           i;

    if( _tree == NULL )
        return nil;

    childCount = CFTreeGetChildCount( _tree );
    returnVal  = nil;
    
    for( i = 0; i < childCount; i++ ){
        
        childTree = CFTreeGetChildAtIndex(_tree, i );
        CFRetain( childTree );
        
        childNode = CFXMLTreeGetNode( childTree );
        CFRetain( childNode );
        
        childName = CFXMLNodeGetString( childNode );
        CFRetain( childName );

        //NSLog(@"checking child name: %@", childName );
        if( CFStringCompare( (CFStringRef)name, childName, NULL ) == kCFCompareEqualTo )
            returnVal = [XMLTree treeWithCFXMLTreeRef:childTree];

        CFRelease( childTree );
        CFRelease( childNode );
        CFRelease( childName );

        if( returnVal )
            break;
        
    }	// end for: each child

    return returnVal;
}	// end childNamed:





-(XMLTree *)childNamed:(NSString *)name
         withAttribute:(NSString *)attrName
               equalTo:(NSString *)attrVal
{
    CFXMLTreeRef  childTree;
    CFXMLNodeRef  childNode;
    CFStringRef   childName;
    CFStringRef   childAttrVal;
    CFXMLElementInfo eInfo;
    XMLTree      *returnVal;
    int           childCount;
    int           i;

    if( _tree == NULL )
        return nil;

    childCount = CFTreeGetChildCount( _tree );
    returnVal  = nil;

    for( i = 0; i < childCount; i++ ){

        childTree = CFTreeGetChildAtIndex(_tree, i );
        CFRetain( childTree );

        childNode = CFXMLTreeGetNode( childTree );
        CFRetain( childNode );

        childName = CFXMLNodeGetString( childNode );
        CFRetain( childName );

        // Name matches?
        if( CFStringCompare( (CFStringRef)name, childName, NULL ) == kCFCompareEqualTo ){

            // Has attributes?
            if( CFXMLNodeGetTypeCode( childNode ) == kCFXMLNodeTypeElement ){
                
                eInfo = *(CFXMLElementInfo *)CFXMLNodeGetInfoPtr(childNode);                
                childAttrVal = (CFStringRef)CFDictionaryGetValue(
                                                                 eInfo.attributes,
                                                                 attrName );
                CFRetain( childAttrVal );
                
                // Attribute matches
                if( CFStringCompare(
                                    (CFStringRef)attrVal,
                                    childAttrVal,
                                    NULL ) == kCFCompareEqualTo ){
                    
                    returnVal = [XMLTree treeWithCFXMLTreeRef:childTree];
                }	// end if: match

                CFRelease( childAttrVal );
                
            }	// end if: has attributes
        }	// end if: name matches

        CFRelease( childTree );
        CFRelease( childNode );
        CFRelease( childName );

        if( returnVal )
            break;

    }	// end for: each child

    return returnVal;
}	// end childNamed:








-(XMLTree *)descendentNamed:(NSString *)name
{
    CFXMLTreeRef       descTree;
    XMLTree           *returnVal;

    if( _tree == NULL )
        return nil;
    
    descTree = XMLTreeDescendentNamed( (CFStringRef)name, _tree );
    
    if( descTree == NULL )
        return nil;

    // descTree will have a +1 retain count that we
    // are responsible for releasing (see comments on that function).
    returnVal = [XMLTree treeWithCFXMLTreeRef:descTree];
    CFRelease( descTree );

    return returnVal;
}	// end descendentNamed:



/* ********  A B O U T   S E L F  ******** */




-(NSString *)name
{
    if( _node == NULL )
        return nil;

    return [NSString stringWithString:(NSString *)CFXMLNodeGetString(_node)];
}	// end name





/*!
  @discussion
   Returns the node type, as defined by Apple's XML parser.
   The values will be one of the following constants:
 <pre>
 enum CFXMLNodeTypeCode {
     kCFXMLNodeTypeDocument = 1,
     kCFXMLNodeTypeElement = 2,
     kCFXMLNodeTypeAttribute = 3,
     kCFXMLNodeTypeProcessingInstruction = 4,
     kCFXMLNodeTypeComment = 5,
     kCFXMLNodeTypeText = 6,
     kCFXMLNodeTypeCDATASection = 7,
     kCFXMLNodeTypeDocumentFragment = 8,
     kCFXMLNodeTypeEntity = 9,
     kCFXMLNodeTypeEntityReference = 10,
     kCFXMLNodeTypeDocumentType = 11,
     kCFXMLNodeTypeWhitespace = 12,
     kCFXMLNodeTypeNotation = 13,
     kCFXMLNodeTypeElementTypeDeclaration = 14,
     kCFXMLNodeTypeAttributeListDeclaration = 15
 };
 </pre>
 */
-(CFXMLNodeTypeCode)type
{
    return CFXMLNodeGetTypeCode(_node);
}	// end type



-(NSDictionary *)attributes
{
    CFXMLElementInfo eInfo;

    if( CFXMLNodeGetTypeCode( _node ) != kCFXMLNodeTypeElement )
        return nil;

    eInfo = *(CFXMLElementInfo *)CFXMLNodeGetInfoPtr(_node);

    return [[(NSDictionary *)eInfo.attributes retain] autorelease];
}	// end attributes







-(NSString *)attributeNamed:(NSString *)name
{
    if( _tree == NULL )
        return nil;

    return [[[[[self attributes] objectForKey:name] description] retain] autorelease];
}	// end attributeNamed:





-(NSString *)description
{
    NSMutableString *descr;
    
    descr = [NSMutableString string];

    //NSLog( @"Description for type %d", CFXMLNodeGetTypeCode(_node) );
    
    switch( CFXMLNodeGetTypeCode(_node) ){

        case kCFXMLNodeTypeDocument:
        case kCFXMLNodeTypeElement:
            XMLTreeDescription( (CFMutableStringRef)descr, _tree );
            break;
            
        case kCFXMLNodeTypeProcessingInstruction:
        case kCFXMLNodeTypeAttribute:
        case kCFXMLNodeTypeComment:
        case kCFXMLNodeTypeText:
        case kCFXMLNodeTypeCDATASection:
        case kCFXMLNodeTypeDocumentFragment:
        case kCFXMLNodeTypeEntity:
        case kCFXMLNodeTypeEntityReference:
        case kCFXMLNodeTypeDocumentType:
        case kCFXMLNodeTypeWhitespace:
        case kCFXMLNodeTypeNotation:
        case kCFXMLNodeTypeElementTypeDeclaration:
        case kCFXMLNodeTypeAttributeListDeclaration:
        default:
            [descr appendString:(NSString *)CFXMLNodeGetString(_node)];
    }	// end switch

    return descr;
}	// end description




-(NSString *)xml
{
    CFDataRef  xmlData;

    if( _tree == NULL )
        return nil;

    xmlData = CFXMLTreeCreateXMLData(
                                     kCFAllocatorDefault,
                                     _tree );
    if( xmlData == NULL )
        return nil;

    
    NSString *string = [[[NSString alloc] initWithData:(NSData *)xmlData
                                              encoding:NSASCIIStringEncoding] autorelease];
    if( xmlData != NULL )	//because it is retained by us after creating it with
        CFRelease(xmlData); 	//CFXMLTreeCreateXMLData() and we're finished with it - TWB
    return string;

}	// end xml




@end // End implementation





CFStringRef XMLTreeDescription( CFMutableStringRef descr, CFXMLTreeRef tree )
{
    CFXMLTreeRef childTree;
    CFXMLNodeRef childNode;
    int childCount;
    int i;

    childCount = CFTreeGetChildCount( tree );

    for( i = 0; i < childCount; i++ ){

        childTree = CFTreeGetChildAtIndex( tree, i );
        CFRetain( childTree );
        
        childNode = CFXMLTreeGetNode( childTree );
        CFRetain( childNode );

        switch( CFXMLNodeGetTypeCode( childNode ) ){

            case kCFXMLNodeTypeText:
                CFStringAppend( descr, CFXMLNodeGetString( childNode ) );
                break;

            case kCFXMLNodeTypeElement:
                XMLTreeDescription( descr, childTree );
                break;

            default:
                break;
        }	// end switch: node type

        CFRelease( childTree );
        CFRelease( childNode );
    }	// end for

    return descr;
}	// end XMLTreeDescription



CFXMLTreeRef XMLTreeDescendentNamed( CFStringRef name, CFXMLTreeRef tree )
{
    CFXMLTreeRef childTree;
    CFXMLTreeRef descTree;
    CFXMLNodeRef childNode;
    CFStringRef  childName;
    CFXMLTreeRef returnVal;
    int childCount;
    int i;
    
    childCount = CFTreeGetChildCount( tree );
    returnVal  = NULL;
    descTree   = NULL;

    for( i = 0; i < childCount; i++ ){

        childTree = CFTreeGetChildAtIndex( tree, i );
        CFRetain( childTree );
        
        childNode = CFXMLTreeGetNode( childTree );
        CFRetain( childNode );
        
        childName = CFXMLNodeGetString( childNode );
        CFRetain( childName );

        // Is this it?
        if( CFStringCompare( name, childName, NULL ) == kCFCompareEqualTo ){
            returnVal = childTree;
            CFRetain( returnVal );
        }	// end if: found it
        
        // Else if child is an element, search recursively
        else if( CFXMLNodeGetTypeCode( childNode ) == kCFXMLNodeTypeElement ){

            descTree = XMLTreeDescendentNamed( name, childTree );
                    
                // Got a match?
            if( descTree != NULL ){
                returnVal = descTree; // Alread +1 retain count
            }	// end if: got match
                        
        }	// end if: element node type
        CFRelease(childTree); //TWB
        CFRelease(childNode); //TWB
        CFRelease(childName); //TWB
        
    }	// end for
    
    return returnVal;
}	// end XMLTreeDescendentNamed:



CFTypeRef XMLTreeXPath( CFMutableStringRef xpath, CFXMLTreeRef tree )
{
    CFTypeRef returnRef;
    CFXMLNodeRef node;
    

    returnRef = NULL;
    node      = CFXMLTreeGetNode( tree );
    CFRetain( node );

    // Are "we" who we're looking for?
    if( xpath == NULL || CFStringGetLength( xpath ) == 0 ){
        
        returnRef = tree;
    }	// end if: looking for us
    
    // Attribute?
    else if( CFStringHasPrefix( xpath, (CFStringRef)@"@" ) ){

        // Must be an element node to make any sense
        if( CFXMLNodeGetTypeCode( node ) == kCFXMLNodeTypeElement ){

            CFXMLElementInfo eInfo;
            CFDictionaryRef  attr;

            // Retrieve attribute dictionary
            eInfo = *(CFXMLElementInfo *)CFXMLNodeGetInfoPtr(node);
            attr  = (CFDictionaryRef)eInfo.attributes;

            // Shave off '@' sign
            CFStringTrim( xpath, (CFStringRef)@"@" );

            returnRef = CFDictionaryGetValue( attr, xpath );
        }	// end if: element node
    }	// end if: attribute

    // Else, not looking at an attribute endpoint
    else{

        BOOL        searchDescendents = NO;
        CFStringRef firstWord = NULL;
        CFRange     nextSlash;
        CFRange     nextBracket;
        CFRange     nextAt;
        CFRange     firstDelimiter;

        // Descendent or child?
        searchDescendents = CFStringHasPrefix( xpath, (CFStringRef)@"//" );
        
        // Strip leading slashes
        CFStringTrim( xpath, (CFStringRef)@"/" );

        // Get location of next delimiters
        nextSlash   = CFStringFind( xpath, (CFStringRef)@"/", NULL );
        nextBracket = CFStringFind( xpath, (CFStringRef)@"[", NULL );
        nextAt      = CFStringFind( xpath, (CFStringRef)@"@", NULL );
        firstDelimiter = nextSlash;
        
        if( nextBracket.location < firstDelimiter.location )
            firstDelimiter = nextBracket;
        if( nextAt.location < firstDelimiter.location )
            firstDelimiter = nextAt;

        // Easiest case, slash or @ without a test
        if( firstDelimiter.location == nextSlash.location
            ||
            firstDelimiter.location == nextAt.location ){

            // Get first word (it's the node we need to retrieve
            firstWord = CFStringCreateWithSubstring( NULL,
                                                     xpath,
                                                     CFRangeMake(0,
                                                                 firstDelimiter.location) );
            
            // Strip word out of xpath
            CFStringDelete( xpath, CFRangeMake(0,firstDelimiter.location) );

            // Get child tree
            CFXMLTreeRef subTree =  XMLTreeDescendentNamed( firstWord, subTree );

            // Call recursively with the rest of the xpath
            returnRef = XMLTreeXPath( xpath, subTree );

            // Release sub tree in accordance with XMLTreeDescendentNamed(...) function.
            CFRelease( subTree );
        }	// end if: slash or @
        
        

    }	// end else: not attribute

    // Release stuff
    CFRelease( node ); //not retained any more - TWB

    return returnRef;
}	// end XMLTreeXPath






