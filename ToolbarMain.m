//
//  ToolbarMain.m
//  iWorship
//
//  Created by Albert Martin on 1/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ToolbarMain.h"
#import "Controller.h"

static void addToolbarItem(NSMutableDictionary *theDict,NSString *identifier,NSString *label,NSString *paletteLabel,NSString *toolTip,id target,SEL settingSelector, id itemContent,SEL action, NSMenu * menu)
{
    NSMenuItem *mItem;
    // here we create the NSToolbarItem and setup its attributes in line with the parameters
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
    [item setLabel:label];
    [item setPaletteLabel:paletteLabel];
    [item setToolTip:toolTip];
    [item setTarget:target];
    // the settingSelector parameter can either be @selector(setView:) or @selector(setImage:).  Pass in the right
    // one depending upon whether your NSToolbarItem will have a custom view or an image, respectively
    // (in the itemContent parameter).  Then this next line will do the right thing automatically.
    [item performSelector:settingSelector withObject:itemContent];
    [item setAction:action];
    // If this NSToolbarItem is supposed to have a menu "form representation" associated with it (for text-only mode),
    // we set it up here.  Actually, you have to hand an NSMenuItem (not a complete NSMenu) to the toolbar item,
    // so we create a dummy NSMenuItem that has our real menu as a submenu.
    if (menu!=NULL)
    {
	// we actually need an NSMenuItem here, so we construct one
	mItem=[[[NSMenuItem alloc] init] autorelease];
	[mItem setSubmenu: menu];
	[mItem setTitle: [menu title]];
	[item setMenuFormRepresentation:mItem];
    }
    // Now that we've setup all the settings for this new toolbar item, we add it to the dictionary.
    // The dictionary retains the toolbar item for us, which is why we could autorelease it when we created
    // it (above).
    [theDict setObject:item forKey:identifier];
}

static void addMetalToolbarItem(NSMutableDictionary *theDict,NSString *identifier,NSString *label,NSString *paletteLabel,NSString *toolTip,id target,SEL action, NSMenu * menu)
{
    NSMenuItem *mItem;
	
    // here we create the NSToolbarItem and setup its attributes in line with the parameters
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
	NSView *metalButtonView = [[[NSView alloc] initWithFrame:NSMakeRect(0,0,47,32)] autorelease];
	
	NSButton *metalButton = [[[NSButton alloc] initWithFrame:NSMakeRect(0,4,47,23)] autorelease];
	
	[metalButton setImage: [NSImage imageNamed: [NSString stringWithFormat: @"TB_%@", identifier]]];
	[metalButton setAlternateImage: [NSImage imageNamed: [NSString stringWithFormat: @"TB_%@-p", identifier]]];
	[metalButton setButtonType: NSMomentaryChangeButton];
	[metalButton setBordered: NO];
	[metalButton setTarget:target];
	[metalButton setAction:action];
	
	[metalButtonView addSubview:metalButton];
	
    [item setLabel:label];
    [item setPaletteLabel:paletteLabel];
    [item setToolTip:toolTip];
    // the settingSelector parameter can either be @selector(setView:) or @selector(setImage:).  Pass in the right
    // one depending upon whether your NSToolbarItem will have a custom view or an image, respectively
    // (in the itemContent parameter).  Then this next line will do the right thing automatically.
    [item setView: metalButtonView];
    // If this NSToolbarItem is supposed to have a menu "form representation" associated with it (for text-only mode),
    // we set it up here.  Actually, you have to hand an NSMenuItem (not a complete NSMenu) to the toolbar item,
    // so we create a dummy NSMenuItem that has our real menu as a submenu.
    if (menu!=NULL)
    {
	// we actually need an NSMenuItem here, so we construct one
	mItem=[[[NSMenuItem alloc] init] autorelease];
	[mItem setSubmenu: menu];
	[mItem setTitle: [menu title]];
	[item setMenuFormRepresentation:mItem];
    }
    // Now that we've setup all the settings for this new toolbar item, we add it to the dictionary.
    // The dictionary retains the toolbar item for us, which is why we could autorelease it when we created
    // it (above).
    [theDict setObject:item forKey:identifier];
}

