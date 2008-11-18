/* IWSlideViewer */

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "Presenter.h"
#import "IWSlideEditor.h"
#import "IWSlideEditScroller.h"
#import "MediaThumbnailBrowser.h"

@interface IWSlideViewer : NSView
{
	IBOutlet id delegate;
	IBOutlet id presenterView;
	
	IBOutlet id songTitle;
	IBOutlet id songArtist;
	IBOutlet id songCopyright;
	IBOutlet id songPublisher;
	IBOutlet id songNumber;
	
	IBOutlet MediaThumbnailBrowser *mediaBrowser;
	
	IBOutlet id playlistTable;
	IBOutlet id libraryTable;
	IBOutlet id myScroller;
	
	IBOutlet id speedArea;
	IBOutlet id speedSlider;
	
	IBOutlet id editFlagField;

	NSSize gridSize;
	NSMutableArray *worshipSlides;
	NSMutableArray *slidesNotes;
	NSMutableArray *mediaReferences;
	
	int worshipSlideFontSize;
	
	float gridVertSpace;
	float gridHorzSpace;
	
	BOOL slideHit;
	BOOL mouseDown;
	BOOL goAheadAndDrag;
	BOOL iDidADrag;
	BOOL editorOn;
	BOOL drawQuickCue;
	BOOL createNewSlide;
	
	int editSlideAtIndex;
	int editPrevSlide;
	
	NSPoint mouseDownPoint;
	NSPoint mouseCurrentPoint;
	unsigned clickedIndex;
	unsigned drawDropperForIndex;
	
	unsigned columns;
	unsigned rows;
	
	unsigned clickedSlideAtIndex;
	
	NSWindow *presentationWindow;
	Presenter *mainPresenterView;
	
	NSImage *deleteWidget;
	
	NSImage *slideToolbarFlag;
	NSImage *slideToolbarMove;
	NSImage *slideToolbarCopy;
	
	// Images required for various states of slides
	NSImage *slideGradientActive;
	NSImage *slideGradientNormal;
	NSImage *slideGradientBlank;
	NSImage *slideEditorCorners;
	NSImage *slideGradientEditor;
	
	// Images required for slide bevel effect
	NSImage *slideSelectedCUL;
	NSImage *slideSelectedCUR;
	NSImage *slideSelectedCLL;
	NSImage *slideSelectedCLR;
	
	NSImage *slideSelectedST;
	NSImage *slideSelectedSB;
	NSImage *slideSelectedSL;
	NSImage *slideSelectedSR;
	
	// Images required for slide bevel effect
	NSImage *slideHighlightCUL;
	NSImage *slideHighlightCUR;
	NSImage *slideHighlightCLL;
	NSImage *slideHighlightCLR;
	
	NSImage *slideHighlightST;
	NSImage *slideHighlightSB;
	NSImage *slideHighlightSL;
	NSImage *slideHighlightSR;
	
	NSMutableParagraphStyle *worshipSlideTextPara;
	NSMutableDictionary *worshipSlideTextAttrs;
	NSMutableParagraphStyle *flagTextPara;
	NSMutableDictionary *flagTextAttrs;
	
	NSShadow *textShadow;
	
	NSMenu *flagMenu;
	
	IWSlideEditScroller *inslideTextScroller;
	IWSlideEditor *inslideTextEditor;
	NSWindow *scrollerOverlay;
	BOOL slideEditorCache;
	
	int alignmentValue;
	int layoutValue;
	float speedValue;
	NSString *fontFamily;
	float fontSizeValue;
	
	BOOL saveHit;
	BOOL performAutoScroll;
	
	IBOutlet id customFlagSheet;
	IBOutlet id customFlagText;
	
	NSRect screenArea;
	NSRect maskingRect;
	NSBezierPath *bgPath;
	
	NSImage *dragImage;
}

- (void)updateGrid;

- (void)setWorshipSlides:(NSArray *)aSlidesArray notesSlides:(NSArray *)aSlidesNotesArray mediaRefs:(NSArray *)aMediaRefsArray;

- (NSRect)gridRectForIndex:(unsigned)index;
- (NSRect)rectCenteredInRect:(NSRect)rect withSize:(NSSize)size;
- (unsigned)slideIndexForPoint:(NSPoint)point;
- (NSRange)slideIndexRangeForRect:(NSRect)rect;

- (NSMutableArray *) worshipSlides;
- (NSMutableArray *) slidesNotes;

- (void) setClickedSlideAtIndex:(unsigned)slideIndex;

- (BOOL)editorOn;
- (void)setEditor:(BOOL)editorState;

- (void)setFlag:(id)sender;

- (void)performAutoscroll:(NSPoint)curSlideBottomRightPoint;

- (void)presentSlideAtIndex:(unsigned)slideIndex;
- (void)deleteSlideAtIndex:(unsigned)slideIndex;

- (void)duplicateSlide:(unsigned)index;

- (void)saveAllSlidesForSong:(NSString *)slideFile;

- (void)setSlideAlignment:(int)alignment;
- (void)setSlideLayout:(int)layout;
- (void)setFontFamilySize:(float)fontSize;

- (NSImage *)generateSlideWithState:(int)state;

// Presentation support
- (IBAction)presentSlideNext:(id)sender;
- (IBAction)presentSlidePrevious:(id)sender;
- (Presenter *)mainPresenterViewCommunicate;

// Slide management support
- (IBAction)newSlide:(id)sender;
- (void)insertNewSlide:(NSString *)slideText slideFlag:(NSString *)slideFlag slideMedia:(NSString *)slideMedia slideIndex:(unsigned)index;
- (IBAction)editFlagWithText:(id)sender;
- (IBAction)assignMediaToSlide:(id)sender;
- (IBAction)applySkipSlide:(id)sender;

// Song management support
- (IBAction)setTransitionSpeed:(id)sender;
- (void)setFontFamily:(NSString *)font;


@end