@implementation ToolbarMain

-(void)awakeFromNib
{
    NSToolbar *toolbar=[[[NSToolbar alloc] initWithIdentifier:@"mainToolbar"] autorelease];
	
    // Here we create the dictionary to hold all of our "master" NSToolbarItems.
    toolbarItems=[[NSMutableDictionary dictionary] retain];
	
	// Create the registration placard
	NSView *placard = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 200, 32)];
	NSImageView* placardImage = [[[NSImageView alloc] initWithFrame:NSMakeRect(4, 1, 176, 29)] autorelease];
    [placardImage setImage:[NSImage imageNamed:@"RegistrationPlacard"]];
    [placardImage setEditable:NO];
    [placardImage setImageFrameStyle:NSImageFrameNone];
	[placard addSubview:placardImage];
	NSTextField* placardText = [[NSTextField alloc] initWithFrame: NSMakeRect(14, 9, 131, 16)];
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if ([standardUserDefaults objectForKey:@"iWorshipRegistrationName"]) {
		[placardText setStringValue: [standardUserDefaults objectForKey:@"iWorshipRegistrationName"]];
	} else {
		[placardText setStringValue: @"Pre-release Beta"];
	}
	[placardText setEditable: NO];
	[placardText setBezeled: NO];
	[placardText setDrawsBackground: NO];
	[[placardText cell] setLineBreakMode: NSLineBreakByTruncatingTail];
	[placard addSubview:placardText];
	
	// Create the viewing mode segmented control
	NSView *viewModeSegment = [[NSView alloc] initWithFrame: NSMakeRect(0,0,73,32)];
	NSButton *presentModeMetalButton = [[[NSButton alloc] initWithFrame:NSMakeRect(0,4,37,23)] autorelease];
	NSButton *editModeMetalButton = [[[NSButton alloc] initWithFrame:NSMakeRect(36,4,37,23)] autorelease];
	
	[presentModeMetalButton setImage: [NSImage imageNamed: @"TB_ModePresent-p"]];
	[presentModeMetalButton setAlternateImage: [NSImage imageNamed: @"TB_ModePresent"]];
	[presentModeMetalButton setButtonType: NSToggleButton];
	[presentModeMetalButton setBordered: NO];
	[presentModeMetalButton setTarget:self];
	[presentModeMetalButton setAction:@selector(newSlide:)];
	
	[editModeMetalButton setImage: [NSImage imageNamed: @"TB_ModeEdit"]];
	[editModeMetalButton setAlternateImage: [NSImage imageNamed: @"TB_ModeEdit-p"]];
	[editModeMetalButton setButtonType: NSToggleButton];
	[editModeMetalButton setBordered: NO];
	[editModeMetalButton setTarget:self];
	[editModeMetalButton setAction:@selector(toggleEditor:)];
	
	[viewModeSegment addSubview:editModeMetalButton];
	[viewModeSegment addSubview:presentModeMetalButton];
	
	// Create the add/remove segmented control
	NSView *addRemoveSegment = [[NSView alloc] initWithFrame: NSMakeRect(0,0,164,32)];
	NSButton *addMetalButton = [[[NSButton alloc] initWithFrame:NSMakeRect(0,4,56,23)] autorelease];
	NSButton *duplicateMetalButton = [[[NSButton alloc] initWithFrame:NSMakeRect(55,4,54,23)] autorelease];
	NSButton *removeMetalButton = [[[NSButton alloc] initWithFrame:NSMakeRect(108,4,56,23)] autorelease];
	
	[addMetalButton setImage: [NSImage imageNamed: @"TB_NewSlide"]];
	[addMetalButton setAlternateImage: [NSImage imageNamed: @"TB_NewSlide-p"]];
	[addMetalButton setButtonType: NSMomentaryChangeButton];
	[addMetalButton setBordered: NO];
	[addMetalButton setTarget:self];
	[addMetalButton setAction:@selector(newSlide:)];
	
	[duplicateMetalButton setImage: [NSImage imageNamed: @"TB_Duplicate"]];
	[duplicateMetalButton setAlternateImage: [NSImage imageNamed: @"TB_Duplicate-p"]];
	[duplicateMetalButton setButtonType: NSMomentaryChangeButton];
	[duplicateMetalButton setBordered: NO];
	[duplicateMetalButton setTarget:self];
	[duplicateMetalButton setAction:@selector(duplicateSlide:)];
	
	[removeMetalButton setImage: [NSImage imageNamed: @"TB_DeleteSlide"]];
	[removeMetalButton setAlternateImage: [NSImage imageNamed: @"TB_DeleteSlide-p"]];
	[removeMetalButton setButtonType: NSMomentaryChangeButton];
	[removeMetalButton setBordered: NO];
	[removeMetalButton setTarget:self];
	[removeMetalButton setAction:@selector(deleteSlide:)];
	
	[addRemoveSegment addSubview:addMetalButton];
	[addRemoveSegment addSubview:duplicateMetalButton];
	[addRemoveSegment addSubview:removeMetalButton];
	

	 // often using an image will be your standard case.  You'll notice that a selector is passed
    // for the action (blueText:), which will be called when the image-containing toolbar item is clicked.
	addToolbarItem(toolbarItems,@"CustomStretcher",@"",@"",@"",self,@selector(setView:),placard,nil,NULL);
	addToolbarItem(toolbarItems,@"ViewModeSegment",@"",@"",@"",self,@selector(setView:),viewModeSegment,nil,NULL);
	addToolbarItem(toolbarItems,@"AddRemoveSegment",@"",@"",@"",self,@selector(setView:),addRemoveSegment,nil,NULL);
    
	addMetalToolbarItem(toolbarItems,@"FlagSlide",@"Flag Slide",@"Flag Slide",@"Add a note flag to the selected slide",self,@selector(showFlagMenu:),NULL);
	addMetalToolbarItem(toolbarItems,@"MediaMixer",@"Media",@"Media",@"Show the media mixer panel",self,@selector(toggleMixer:),NULL);
	addMetalToolbarItem(toolbarItems,@"Print",@"Print",@"Print",@"Print slide outline",self,@selector(print:),NULL);
	
    // the toolbar wants to know who is going to handle processing of NSToolbarItems for it.  This controller will.
    [toolbar setDelegate:self];
    // If you pass NO here, you turn off the customization palette.  The palette is normally handled automatically
    // for you by NSWindow's -runToolbarCustomizationPalette: method; you'll notice that the "Customize Toolbar"
    // menu item is hooked up to that method in Interface Builder.  Interface Builder currently doesn't automatically 
    // show this action (or the -toggleToolbarShown: action) for First Responder/NSWindow (this is a bug), so you 
    // have to manually add those methods to the First Responder in Interface Builder (by hitting return on the First Responder and 
    // adding the new actions in the usual way) if you want to wire up menus to them.
    [toolbar setAllowsUserCustomization: YES];
    
    // tell the toolbar to show icons only by default
    [toolbar setDisplayMode: NSToolbarDisplayModeIconOnly];
	
    // install the toolbar.
   // [toolbarWindow setToolbar:toolbar];
}

// This method is required of NSToolbar delegates.  It takes an identifier, and returns the matching NSToolbarItem.
// It also takes a parameter telling whether this toolbar item is going into an actual toolbar, or whether it's
// going to be displayed in a customization palette.
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    // We create and autorelease a new NSToolbarItem, and then go through the process of setting up its
    // attributes from the master toolbar item matching that identifier in our dictionary of items.
    NSToolbarItem *newItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    NSToolbarItem *item=[toolbarItems objectForKey:itemIdentifier];
    
    [newItem setLabel:[item label]];
    [newItem setPaletteLabel:[item paletteLabel]];
    if ([item view]!=NULL)
    {
	[newItem setView:[item view]];
    }
    else
    {
	[newItem setImage:[item image]];
    }
    [newItem setToolTip:[item toolTip]];
    [newItem setTarget:[item target]];
    [newItem setAction:[item action]];
    [newItem setMenuFormRepresentation:[item menuFormRepresentation]];
    // If we have a custom view, we *have* to set the min/max size - otherwise, it'll default to 0,0 and the custom
    // view won't show up at all!  This doesn't affect toolbar items with images, however.
    if ([newItem view]!=NULL)
    {
	[newItem setMinSize:[[item view] bounds].size];
	[newItem setMaxSize:[[item view] bounds].size];
    }

    return newItem;
}

- (NSToolbarItem *)itemForItemIdentifier:(NSString *)itemIdentifier
{
	return [toolbarItems objectForKey:itemIdentifier];
}

// This method is required of NSToolbar delegates.  It returns an array holding identifiers for the default
// set of toolbar items.  It can also be called by the customization palette to display the default toolbar.    
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"CustomStretcher",@"ViewModeSegment",@"AddRemoveSegment",@"FlagSlide",NSToolbarFlexibleSpaceItemIdentifier,@"MediaMixer",@"Print",nil];
}

// This method is required of NSToolbar delegates.  It returns an array holding identifiers for all allowed
// toolbar items in this toolbar.  Any not listed here will not be available in the customization palette.
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"CustomStretcher",NSToolbarSpaceItemIdentifier,@"ViewModeSegment",@"AddRemoveSegment",@"FlagSlide",NSToolbarFlexibleSpaceItemIdentifier,@"MediaMixer",@"Print",nil];
}

// throw away our toolbar items dictionary
- (void) dealloc
{
    [toolbarItems release];
    [super dealloc];
}

-(IBAction) toggleEditor:(id)sender
{
	if (![slideViewer editorOn]) {
		[slideViewer setEditor: YES];
	} else {
		[slideViewer setEditor: NO];
	}
}

- (IBAction)newSlide:(id)sender
{
	[slideViewer insertNewSlide:@"" slideFlag:@"" slideIndex:nil];
}

- (IBAction)deleteSlide:(id)sender
{
	[slideViewer deleteSlideAtIndex:nil];
}

- (IBAction)duplicateSlide:(id)sender
{
	[slideViewer duplicateSlide:nil];
}

-(IBAction) toggleMixer:(id)sender
{
	if ([[[NSApp delegate] backgroundMediaMixer] isVisible]) {
		[[[NSApp delegate] backgroundMediaMixer] orderOut: self];
	} else {
		[[[NSApp delegate] backgroundMediaMixer] orderFront: self];
	}
}

- (IBAction)showFlagMenu:(id)sender
{
	NSMenu *flagMenu = [[NSMenu alloc] initWithTitle:@"Flag Choices"];
	[flagMenu addItemWithTitle:@"None" action:@selector(setFlag:) keyEquivalent:@""];
	[flagMenu addItem:[NSMenuItem separatorItem]];
	[flagMenu addItemWithTitle:@"Skip" action:@selector(setFlag:) keyEquivalent:@""];
	[flagMenu addItemWithTitle:@"Pause" action:@selector(setFlag:) keyEquivalent:@""];
	[flagMenu addItemWithTitle:@"Intro" action:@selector(setFlag:) keyEquivalent:@""];
	[flagMenu addItemWithTitle:@"Verse" action:@selector(setFlag:) keyEquivalent:@""];
	[flagMenu addItemWithTitle:@"Chorus" action:@selector(setFlag:) keyEquivalent:@""];
	[flagMenu addItemWithTitle:@"Solo" action:@selector(setFlag:) keyEquivalent:@""];
	[flagMenu addItemWithTitle:@"Bridge" action:@selector(setFlag:) keyEquivalent:@""];
	[flagMenu addItemWithTitle:@"Refrain" action:@selector(setFlag:) keyEquivalent:@""];
	[flagMenu addItem:[NSMenuItem separatorItem]];
	[flagMenu addItemWithTitle:@"Custom..." action:@selector(customFlag:) keyEquivalent:@""];
		
	[NSMenu popUpContextMenu:flagMenu withEvent:nil forView:sender];
}

-(IBAction) goFullscreen:(id)sender
{
	[fullScreenWindow makeKeyAndOrderFront: self];
}

@end
